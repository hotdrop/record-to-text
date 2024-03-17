import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/select_menu_provider.dart';
import 'package:recorod_to_text/ui/app_setting_contents.dart';
import 'package:recorod_to_text/ui/record_contents.dart';

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
            const _ViewMenu(),
            const VerticalDivider(width: 1),
            Expanded(
              child: (selectMenu == 0) ? const RecordContents() : const AppSettingContents(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewMenu extends ConsumerWidget {
  const _ViewMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SelectMenu(
          icon: Icons.record_voice_over,
          label: 'Record',
          onTap: () => ref.read(selectMenuProvider.notifier).selectRecord(),
        ),
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
