import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record_title.dart';
import 'package:recorod_to_text/providers/record_items_provider.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/summary_controller_provider.dart';
import 'package:recorod_to_text/repository/record_repository.dart';

final recordTitlesProvider = NotifierProvider<_RecordTitlesNotifier, List<RecordOnlyTitle>>(_RecordTitlesNotifier.new);

class _RecordTitlesNotifier extends Notifier<List<RecordOnlyTitle>> {
  @override
  List<RecordOnlyTitle> build() {
    return [];
  }

  Future<void> onLoad() async {
    final recordOnlyTitles = await ref.read(recordRepositoryProvider).findTitles();
    state = [...recordOnlyTitles];
  }

  Future<void> select(RecordOnlyTitle recordOnlyTitle) async {
    // ごちゃごちゃしているので処理をそのまま日本語コメントにしています。
    // UIをローディング状態にする
    ref.read(recordDataLoadingStateProvider.notifier).state = true;
    // 詳細録音データの選択状態をクリアし、タイトルを選択状態にする
    ref.invalidate(selectRecordItemStateProvider);
    ref.read(selectRecordTitleIdStateProvider.notifier).state = recordOnlyTitle.id;
    // データロード
    final targetRecord = await ref.read(recordRepositoryProvider).find(recordOnlyTitle.id);
    await ref.read(currentRecordProvider.notifier).select(targetRecord);
    // UIのローディング状態を戻す
    ref.read(recordDataLoadingStateProvider.notifier).state = false;
  }

  Future<void> clear() async {
    ref.invalidate(selectRecordTitleIdStateProvider);
    ref.invalidate(currentRecordProvider);
    ref.invalidate(recordItemsProvider);
    ref.invalidate(summaryControllerProvider);
    ref.invalidate(selectRecordItemStateProvider);
  }
}

// 録音タイトル選択時の録音データロード状態
final recordDataLoadingStateProvider = StateProvider<bool>((_) => false);

// 選択中の録音タイトルIDを保持する
final selectRecordTitleIdStateProvider = StateProvider<int>((_) => 0);
