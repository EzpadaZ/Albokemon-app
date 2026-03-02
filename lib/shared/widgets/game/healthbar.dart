import 'package:flutter/material.dart';

Widget hpBar({
  required int current,
  required int max,
  double width = 72,
  double height = 6,
}) {
  final pct = max <= 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
  final color = pct > 0.55 ? Colors.green : (pct > 0.25 ? Colors.yellow : Colors.red);

  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(2),
      border: Border.all(color: Colors.black.withOpacity(0.55), width: 1),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: pct,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ),
  );
}