import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/models/record_provider.dart';
import 'package:realtime_talk/models/timer_provider.dart';

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
          Divider(),
          _ViewPathList(),
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

    return Column(
      children: [
        Text(
          isRunning ? '録音中' : '停止',
          style: TextStyle(
            color: isRunning ? Colors.red : Colors.green,
            fontSize: 36,
          ),
        ),
        Text('録音 $timer 秒'),
      ],
    );
  }
}

class _ViewPathList extends ConsumerWidget {
  const _ViewPathList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paths = ref.watch(recordFilePathsProvider);
    return Flexible(
      child: ListView.builder(
        itemCount: paths.length,
        itemBuilder: (context, index) {
          return _RowPath(paths[index]);
        },
      ),
    );
  }
}

class _RowPath extends StatelessWidget {
  const _RowPath(this.path);
  final String path;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: path,
        child: Card(
          child: ListTile(
            title: Text(path.split('/').last, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
