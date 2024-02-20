import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/providers/timer_provider.dart';
import 'package:recorod_to_text/ui/widgets/record_to_text_view.dart';
import 'package:recorod_to_text/ui/widgets/row_record_data.dart';
import 'package:recorod_to_text/ui/widgets/summary_text_view.dart';

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
            Expanded(child: _SummaryTextView()),
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
    final color = isRunning ? Colors.redAccent : Colors.green;

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
    final apiKey = ref.watch(appSettingProvider.select((value) => value.apiKey));

    if (apiKey.isEmpty) {
      return const Text(
        'Settingメニューを開きApiKeyを設定してください。',
        style: TextStyle(color: Colors.red),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: !isRecording ? () => ref.read(recordProvider.notifier).start() : null,
          label: const Text('録音開始'),
          icon: const Icon(Icons.fiber_manual_record_rounded),
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
    final isDarkMode = ref.watch(appSettingProvider).isDarkMode;

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
            selectColor: isDarkMode ? const Color.fromARGB(255, 97, 97, 97) : const Color.fromARGB(255, 224, 224, 224),
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
      return const RecordToTextView('選択した行の文字起こしテキストをここに表示します');
    }

    return switch (selectFile.status) {
      SpeechToTextStatus.success => RecordToTextView(selectFile.speechToText!),
      SpeechToTextStatus.error => RecordToTextView(
          selectFile.errorMessage!,
          onErrorRetryButton: () async {
            await ref.read(recordFilesProvider.notifier).retry(file: selectFile);
          },
        ),
      SpeechToTextStatus.wait => const RecordToTextView('文字起こし処理中です。しばらくお待ちください'),
    };
  }
}

class _SummaryTextView extends ConsumerWidget {
  const _SummaryTextView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(summaryProvider).when(
          data: (text) => SummayTextView(
            text.isEmpty ? '録音データが追加されるたびにここにまとめテキストが作成されます。' : text,
          ),
          error: (e, s) => SummayTextView(
            'エラーが発生しました\n$e',
            onErrorRetryButton: () async {
              await ref.read(summaryProvider.notifier).retry();
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}
