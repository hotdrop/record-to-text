import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/ui/widgets/drop_down_record_interval.dart';

class AppSettingPage extends StatelessWidget {
  const AppSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TextFieldApiKey(),
            SizedBox(height: 16),
            _DropdownRecordIntervalMinutes(),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),
            _TextFieldCacheDirPath(),
            SizedBox(height: 16),
            _SwitchAppTheme(),
            SizedBox(height: 16),
            _ButtonLicense(),
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
    return TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.key, size: 28),
        border: OutlineInputBorder(),
        label: Text('OpenAI API Keyを入力してください'),
        counterText: '',
      ),
      style: const TextStyle(fontSize: 14),
      initialValue: ref.watch(appSettingProvider).apiKey,
      maxLength: 100,
      onChanged: (String? value) {
        if (value != null) {
          ref.read(appSettingProvider.notifier).setApiKey(value);
        }
      },
    );
  }
}

class _TextFieldCacheDirPath extends ConsumerWidget {
  const _TextFieldCacheDirPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(appSettingProvider.select((value) => value.cacheDirPath));
    return TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.folder_open, size: 28),
        border: OutlineInputBorder(),
        counterText: '',
        label: Text('音声ファイルの一時出力パス'),
        errorText: '※ 定期的にこのフォルダの一時ファイルを削除することをオススメします',
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: const TextStyle(fontSize: 14),
      controller: TextEditingController(text: path),
      readOnly: true,
    );
  }
}

class _DropdownRecordIntervalMinutes extends ConsumerWidget {
  const _DropdownRecordIntervalMinutes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Text('録音のデータ化間隔: '),
        const SizedBox(width: 8),
        DropDownRecordInterval(
          value: ref.watch(appSettingProvider).recordIntervalMinutes,
          onChanged: (int? selectValue) {
            if (selectValue != null) {
              ref.read(appSettingProvider.notifier).setRecordIntervalMinutes(selectValue);
            }
          },
        ),
      ],
    );
  }
}

///
/// アプリのテーマを変更するスイッチ
///
class _SwitchAppTheme extends ConsumerWidget {
  const _SwitchAppTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appSettingProvider).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 32),
          const SizedBox(width: 16),
          const Text('アプリのテーマ'),
          const SizedBox(width: 16),
          Switch(
            value: isDarkMode,
            onChanged: (isDark) async {
              await ref.read(appSettingProvider.notifier).setDarkMode(isDark);
            },
          ),
        ],
      ),
    );
  }
}

class _ButtonLicense extends ConsumerWidget {
  const _ButtonLicense();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        final appSetting = ref.read(appSettingProvider);
        showLicensePage(
          context: context,
          applicationName: appSetting.appName,
          applicationVersion: appSetting.appVersion,
          applicationIcon: Image.asset('assets/ic_launch.png'),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('ライセンスとアプリバージョン'),
      ),
    );
  }
}
