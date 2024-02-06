import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/models/timer_provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Column(
        children: [
          // Row 「開始する」「停止する」
          _RecordButtons(),
          _ViewTimer(),
          // streamのファイル出力
        ],
      ),
    );
  }
}

class _RecordButtons extends ConsumerWidget {
  const _RecordButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text('Start Record'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text('Stop Record'),
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
    return Text('録音 ${timer} 秒');
  }
}
