import 'package:flutter/material.dart';
import 'package:recorod_to_text/models/record_item.dart';
import 'package:recorod_to_text/models/record_status_enum.dart';

class RowRecordData extends StatelessWidget {
  const RowRecordData({
    super.key,
    required this.recordItem,
    required this.isSelected,
    required this.selectColor,
    required this.onTap,
  });

  final RecordItem recordItem;
  final bool isSelected;
  final Color selectColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.0),
            color: (isSelected) ? selectColor : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recordItem.fileName(), overflow: TextOverflow.ellipsis),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('録音:${recordItem.recordTime}秒'),
                  const SizedBox(width: 8),
                  _statusIcon(recordItem.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(RecordToTextStatus status) {
    return switch (status) {
      RecordToTextStatus.success => const Icon(Icons.check_circle, color: Colors.green),
      RecordToTextStatus.error => const Icon(Icons.error, color: Colors.red),
      RecordToTextStatus.wait => const Icon(Icons.hourglass_empty, color: Colors.amber),
    };
  }
}
