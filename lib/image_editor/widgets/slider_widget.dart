import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class SliderWidget extends StatelessWidget {
  SliderWidget(
    this.value, {
    required this.label,
    required this.onChanged,
    this.min = 0,
    this.max = 4,
    this.divisions = 40,
  }) : super(key: ValueKey(label));
  final num value, min, max;
  final String label;
  final int divisions;
  final Function(double) onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ).padding(top: 5),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            label: value.toString(),
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
