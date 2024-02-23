import 'package:flutter/material.dart';

class SummayTextView extends StatelessWidget {
  const SummayTextView(this.text, {super.key, this.onErrorRetryButton});

  final String? text;
  final VoidCallback? onErrorRetryButton;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = (onErrorRetryButton != null) ? const TextStyle(color: Colors.red) : null;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Text('これまでの録音情報まとめ', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          Text('文字数: ${text?.length ?? 0}', style: const TextStyle(color: Colors.green)),
          const Divider(),
          if (onErrorRetryButton != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: onErrorRetryButton,
                icon: const Icon(Icons.autorenew_sharp, color: Colors.red),
                label: const Text('リトライする', style: TextStyle(color: Colors.red)),
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              child: SelectableText(text ?? '録音データが追加されるたびにここにまとめテキストが作成されます。', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
