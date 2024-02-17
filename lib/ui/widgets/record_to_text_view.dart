import 'package:flutter/material.dart';

class RecordToTextView extends StatelessWidget {
  const RecordToTextView({super.key, required this.fileName, required this.message, this.onErrorRetryButton});

  final String fileName;
  final String message;
  final VoidCallback? onErrorRetryButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('選択ファイル名: $fileName'),
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
                child: SelectableText(message),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
