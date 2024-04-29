import 'package:isar/isar.dart';

part 'record_summary_entity.g.dart';

@collection
class RecordSummaryEntity {
  RecordSummaryEntity({
    required this.recordId,
    required this.summaryText,
    required this.summaryExecuteTime,
  });

  Id id = Isar.autoIncrement;

  final int recordId;
  final String summaryText;
  final int summaryExecuteTime;
}
