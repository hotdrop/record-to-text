import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/models/record_title.dart';
import 'package:recorod_to_text/providers/record_controller_provider.dart';
import 'package:recorod_to_text/providers/record_title_provider.dart';
import 'package:recorod_to_text/providers/select_menu_provider.dart';
import 'package:recorod_to_text/ui/app_setting_contents.dart';
import 'package:recorod_to_text/ui/record_contents.dart';
import 'package:recorod_to_text/ui/widgets/row_record_title.dart';

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
            final isRecording = ref.read(nowRecordingProvider);
            if (isRecording) {
              return;
            }
            ref.read(recordTitlesProvider.notifier).clear();
            ref.read(selectMenuProvider.notifier).selectRecordMenu();
          },
        ),
        const Divider(),
        const _ListViewRecords(),
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
    final recordTitles = ref.watch(recordTitlesProvider);
    final nowRecording = ref.watch(nowRecordingProvider);

    return Expanded(
      child: ListView.builder(
        key: ValueKey(recordTitles.length),
        itemCount: recordTitles.length,
        itemBuilder: (context, index) => _RowRecordTitle(
          recordTitles[index],
          onTap: nowRecording
              ? null
              : () async {
                  await ref.read(recordTitlesProvider.notifier).select(recordTitles[index]);
                  ref.read(selectMenuProvider.notifier).selectRecordMenu();
                },
        ),
      ),
    );
  }
}

class _SelectMenu extends ConsumerWidget {
  const _SelectMenu({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowRecording = ref.watch(nowRecordingProvider);

    return InkWell(
      onTap: nowRecording ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: nowRecording ? Colors.grey : null)),
          ],
        ),
      ),
    );
  }
}

class _RowRecordTitle extends ConsumerWidget {
  const _RowRecordTitle(this.recordOnlyTitle, {required this.onTap});

  final RecordOnlyTitle recordOnlyTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectRecordTitleId = ref.watch(selectRecordTitleIdStateProvider);
    return Tooltip(
      message: recordOnlyTitle.title,
      child: RowRecordTitle(
        recordOnlyTitle: recordOnlyTitle,
        isSelected: selectRecordTitleId == recordOnlyTitle.id,
        onTap: onTap,
        onTitleEditted: (String newTitle) {
          ref.read(recordTitlesProvider.notifier).updateTitle(recordOnlyTitle: recordOnlyTitle, newTitle: newTitle);
        },
      ),
    );
  }
}
