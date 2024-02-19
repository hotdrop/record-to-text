import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/repository/app_setting_repository.dart';

///
/// ここでアプリに必要な初期処理を行う
///
final appInitFutureProvider = FutureProvider((ref) async {
  final minutes = await ref.read(appSettingsRepositoryProvider).getRecordIntervalMinutes();
  final cacheDir = await getApplicationCacheDirectory();
  final packageInfo = await PackageInfo.fromPlatform();
  final isDarkMode = await ref.read(appSettingsRepositoryProvider).isDarkMode();

  await ref.read(appSettingProvider.notifier).refresh(
        cacheDirPath: cacheDir.path,
        recordIntervalMinutes: minutes,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      );
});
