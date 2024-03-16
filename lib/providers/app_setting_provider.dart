import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
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

class AppSetting {
  const AppSetting({
    this.apiKey = '',
    this.cacheDirPath = '',
    this.audioExtension = 'm4a', // 複数プラットフォーム対応する場合は拡張子を可変にする
    this.recordIntervalMinutes = 1,
    this.inputDevice,
    this.summaryPrompt = defaultSummaryPrompt,
    this.appName = '',
    this.appVersion = '',
    this.themeMode = ThemeMode.system,
  });

  // OpenAI API Key
  final String apiKey;
  // 一時出力する音声データファイルのディレクトリパス
  final String cacheDirPath;
  // 一時出力する音声データファイルの拡張子
  final String audioExtension;
  // 録音の間隔（分）
  final int recordIntervalMinutes;
  // 録音対象のデバイス
  final InputDevice? inputDevice;
  // サマリーのプロンプト
  final String summaryPrompt;
  // アプリ名
  final String appName;
  // アプリバージョン
  final String appVersion;
  // テーマモード
  final ThemeMode themeMode;

  static const String defaultSummaryPrompt = '次の文章は複数の音声録音からの文字起こしをつなげて作成されたものです。このテキストに含まれる主要な情報を要約してください:';

  String createSoundFilePath() {
    final dateFormat = DateFormat('yyyyMMddHHmmss');
    final fileName = '${dateFormat.format(DateTime.now())}.$audioExtension';
    return path.join(cacheDirPath, fileName);
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppSetting copyWith({
    String? apiKey,
    String? cacheDirPath,
    String? audioExtension,
    int? recordIntervalMinutes,
    InputDevice? inputDevice,
    String? summaryPrompt,
    String? appName,
    String? appVersion,
    ThemeMode? themeMode,
  }) {
    return AppSetting(
      apiKey: apiKey ?? this.apiKey,
      cacheDirPath: cacheDirPath ?? this.cacheDirPath,
      audioExtension: audioExtension ?? this.audioExtension,
      recordIntervalMinutes: recordIntervalMinutes ?? this.recordIntervalMinutes,
      inputDevice: inputDevice ?? this.inputDevice,
      summaryPrompt: summaryPrompt ?? this.summaryPrompt,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
