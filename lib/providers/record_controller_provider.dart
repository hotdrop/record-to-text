import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_items_provider.dart';
import 'package:recorod_to_text/providers/timer_provider.dart';

final recordControllerProvider = NotifierProvider<RecordControllerNotifier, AudioRecorder>(RecordControllerNotifier.new);

class RecordControllerNotifier extends Notifier<AudioRecorder> {
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
        final appSetting = ref.read(appSettingProvider);
        final config = RecordConfig(encoder: AudioEncoder.aacLc, device: appSetting.inputDevice);
        // 初回録音を実行し、以降は一定間隔で録音データを管理する
        ref.read(timerProvider.notifier).start();
        await state.start(config, path: appSetting.createSoundFilePath());
        await _startRecordingLoop(config);
      }
    } catch (e, s) {
      stop();
      AppLogger.e('録音処理でエラー', error: e, s: s);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _saveCurrentSegment();
    _segmentTimer?.cancel();
    ref.read(timerProvider.notifier).stop();
    ref.read(nowRecordingProvider.notifier).state = false;
    _elapsedTime = 0;
  }

  Future<void> _startRecordingLoop(RecordConfig config) async {
    final appSetting = ref.read(appSettingProvider);

    _segmentTimer = Timer.periodic(Duration(minutes: appSetting.recordIntervalMinutes), (timer) async {
      // 現在のセグメントを保存し、音声データを生成
      await _saveCurrentSegment();
      // 新しいセグメントの録音を開始
      await state.start(config, path: appSetting.createSoundFilePath());
    });

    ref.read(nowRecordingProvider.notifier).state = true;
  }

  Future<void> _saveCurrentSegment() async {
    final filePath = await state.stop();
    if (filePath != null) {
      ref.read(recordItemsProvider.notifier).add(
            filePath: filePath,
            time: ref.read(timerProvider) - _elapsedTime,
          );
      _elapsedTime = ref.read(timerProvider);
    } else {
      AppLogger.e('音声データの保存に失敗しました filePath=$filePath');
    }
  }

  Future<List<String>> devices() async {
    final record = await state.listInputDevices();
    return record.map((e) => e.label).toList();
  }
}

final recordDevicesProvider = FutureProvider<List<InputDevice>>((ref) async {
  return await ref.watch(recordControllerProvider).listInputDevices();
});

final nowRecordingProvider = StateProvider<bool>((ref) => false);
