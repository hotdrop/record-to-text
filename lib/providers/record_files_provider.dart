import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:recorod_to_text/repository/gpt_repository.dart';

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
    Future<void>.delayed(Duration.zero).then((_) => _updateSpeechToText(newFile));
  }

  Future<void> _updateSpeechToText(RecordFile recordFile) async {
    try {
      final text = await ref.read(gptRepositoryProvider).speechToText(recordFile);
      final newRecordFile = recordFile.copyWith(
        speechToText: text,
        status: SpeechToTextStatus.success,
      );
      _update(newRecordFile);
    } catch (e) {
      final newRecordFile = recordFile.copyWith(
        status: SpeechToTextStatus.error,
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
    this.status = SpeechToTextStatus.wait,
    this.errorMessage,
  });

  final String id;
  final String filePath;
  final int recordTime;

  final String? speechToText;
  final SpeechToTextStatus status;
  final String? errorMessage;

  String fileName() => path.basename(filePath);

  bool isSuccess() => status == SpeechToTextStatus.success;
  bool isError() => status == SpeechToTextStatus.error;
  bool isWait() => status == SpeechToTextStatus.wait;

  RecordFile copyWith({
    String? speechToText,
    SpeechToTextStatus? status,
    String? errorMessage,
  }) {
    return RecordFile(
      id: id,
      filePath: filePath,
      recordTime: recordTime,
      speechToText: speechToText ?? this.speechToText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum SpeechToTextStatus { wait, success, error }

// ホーム画面で選択したRecordFileを保持する
final selectRecordFileStateProvider = StateProvider<RecordFile?>((ref) => null);
