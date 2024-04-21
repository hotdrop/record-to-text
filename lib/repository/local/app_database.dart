import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:recorod_to_text/common/app_logger.dart';
import 'package:recorod_to_text/repository/local/entity/record_entity.dart';

final databaseProvider = Provider((_) => const AppDatabase());

///
/// テストで使うためprivateスコープにはしない
///
class AppDatabase {
  const AppDatabase();

  static Isar? _instance;

  Isar get isar {
    if (_instance != null) {
      return _instance!;
    } else {
      throw StateError('Isarを初期化せずに使用しようとしました');
    }
  }

  Future<void> init() async {
    if (_instance != null && _instance!.isOpen) {
      AppLogger.d('すでにIsarを初期化しているので何もしません');
      return;
    }
    AppLogger.d('Isarを初期化します');
    final dirPath = await getDirectoryPath();
    _instance = await Isar.open(
      [RecordEntitySchema],
      directory: dirPath,
    );
  }

  ///
  /// テストでoverrideしてテンポラリディレクトリを使うためpublicスコープで定義する
  ///
  Future<String> getDirectoryPath() async {
    final dir = await path.getApplicationDocumentsDirectory();
    return dir.path;
  }
}
