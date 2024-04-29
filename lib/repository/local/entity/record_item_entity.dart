import 'package:isar/isar.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';

part 'record_item_entity.g.dart';

@collection
class RecordItemEntity {
  RecordItemEntity({
    required this.recordId,
    required this.itemId,
    required this.filePath,
    required this.recordTime,
    required this.status,
    this.speechToText,
    this.speechToTextExecTime,
    this.errorMessage,
  });

  Id id = Isar.autoIncrement;

  // 実際にレコードを特定するのはrecordIdとitemId
  final int recordId;
  final String itemId;
  final String filePath;
  final int recordTime;
  @enumerated
  late RecordToTextStatus status;
  String? speechToText;
  int? speechToTextExecTime;
  String? errorMessage;
}
