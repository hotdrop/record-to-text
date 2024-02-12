import 'package:flutter/material.dart';

class DropDownRecordInterval extends StatelessWidget {
  const DropDownRecordInterval({super.key, required this.value, required this.onChanged});

  final int value;
  final Function(int? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: DropdownButton<int>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 8,
        underline: Container(color: Colors.transparent),
        onChanged: onChanged,
        items: [1, 5, 10].map<DropdownMenuItem<int>>((m) {
          return DropdownMenuItem<int>(
            value: m,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$m分'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
