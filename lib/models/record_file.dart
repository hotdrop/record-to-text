import 'package:path/path.dart' as path;

class RecordFile {
  const RecordFile({
    required this.id,
    required this.filePath,
    required this.recordTime,
    this.speechToText,
    this.speechToTextExecTime = 0,
    this.status = RecordToTextStatus.wait,
    this.errorMessage,
  });

  final String id;
  final String filePath;
  final int recordTime;
  final int speechToTextExecTime;

  final String? speechToText;
  final RecordToTextStatus status;
  final String? errorMessage;

  String fileName() => path.basename(filePath);

  bool isSuccess() => status == RecordToTextStatus.success;
  bool isError() => status == RecordToTextStatus.error;
  bool isWait() => status == RecordToTextStatus.wait;

  RecordFile copyWith({
    String? speechToText,
    int? speechToTextExecTime,
    RecordToTextStatus? status,
    String? errorMessage,
  }) {
    return RecordFile(
      id: id,
      filePath: filePath,
      recordTime: recordTime,
      speechToTextExecTime: speechToTextExecTime ?? this.speechToTextExecTime,
      speechToText: speechToText ?? this.speechToText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum RecordToTextStatus { wait, success, error }
