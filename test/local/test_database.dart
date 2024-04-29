import 'dart:io';

import 'package:recorod_to_text/repository/local/app_database.dart';

class TestAppDatabase extends AppDatabase {
  const TestAppDatabase();

  @override
  Future<String> getDirectoryPath() async {
    final dir = await Directory.systemTemp.createTemp();
    return dir.path;
  }
}
