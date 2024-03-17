import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';

class History {
  const History({required this.id, required this.title, required this.recordFiles, this.summaryTextResult});

  final int id;
  final String title;
  final List<RecordFile> recordFiles;
  final SummaryTextResult? summaryTextResult;
}
