import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundRepositoryProvider = Provider((ref) => SoundRepository(ref));

class SoundRepository {
  const SoundRepository(this.ref);

  final Ref ref;

  Future<String> speechToText(String filePath) async {
    // TODO whisperAPIで文字起こしする
    await Future<void>.delayed(const Duration(seconds: 3));
    return "こんにちわ。私はテストHogeです。よろしくお願いします。\nここは文字起こしの結果を表示します。\n\nスクロール確認です。\n\nテキストがスクロール対応するか確認します。";
  }
}
