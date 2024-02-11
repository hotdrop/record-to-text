import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final appInitFutureProvider = FutureProvider((ref) async {
  // ここでアプリに必要な初期処理を行う
  final cacheDir = await getApplicationCacheDirectory();
  await ref.read(appSettingNotifierProvider.notifier).refresh(cacheDirPath: cacheDir.path);
});

final appSettingNotifierProvider = NotifierProvider<AppSettingNotifer, AppSettings>(AppSettingNotifer.new);

class AppSettingNotifer extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  Future<void> refresh({required String cacheDirPath}) async {
    state = state.copyWith(cacheDirPath: cacheDirPath);
  }
}

class AppSettings {
  const AppSettings({
    this.cacheDirPath = '',
    this.audioExtension = 'm4a',
    this.divideSoundMinutes = 1,
    this.audioChannel = 2,
  });

  // 一時出力する音声データファイルのディレクトリパス
  final String cacheDirPath;
  // 一時出力する音声データファイルの拡張子
  final String audioExtension;
  // 録音データの分割分数（1か5か10にする
  final int divideSoundMinutes;
  // オーディオ音源のチャネル。numChannelはデフォルト2
  final int audioChannel;

  // TODO フィラー除去のプロンプト
  // TODO 統合時のContext長

  String createSoundFilePath() {
    final dateFormat = DateFormat('yyyyMMddHHmmss');
    final fileName = '${dateFormat.format(DateTime.now())}.$audioExtension';
    return path.join(cacheDirPath, fileName);
  }

  AppSettings copyWith({String? cacheDirPath, String? audioExtension, int? divideSoundMinutes}) {
    return AppSettings(
      cacheDirPath: cacheDirPath ?? this.cacheDirPath,
      audioExtension: audioExtension ?? this.audioExtension,
      divideSoundMinutes: divideSoundMinutes ?? this.divideSoundMinutes,
    );
  }
}
