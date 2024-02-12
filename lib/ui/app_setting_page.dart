import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/app_setting_provider.dart';

class AppSettingPage extends StatelessWidget {
  const AppSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _TextFieldApiKey(),
            SizedBox(height: 16),
            _TextFieldCacheDirPath(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TextFieldApiKey extends ConsumerWidget {
  const _TextFieldApiKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.key, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text('OpenAI API Keyを入力してください'),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 14),
            initialValue: ref.watch(appSettingNotifierProvider).apiKey,
            maxLength: 100,
            onChanged: (String? value) {
              if (value != null) {
                ref.read(appSettingNotifierProvider.notifier).setApiKey(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _TextFieldCacheDirPath extends ConsumerWidget {
  const _TextFieldCacheDirPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(appSettingNotifierProvider.select((value) => value.cacheDirPath));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('音声ファイルの一時出力パス'),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
          ),
          style: const TextStyle(fontSize: 14),
          controller: TextEditingController(text: path),
          readOnly: true,
        ),
        const Text('(※ 定期的にファイルを削除することをオススメします)', style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }
}
