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
  @override
  AudioRecorder build() {
    ref.onDispose(() {
      state.dispose();
    });
    return AudioRecorder();
  }

  Future<void> start() async {
    try {
      if (await state.hasPermission()) {
        _startTimer();
        final filePath = await _getPath();
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await state.start(config, path: filePath);
      }
    } catch (e, s) {
      _stopTimer();
      AppLogger.e('録画開始処理でエラー', error: e, s: s);
      rethrow;
    }
  }

  ///
  /// streamはうまくいかなかった
  ///
  // Future<void> _recordStream() async {
  //   final path = await _getPath();
  //   final file = File(path);
  //   // numChannels 1は長さ0になる 2は6倍くらいになる 3はエラー
  //   const config = RecordConfig(encoder: AudioEncoder.pcm16bits);
  //   final stream = await state.startStream(config);
  //   stream.listen((event) {
  //     file.writeAsBytesSync(event, mode: FileMode.append);
  //   }, onDone: () {
  //     AppLogger.d('End of stream. File written to $path.');
  //     final oldList = ref.read(recordFilePathsProvider);
  //     ref.read(recordFilePathsProvider.notifier).state = [path, ...oldList];
  //   });
  // }

  Future<void> stop() async {
    final path = await state.stop();
    _stopTimer();
    if (path != null) {
      AppLogger.d('Stop of Record. File to $path.');
      final time = ref.read(timerProvider);
      ref.read(soundFilesProvider.notifier).add(filePath: path, time: time);
    }
  }

  Future<String> _getPath() async {
    final dir = await getApplicationCacheDirectory();
    return path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');
  }

  void _startTimer() {
    ref.read(timerProvider.notifier).start();
    _updateRecordState(true);
  }

  void _stopTimer() {
    ref.read(timerProvider.notifier).stop();
    _updateRecordState(false);
  }

  void _updateRecordState(bool isRecording) {
    ref.read(isRecordingProvider.notifier).state = isRecording;
  }
}

final isRecordingProvider = StateProvider<bool>((ref) => false);
