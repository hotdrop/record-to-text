import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record_file.dart';
import 'package:recorod_to_text/repository/record_repository.dart';

final recordFilesProvider = NotifierProvider<RecordFilesNotifier, List<RecordFile>>(RecordFilesNotifier.new);

class RecordFilesNotifier extends Notifier<List<RecordFile>> {
  @override
  List<RecordFile> build() {
    return [];
  }

  void add({required String filePath, required int time}) {
    final id = _createIdFromPath(filePath);
    final newFile = RecordFile(id: id, filePath: filePath, recordTime: time);
    state = [newFile, ...state];
    Future<void>.delayed(Duration.zero).then((_) async {
      final updatedFile = await _executeToText(newFile);
      _update(updatedFile);
      final selectedFile = ref.read(selectRecordFileStateProvider);
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

  Future<void> retry({required RecordFile file}) async {
    final newFile = file.copyWith(status: RecordToTextStatus.wait);
    // リトライする場合、ステータスの変更前後の選択行を更新するので実行前後でselectRowを呼ぶ
    _update(newFile);
    selectRow(newFile);
    final updatedFile = await _executeToText(newFile);
    _update(updatedFile);
    selectRow(updatedFile);
  }

  Future<RecordFile> _executeToText(RecordFile recordFile) async {
    try {
      final result = await ref.read(gptRepositoryProvider).speechToText(recordFile);
      return recordFile.copyWith(
        speechToText: result.text,
        speechToTextExecTime: result.executeTime,
        status: RecordToTextStatus.success,
      );
    } catch (e) {
      return recordFile.copyWith(
        status: RecordToTextStatus.error,
        errorMessage: '$e',
      );
    }
  }

  void _update(RecordFile recordFile) {
    final idx = state.indexWhere((e) => e.id == recordFile.id);
    state = List.of(state)..[idx] = recordFile;
  }

  void selectRow(RecordFile recordFile) {
    ref.read(selectRecordFileStateProvider.notifier).state = recordFile;
  }

  void clearSelectRow() {
    ref.read(selectRecordFileStateProvider.notifier).state = null;
  }

  void setHistory(List<RecordFile> recordFiles) {
    state = [...recordFiles];
  }
}

// ホーム画面で選択したRecordFileを保持する
final selectRecordFileStateProvider = StateProvider<RecordFile?>((ref) => null);
