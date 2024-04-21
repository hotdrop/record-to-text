import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/repository/local/app_database.dart';
import 'package:recorod_to_text/repository/local/entity/record_entity.dart';

final recordDaoProvider = Provider((ref) => _RecordDao(ref));

class _RecordDao {
  const _RecordDao(this.ref);

  final Ref ref;

  Future<List<RecordOnlyTitle>> findRecordOnlyTitles() async {
    final isar = ref.read(databaseProvider).isar;
    final entities = await isar.recordEntitys.where().findAll();
    AppLogger.d("レコードの一覧を取得しました。length=${entities.length}");
    if (entities.isEmpty) {
      return [];
    }

    return entities
        .map((e) => RecordOnlyTitle(
              id: e.id,
              title: e.title,
              createAt: e.createAt,
            ))
        .toList();
  }

  Future<Record> find(int id) async {
    final isar = ref.read(databaseProvider).isar;
    final entities = isar.recordEntitys;

    final target = await entities.filter().idEqualTo(id).findFirst();
    return Record(
      id: target!.id,
      title: target.title,
      recordItems: target.recordItems
          .map((item) => RecordItem(
                id: item.id!,
                filePath: item.filePath!,
                recordTime: item.recordTime!,
                speechToTextExecTime: item.speechToTextExecTime!,
                speechToText: item.speechToText!,
                status: item.status,
                errorMessage: item.errorMessage,
              ))
          .toList(),
      createAt: target.createAt,
    );
  }

  Future<Record> saveNewRecord({required String title, required RecordItem recordItem}) async {
    final recordEntity = RecordEntity(
      title: title,
      recordItems: [_toRecordItemEntity(recordItem)],
      createAt: DateTime.now(),
    );

    final isar = ref.read(databaseProvider).isar;
    await isar.writeTxn(() async {
      await isar.recordEntitys.put(recordEntity);
    });

    return _entityToRecord(recordEntity);
  }

  Future<void> save(Record record) async {
    final newEntity = RecordEntity(
      title: record.title,
      recordItems: record.recordItems.map((e) => _toRecordItemEntity(e)).toList(),
      summaryText: record.summaryTextResult?.text,
      summaryExecuteTime: record.summaryTextResult?.executeTime,
      createAt: record.createAt,
    );
    final isar = ref.read(databaseProvider).isar;
    final entities = isar.recordEntitys;
    final target = await entities.filter().idEqualTo(record.id).findFirst();
    if (target == null) {
      throw StateError('ID=${record.id}のデータがローカルに存在しません');
    }

    await isar.writeTxn(() async {
      await entities.put(newEntity);
    });
  }

  Record _entityToRecord(RecordEntity entity) {
    SummaryTextResult? summary;
    if (entity.summaryText != null) {
      summary = SummaryTextResult(entity.summaryText!, entity.summaryExecuteTime!);
    }

    return Record(
      id: entity.id,
      title: entity.title,
      recordItems: entity.recordItems.map((e) => _entityToItem(e)).toList(),
      summaryTextResult: summary,
      createAt: entity.createAt,
    );
  }

  RecordItem _entityToItem(RecordItemEntity entity) {
    return RecordItem(
      id: entity.id!,
      filePath: entity.filePath!,
      recordTime: entity.recordTime!,
      speechToTextExecTime: entity.speechToTextExecTime!,
      speechToText: entity.speechToText,
      status: entity.status,
      errorMessage: entity.errorMessage,
    );
  }

  RecordItemEntity _toRecordItemEntity(RecordItem item) {
    return RecordItemEntity()
      ..id = item.id
      ..filePath = item.filePath
      ..recordTime = item.recordTime
      ..speechToTextExecTime = item.speechToTextExecTime
      ..speechToText = item.speechToText
      ..status = item.status
      ..errorMessage = item.errorMessage;
  }
}
