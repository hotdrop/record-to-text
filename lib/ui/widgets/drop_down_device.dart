import 'package:flutter/material.dart';
import 'package:record/record.dart';

class DropDownDevice extends StatelessWidget {
  const DropDownDevice({super.key, required this.selectDevice, required this.devices, required this.onChanged});

  final InputDevice? selectDevice;
  final List<InputDevice> devices;
  final Function(InputDevice? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: DropdownButton<InputDevice>(
        value: selectDevice ?? devices.first,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 8,
        underline: Container(color: Colors.transparent),
        onChanged: onChanged,
        items: devices.map<DropdownMenuItem<InputDevice>>((device) {
          return DropdownMenuItem<InputDevice>(
            value: device,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(device.label),
            ),
          );
        }).toList(),
      ),
    );
  }
}
