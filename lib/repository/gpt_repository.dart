import 'package:flutter_riverpod/flutter_riverpod.dart';

final gptRepositoryProvider = Provider((ref) => GPTRepository(ref));

class GPTRepository {
  const GPTRepository(this.ref);

  final Ref ref;

  Future<String> speechToText(String filePath) async {
    // TODO whisperAPIで文字起こしする
    await Future<void>.delayed(const Duration(seconds: 3));
    return '''
    こんにちわ。私はテストHogeです。よろしくお願いします。\n
    ここは文字起こしの結果を表示します。\n
    \n
    スクロール確認です。\n
    \n
    テキストがスクロール対応するか確認します。
    \n\n\n\n\n
    ここらへんまで改行すればスクロール確認できるかと思います。\n
    Whisperがどの程度の精度かまだ不明なのでフィラーを別途削除する必要があるのか、
    公式サイトのSpeech-to-textページの下の方にあるImproving reliabilityのようにした方がいいかは要検証となります。
    ''';
  }

  Future<String> requestSummary(String text) async {
    // TODO GPT APIを実行する
    await Future<void>.delayed(const Duration(seconds: 3));
    return '''
    これまでの録音データからサマリー作りました。\n
    サマリーはGPT4モデルのAPIを使う想定です。Context長を考慮し最初の録音データの文字起こしから順番に文字列結合してサマリーを作ります。\n
    これがうまくいくかは試してみないとわかりません。\n
    最初はContext長を制御しようと思いましたが、せいぜい30分〜1時間程度の想定なのでバグを作り込むリスクの方が高いと判断しContext長の制御はやめました\n
    ''';
  }
}
