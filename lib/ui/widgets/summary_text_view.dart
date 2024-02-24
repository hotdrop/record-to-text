import 'package:flutter/material.dart';
import 'package:recorod_to_text/common/int_extension.dart';
import 'package:recorod_to_text/providers/summary_provider.dart';
import 'package:recorod_to_text/ui/widgets/retry_button.dart';

class SummayTextView extends StatelessWidget {
  const SummayTextView(this.summary, {super.key});

  final SummaryTextResult? summary;

  @override
  Widget build(BuildContext context) {
    final textLength = summary?.text.length ?? 0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _Header(textLength: textLength, execTimeStr: summary?.executeTime.formatExecTime()),
          const Divider(),
          _TextViewArea(summary?.text ?? '録音データが追加されるたびにここにまとめテキストが作成されます。'),
        ],
      ),
    );
  }
}

class SummayLoadingView extends StatelessWidget {
  const SummayLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          _Header(textLength: 0),
          Divider(),
          Text('これまでの文字起こしテキストからサマリーを作成します'),
          SizedBox(height: 64),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class SummaryErrorTextView extends StatelessWidget {
  const SummaryErrorTextView({super.key, required this.errorMessage, required this.onPressed});

  final String errorMessage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const _Header(textLength: 0),
          const SizedBox(height: 8),
          const Divider(),
          RetryButton(onPressed: onPressed),
          _TextViewArea(errorMessage, textColor: Colors.red),
        ],
      ),
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
        const Text('これまでの録音情報まとめ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
