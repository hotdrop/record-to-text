import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  const RetryButton({super.key, required this.onPressed});

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
