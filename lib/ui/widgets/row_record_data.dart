import 'package:flutter/material.dart';
import 'package:recorod_to_text/models/record_file.dart';

class RowRecordData extends StatelessWidget {
  const RowRecordData({
    super.key,
    required this.recordFile,
    required this.isSelected,
    required this.selectColor,
    required this.onTap,
  });

  final RecordFile recordFile;
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
              Text(recordFile.fileName(), overflow: TextOverflow.ellipsis),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('録音:${recordFile.recordTime}秒'),
                  const SizedBox(width: 8),
                  _statusIcon(recordFile.status),
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
