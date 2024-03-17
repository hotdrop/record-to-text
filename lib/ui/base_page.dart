import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/history_provider.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/select_menu_provider.dart';
import 'package:recorod_to_text/ui/app_setting_contents.dart';
import 'package:recorod_to_text/ui/record_contents.dart';
import 'package:recorod_to_text/ui/widgets/row_history.dart';

class BasePage extends ConsumerWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectMenu = ref.watch(selectMenuProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const Expanded(flex: 2, child: _MenuList()),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 8,
              child: (selectMenu == 0) ? const RecordContents() : const AppSettingContents(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuList extends ConsumerWidget {
  const _MenuList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectMenu(
          icon: Icons.record_voice_over,
          label: 'Record',
          onTap: () {
            // 履歴が選択されている場合があるのでクリアする
            ref.read(historiesProvider.notifier).clear();
            ref.read(selectMenuProvider.notifier).selectRecord();
          },
        ),
        const Divider(),
        const _ListViewHistories(),
        const Spacer(),
        const Divider(),
        _SelectMenu(
          icon: Icons.settings,
          label: 'Setting',
          onTap: () => ref.read(selectMenuProvider.notifier).selectSetting(),
        ),
      ],
    );
  }
}

class _ListViewHistories extends ConsumerWidget {
  const _ListViewHistories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historiesProvider);
    final isRecording = ref.watch(isRecordingProvider);

    // TODO 履歴が多くなる可能性を考慮しページネーションや遅延ローディングを検討する
    return Expanded(
      child: ListView.builder(
        itemCount: histories.length,
        itemBuilder: (context, index) => RowHistory(
          histories[index],
          onTap: isRecording
              ? null
              : () async {
                  await ref.read(historiesProvider.notifier).setHistory(histories[index]);
                  ref.read(selectMenuProvider.notifier).selectRecord();
                },
        ),
      ),
    );
  }
}

class _SelectMenu extends StatelessWidget {
  const _SelectMenu({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
