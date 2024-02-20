import 'package:flutter/material.dart';

class RecordToTextView extends StatelessWidget {
  const RecordToTextView(this.text, {super.key, this.onErrorRetryButton});

  final String text;
  final VoidCallback? onErrorRetryButton;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = (onErrorRetryButton != null) ? const TextStyle(color: Colors.red) : null;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text('文字起こしテキスト', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
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
              child: SelectableText(text, style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
