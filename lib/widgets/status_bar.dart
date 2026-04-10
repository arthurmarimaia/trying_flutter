import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String label;
  final int value;

  const StatusBar({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        LinearProgressIndicator(value: value / 100),
        const SizedBox(height: 10),
      ],
    );
  }
}