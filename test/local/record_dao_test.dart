import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/repository/local/app_database.dart';
import 'package:recorod_to_text/repository/local/record_dao.dart';

import 'test_database.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    await container.read(databaseProvider).init();
  });

  test('RecordのIDとタイトル一覧取得が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);
    final item1 = await dao.saveNewRecord(title: 'テスト1', recordItem: _createRecordItem('test1'));
    final item2 = await dao.saveNewRecord(title: 'テスト2', recordItem: _createRecordItem('test2'));
    final item3 = await dao.saveNewRecord(title: 'テスト3', recordItem: _createRecordItem('test3'));
    final records = await dao.findRecordOnlyTitles();

    expect(records.length, 3);
    expect(records[0].id, item1.id);
    expect(records[0].title, 'テスト1');
    expect(records[1].id, item2.id);
    expect(records[1].title, 'テスト2');
    expect(records[2].id, item3.id);
    expect(records[2].title, 'テスト3');
  });

  test('IDを指定したRecordの取得が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);
    await dao.saveNewRecord(title: 'テスト1', recordItem: _createRecordItem('test1'));
    await dao.saveNewRecord(title: 'テスト3', recordItem: _createRecordItem('test3'));
    final item2 = await dao.saveNewRecord(title: 'テスト2', recordItem: _createRecordItem('test2'));

    final targetItem = await dao.find(item2.id);

    expect(targetItem.id, item2.id);
    expect(targetItem.title, item2.title);

    expect(targetItem.recordItems.length, 1);
    final recordItem = targetItem.recordItems.first;
    expect(recordItem.filePath, 'testpath');
    expect(recordItem.recordTime, 60);
    expect(recordItem.speechToText, 'テストです');
    expect(recordItem.speechToTextExecTime, 10);
    expect(recordItem.status, RecordToTextStatus.wait);
    expect(recordItem.errorMessage, null);
  });

  test('Recordの新規保存が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);
    final newRecord = await dao.saveNewRecord(title: '新規登録テスト', recordItem: _createRecordItem('test1'));
    expect(newRecord.title, '新規登録テスト');
    expect(newRecord.recordItems.length, 1);

    final item = newRecord.recordItems.first;
    expect(item.id, 'test1');
    expect(item.filePath, 'testpath');
    expect(item.recordTime, 60);
    expect(item.speechToText, 'テストです');
    expect(item.speechToTextExecTime, 10);
    expect(item.status, RecordToTextStatus.wait);
    expect(item.errorMessage, null);
  });

  test('Recordの更新保存が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);
    final newRecord = await dao.saveNewRecord(title: 'テスト1', recordItem: _createRecordItem('test1'));
    final updateRecord = newRecord.copyWith(
      recordItems: [
        ...newRecord.recordItems,
        _createRecordItem('test2'),
      ],
      summaryTextResult: const SummaryTextResult('サマリーテキストです', 120),
    );

    await dao.update(updateRecord);
    final resultRecord = await dao.find(updateRecord.id);

    expect(resultRecord.id, updateRecord.id);
    expect(resultRecord.title, updateRecord.title);
    expect(resultRecord.recordItems.length, 2);

    final resultRecordItem2 = resultRecord.recordItems[1];
    expect(resultRecordItem2.id, 'test2');
    expect(resultRecordItem2.filePath, 'testpath');
    expect(resultRecordItem2.recordTime, 60);
    expect(resultRecordItem2.speechToText, 'テストです');
    expect(resultRecordItem2.speechToTextExecTime, 10);
    expect(resultRecordItem2.status, RecordToTextStatus.wait);
    expect(resultRecordItem2.errorMessage, null);

    final resultSummary = resultRecord.summaryTextResult;
    expect(resultSummary!.text, 'サマリーテキストです');
    expect(resultSummary.executeTime, 120);
  });
}

RecordItem _createRecordItem(String id) {
  return RecordItem(
    id: id,
    filePath: 'testpath',
    recordTime: 60,
    speechToText: 'テストです',
    speechToTextExecTime: 10,
    status: RecordToTextStatus.wait,
    errorMessage: null,
  );
}
