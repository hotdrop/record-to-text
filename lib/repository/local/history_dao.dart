import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/history.dart';
import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';

final historyDaoProvider = Provider((ref) => HistoryDao(ref));

class HistoryDao {
  const HistoryDao(this.ref);
  final Ref ref;

  Future<List<HistoryTitle>> findTitles() async {
    // TODO ローカルストレージで実装する
    await Future<void>.delayed(const Duration(seconds: 2));
    // ダミーデータ
    return [
      const HistoryTitle(id: '1', title: '履歴1です'),
      const HistoryTitle(id: '2', title: '履歴2です'),
      const HistoryTitle(id: '3', title: '履歴3です'),
    ];
  }

  Future<History> find(String historyId) async {
    // ダミーデータ
    await Future<void>.delayed(const Duration(seconds: 1));
    if (historyId == '1') {
      return const History(
        id: '1',
        title: '履歴1です',
        recordFiles: [
          RecordFile(id: '1', filePath: 'test', recordTime: 60, speechToText: '履歴その1です', speechToTextExecTime: 12, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('サマリー1です', 32),
      );
    } else if (historyId == '2') {
      return const History(
        id: '2',
        title: '履歴2です',
        recordFiles: [
          RecordFile(id: '1', filePath: 'test', recordTime: 60, speechToText: '履歴その2です', speechToTextExecTime: 12, status: RecordToTextStatus.success),
          RecordFile(id: '2', filePath: 'test', recordTime: 60, speechToText: '2つ目のレコード', speechToTextExecTime: 15, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('サマリーにです', 32),
      );
    } else {
      return const History(
        id: '3',
        title: '履歴3です',
        recordFiles: [
          RecordFile(id: '1', filePath: 'test', recordTime: 60, speechToText: '履歴その3です', speechToTextExecTime: 12, status: RecordToTextStatus.success),
          RecordFile(id: '2', filePath: 'test', recordTime: 60, speechToText: 'これは', speechToTextExecTime: 15, status: RecordToTextStatus.success),
          RecordFile(id: '3', filePath: 'test', recordTime: 30, speechToText: '3つ目のレコード', speechToTextExecTime: 13, status: RecordToTextStatus.success),
        ],
        summaryTextResult: SummaryTextResult('サマリーさんです', 32),
      );
    }
  }
}
