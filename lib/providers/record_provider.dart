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
      state = await ref.read(recordRepositoryProvider).saveNewRecord(
            title: text.substring(0, min(30, text.length)),
            recordItem: recordItem,
          );
      // リストのタイトルしか持たないのでリストのロードが必要なのは新規登録時のみ
      await ref.read(recordTitlesProvider.notifier).onLoad();
    } else {
      // 既存録音データに追加
      final updateRecord = state!.setRecoreItem(recordItem);
      await ref.read(recordRepositoryProvider).saveRecordItem(recordId: updateRecord.id, item: recordItem);
      state = updateRecord;
    }
  }

  Future<void> setSummaryTextResult(SummaryTextResult result) async {
    if (state != null) {
      final recordAddSummary = state!.copyWith(summaryTextResult: result);
      await ref.read(recordRepositoryProvider).saveSummary(recordId: state!.id, summaryTextResult: result);
      state = recordAddSummary;
    }
  }
}

final recordTitlesProvider = NotifierProvider<_RecordTitlesNotifier, List<RecordOnlyTitle>>(_RecordTitlesNotifier.new);

class _RecordTitlesNotifier extends Notifier<List<RecordOnlyTitle>> {
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
    ref.invalidate(selectRecordItemStateProvider);
    ref.read(selectRecordTitleIdStateProvider.notifier).state = recordOnlyTitle.id;
    final targetRecord = await ref.read(recordRepositoryProvider).find(recordOnlyTitle.id);
    await ref.read(currentRecordProvider.notifier).setCurrentRecord(targetRecord);
    ref.read(recordLoadingProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.invalidate(selectRecordTitleIdStateProvider);
    ref.invalidate(currentRecordProvider);
    ref.invalidate(recordItemsProvider);
    ref.invalidate(summaryControllerProvider);
    ref.invalidate(selectRecordItemStateProvider);
  }

  ///
  /// 録音データを保存する
  /// TODO このメソッドが_RecordTitlesNotifierにあるのはおかしいので移動する
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
  /// TODO このメソッドが_RecordTitlesNotifierにあるのはおかしいので移動する
  ///
  Future<void> addSummaryTextResult(SummaryTextResult result) async {
    await ref.read(currentRecordProvider.notifier).setSummaryTextResult(result);
  }
}

final recordLoadingProvider = StateProvider<bool>((_) => false);

// 選択中の録音タイトルIDを保持する
final selectRecordTitleIdStateProvider = StateProvider<int>((_) => 0);
