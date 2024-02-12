import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/record_provider.dart';
import 'package:realtime_talk/providers/record_files_provider.dart';
import 'package:realtime_talk/providers/timer_provider.dart';
import 'package:realtime_talk/ui/widgets/row_record_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: _RecordOperationLayout()),
            VerticalDivider(width: 1),
            Expanded(child: _RecordDetailLayout()),
          ],
        ),
      ),
    );
  }
}

class _RecordOperationLayout extends StatelessWidget {
  const _RecordOperationLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ViewTimer(),
        SizedBox(height: 16),
        _RecordButtons(),
        _ViewRecordList(),
      ],
    );
  }
}

class _ViewTimer extends ConsumerWidget {
  const _ViewTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final isRunning = ref.watch(isRecordingProvider);
    final color = isRunning ? Colors.red : Colors.green;

    return Column(
      children: [
        Text(isRunning ? '録音中' : '停止', style: TextStyle(color: color, fontSize: 36)),
        Text('録音時間: $timer 秒', style: TextStyle(color: color)),
      ],
    );
  }
}

class _RecordButtons extends ConsumerWidget {
  const _RecordButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(isRecordingProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: !isRecording ? () => ref.read(recordProvider.notifier).start() : null,
          label: const Text('録音開始'),
          icon: const Icon(Icons.play_arrow),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: isRecording ? () => ref.read(recordProvider.notifier).stop() : null,
          label: const Text('録音停止'),
          icon: const Icon(Icons.stop),
        ),
      ],
    );
  }
}

class _ViewRecordList extends ConsumerWidget {
  const _ViewRecordList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordFiles = ref.watch(recordFilesProvider);
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recordFiles.length,
        itemBuilder: (context, index) {
          final currentFile = recordFiles[index];
          return RowRecordData(
            key: ValueKey(currentFile.id),
            recordFile: currentFile,
            onTap: () {
              ref.read(recordFilesProvider.notifier).selectRow(currentFile);
            },
          );
        },
      ),
    );
  }
}

class _RecordDetailLayout extends ConsumerWidget {
  const _RecordDetailLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectFile = ref.watch(selectRecordFileStateProvider);

    String textValue;
    if (selectFile == null) {
      textValue = '選択した行の文字起こしテキストをここに表示します';
    } else {
      textValue = switch (selectFile.speechToTextStatus) {
        SpeechToTextStatus.success => selectFile.speechToText!,
        SpeechToTextStatus.error => selectFile.speechToTextProcessErrorMessage!,
        SpeechToTextStatus.wait => '文字起こし処理中です。しばらくお待ちください',
      };
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('選択ファイル名: ${selectFile?.fileName() ?? ''}'),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(textValue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
