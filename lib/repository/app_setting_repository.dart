import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recorod_to_text/repository/local/shared_prefs.dart';

final appSettingsRepositoryProvider = Provider((ref) => _AppSettingRepository(ref));

class _AppSettingRepository {
  _AppSettingRepository(this._ref);

  final Ref _ref;

  Future<int?> getRecordIntervalMinutes() async {
    return await _ref.read(sharedPrefsProvider).getRecordIntervalMinutes();
  }

  Future<void> saveRecordIntervalMinutes(int value) async {
    await _ref.read(sharedPrefsProvider).saveRecordIntervalMinutes(value);
  }
}
