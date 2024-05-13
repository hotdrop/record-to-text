import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/record_items_provider.dart';
import 'package:recorod_to_text/providers/record_title_provider.dart';
import 'package:recorod_to_text/repository/gpt_repository.dart';

final summaryControllerProvider = AsyncNotifierProvider<SummaryControllerNotifier, SummaryTextResult?>(SummaryControllerNotifier.new);

class SummaryControllerNotifier extends AsyncNotifier<SummaryTextResult?> {
  @override
  FutureOr<SummaryTextResult?> build() async {
    final recordItems = ref.watch(recordItemsProvider);

    // 文字起こし中のデータが存在する場合はサマリー実行しない
    if (recordItems.any((r) => r.isWait())) {
      return state.value;
    }

    // タイトル選択時のロード中状態でもサマリーしない
    final isDataLoading = ref.read(recordDataLoadingStateProvider);
    if (isDataLoading) {
      return state.value;
    }

    // 全部エラーになっている場合はサマリーを実行するだけ無駄なのでリターン
    final successRecordItems = recordItems.where((r) => r.isSuccess());
    if (successRecordItems.isEmpty) {
      return null;
    }

    final targetText = successRecordItems.map((e) => e.speechToText ?? '').join('');
    final summaryResult = await ref.read(gptRepositoryProvider).requestSummary(targetText);
    ref.read(currentRecordProvider.notifier).setSummaryTextResult(summaryResult);
    return summaryResult;
  }

  Future<void> retry() async {
    final recordItems = ref.read(recordItemsProvider);

    // リトライの場合は成功している文字起こしデータが少なくとも1件はあるのでWait中のものがあるかだけチェックする
    if (recordItems.any((r) => r.isWait())) {
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final successRecordItems = recordItems.where((r) => r.isSuccess());
      final targetText = successRecordItems.map((e) => e.speechToText ?? '').join('');
      final summaryResult = await ref.read(gptRepositoryProvider).requestSummary(targetText);
      ref.read(currentRecordProvider.notifier).setSummaryTextResult(summaryResult);
      return summaryResult;
    });
  }

  Future<void> setSummaryTextResult(SummaryTextResult? result) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return (result != null) ? result : const SummaryTextResult('サマリーがありません。録音を開始してすぐ停止すればサマリーが再作成されます。', 0);
    });
  }
}
