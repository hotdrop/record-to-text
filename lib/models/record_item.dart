import 'package:path/path.dart' as path;
import 'package:recorod_to_text/models/record_status_enum.dart';

class RecordItem {
  const RecordItem({
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

  RecordItem copyWith({
    String? speechToText,
    int? speechToTextExecTime,
    RecordToTextStatus? status,
    String? errorMessage,
  }) {
    return RecordItem(
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
