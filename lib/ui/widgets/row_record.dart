import 'package:flutter/material.dart';
import 'package:recorod_to_text/models/record.dart';

class RowRecord extends StatelessWidget {
  const RowRecord(this.recordOnlyTitle, {super.key, required this.onTap});

  final RecordOnlyTitle recordOnlyTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: recordOnlyTitle.title,
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(
          recordOnlyTitle.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: (onTap != null) ? null : Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}
