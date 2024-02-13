import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:recorod_to_text/repository/app_setting_repository.dart';

///
/// このFutureProviderでアプリに必要な初期処理を行う
///
final appInitFutureProvider = FutureProvider((ref) async {
  final minutes = await ref.read(appSettingsRepositoryProvider).getRecordIntervalMinutes();
  final cacheDir = await getApplicationCacheDirectory();
  await ref.read(appSettingNotifierProvider.notifier).refresh(
        cacheDirPath: cacheDir.path,
        recordIntervalMinutes: minutes,
      );
});

///
/// アプリ設定情報を管理するNotifierProvider
///
final appSettingNotifierProvider = NotifierProvider<AppSettingNotifer, AppSettings>(AppSettingNotifer.new);

class AppSettingNotifer extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setApiKey(String value) {
    state = state.copyWith(apiKey: value);
  }

  void setRecordIntervalMinutes(int value) {
    ref.read(appSettingsRepositoryProvider).saveRecordIntervalMinutes(value);
    state = state.copyWith(recordIntervalMinutes: value);
  }

  Future<void> refresh({required String cacheDirPath, int? recordIntervalMinutes}) async {
    state = state.copyWith(cacheDirPath: cacheDirPath, recordIntervalMinutes: recordIntervalMinutes);
  }
}

class AppSettings {
  const AppSettings({
    this.apiKey = '',
    this.cacheDirPath = '',
    this.audioExtension = 'm4a', // 複数プラットフォーム対応する場合は拡張子を可変にする
    this.recordIntervalMinutes = 1,
  });

  // OpenAI API Key
  final String apiKey;
  // 一時出力する音声データファイルのディレクトリパス
  final String cacheDirPath;
  // 一時出力する音声データファイルの拡張子
  final String audioExtension;
  // 録音の間隔（分）
  final int recordIntervalMinutes;

  // TODO フィラー除去のプロンプト

  String createSoundFilePath() {
    final dateFormat = DateFormat('yyyyMMddHHmmss');
    final fileName = '${dateFormat.format(DateTime.now())}.$audioExtension';
    return path.join(cacheDirPath, fileName);
  }

  AppSettings copyWith({String? apiKey, String? cacheDirPath, String? audioExtension, int? recordIntervalMinutes}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      cacheDirPath: cacheDirPath ?? this.cacheDirPath,
      audioExtension: audioExtension ?? this.audioExtension,
      recordIntervalMinutes: recordIntervalMinutes ?? this.recordIntervalMinutes,
    );
  }
}
