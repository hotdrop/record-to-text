import 'package:flutter/material.dart';
import 'package:recorod_to_text/providers/record_files_provider.dart';

class RowRecordData extends StatelessWidget {
  const RowRecordData({super.key, required this.recordFile, required this.onTap});

  final RecordFile recordFile;
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

  Widget _statusIcon(SpeechToTextStatus status) {
    return switch (status) {
      SpeechToTextStatus.success => const Icon(Icons.check_circle, color: Colors.green),
      SpeechToTextStatus.error => const Icon(Icons.error, color: Colors.red),
      SpeechToTextStatus.wait => const Icon(Icons.hourglass_empty, color: Colors.amber),
    };
  }
}
