import 'package:flutter/material.dart';

/// Horizontal bar showing a SHAP-like value. Positive values are green, negative are red.
class ShapBarWidget extends StatelessWidget {
  final String feature;
  final double value; // in percentage of impact, -100..100 roughly

  const ShapBarWidget({super.key, required this.feature, required this.value});

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final absVal = value.abs().clamp(0, 100);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(feature, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Align(
                alignment: positive
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  height: 28,
                  width:
                      MediaQuery.of(context).size.width * (absVal / 100) * 0.4,
                  decoration: BoxDecoration(
                    color: positive
                        ? const Color.fromRGBO(76, 175, 80, 0.85)
                        : const Color.fromRGBO(255, 82, 82, 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(value.toStringAsFixed(1), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
