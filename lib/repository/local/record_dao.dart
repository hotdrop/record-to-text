import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_title.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/repository/local/app_database.dart';
import 'package:recorod_to_text/repository/local/entity/record_entity.dart';
import 'package:recorod_to_text/repository/local/entity/record_item_entity.dart';
import 'package:recorod_to_text/repository/local/entity/record_summary_entity.dart';

final recordDaoProvider = Provider((ref) => _RecordDao(ref));

class _RecordDao {
  const _RecordDao(this.ref);

  final Ref ref;

  Future<List<RecordOnlyTitle>> findRecordOnlyTitles() async {
    final isar = ref.read(databaseProvider).isar;
    final entities = await isar.recordEntitys.where().findAll();

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

    final targetRecord = await isar.recordEntitys.filter().idEqualTo(id).findFirst();
    final targetItems = await isar.recordItemEntitys.filter().recordIdEqualTo(id).findAll();
    final targetSummary = await isar.recordSummaryEntitys.filter().recordIdEqualTo(id).findFirst();

    return Record(
      id: targetRecord!.id,
      title: targetRecord.title,
      recordItems: targetItems.map((item) => _entityToRecordItem(item)).toList(),
      summaryTextResult: _entityToSummary(targetSummary),
      createAt: targetRecord.createAt,
    );
  }

  Future<int> saveNewRecord({required String title}) async {
    final recordEntity = RecordEntity(title: title, createAt: DateTime.now());
    final isar = ref.read(databaseProvider).isar;
    return await isar.writeTxn(() async {
      return await isar.recordEntitys.put(recordEntity);
    });
  }

  Future<void> upsertRecordItem({required int recordId, required RecordItem item}) async {
    final isar = ref.read(databaseProvider).isar;

    await isar.writeTxn(() async {
      final currentRecordItems = await isar.recordItemEntitys.filter().recordIdEqualTo(recordId).findAll();
      final targetItem = currentRecordItems.where((e) => e.itemId == item.id).firstOrNull;
      if (targetItem == null) {
        final newItem = _recordItemToEntity(recordId, item);
        await isar.recordItemEntitys.put(newItem);
      } else {
        final existItem = _recordItemToEntity(recordId, item)..id = targetItem.id;
        await isar.recordItemEntitys.put(existItem);
      }
    });
  }

  Future<void> upsertSummary({required int recordId, required SummaryTextResult summaryTextResult}) async {
    final isar = ref.read(databaseProvider).isar;

    await isar.writeTxn(() async {
      final currentSummary = await isar.recordSummaryEntitys.filter().recordIdEqualTo(recordId).findFirst();
      if (currentSummary == null) {
        final newSummary = _summaryToEntity(recordId, summaryTextResult);
        await isar.recordSummaryEntitys.put(newSummary);
      } else {
        final existSummary = _summaryToEntity(recordId, summaryTextResult)..id = currentSummary.id;
        await isar.recordSummaryEntitys.put(existSummary);
      }
    });
  }

  RecordItem _entityToRecordItem(RecordItemEntity entity) {
    return RecordItem(
      id: entity.itemId,
      filePath: entity.filePath,
      recordTime: entity.recordTime,
      speechToTextExecTime: entity.speechToTextExecTime!,
      speechToText: entity.speechToText!,
      status: entity.status,
      errorMessage: entity.errorMessage,
    );
  }

  SummaryTextResult? _entityToSummary(RecordSummaryEntity? entity) {
    if (entity == null) {
      return null;
    }

    return SummaryTextResult(entity.summaryText, entity.summaryExecuteTime);
  }

  RecordItemEntity _recordItemToEntity(int recordId, RecordItem item) {
    return RecordItemEntity(
      recordId: recordId,
      itemId: item.id,
      filePath: item.filePath,
      recordTime: item.recordTime,
      speechToTextExecTime: item.speechToTextExecTime,
      speechToText: item.speechToText,
      status: item.status,
      errorMessage: item.errorMessage,
    );
  }

  RecordSummaryEntity _summaryToEntity(int recordId, SummaryTextResult summary) {
    return RecordSummaryEntity(
      recordId: recordId,
      summaryText: summary.text,
      summaryExecuteTime: summary.executeTime,
    );
  }
}
