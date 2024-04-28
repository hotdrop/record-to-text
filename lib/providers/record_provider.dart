import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/providers/record_items_provider.dart';
import 'package:recorod_to_text/providers/summary_controller_provider.dart';
import 'package:recorod_to_text/repository/record_repository.dart';

final currentRecordProvider = NotifierProvider<_CurrentRecordNotifier, Record?>(_CurrentRecordNotifier.new);

class _CurrentRecordNotifier extends Notifier<Record?> {
  @override
  Record? build() {
    return null;
  }

  Future<void> setCurrentRecord(Record record) async {
    // 取得した履歴をそれぞれ録音データとサマリーデータにセットする。サマリーはAsyncNotifierProviderなのでawaitつけている
    ref.read(recordItemsProvider.notifier).setItems(record.recordItems);
    await ref.read(summaryControllerProvider.notifier).setSummaryTextResult(record.summaryTextResult);
    state = record;
  }

  Future<void> setRecordItem(RecordItem recordItem) async {
    if (state == null) {
      final text = recordItem.speechToText ?? 'no data';
      state = await ref.read(recordRepositoryProvider).saveNew(
            title: text.substring(0, min(30, text.length)),
            recordItem: recordItem,
          );
    } else {
      // 既存録音データに追加
      state!.upsertRecoreFile(recordItem);
      await ref.read(recordRepositoryProvider).update(state!);
    }
  }

  Future<void> setSummaryTextResult(SummaryTextResult result) async {
    if (state != null) {
      final recordAddSummary = state!.copyWith(summaryTextResult: result);
      await ref.read(recordRepositoryProvider).update(recordAddSummary);
      state = recordAddSummary;
    }
  }
}

final recordsProvider = NotifierProvider<_RecordsNotifier, List<RecordOnlyTitle>>(_RecordsNotifier.new);

class _RecordsNotifier extends Notifier<List<RecordOnlyTitle>> {
  @override
  List<RecordOnlyTitle> build() {
    return [];
  }

  Future<void> onLoad() async {
    final recordOnlyTitles = await ref.read(recordRepositoryProvider).findTitles();
    state = [...recordOnlyTitles];
  }

  Future<void> selectRecord(RecordOnlyTitle recordOnlyTitle) async {
    ref.read(recordLoadingProvider.notifier).state = true;

    final targetRecord = await ref.read(recordRepositoryProvider).find(recordOnlyTitle.id);
    await ref.read(currentRecordProvider.notifier).setCurrentRecord(targetRecord);

    ref.read(recordLoadingProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.read(recordLoadingProvider.notifier).state = true;
    ref.invalidate(recordItemsProvider);
    ref.invalidate(summaryControllerProvider);
    ref.invalidate(selectRecordItemStateProvider);
    ref.read(currentRecordProvider.notifier).state = null;
    ref.read(recordLoadingProvider.notifier).state = false;
  }

  ///
  /// 録音データを保存する
  ///
  Future<void> addRecordItem(RecordItem recordItem) async {
    final currentRecord = ref.read(currentRecordProvider);
    if (currentRecord == null) {
      ref.read(currentRecordProvider.notifier).setRecordItem(recordItem);
      // 履歴を選択していない＝録音データが新規の場合は一覧をロードする
      await onLoad();
    } else {
      ref.read(currentRecordProvider.notifier).setRecordItem(recordItem);
    }
  }

  ///
  /// 履歴情報にサマリーデータを追加
  ///
  Future<void> addSummaryTextResult(SummaryTextResult result) async {
    await ref.read(currentRecordProvider.notifier).setSummaryTextResult(result);
  }
}

final recordLoadingProvider = StateProvider<bool>((_) => false);
