import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'circuit_theme.mapper.dart';

enum VoltageSourceStyle { circle }

// abstract final class EditorCircuitTheme {
//   static const resistorPerpendicularSize = 20.0;
//   static const resistorSteps = 2;
//   static const resistorParallelSize = 30.0;
//   static const componentRadius = 20.0;
//   static const voltageSourceStyle = VoltageSourceStyle.circle;
// }

final fillPaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.0
  ..style = PaintingStyle.fill
  ..strokeCap = StrokeCap.round;

final circuitPaint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke
  ..isAntiAlias = true
  ..strokeCap = StrokeCap.round;

@MappableClass()
final class EditorCircuitTheme extends CircuitTheme
    with EditorCircuitThemeMappable {
  EditorCircuitTheme()
    : super(
        resistorPerpendicularSize: 20.0,
        resistorSteps: 2,
        resistorParallelSize: 30.0,
        componentRadius: 20.0,
        voltageSourceStyle: VoltageSourceStyle.circle,
        circuitPaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round,
        fillPaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round,
      );
}

@MappableClass()
final class IconCircuitTheme extends CircuitTheme
    with IconCircuitThemeMappable {
  IconCircuitTheme()
    : super(
        resistorPerpendicularSize: 8.0,
        resistorSteps: 2,
        resistorParallelSize: 12.0,
        componentRadius: 8.0,
        voltageSourceStyle: VoltageSourceStyle.circle,
        circuitPaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round,
        fillPaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round,
      );
}

@MappableClass()
class CircuitTheme with CircuitThemeMappable {
  final double resistorPerpendicularSize;
  final int resistorSteps;
  final double resistorParallelSize;
  final double componentRadius;
  final VoltageSourceStyle voltageSourceStyle;
  final Paint circuitPaint;
  final Paint fillPaint;

  @MappableConstructor()
  const CircuitTheme({
    required this.resistorPerpendicularSize,
    required this.resistorSteps,
    required this.resistorParallelSize,
    required this.componentRadius,
    required this.voltageSourceStyle,
    required this.circuitPaint,
    required this.fillPaint,
  });

  factory CircuitTheme.editor() = EditorCircuitTheme;
  factory CircuitTheme.icon() = IconCircuitTheme;

  CircuitTheme scale(double scalingFactor) {
    return CircuitTheme(
      resistorPerpendicularSize: resistorPerpendicularSize * scalingFactor,
      resistorSteps: resistorSteps,
      resistorParallelSize: resistorParallelSize * scalingFactor,
      componentRadius: componentRadius * scalingFactor,
      voltageSourceStyle: voltageSourceStyle,
      circuitPaint: Paint.from(circuitPaint)..strokeWidth *= scalingFactor,
      fillPaint: Paint.from(fillPaint)..strokeWidth *= scalingFactor,
    );
  }
}
