import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/providers/timer_provider.dart';
import 'package:recorod_to_text/ui/widgets/record_to_text_view.dart';
import 'package:recorod_to_text/ui/widgets/row_record_data.dart';
import 'package:recorod_to_text/ui/widgets/summary_text_view.dart';

class RecordContents extends StatelessWidget {
  const RecordContents({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(flex: 2, child: _OperationView()),
            VerticalDivider(width: 1),
            Expanded(flex: 3, child: _RecordToTextView()),
            VerticalDivider(width: 1),
            Expanded(flex: 3, child: _SummaryTextView()),
          ],
        ),
      ),
    );
  }
}

class _OperationView extends StatelessWidget {
  const _OperationView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ViewTimer(),
        SizedBox(height: 16),
        _OperationButtons(),
        _ListRecords(),
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

class _OperationButtons extends ConsumerWidget {
  const _OperationButtons();

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

    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: !isRecording ? () => ref.read(recordProvider.notifier).start() : null,
          label: const Text('開始'),
          icon: Icon(Icons.fiber_manual_record_rounded, color: isRecording ? null : Colors.red),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: isRecording ? () => ref.read(recordProvider.notifier).stop() : null,
          label: const Text('停止'),
          icon: const Icon(Icons.stop),
        ),
      ],
    );
  }
}

class _ListRecords extends ConsumerWidget {
  const _ListRecords();

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

class _RecordToTextView extends ConsumerWidget {
  const _RecordToTextView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectFile = ref.watch(selectRecordFileStateProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RecordToTextView(
        selectFile,
        onErrorRetryButton: () async {
          await ref.read(recordFilesProvider.notifier).retry(file: selectFile!);
        },
      ),
    );
  }
}

class _SummaryTextView extends ConsumerWidget {
  const _SummaryTextView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(summaryProvider).when(
          data: (data) => SummayTextView(data),
          error: (e, s) => SummaryErrorTextView(
            errorMessage: 'エラーが発生しました\n$e',
            onPressed: () async {
              await ref.read(summaryProvider.notifier).retry();
            },
          ),
          loading: () => const SummayLoadingView(),
        );
  }
}
