import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';

class HistoryTitle {
  const HistoryTitle({required this.id, required this.title});
  final String id;
  final String title;
}

class History {
  const History({required this.id, required this.title, required this.recordFiles, this.summaryTextResult});

  final String id;
  final String title;
  final List<RecordFile> recordFiles;
  final SummaryTextResult? summaryTextResult;

  static String createId() {
    // 1秒以内に複数IDを生成することはないはずなので秒まででIDを生成する
    var epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return epoch.toString();
  }

  History upsertRecoreFile(RecordFile newRecordFile) {
    final idx = recordFiles.indexWhere((e) => e.id == newRecordFile.id);
    if (idx != -1) {
      return copyWith(recordFiles: List.of(recordFiles)..[idx] = newRecordFile);
    } else {
      return copyWith(recordFiles: [newRecordFile, ...recordFiles]);
    }
  }

  History copyWith({
    String? title,
    List<RecordFile>? recordFiles,
    SummaryTextResult? summaryTextResult,
  }) {
    return History(
      id: id,
      title: title ?? this.title,
      recordFiles: recordFiles ?? this.recordFiles,
      summaryTextResult: summaryTextResult ?? this.summaryTextResult,
    );
  }
}
