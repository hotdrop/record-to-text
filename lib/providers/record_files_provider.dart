import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordFilesProvider = NotifierProvider<RecordFilesNotifier, List<RecordFile>>(RecordFilesNotifier.new);

class RecordFilesNotifier extends Notifier<List<RecordFile>> {
  @override
  build() {
    return [
      RecordFile(id: '1234', filePath: 'test/20231231234591.m4a', recordTime: 75),
      RecordFile(id: '5678', filePath: 'test/20240102123456.m4a', recordTime: 65),
    ];
  }

  void add({required String filePath, required int time}) {
    final id = _createIdFromPath(filePath);
    final newFile = RecordFile(id: id, filePath: filePath, recordTime: time);
    state = [newFile, ...state];
  }

  String _createIdFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final extentionIdx = fileName.lastIndexOf('.');
    return fileName.substring(0, extentionIdx);
  }
}

class RecordFile {
  const RecordFile({required this.id, required this.filePath, required this.recordTime, this.speechToText, this.isSummarized});

  final String id;
  final String filePath;
  final int recordTime;
  final String? speechToText;
  final bool? isSummarized;

  String fileName() => filePath.split('/').last;

  RecordProcessStatus statusSpeechToText() {
    // TODO 未実装
    return RecordProcessStatus.success;
  }

  RecordProcessStatus statusSummarized() {
    // TODO 未実装
    return RecordProcessStatus.wait;
  }

  RecordFile copyWith({required String speechToText}) {
    return RecordFile(
      id: id,
      filePath: filePath,
      recordTime: recordTime,
      speechToText: speechToText,
    );
  }
}

enum RecordProcessStatus { wait, success, error }
