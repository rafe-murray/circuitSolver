import 'package:flutter/material.dart';

enum VoltageSourceStyle { circle }

abstract final class CircuitTheme {
  static const resistorPerpendicularSize = 20.0;
  static const resistorSteps = 2;
  static const resistorParallelSize = 30.0;
  static const componentRadius = 20.0;
  static const voltageSourceStyle = VoltageSourceStyle.circle;
}

final fillPaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.0
  ..style = PaintingStyle.fill
  ..strokeCap = StrokeCap.round;

final circuitPaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;
