import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundRepositoryProvider = Provider((ref) => SoundRepository(ref));

class SoundRepository {
  const SoundRepository(this.ref);

  final Ref ref;

  Future<String> speechToText(String filePath) async {
    // TOD whisperAPIで文字起こしする
    return "こんにちわ。私はテストHogeです。よろしくお願いします！";
  }

  Future<void> textToSpeech(String text) async {
    // TODO VOICE BOXなどでテキストを音声にする
  }
}
