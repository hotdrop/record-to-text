import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/repository/sound_repository.dart';

final recordFilesProvider = NotifierProvider<RecordFilesNotifier, List<RecordFile>>(RecordFilesNotifier.new);

class RecordFilesNotifier extends Notifier<List<RecordFile>> {
  @override
  build() {
    return [];
  }

  void add({required String filePath, required int time}) {
    final id = _createIdFromPath(filePath);
    final newFile = RecordFile(id: id, filePath: filePath, recordTime: time);
    state = [newFile, ...state];
    // 非同期処理で文字起こしを行う
    Future<void>.delayed(Duration.zero).then((_) => _updateSpeechToText(newFile));
  }

  Future<void> _updateSpeechToText(RecordFile recordFile) async {
    try {
      final text = await ref.read(soundRepositoryProvider).speechToText(recordFile.filePath);
      final newRecordFile = recordFile.copyWith(
        speechToText: text,
        speechToTextState: RecordProcessStatus.success,
      );
      _update(newRecordFile);
    } catch (e) {
      final newRecordFile = recordFile.copyWith(
        speechToTextState: RecordProcessStatus.error,
        errorMessage: '$e',
      );
      _update(newRecordFile);
    }
  }

  void _update(RecordFile recordFile) {
    final idx = state.indexWhere((e) => e.id == recordFile.id);
    state = List.of(state)..[idx] = recordFile;
  }

  String _createIdFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final extentionIdx = fileName.lastIndexOf('.');
    return fileName.substring(0, extentionIdx);
  }

  void selectRow(RecordFile recordFile) {
    ref.read(selectRecordFileStateProvider.notifier).state = recordFile;
  }

  void clearSelectRow() {
    ref.read(selectRecordFileStateProvider.notifier).state = null;
  }
}

class RecordFile {
  const RecordFile({
    required this.id,
    required this.filePath,
    required this.recordTime,
    this.speechToText,
    this.speechToTextState = RecordProcessStatus.wait,
    this.summarizedState = RecordProcessStatus.wait,
    this.errorMessage,
  });

  final String id;
  final String filePath;
  final int recordTime;
  final String? speechToText;

  final RecordProcessStatus speechToTextState;
  final RecordProcessStatus summarizedState;
  final String? errorMessage;

  String fileName() => filePath.split('/').last;

  RecordFile copyWith({
    String? speechToText,
    RecordProcessStatus? speechToTextState,
    RecordProcessStatus? summarizedState,
    String? errorMessage,
  }) {
    return RecordFile(
      id: id,
      filePath: filePath,
      recordTime: recordTime,
      speechToText: speechToText ?? this.speechToText,
      speechToTextState: speechToTextState ?? this.speechToTextState,
      summarizedState: summarizedState ?? this.summarizedState,
    );
  }
}

enum RecordProcessStatus { wait, success, error }

// ホーム画面で選択したRecordFileを保持する
final selectRecordFileStateProvider = StateProvider<RecordFile?>((ref) => null);
