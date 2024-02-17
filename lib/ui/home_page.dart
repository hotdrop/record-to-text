import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/providers/timer_provider.dart';
import 'package:recorod_to_text/ui/widgets/record_to_text_view.dart';
import 'package:recorod_to_text/ui/widgets/row_record_data.dart';

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
            VerticalDivider(width: 1),
            Expanded(child: _RecordSummaryLayout()),
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
    final apiKey = ref.watch(appSettingNotifierProvider.select((value) => value.apiKey));

    if (apiKey.isEmpty) {
      return const Text(
        'settingメニューからApiKeyを設定してください。',
        style: TextStyle(color: Colors.red),
      );
    }

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
    final selectFileId = ref.watch(selectRecordFileStateProvider)?.id ?? -1;
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recordFiles.length,
        itemBuilder: (context, index) {
          final currentFile = recordFiles[index];
          return RowRecordData(
            key: ValueKey(currentFile.id),
            recordFile: currentFile,
            isSelected: currentFile.id == selectFileId,
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

    if (selectFile == null) {
      return const RecordToTextView(fileName: '', message: '選択した行の文字起こしテキストをここに表示します');
    }

    return switch (selectFile.status) {
      SpeechToTextStatus.success => RecordToTextView(
          fileName: selectFile.fileName(),
          message: selectFile.speechToText!,
        ),
      SpeechToTextStatus.error => RecordToTextView(
          fileName: selectFile.fileName(),
          message: selectFile.errorMessage!,
          onErrorRetryButton: () async {
            await ref.read(recordFilesProvider.notifier).retry(file: selectFile);
          },
        ),
      SpeechToTextStatus.wait => RecordToTextView(
          fileName: selectFile.fileName(),
          message: '文字起こし処理中です。しばらくお待ちください',
        ),
    };
  }
}

class _RecordSummaryLayout extends StatelessWidget {
  const _RecordSummaryLayout();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('これまでの録音情報まとめ'),
          Divider(),
          Flexible(
            child: _SummaryTextView(),
          ),
        ],
      ),
    );
  }
}

class _SummaryTextView extends ConsumerWidget {
  const _SummaryTextView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(summaryNotifierProvider).when(
          data: (text) {
            if (text.isEmpty) {
              return const Text('録音データが追加されるたびにここにまとめテキストが作成されます。');
            }
            return SingleChildScrollView(
              child: SelectableText(text),
            );
          },
          error: (e, s) {
            return SingleChildScrollView(
              child: SelectableText('エラーが発生しました\n$e', style: const TextStyle(color: Colors.red)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}
