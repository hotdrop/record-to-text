import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

///
/// このFutureProviderでアプリに必要な初期処理を行う
///
final appInitFutureProvider = FutureProvider((ref) async {
  final cacheDir = await getApplicationCacheDirectory();
  // TODO 前回のアプリ設定情報を取得する
  await ref.read(appSettingNotifierProvider.notifier).refresh(cacheDirPath: cacheDir.path);
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

  void setDivideSoundMinutes(int value) {
    state = state.copyWith(divideSoundMinutes: value);
  }

  Future<void> refresh({
    String? apiKey,
    required String cacheDirPath,
    int? divideSoundMinutes,
  }) async {
    state = state.copyWith(apiKey: apiKey, cacheDirPath: cacheDirPath, divideSoundMinutes: divideSoundMinutes);
  }
}

class AppSettings {
  const AppSettings({
    this.apiKey = '',
    this.cacheDirPath = '',
    this.audioExtension = 'm4a', // 複数プラットフォーム対応する場合は拡張子を可変にする
    this.divideSoundMinutes = 1,
  });

  // OpenAI API Key
  final String apiKey;
  // 一時出力する音声データファイルのディレクトリパス
  final String cacheDirPath;
  // 一時出力する音声データファイルの拡張子
  final String audioExtension;
  // 録音データの分割分数（1か5か10にする
  final int divideSoundMinutes;

  // TODO フィラー除去のプロンプト
  // TODO 統合時のContext長

  String createSoundFilePath() {
    final dateFormat = DateFormat('yyyyMMddHHmmss');
    final fileName = '${dateFormat.format(DateTime.now())}.$audioExtension';
    return path.join(cacheDirPath, fileName);
  }

  AppSettings copyWith({String? apiKey, String? cacheDirPath, String? audioExtension, int? divideSoundMinutes}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      cacheDirPath: cacheDirPath ?? this.cacheDirPath,
      audioExtension: audioExtension ?? this.audioExtension,
      divideSoundMinutes: divideSoundMinutes ?? this.divideSoundMinutes,
    );
  }
}
