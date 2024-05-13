import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/repository/gpt_repository.dart';

final recordItemsProvider = NotifierProvider<RecordItemsNotifier, List<RecordItem>>(RecordItemsNotifier.new);

class RecordItemsNotifier extends Notifier<List<RecordItem>> {
  @override
  List<RecordItem> build() {
    return [];
  }

  void add({required String filePath, required int time}) {
    final id = _createIdFromPath(filePath);
    final newFile = RecordItem(id: id, filePath: filePath, recordTime: time);
    state = [newFile, ...state];
    Future<void>.delayed(Duration.zero).then((_) async {
      final updatedFile = await _executeToText(newFile);
      _update(updatedFile);
      final selectedFile = ref.read(selectRecordItemStateProvider);
      if (selectedFile != null) {
        selectRow(updatedFile);
      }
    });
  }

  String _createIdFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final extentionIdx = fileName.lastIndexOf('.');
    return fileName.substring(0, extentionIdx);
  }

  Future<void> retry({required RecordItem file}) async {
    final newFile = file.copyWith(status: RecordToTextStatus.wait);
    // リトライする場合、ステータスの変更前後の選択行を更新するので実行前後でselectRowを呼ぶ
    _update(newFile);
    selectRow(newFile);
    final updatedFile = await _executeToText(newFile);
    _update(updatedFile);
    selectRow(updatedFile);
  }

  Future<RecordItem> _executeToText(RecordItem recordItem) async {
    try {
      final result = await ref.read(gptRepositoryProvider).speechToText(recordItem);
      final newRecordItem = recordItem.copyWith(
        speechToText: result.text,
        speechToTextExecTime: result.executeTime,
        status: RecordToTextStatus.success,
      );
      ref.read(recordTitlesProvider.notifier).addRecordItem(newRecordItem);
      return newRecordItem;
    } catch (e) {
      final newRecordItem = recordItem.copyWith(
        status: RecordToTextStatus.error,
        errorMessage: '$e',
      );
      ref.read(recordTitlesProvider.notifier).addRecordItem(newRecordItem);
      return newRecordItem;
    }
  }

  void _update(RecordItem recordItem) {
    final idx = state.indexWhere((e) => e.id == recordItem.id);
    state = List.of(state)..[idx] = recordItem;
  }

  void selectRow(RecordItem recordItem) {
    ref.read(selectRecordItemStateProvider.notifier).state = recordItem;
  }

  void clearSelectRow() {
    ref.read(selectRecordItemStateProvider.notifier).state = null;
  }

  void setItems(List<RecordItem> recordItems) {
    state = [...recordItems];
  }
}

// 選択中のRecordItemを保持する
final selectRecordItemStateProvider = StateProvider<RecordItem?>((ref) => null);
