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

    // テストデータ登録
    final recordId1 = await dao.saveNewRecord(title: 'テスト1');
    final recordId2 = await dao.saveNewRecord(title: 'テスト2');
    final recordId3 = await dao.saveNewRecord(title: 'テスト3');

    // テスト実行
    final records = await dao.findRecordOnlyTitles();

    // 結果確認
    expect(records.length, 3);
    expect(records[0].id, recordId1);
    expect(records[0].title, 'テスト1');
    expect(records[1].id, recordId2);
    expect(records[1].title, 'テスト2');
    expect(records[2].id, recordId3);
    expect(records[2].title, 'テスト3');
  });

  test('IDを指定したRecordの取得が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId1 = await dao.saveNewRecord(title: 'テスト1');
    await dao.upsertRecordItem(recordId: recordId1, item: _createRecordItem('test1'));
    final recordId2 = await dao.saveNewRecord(title: 'テスト2');
    await dao.upsertRecordItem(recordId: recordId2, item: _createRecordItem('test2'));
    final recordId3 = await dao.saveNewRecord(title: 'テスト3');
    await dao.upsertRecordItem(recordId: recordId3, item: _createRecordItem('test3'));

    // テスト実行
    final result = await dao.find(recordId2);

    // 結果確認
    expect(result.id, recordId2);
    expect(result.title, 'テスト2');
    expect(result.recordItems.length, 1);
    final resultItem = result.recordItems.first;
    expect(resultItem.id, 'test2');
    expect(resultItem.filePath, 'testpath');
    expect(resultItem.recordTime, 60);
    expect(resultItem.speechToText, 'テストです');
    expect(resultItem.speechToTextExecTime, 10);
    expect(resultItem.status, RecordToTextStatus.wait);
    expect(resultItem.errorMessage, null);
  });

  test('RecordItemの新規登録が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId = await dao.saveNewRecord(title: 'テスト1');

    // テスト実行
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test1'));

    // テスト結果確認
    final result = await dao.find(recordId);
    expect(result.id, recordId);
    expect(result.title, 'テスト1');
    expect(result.recordItems.length, 1);
    final resultItem = result.recordItems.first;
    expect(resultItem.id, 'test1');
    expect(resultItem.filePath, 'testpath');
    expect(resultItem.recordTime, 60);
    expect(resultItem.speechToText, 'テストです');
    expect(resultItem.speechToTextExecTime, 10);
    expect(resultItem.status, RecordToTextStatus.wait);
    expect(resultItem.errorMessage, null);
  });

  test('RecordItemの追加登録が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId = await dao.saveNewRecord(title: 'テスト1');
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test1'));

    // テスト実行
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test2'));

    // テスト結果確認
    final result = await dao.find(recordId);
    expect(result.id, recordId);
    expect(result.title, 'テスト1');
    expect(result.recordItems.length, 2);
    expect(result.recordItems[0].id, 'test1');
    expect(result.recordItems[1].id, 'test2');
  });

  test('RecordItemの既存データ更新が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId = await dao.saveNewRecord(title: 'テスト1');
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test1'));
    final targetItem = _createRecordItem('test2');
    await dao.upsertRecordItem(recordId: recordId, item: targetItem);

    // テスト実行
    final updateItem = targetItem.copyWith(
      speechToText: '更新されたデータです',
      speechToTextExecTime: 20,
      errorMessage: 'テストです',
    );

    await dao.upsertRecordItem(recordId: recordId, item: updateItem);
    final result = await dao.find(recordId);

    expect(result.id, recordId);
    expect(result.title, 'テスト1');
    expect(result.recordItems.length, 2);

    final resultItem = result.recordItems.where((e) => e.id == 'test2').first;
    expect(resultItem.filePath, 'testpath');
    expect(resultItem.recordTime, 60);
    expect(resultItem.speechToText, '更新されたデータです');
    expect(resultItem.speechToTextExecTime, 20);
    expect(resultItem.status, RecordToTextStatus.wait);
    expect(resultItem.errorMessage, 'テストです');
  });

  test('upsertSummaryの新規登録が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId = await dao.saveNewRecord(title: 'テスト1');
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test1'));

    // テスト実行
    await dao.upsertSummary(recordId: recordId, summaryTextResult: const SummaryTextResult('サマリー', 10));

    // テスト結果確認
    final result = await dao.find(recordId);
    final resultSummary = result.summaryTextResult;
    expect(resultSummary!.text, 'サマリー');
    expect(resultSummary.executeTime, 10);
  });
  test('upsertSummaryの既存データ更新が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);

    // テストデータ登録
    final recordId = await dao.saveNewRecord(title: 'テスト1');
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test1'));
    await dao.upsertRecordItem(recordId: recordId, item: _createRecordItem('test2'));
    await dao.upsertSummary(recordId: recordId, summaryTextResult: const SummaryTextResult('サマリー', 10));

    // テスト実行
    await dao.upsertSummary(recordId: recordId, summaryTextResult: const SummaryTextResult('更新サマリー', 50));

    // テスト結果確認
    final result = await dao.find(recordId);
    final resultSummary = result.summaryTextResult;
    expect(resultSummary!.text, '更新サマリー');
    expect(resultSummary.executeTime, 50);
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
