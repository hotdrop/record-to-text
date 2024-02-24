import 'package:flutter/material.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';

class RecordToTextView extends StatelessWidget {
  const RecordToTextView(this.recordFile, {super.key, this.onErrorRetryButton});

  final RecordFile? recordFile;
  final VoidCallback? onErrorRetryButton;

  @override
  Widget build(BuildContext context) {
    final record = recordFile;

    if (record == null) {
      return const _EmptyTextView();
    } else {
      return switch (record.status) {
        SpeechToTextStatus.success => Column(
            children: [
              _Header(textLength: record.speechToText!.length, execTimeStr: record.formatSpeechToTextExecTime()),
              const Divider(),
              _TextViewArea(record.speechToText!),
            ],
          ),
        SpeechToTextStatus.error => Column(
            children: [
              const _Header(textLength: 0),
              const Divider(),
              _RetryButton(onPressed: onErrorRetryButton),
              _TextViewArea(record.errorMessage ?? '不明なエラーです', textColor: Colors.red),
            ],
          ),
        SpeechToTextStatus.wait => const _LoadingTextView(),
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

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.autorenew_sharp, color: Colors.red),
        label: const Text('リトライする', style: TextStyle(color: Colors.red)),
      ),
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
