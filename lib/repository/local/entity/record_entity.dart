import 'package:isar/isar.dart';

part 'record_entity.g.dart';

@collection
class RecordEntity {
  RecordEntity({
    required this.title,
    required this.createAt,
  });
  // finalをつけるとIDがInt64の最小値（マーカー値）になってしまうのでつけない
  // https://github.com/isar/isar/issues/1389
  Id id = Isar.autoIncrement;
  final String title;
  final DateTime createAt;
}
