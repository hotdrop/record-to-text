import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/record_files_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  void build() {}

  void selectRow(RecordFile recordFile) {
    ref.read(selectRecordFileStateProvider.notifier).state = recordFile;
  }

  void clearSelectRow() {
    ref.read(selectRecordFileStateProvider.notifier).state = null;
  }
}

final selectRecordFileStateProvider = StateProvider<RecordFile?>((ref) => null);
