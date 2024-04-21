import 'package:isar/isar.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';

part 'record_entity.g.dart';

@collection
class RecordEntity {
  RecordEntity({
    required this.title,
    required this.recordItems,
    this.summaryText,
    this.summaryExecuteTime,
    required this.createAt,
  });
  final Id id = Isar.autoIncrement;
  final String title;
  final List<RecordItemEntity> recordItems;
  final String? summaryText;
  final int? summaryExecuteTime;
  final DateTime createAt;
}

@embedded
class RecordItemEntity {
  String? id;
  String? filePath;
  int? recordTime;
  int? speechToTextExecTime;
  String? speechToText;
  @enumerated
  late RecordToTextStatus status;
  String? errorMessage;
}
