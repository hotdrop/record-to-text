import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/repository/gpt_repository.dart';

final summaryNotifierProvider = AsyncNotifierProvider<SummaryNotifier, String>(SummaryNotifier.new);

class SummaryNotifier extends AsyncNotifier<String> {
  @override
  FutureOr<String> build() async {
    final recordFiles = ref.watch(recordFilesProvider);
    if (recordFiles.any((r) => r.isWait())) {
      AppLogger.d('文字起こし中のデータが存在するためサマリー実行はしません');
      return state.value ?? '';
    }

    final successRecordFiles = recordFiles.where((r) => r.isSuccess());
    if (successRecordFiles.isEmpty) {
      return '';
    }
    final targetText = successRecordFiles.map((e) => e.speechToText ?? '').join('');
    return await ref.read(gptRepositoryProvider).requestSummary(targetText);
  }
}
