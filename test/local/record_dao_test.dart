import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';
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

  // test('RecordのIDとタイトル一覧取得が正しく行えるか確認する', () async {
  // }

  // test('IDを指定したRecordの取得が正しく行えるか確認する', () async {
  // }

  test('Recordの新規保存が正しく行えるか確認する', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWith((_) => const TestAppDatabase())],
    );
    final dao = container.read(recordDaoProvider);
    final testItem = _createRecordItem('test1');

    final newRecord = await dao.saveNewRecord(title: '新規登録テスト', recordItem: testItem);

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
}

// test('Recordの更新保存が正しく行えるか確認する', () async {
// }

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
