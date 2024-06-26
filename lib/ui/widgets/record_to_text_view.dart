import 'package:flutter/material.dart';
import 'package:recorod_to_text/common/int_extension.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';
import 'package:recorod_to_text/ui/widgets/retry_button.dart';

class RecordToTextView extends StatelessWidget {
  const RecordToTextView(this.recordItem, {super.key, this.onErrorRetryButton});

  final RecordItem? recordItem;
  final VoidCallback? onErrorRetryButton;

  @override
  Widget build(BuildContext context) {
    final lRecordItem = recordItem;

    if (lRecordItem == null) {
      return const _EmptyTextView();
    } else {
      return switch (lRecordItem.status) {
        RecordToTextStatus.success => Column(
            children: [
              _Header(textLength: lRecordItem.speechToText!.length, execTimeStr: lRecordItem.speechToTextExecTime.formatExecTime()),
              const Divider(),
              _TextViewArea(lRecordItem.speechToText!),
            ],
          ),
        RecordToTextStatus.error => Column(
            children: [
              const _Header(textLength: 0),
              const Divider(),
              RetryButton(onPressed: onErrorRetryButton),
              _TextViewArea(lRecordItem.errorMessage ?? '不明なエラーです', textColor: Colors.red),
            ],
          ),
        RecordToTextStatus.wait => const _LoadingTextView(),
      };
    }
  }
}

class _EmptyTextView extends StatelessWidget {
  const _EmptyTextView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('文字起こしテキスト', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 8),
        Text('選択した行の文字起こしテキストをここに表示します'),
      ],
    );
  }
}

class _LoadingTextView extends StatelessWidget {
  const _LoadingTextView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('文字起こしテキスト', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 8),
        Text('選択した行の文字起こしテキストをここに表示します'),
        SizedBox(height: 64),
        CircularProgressIndicator(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.textLength, this.execTimeStr});

  final int textLength;
  final String? execTimeStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('文字起こしテキスト', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (textLength > 0) Text('文字数: $textLength', style: const TextStyle(color: Colors.green)),
            if (execTimeStr != null) Text('実行時間: $execTimeStr', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ],
    );
  }
}

class _TextViewArea extends StatelessWidget {
  const _TextViewArea(this.text, {this.textColor});

  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: SelectableText(text, style: TextStyle(color: textColor)),
      ),
    );
  }
}
