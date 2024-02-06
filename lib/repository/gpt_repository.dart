import 'package:flutter_riverpod/flutter_riverpod.dart';

final gptRepositoryProvider = Provider((ref) => GPTRepository(ref));

class GPTRepository {
  const GPTRepository(this.ref);

  final Ref ref;

  Future<String> request(String text) async {
    // TODO GPT APIを実行する
    return "こんにちわ。私はずんだもんです。よろしくお願いします！";
  }
}
