import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/repository/local/record_dao.dart';

final recordRepositoryProvider = Provider((ref) => _RecordRepoistory(ref));

class _RecordRepoistory {
  const _RecordRepoistory(this.ref);

  final Ref ref;

  Future<List<RecordOnlyTitle>> findTitles() async {
    return await ref.read(recordDaoProvider).findRecordOnlyTitles();
  }

  Future<Record> find(int recordId) async {
    return await ref.read(recordDaoProvider).find(recordId);
  }

  Future<Record> saveNewRecord({required String title, required RecordItem recordItem}) async {
    AppLogger.d('録音情報を保存します title=$title');
    final recordId = await ref.read(recordDaoProvider).saveNewRecord(title: title);
    await saveRecordItem(recordId: recordId, item: recordItem);
    return await ref.read(recordDaoProvider).find(recordId);
  }

  Future<void> saveRecordItem({required int recordId, required RecordItem item}) async {
    AppLogger.d('ID:$recordIdの録音情報を登録します');
    await ref.read(recordDaoProvider).upsertRecordItem(recordId: recordId, item: item);
  }

  Future<void> saveSummary({required int recordId, required SummaryTextResult summaryTextResult}) async {
    AppLogger.d('ID:$recordIdのサマリーを登録または更新します');
    await ref.read(recordDaoProvider).upsertSummary(recordId: recordId, summaryTextResult: summaryTextResult);
  }
}
