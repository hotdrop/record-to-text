import 'dart:io';
import 'dart:math';

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
    // return await ref.read(openAiApiProvider).speechToText(recordFile);
    await Future<void>.delayed(const Duration(seconds: 3));
    stopWatch.stop();

    // if (Random().nextBool()) {
    const text = '''
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
    return SpeechToTextResult(text, stopWatch.elapsedMilliseconds);
    // } else {
    //   throw const HttpException('エラーが発生しました。これはダミーの処理です再実行しましょう。');
    // }
  }

  Future<SummaryTextResult> requestSummary(String text) async {
    final stopWatch = Stopwatch()..start();
    // return await ref.read(openAiApiProvider).requestSummary(text);
    await Future<void>.delayed(const Duration(seconds: 3));
    stopWatch.stop();

    if (Random().nextBool()) {
      const text = '''
    これまでの録音データからサマリー作りました。\n
    録音中の時間経過によるサマリーはgpt-4-turboモデルを使い、録音終了後に高性能なサマリーを作りたい場合はgpt-4を使ったサマリーを作成します。\n
    これがうまくいくかは試してみないとわかりません。\n
    最初はContext長を制御しようと思いましたが、せいぜい30分〜1時間程度の想定なのでバグを作り込むリスクの方が高いと判断しContext長の制御はやめました\n
    ''';
      return SummaryTextResult(text, stopWatch.elapsedMilliseconds);
    } else {
      throw const HttpException('エラーが発生しました。これはダミーの処理です再実行しましょう。');
    }
  }
}
