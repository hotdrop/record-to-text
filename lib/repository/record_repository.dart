import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/repository/remote/open_ai_api.dart';

final gptRepositoryProvider = Provider((ref) => GPTRepository(ref));

class GPTRepository {
  const GPTRepository(this.ref);

  final Ref ref;

  Future<SpeechToTextResult> speechToText(RecordFile recordFile) async {
    final stopWatch = Stopwatch()..start();
    final text = await ref.read(openAiApiProvider).speechToText(recordFile);
    stopWatch.stop();
    return SpeechToTextResult(text, stopWatch.elapsedMilliseconds);
  }

  Future<SummaryTextResult> requestSummary(String text) async {
    final stopWatch = Stopwatch()..start();
    final result = await ref.read(openAiApiProvider).requestSummary(text);
    stopWatch.stop();
    return SummaryTextResult(result, stopWatch.elapsedMilliseconds);
  }
}
