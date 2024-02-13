import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_talk/providers/app_setting_provider.dart';
import 'package:realtime_talk/providers/record_files_provider.dart';
import 'package:realtime_talk/repository/gpt_repository.dart';

final summaryNotifierProvider = AsyncNotifierProvider<SummaryNotifier, RecordSummary>(SummaryNotifier.new);

class SummaryNotifier extends AsyncNotifier<RecordSummary> {
  @override
  Future<RecordSummary> build() async {
    final successRecordFiles = ref.watch(recordFilesProvider);
    final limitContextLength = ref.watch(appSettingNotifierProvider).limitContextLength;

    final List<String> targetIds = [];
    String addText = '';
    RecordSummary rs = state.value ?? const RecordSummary();

    for (var recordFile in successRecordFiles) {
      // 文字起こし中やエラーになったもの、 既にサマリー済のファイルは無視
      if (!recordFile.isSuccess() || rs.doSummaryIdMap.containsKey(recordFile.id)) {
        continue;
      }

      // 現在のサマリーと、追加しようとしているテキストの長さがContext長を超えないか確認する
      final textSpeech = recordFile.speechToText ?? '';
      if (canAddText(rs.summary.length, addText.length + textSpeech.length, limitContextLength)) {
        targetIds.add(recordFile.id);
        addText += textSpeech;
        continue;
      }

      // コンテキスト長がオーバーしたのでここまでをサマリー
      rs = await _processSummaryUpdate(rs, addText, targetIds);
      // 現在のファイルを次のサイクルの最初のターゲットにする
      addText = textSpeech;
      targetIds.add(recordFile.id);
    }

    // 最後の追加分をサマリーに含める
    if (addText.isNotEmpty) {
      rs = await _processSummaryUpdate(rs, addText, targetIds);
    }

    return rs;
  }

  bool canAddText(int currentCount, int textLength, int limit) {
    return (currentCount + textLength) <= limit;
  }

  Future<RecordSummary> _processSummaryUpdate(RecordSummary recordSummary, String addText, List<String> targetIds) async {
    // サマリー作成
    final newSummaryText = await ref.read(gptRepositoryProvider).request(currentSummary: recordSummary.summary, addText: addText);
    // サマリー作成した録音ファイルのidをサマリー済マークする
    final newDoSummaryIdMap = Map<String, bool>.from(recordSummary.doSummaryIdMap);
    for (var id in targetIds) {
      newDoSummaryIdMap[id] = true;
    }
    return RecordSummary(summary: newSummaryText, doSummaryIdMap: newDoSummaryIdMap);
  }
}

class RecordSummary {
  const RecordSummary({this.summary = '', Map<String, bool>? doSummaryIdMap}) : doSummaryIdMap = doSummaryIdMap ?? const {};

  final String summary;
  final Map<String, bool> doSummaryIdMap;

  RecordSummary copyWith({String? summary, Map<String, bool>? doSummaryIdMap}) {
    return RecordSummary(
      summary: summary ?? this.summary,
      doSummaryIdMap: doSummaryIdMap ?? this.doSummaryIdMap,
    );
  }

  // 新しいテキストを追加し、IDマップを更新する
  RecordSummary updateWithNewText(String addText, Iterable<String> targetIds) {
    final newSummary = summary + addText;
    final newDoSummaryIdMap = Map<String, bool>.from(doSummaryIdMap);
    for (var id in targetIds) {
      newDoSummaryIdMap[id] = true;
    }
    return RecordSummary(summary: newSummary, doSummaryIdMap: newDoSummaryIdMap);
  }
}
