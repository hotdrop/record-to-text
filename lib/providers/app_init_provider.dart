import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorod_to_text/providers/app_setting_provider.dart';
import 'package:recorod_to_text/providers/record_title_provider.dart';
import 'package:recorod_to_text/repository/app_setting_repository.dart';
import 'package:recorod_to_text/repository/local/app_database.dart';

///
/// ここでアプリに必要な初期処理を行う
///
final appInitFutureProvider = FutureProvider((ref) async {
  // ローカルストレージ初期化
  await ref.read(databaseProvider).init();

  // 録音データロード
  await ref.read(recordTitlesProvider.notifier).onLoad();

  // 設定系の値を取得
  final minutes = await ref.read(appSettingsRepositoryProvider).getRecordIntervalMinutes();
  final summaryPrompt = await ref.read(appSettingsRepositoryProvider).getSummaryPrompt();
  final cacheDir = await getApplicationCacheDirectory();
  final packageInfo = await PackageInfo.fromPlatform();
  final isDarkMode = await ref.read(appSettingsRepositoryProvider).isDarkMode();

  await ref.read(appSettingProvider.notifier).refresh(
        cacheDirPath: cacheDir.path,
        recordIntervalMinutes: minutes,
        summaryPrompt: summaryPrompt,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      );
});
