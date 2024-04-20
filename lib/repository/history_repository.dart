import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/repository/local/history_dao.dart';

final historyRepositoryProvider = Provider((ref) => _HistoryRepoistory(ref));

class _HistoryRepoistory {
  const _HistoryRepoistory(this.ref);

  final Ref ref;

  Future<List<HistoryTitle>> findTitles() async {
    return await ref.read(historyDaoProvider).findTitles();
  }

  Future<History> find(String historyId) async {
    return await ref.read(historyDaoProvider).find(historyId);
  }

  Future<void> save(History history) async {
    // TODO 保存処理を実装する
    AppLogger.d('履歴を保存します id=${history.id}');
  }
}
