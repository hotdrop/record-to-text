import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundFilesProvider = NotifierProvider<SoundFilesNotifier, List<SoundFile>>(SoundFilesNotifier.new);

class SoundFilesNotifier extends Notifier<List<SoundFile>> {
  @override
  build() {
    return [];
  }

  void add({required String filePath, required int time}) {
    final id = _createIdFromPath(filePath);
    final newFile = SoundFile(id: id, soundFilePath: filePath, recordTime: time);
    state = [newFile, ...state];
  }

  String _createIdFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final extentionIdx = fileName.lastIndexOf('.');
    return fileName.substring(0, extentionIdx);
  }
}

class SoundFile {
  const SoundFile({required this.id, required this.soundFilePath, required this.recordTime, this.speechToText});

  final String id;
  final String soundFilePath;
  final int recordTime;
  final String? speechToText;

  String fileName() => soundFilePath.split('/').last;

  SoundFile copyWith({required String speechToText}) {
    return SoundFile(
      id: id,
      soundFilePath: soundFilePath,
      recordTime: recordTime,
      speechToText: speechToText,
    );
  }
}
