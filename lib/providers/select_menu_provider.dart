import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectMenuProvider = NotifierProvider<_SelectMenuNotifier, int>(_SelectMenuNotifier.new);

class _SelectMenuNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectRecordMenu() {
    state = 0;
  }

  void selectSettingMenu() {
    state = 1;
  }
}
