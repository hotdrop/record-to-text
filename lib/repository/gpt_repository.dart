import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_to_text_result.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';
import 'package:recorod_to_text/repository/remote/open_ai_api.dart';

final gptRepositoryProvider = Provider((ref) => GPTRepository(ref));

class GPTRepository {
  const GPTRepository(this.ref);

  final Ref ref;

  Future<RecordToTextResult> speechToText(RecordItem recordItem) async {
    final stopWatch = Stopwatch()..start();
    final text = await ref.read(openAiApiProvider).speechToText(recordItem);
    stopWatch.stop();
    return RecordToTextResult(text, stopWatch.elapsedMilliseconds);
  }

  Future<SummaryTextResult> requestSummary(String text) async {
    final stopWatch = Stopwatch()..start();
    final result = await ref.read(openAiApiProvider).requestSummary(text);
    stopWatch.stop();
    return SummaryTextResult(result, stopWatch.elapsedMilliseconds);
  }
}
