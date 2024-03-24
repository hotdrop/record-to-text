import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/repository/history_repository.dart';

final historiesProvider = NotifierProvider<_HistoriesNotifier, List<History>>(_HistoriesNotifier.new);

class _HistoriesNotifier extends Notifier<List<History>> {
  @override
  List<History> build() {
    return [];
  }

  String? _selectedHistoryId;

  Future<void> onLoad() async {
    final histories = await ref.read(historyRepositoryProvider).findAll();
    state = [...histories];
  }

  Future<void> setHistory(History history) async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    ref.read(recordFilesProvider.notifier).setHistory(history.recordFiles);
    await ref.read(summaryProvider.notifier).setHistory(history.summaryTextResult);
    _selectedHistoryId = history.id;
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.read(historyNowLoadingProvider.notifier).state = true;
    ref.invalidate(recordFilesProvider);
    ref.invalidate(summaryProvider);
    _selectedHistoryId = null;
    ref.read(historyNowLoadingProvider.notifier).state = false;
  }

  ///
  /// 履歴に録音データを追加
  ///
  Future<void> addRecordFile(RecordFile recordFile) async {
    if (_selectedHistoryId == null) {
      final text = recordFile.speechToText ?? 'no data';
      final newHistory = History(
        id: History.createId(),
        title: text.substring(0, min(30, text.length)),
        recordFiles: [recordFile],
      );
      await ref.read(historyRepositoryProvider).save(newHistory);
      _selectedHistoryId = newHistory.id;
      state = [newHistory, ...state];
      return;
    }

    // 既存録音データに追加
    final idx = state.indexWhere((e) => e.id == _selectedHistoryId);
    final newHistory = state[idx].upsertRecoreFile(recordFile);

    await ref.read(historyRepositoryProvider).save(newHistory);

    state = List.of(state)..[idx] = newHistory;
  }

  ///
  /// 履歴情報にサマリーデータを追加
  ///
  Future<void> addSummaryTextResult(SummaryTextResult result) async {
    final idx = state.indexWhere((e) => e.id == _selectedHistoryId);
    final newHistory = state[idx].copyWith(summaryTextResult: result);

    await ref.read(historyRepositoryProvider).save(newHistory);

    state = List.of(state)..[idx] = newHistory;
  }
}

final historyNowLoadingProvider = StateProvider<bool>((_) => false);
