import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/record_provider.dart';
import 'package:recorod_to_text/providers/record_controller_provider.dart';
import 'package:recorod_to_text/providers/select_menu_provider.dart';
import 'package:recorod_to_text/ui/app_setting_contents.dart';
import 'package:recorod_to_text/ui/record_contents.dart';
import 'package:recorod_to_text/ui/widgets/row_record.dart';

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
          label: 'New Record',
          onTap: () {
            // TODO 履歴が選択されている場合があるのでリストをクリアする。録音中はクリアしない。履歴機能ができたらこの分岐は不要
            final isRecording = ref.read(nowRecordingProvider);
            if (!isRecording) {
              ref.read(recordsProvider.notifier).clear();
            }
            ref.read(selectMenuProvider.notifier).selectRecordMenu();
          },
        ),
        const Divider(),
        const _ListViewRecords(),
        const Spacer(),
        const Divider(),
        _SelectMenu(
          icon: Icons.settings,
          label: 'Setting',
          onTap: () => ref.read(selectMenuProvider.notifier).selectSettingMenu(),
        ),
      ],
    );
  }
}

class _ListViewRecords extends ConsumerWidget {
  const _ListViewRecords();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordTitles = ref.watch(recordsProvider);
    final nowRecording = ref.watch(nowRecordingProvider);

    return Expanded(
      child: ListView.builder(
        itemCount: recordTitles.length,
        itemBuilder: (context, index) => RowRecord(
          recordTitles[index],
          onTap: nowRecording
              ? null
              : () async {
                  await ref.read(recordsProvider.notifier).selectRecord(recordTitles[index]);
                  ref.read(selectMenuProvider.notifier).selectRecordMenu();
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
