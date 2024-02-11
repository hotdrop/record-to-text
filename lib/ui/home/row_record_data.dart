import 'package:flutter/material.dart';
import 'package:realtime_talk/providers/record_files_provider.dart';

class RowRecordData extends StatelessWidget {
  const RowRecordData({super.key, required this.recordFile});

  final RecordFile recordFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recordFile.fileName(), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          FittedBox(
            child: Row(
              children: [
                Text('録音: ${recordFile.recordTime}秒'),
                const SizedBox(width: 8),
                _statusIcon(recordFile.statusSpeechToText()),
                const SizedBox(width: 8),
                _statusIcon(recordFile.statusSummarized()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(RecordProcessStatus status) {
    return switch (status) {
      RecordProcessStatus.success => const Icon(Icons.check_circle, color: Colors.green),
      RecordProcessStatus.error => const Icon(Icons.error, color: Colors.red),
      RecordProcessStatus.wait => const Icon(Icons.hourglass_empty, color: Colors.amber),
    };
  }
}
