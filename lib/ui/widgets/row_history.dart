import 'package:flutter/material.dart';
import 'package:recorod_to_text/models/history.dart';

class RowHistory extends StatelessWidget {
  const RowHistory(this.historyTitle, {super.key, required this.onTap});

  final HistoryTitle historyTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: historyTitle.title,
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(
          historyTitle.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: (onTap != null) ? null : Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}
