import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/providers/app_init_provider.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/ui/base_menu.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appSettingProvider).isDarkMode;

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', '')],
      title: 'RecordToText',
      theme: isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: ref.watch(appInitFutureProvider).when(
            data: (_) => const BaseMenu(),
            error: (error, s) => _ViewOnLoading(errorMessage: '$error'),
            loading: () => const _ViewOnLoading(),
          ),
    );
  }
}

class _ViewOnLoading extends StatelessWidget {
  const _ViewOnLoading({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: errorMessage == null
            ? const CircularProgressIndicator()
            : Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
      ),
    );
  }
}
