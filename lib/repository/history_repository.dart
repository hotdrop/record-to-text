import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';

final historyRepositoryProvider = Provider((ref) => _HistoryRepoistory(ref));

class _HistoryRepoistory {
  const _HistoryRepoistory(this.ref);

  final Ref ref;

  Future<List<History>> findAll() async {
    // TODO ローカルストレージを使う予定
    await Future<void>.delayed(const Duration(seconds: 2));
    // ダミーデータ
    return [
      const History(
        id: 1,
        title: '2024010203985',
        recordFiles: [
          RecordFile(id: '1', filePath: 'test', recordTime: 60, speechToText: 'おはようございます', speechToTextExecTime: 12, status: RecordToTextStatus.success),
          RecordFile(id: '2', filePath: 'test', recordTime: 60, speechToText: 'これは', speechToTextExecTime: 15, status: RecordToTextStatus.success),
          RecordFile(id: '3', filePath: 'test', recordTime: 30, speechToText: 'テストです', speechToTextExecTime: 13, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('ここがサマリーです', 32),
      ),
      const History(
        id: 2,
        title: 'これはテストデータです。長いタイトルを指定します。',
        recordFiles: [
          RecordFile(id: '4', filePath: 'test', recordTime: 60, speechToText: '二つ目です', speechToTextExecTime: 15, status: RecordToTextStatus.success),
        ],
        summaryTextResult: null,
      ),
      const History(
        id: 3,
        title: 'タイトルのデフォルトは1つ目のRecordFileのidである日付にする予定',
        recordFiles: [
          RecordFile(id: '5', filePath: 'test', recordTime: 60, speechToText: 'アイウエオ', speechToTextExecTime: 15, status: RecordToTextStatus.success),
          RecordFile(id: '6', filePath: 'test', recordTime: 60, speechToText: 'かきくけこ', speechToTextExecTime: 15, status: RecordToTextStatus.success),
          RecordFile(id: '7', filePath: 'test', recordTime: 60, speechToText: 'さしすせそ', speechToTextExecTime: 15, status: RecordToTextStatus.success),
          RecordFile(id: '8', filePath: 'test', recordTime: 60, speechToText: 'タチツテト', speechToTextExecTime: 15, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('サマリー3です', 25),
      ),
      const History(
        id: 4,
        title: '履歴4',
        recordFiles: [
          RecordFile(id: '5', filePath: 'test', recordTime: 60, speechToText: 'アイウエオ', speechToTextExecTime: 15, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('サマリー作成は結構時間かかる', 25),
      ),
    ];
  }
}
