import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/summary_text_result.dart';

class RecordOnlyTitle {
  const RecordOnlyTitle({required this.id, required this.title, required this.createAt});
  final int id;
  final String title;
  final DateTime createAt;
}

class Record {
  const Record({
    required this.id,
    required this.title,
    required this.recordItems,
    this.summaryTextResult,
    required this.createAt,
  });

  final int id;
  final String title;
  final List<RecordItem> recordItems;
  final SummaryTextResult? summaryTextResult;
  final DateTime createAt;

  Record upsertRecoreFile(RecordItem newRecordItem) {
    final idx = recordItems.indexWhere((e) => e.id == newRecordItem.id);
    if (idx != -1) {
      return copyWith(recordItems: List.of(recordItems)..[idx] = newRecordItem);
    } else {
      return copyWith(recordItems: [newRecordItem, ...recordItems]);
    }
  }

  Record copyWith({
    String? title,
    List<RecordItem>? recordItems,
    SummaryTextResult? summaryTextResult,
  }) {
    return Record(
      id: id,
      title: title ?? this.title,
      recordItems: recordItems ?? this.recordItems,
      summaryTextResult: summaryTextResult ?? this.summaryTextResult,
      createAt: createAt,
    );
  }
}
