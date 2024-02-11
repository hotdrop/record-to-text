import 'package:flutter/material.dart';
import 'package:realtime_talk/ui/appsetting/app_setting_page.dart';
import 'package:realtime_talk/ui/home/home_page.dart';

class BaseMenu extends StatefulWidget {
  const BaseMenu({super.key});

  @override
  State<BaseMenu> createState() => _BaseMenuState();
}

class _BaseMenuState extends State<BaseMenu> {
  static const int _homeIndex = 0;
  static const int _appSettingIndex = 1;

  int _selectIndex = _homeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: destinations
                .map((e) => NavigationRailDestination(
                      icon: e.icon,
                      label: Text(e.title),
                    ))
                .toList(),
            selectedIndex: _selectIndex,
            onDestinationSelected: (index) {
              setState(() => _selectIndex = index);
            },
            labelType: NavigationRailLabelType.selected,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _menuView(_selectIndex)),
        ],
      ),
    );
  }

  List<Destination> get destinations => <Destination>[
        const Destination('Home', Icon(Icons.home)),
        const Destination('Setting', Icon(Icons.settings)),
      ];

  Widget _menuView(int index) {
    return switch (index) {
      _homeIndex => const HomePage(),
      _appSettingIndex => const AppSettingPage(),
      _ => throw Exception(['不正なIndexです index=$index']),
    };
  }
}

class Destination {
  const Destination(this.title, this.icon);

  final String title;
  final Widget icon;
}
