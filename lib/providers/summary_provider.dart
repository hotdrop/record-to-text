import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/repository/record_repository.dart';

final summaryProvider = AsyncNotifierProvider<SummaryNotifier, SummaryTextResult?>(SummaryNotifier.new);

class SummaryNotifier extends AsyncNotifier<SummaryTextResult?> {
  @override
  FutureOr<SummaryTextResult?> build() async {
    final recordFiles = ref.watch(recordFilesProvider);

    // 文字起こし中のデータが存在する場合はサマリー実行しない
    if (recordFiles.any((r) => r.isWait())) {
      return state.value;
    }

    final successRecordFiles = recordFiles.where((r) => r.isSuccess());
    if (successRecordFiles.isEmpty) {
      return null;
    }
    final targetText = successRecordFiles.map((e) => e.speechToText ?? '').join('');
    return await ref.read(gptRepositoryProvider).requestSummary(targetText);
  }

  Future<void> retry() async {
    final recordFiles = ref.read(recordFilesProvider);

    // リトライの場合は成功している文字起こしデータが少なくとも1件はあるのでWait中のものがあるかだけチェックする
    if (recordFiles.any((r) => r.isWait())) {
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final successRecordFiles = recordFiles.where((r) => r.isSuccess());
      final targetText = successRecordFiles.map((e) => e.speechToText ?? '').join('');
      return await ref.read(gptRepositoryProvider).requestSummary(targetText);
    });
  }
}

class SummaryTextResult {
  const SummaryTextResult(this.text, this.executeTime);

  final String text;
  final int executeTime;
}
