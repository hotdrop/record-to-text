import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/repository/history_repository.dart';

final historiesProvider = NotifierProvider<_HistoryNotifier, List<History>>(_HistoryNotifier.new);

class _HistoryNotifier extends Notifier<List<History>> {
  @override
  List<History> build() {
    return [];
  }

  Future<void> onLoad() async {
    final histories = await ref.read(historyRepositoryProvider).findAll();
    state = [...histories];
  }

  Future<void> setHistory(History history) async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    ref.read(recordFilesProvider.notifier).setHistory(history.recordFiles);
    await ref.read(summaryProvider.notifier).setHistory(history.summaryTextResult);
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    ref.invalidate(recordFilesProvider);
    ref.invalidate(summaryProvider);
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }
}

final historyNowLoadingProvider = StateProvider<bool>((_) => false);
