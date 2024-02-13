import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/timer_provider.dart';

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
        final appSetting = ref.read(appSettingNotifierProvider);
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        // 初回録音を実行し、以降は一定間隔で録音データを管理する
        ref.read(timerProvider.notifier).start();
        await state.start(config, path: appSetting.createSoundFilePath());
        await _onLoadLoopRecording(config);
      }
    } catch (e, s) {
      stop();
      AppLogger.e('録画処理でエラー', error: e, s: s);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _saveCurrentSegment();
    _segmentTimer?.cancel();
    ref.read(timerProvider.notifier).stop();
    ref.read(isRecordingProvider.notifier).state = false;
    _elapsedTime = 0;
  }

  Future<void> _onLoadLoopRecording(RecordConfig config) async {
    final appSetting = ref.read(appSettingNotifierProvider);
    // X分ごとに音声データを保存する
    _segmentTimer = Timer.periodic(Duration(minutes: appSetting.recordIntervalMinutes), (timer) async {
      // 現在のセグメントを保存し、音声データを生成
      await _saveCurrentSegment();
      // 新しいセグメントの録音を開始
      await state.start(config, path: appSetting.createSoundFilePath());
    });
    ref.read(isRecordingProvider.notifier).state = true;
  }

  Future<void> _saveCurrentSegment() async {
    final filePath = await state.stop();
    if (filePath != null) {
      AppLogger.d('Stop of Record. File to $filePath.');
      ref.read(recordFilesProvider.notifier).add(
            filePath: filePath,
            time: ref.read(timerProvider) - _elapsedTime,
          );
      _elapsedTime = ref.read(timerProvider);
    }
  }
}

final isRecordingProvider = StateProvider<bool>((ref) => false);
