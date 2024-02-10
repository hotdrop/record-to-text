import 'dart:async';
import 'package:path/path.dart' as path;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realtime_talk/common/app_logger.dart';
import 'package:realtime_talk/providers/sound_files_provider.dart';
import 'package:realtime_talk/providers/timer_provider.dart';
import 'package:record/record.dart';

final recordProvider = NotifierProvider<RecordNotifier, AudioRecorder>(RecordNotifier.new);

class RecordNotifier extends Notifier<AudioRecorder> {
  Timer? _segmentTimer;
  int _elapsedTime = 0;

  @override
  AudioRecorder build() {
    ref.onDispose(() {
      state.dispose();
      _segmentTimer?.cancel();
    });
    return AudioRecorder();
  }

  Future<void> start() async {
    try {
      if (await state.hasPermission()) {
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        // 初回録音を実行し、以降は一定間隔で録音データを管理する
        ref.read(timerProvider.notifier).start();
        await state.start(config, path: await _getPath());
        await _onLoadLoopRecording(config);
      }
    } catch (e, s) {
      _segmentTimer?.cancel();
      AppLogger.e('録画開始処理でエラー', error: e, s: s);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _saveCurrentSegment();
    _segmentTimer?.cancel();
    ref.read(timerProvider.notifier).stop();
    ref.read(isRecordingProvider.notifier).state = false;
  }

  Future<void> _onLoadLoopRecording(RecordConfig config) async {
    // X分ごとに音声データを保存する
    _segmentTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      // 現在のセグメントを保存し、音声データを生成
      await _saveCurrentSegment();
      // 新しいセグメントの録音を開始
      await state.start(config, path: await _getPath());
    });
    ref.read(isRecordingProvider.notifier).state = true;
  }

  Future<void> _saveCurrentSegment() async {
    final filePath = await state.stop();
    if (filePath != null) {
      AppLogger.d('Stop of Record. File to $filePath.');
      ref.read(soundFilesProvider.notifier).add(
            filePath: filePath,
            time: ref.read(timerProvider) - _elapsedTime,
          );
      _elapsedTime = ref.read(timerProvider);
    }
  }

  Future<String> _getPath() async {
    final dir = await getApplicationCacheDirectory();
    return path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');
  }
}

final isRecordingProvider = StateProvider<bool>((ref) => false);
