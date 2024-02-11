import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/app_setting_provider.dart';

class AppSettingPage extends StatelessWidget {
  const AppSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('音声ファイルの一時出力パス(定期的にファイルを削除することをオススメします)'),
            const SizedBox(height: 8),
            _ViewCacheDirPath(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ViewCacheDirPath extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(appSettingNotifierProvider.select((value) => value.cacheDirPath));
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        counterText: '',
      ),
      style: const TextStyle(fontSize: 14),
      controller: TextEditingController(text: path),
      readOnly: true,
    );
  }
}
