import 'package:flutter_test/flutter_test.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';

void main() {
  test('RecordItemが正しく追加できるか確認する', () async {
    final record = Record(
      id: 1,
      title: 'テスト',
      recordItems: [_createRecordItem('test1')],
      createAt: DateTime.now(),
    );
    final item1 = _createRecordItem('test2');
    final resultRecord = record.setRecoreItem(item1);

    expect(resultRecord.recordItems.length, 2);
    final resultItem = resultRecord.recordItems.where((e) => e.id == 'test2').first;
    expect(resultItem.speechToText, 'テストです');

    final item1Update = item1.copyWith(speechToText: '更新しました');
    final resultRecord2 = record.setRecoreItem(item1Update);

    expect(resultRecord2.recordItems.length, 2);
    final resultUpdateItem = resultRecord2.recordItems.where((e) => e.id == 'test2').first;
    expect(resultUpdateItem.speechToText, '更新しました');
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
