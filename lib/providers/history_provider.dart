import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/repository/history_repository.dart';

final currentHistoryProvider = NotifierProvider<_CurrentHistoryNotifier, History?>(_CurrentHistoryNotifier.new);

class _CurrentHistoryNotifier extends Notifier<History?> {
  @override
  History? build() {
    return null;
  }

  Future<void> currentSet(History history) async {
    // 取得した履歴をそれぞれ録音データとサマリーデータにセットする。サマリーはAsyncNotifierProviderなのでawaitつけている
    ref.read(recordFilesProvider.notifier).setHistory(history.recordFiles);
    await ref.read(summaryProvider.notifier).setHistory(history.summaryTextResult);
    state = history;
  }

  Future<void> addRecord(RecordFile recordFile) async {
    if (state == null) {
      final text = recordFile.speechToText ?? 'no data';
      final newHistory = History(
        id: History.createId(),
        title: text.substring(0, min(30, text.length)),
        recordFiles: [recordFile],
      );
      await ref.read(historyRepositoryProvider).save(newHistory);
      state = newHistory;
    } else {
      // 既存録音データに追加
      state!.upsertRecoreFile(recordFile);
      await ref.read(historyRepositoryProvider).save(state!);
    }
  }

  Future<void> addSummary(SummaryTextResult result) async {
    if (state != null) {
      final newHistory = state!.copyWith(summaryTextResult: result);
      await ref.read(historyRepositoryProvider).save(newHistory);
      state = newHistory;
    }
  }
}

final historiesProvider = NotifierProvider<_HistoriesNotifier, List<HistoryTitle>>(_HistoriesNotifier.new);

class _HistoriesNotifier extends Notifier<List<HistoryTitle>> {
  @override
  List<HistoryTitle> build() {
    return [];
  }

  Future<void> onLoad() async {
    final historyTitles = await ref.read(historyRepositoryProvider).findTitles();
    state = [...historyTitles];
  }

  Future<void> setHistory(HistoryTitle historyTitle) async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    final history = await ref.read(historyRepositoryProvider).find(historyTitle.id);
    await ref.read(currentHistoryProvider.notifier).currentSet(history);
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    ref.invalidate(recordFilesProvider);
    ref.invalidate(summaryProvider);
    ref.read(currentHistoryProvider.notifier).state = null;
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }

  ///
  /// 録音データを保存する
  ///
  Future<void> addRecordFile(RecordFile recordFile) async {
    final currentHistory = ref.read(currentHistoryProvider);
    if (currentHistory == null) {
      ref.read(currentHistoryProvider.notifier).addRecord(recordFile);
      // 履歴を選択していない＝録音データが新規の場合は一覧をロードする
      await onLoad();
    } else {
      ref.read(currentHistoryProvider.notifier).addRecord(recordFile);
    }
  }

  ///
  /// 履歴情報にサマリーデータを追加
  ///
  Future<void> addSummaryTextResult(SummaryTextResult result) async {
    await ref.read(currentHistoryProvider.notifier).addSummary(result);
  }
}

final historyNowLoadingProvider = StateProvider<bool>((_) => false);
