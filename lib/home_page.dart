import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/record_provider.dart';
import 'package:realtime_talk/providers/sound_files_provider.dart';
import 'package:realtime_talk/providers/timer_provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: const Column(
        children: [
          Divider(),
          _ViewTimer(),
          SizedBox(height: 16),
          _RecordButtons(),
          SizedBox(height: 16),
          _ViewRecordList(),
        ],
      ),
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

class _ViewRecordList extends ConsumerWidget {
  const _ViewRecordList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundFile = ref.watch(soundFilesProvider);
    return Flexible(
      child: ListView.builder(
        itemCount: soundFile.length,
        itemBuilder: (context, index) {
          return _RowSoundData(soundFile[index]);
        },
      ),
    );
  }
}

class _RowSoundData extends StatelessWidget {
  const _RowSoundData(this.soundFile);
  final SoundFile soundFile;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: soundFile.soundFilePath,
        child: Card(
          child: ListTile(
            title: Text(soundFile.fileName(), overflow: TextOverflow.ellipsis),
            subtitle: Text('録音時間: ${soundFile.recordTime}秒'),
          ),
        ),
      ),
    );
  }
}
