// import 'dart:async';
// import 'dart:io';
// import 'package:path/path.dart' as path;

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:realtime_talk/common/app_logger.dart';
// import 'package:realtime_talk/models/timer_provider.dart';
// import 'package:record/record.dart';

// final recordProvider = NotifierProvider<RecordNotifier, AudioRecorder>(RecordNotifier.new);

// class RecordNotifier extends Notifier<AudioRecorder> {
//   @override
//   AudioRecorder build() {
//     ref.onDispose(() {
//       state.dispose();
//     });
//     return AudioRecorder();
//   }

//   Future<void> start() async {
//     try {
//       ref.read(timerProvider.notifier).start();
//       if (await state.hasPermission()) {
//         await _recordStream();
//       }
//     } catch (e, s) {
//       ref.read(timerProvider.notifier).stop();
//       AppLogger.e('録画開始処理でエラー', error: e, s: s);
//       rethrow;
//     }
//   }

//   Future<void> _recordStream() async {
//     final path = await _getPath();
//     final file = File(path);
//     final stream = await state.startStream(const RecordConfig(encoder: AudioEncoder.aacLc));

//     stream.listen((event) {
//       file.writeAsBytesSync(event, mode: FileMode.append);
//       // TODO ここは未実装
//     }, onDone: () {
//       AppLogger.d('End of stream. File written to $path.');
//     });
//   }

//   Future<void> stop() async {
//     final path = await state.stop();
//     if (path != null) {
//       final oldList = ref.read(recordFilePathsProvider);
//       ref.read(recordFilePathsProvider.notifier).state = [...oldList, path];
//     }
//     ref.read(timerProvider.notifier).stop();
//   }

//   Future<String> _getPath() async {
//     final dir = await getApplicationCacheDirectory();
//     return path.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
//   }
// }

// final recordFilePathsProvider = StateProvider<List<String>>((_) => []);
