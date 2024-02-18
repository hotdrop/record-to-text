import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider((ref) => _SharedPrefs(ref));
final _sharefPregerencesProvider = Provider((ref) async => await SharedPreferences.getInstance());

class _SharedPrefs {
  const _SharedPrefs(this._ref);

  final Ref _ref;

  ///
  /// 録音時間の間隔（分）
  ///
  Future<int?> getRecordIntervalMinutes() async => await _getInt('key001');
  Future<void> saveRecordIntervalMinutes(int value) async {
    await _saveInt('key001', value);
  }

  // 以下は型別のデータ格納/取得処理
  // Future<String?> _getString(String key) async {
  //   final prefs = await _ref.read(_sharefPregerencesProvider);
  //   return prefs.getString(key);
  // }

  // Future<void> _saveString(String key, String value) async {
  //   final prefs = await _ref.read(_sharefPregerencesProvider);
  //   prefs.setString(key, value);
  // }

  Future<int?> _getInt(String key) async {
    final prefs = await _ref.read(_sharefPregerencesProvider);
    return prefs.getInt(key);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await _ref.read(_sharefPregerencesProvider);
    prefs.setInt(key, value);
  }
}
