import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/repository/local/record_dao.dart';

final recordRepositoryProvider = Provider((ref) => _RecordRepoistory(ref));

class _RecordRepoistory {
  const _RecordRepoistory(this.ref);

  final Ref ref;

  Future<List<RecordOnlyTitle>> findTitles() async {
    return await ref.read(recordDaoProvider).findRecordOnlyTitles();
  }

  Future<Record> find(int id) async {
    return await ref.read(recordDaoProvider).find(id);
  }

  Future<void> save(Record record) async {
    // TODO 保存処理を実装する
    AppLogger.d('履歴を保存します id=${record.id}');
  }

  Future<Record> saveNew({required String title, required RecordItem recordItem}) async {
    // TODO 保存処理を実装する
    AppLogger.d('新規で履歴を作成/保存します title=$title');
    return Record(
      id: 5,
      title: title,
      recordItems: [recordItem],
      createAt: DateTime.now(),
    );
  }
}
