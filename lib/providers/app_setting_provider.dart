import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:recorod_to_text/models/app_setting.dart';
import 'package:recorod_to_text/repository/app_setting_repository.dart';

final appSettingProvider = NotifierProvider<AppSettingNotifier, AppSetting>(AppSettingNotifier.new);

class AppSettingNotifier extends Notifier<AppSetting> {
  @override
  AppSetting build() {
    return const AppSetting();
  }

  Future<void> refresh({
    required String cacheDirPath,
    int? recordIntervalMinutes,
    String? summaryPrompt,
    required String appName,
    required String appVersion,
    required ThemeMode themeMode,
  }) async {
    state = state.copyWith(
      cacheDirPath: cacheDirPath,
      recordIntervalMinutes: recordIntervalMinutes,
      summaryPrompt: summaryPrompt,
      appName: appName,
      appVersion: appVersion,
      themeMode: themeMode,
    );
  }

  void setApiKey(String value) {
    state = state.copyWith(apiKey: value);
  }

  void setRecordIntervalMinutes(int value) {
    ref.read(appSettingsRepositoryProvider).saveRecordIntervalMinutes(value);
    state = state.copyWith(recordIntervalMinutes: value);
  }

  void setRecordDevice(InputDevice device) {
    state = state.copyWith(inputDevice: device);
  }

  void setSummaryPrompt(String value) {
    ref.read(appSettingsRepositoryProvider).saveSummaryPrompt(value);
    state = state.copyWith(summaryPrompt: value);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await ref.read(appSettingsRepositoryProvider).changeThemeMode(isDarkMode);
    final mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: mode);
  }
}
