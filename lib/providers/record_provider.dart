import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/providers/record_items_provider.dart';
import 'package:recorod_to_text/providers/record_title_provider.dart';
import 'package:recorod_to_text/providers/summary_controller_provider.dart';
import 'package:recorod_to_text/repository/record_repository.dart';

final currentRecordProvider = NotifierProvider<_RecordNotifier, Record?>(_RecordNotifier.new);

class _RecordNotifier extends Notifier<Record?> {
  @override
  Record? build() {
    return null;
  }

  ///
  /// 録音データを選択状態にする
  ///
  Future<void> select(Record record) async {
    // 取得した履歴をそれぞれ録音データとサマリーデータにセットする。サマリーはAsyncNotifierProviderなのでawaitつけている
    ref.read(recordItemsProvider.notifier).setItems(record.recordItems);
    await ref.read(summaryControllerProvider.notifier).setSummaryTextResult(record.summaryTextResult);
    state = record;
  }

  ///
  /// 録音データを追加する
  ///
  Future<void> setRecordItem(RecordItem recordItem) async {
    if (state == null) {
      final text = recordItem.speechToText ?? 'no data';
      state = await ref.read(recordRepositoryProvider).saveNewRecord(
            title: text.substring(0, min(30, text.length)),
            recordItem: recordItem,
          );
      // 新規登録時では録音データのタイトルがRepositoryに追加されているはずなのでタイトル一覧をロードする
      await ref.read(recordTitlesProvider.notifier).onLoad();
    } else {
      // 既存録音データに追加
      final updateRecord = state!.setRecoreItem(recordItem);
      await ref.read(recordRepositoryProvider).saveRecordItem(recordId: updateRecord.id, item: recordItem);
      state = updateRecord;
    }
  }

  ///
  /// サマリーデータを保存する
  ///
  Future<void> setSummaryTextResult(SummaryTextResult result) async {
    if (state != null) {
      final recordAddSummary = state!.copyWith(summaryTextResult: result);
      await ref.read(recordRepositoryProvider).saveSummary(recordId: state!.id, summaryTextResult: result);
      state = recordAddSummary;
    }
  }
}
