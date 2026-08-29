import 'package:flutter/rendering.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:uuid/uuid.dart';

import '../core/themes/circuit_theme.dart';

class ComponentPainter extends BranchPainter {
  final ComponentModel componentModel;
  final Map<UuidValue, EndpointModel> endpoints;

  ComponentPainter({required this.componentModel, required this.endpoints})
    : super(
        branch: componentModel.branch,
        from: endpoints[componentModel.fromId]!.pos,
        to: endpoints[componentModel.toId]!.pos,
      );
}

class BranchPainter extends CustomPainter {
  final BranchModel branch;
  final Offset from;
  final Offset to;
  final CircuitTheme theme;
  BranchPainter({
    required this.branch,
    required this.from,
    required this.to,
    this.theme = const EditorCircuitTheme(),
  });
  @override
  void paint(Canvas canvas, Size size) async {
    final localBranch = branch;
    switch (localBranch) {
      case CurrentSource():
        _paintCurrentSource(canvas, size, from, to, localBranch, theme);
        break;
      case IdealDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
      case RealDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
      case Resistor():
        _paintResistor(canvas, size, from, to, localBranch, theme);
        break;
      case VoltageSource():
        _paintVoltageSource(canvas, size, from, to, localBranch, theme);
        break;
      case ZenerDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return (oldDelegate.branch != branch ||
        oldDelegate.from != from ||
        oldDelegate.to != to);
  }
}

Offset _direction(Offset from, Offset to) {
  return (to - from) / (to - from).distance;
}

Offset _normal(Offset from, Offset to) {
  final normal = Offset(from.dy - to.dy, to.dx - from.dx);
  return normal / normal.distance;
}

Offset _leadEndPosition({
  required Offset from,
  required Offset to,
  required Offset direction,
  required double componentRadius,
}) {
  return (to - from) / 2 - direction * componentRadius + from;
}

void _paintVoltageSource(
  Canvas canvas,
  Size size,
  Offset from,
  Offset to,
  VoltageSource voltageSource,
  CircuitTheme theme,
) {
  canvas.save();
  _paintLeads(canvas, size, from, to, theme.componentRadius);
  final radius = theme.componentRadius;
  canvas.drawCircle((to - from) / 2 + from, radius, circuitPaint);
  final direction = _direction(from, to);
  final normal = _normal(from, to);
  final centre = (from + to) / 2;
  // proportion of radius at which to place the + and -
  const placementProportion = 0.6;
  // proprtion of radius to offset the ends of each +/- from centre (in the normal direction)
  const widthProportion = 0.2;

  // The plus looks like it is closer to the edge of the circle even if it is
  // not, so we correct it to be closer to the centre. This makes it look more
  // balanced with the minus sign
  const plusVisualCorrection = 0.85;

  final directionOffset = direction * radius * placementProportion;
  final normalOffset = normal * radius * widthProportion;

  final minusLeft = centre - directionOffset - normalOffset;
  final minusRight = centre - directionOffset + normalOffset;
  canvas.drawLine(minusLeft, minusRight, circuitPaint);

  final plusDirectionOffset = directionOffset * plusVisualCorrection;

  final plusLeft = centre + plusDirectionOffset - normalOffset;
  final plusRight = centre + plusDirectionOffset + normalOffset;
  canvas.drawLine(plusLeft, plusRight, circuitPaint);

  final plusTop =
      centre + plusDirectionOffset + direction * radius * widthProportion;
  final plusBottom =
      centre + plusDirectionOffset - direction * radius * widthProportion;
  canvas.drawLine(plusTop, plusBottom, circuitPaint);

  canvas.restore();
}

void _paintLeads(
  Canvas canvas,
  Size size,
  Offset from,
  Offset to,
  double componentRadius,
) {
  final direction = _direction(from, to);
  canvas.drawLine(
    from,
    _leadEndPosition(
      from: from,
      to: to,
      direction: direction,
      componentRadius: componentRadius,
    ),
    circuitPaint,
  );
  canvas.drawLine(
    to,
    _leadEndPosition(
      from: to,
      to: from,
      direction: -direction,
      componentRadius: componentRadius,
    ),
    circuitPaint,
  );
}

void _paintCurrentSource(
  Canvas canvas,
  Size size,
  Offset from,
  Offset to,
  CurrentSource currentSource,
  CircuitTheme theme,
) {
  canvas.save();
  _paintLeads(canvas, size, from, to, theme.componentRadius);
  final radius = theme.componentRadius;
  const arrowProportion = 0.8;
  const arrowheadLengthProportion = 0.5;
  const arrowheadWidthProportion = 0.4;

  canvas.drawCircle((to - from) / 2 + from, radius, circuitPaint);

  final centre = (to + from) / 2;
  final direction = _direction(to, from);
  final tip = centre + direction * arrowProportion * radius;

  final headLength = arrowheadLengthProportion * radius;
  canvas.drawLine(
    centre - direction * arrowProportion * radius,
    // Finish line at start of arrowhead. This avoids drawing a wide line at the
    // tip of the triangle
    tip - direction * headLength,
    circuitPaint,
  );

  final normal = _normal(from, to);
  final left =
      tip -
      direction * headLength +
      normal * headLength * arrowheadWidthProportion;
  final right =
      tip -
      direction * headLength -
      normal * headLength * arrowheadWidthProportion;

  final head = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(left.dx, left.dy)
    ..lineTo(right.dx, right.dy)
    ..close();
  canvas.drawPath(head, fillPaint);
  canvas.restore();
}

void _paintResistor(
  Canvas canvas,
  Size size,
  Offset from,
  Offset to,
  Resistor resistor,
  CircuitTheme theme,
) {
  canvas.save();
  final path = Path();

  path.moveTo(from.dx, from.dy);
  final direction = _direction(from, to);
  final normal = _normal(from, to);

  final leadEnd = _leadEndPosition(
    from: from,
    to: to,
    direction: direction,
    componentRadius: theme.resistorParallelSize / 2,
  );
  path.lineTo(leadEnd.dx, leadEnd.dy);

  final segmentLength = theme.resistorParallelSize / theme.resistorSteps;
  for (int i = 0; i < theme.resistorSteps; i++) {
    // final double d = i.toDouble();
    final firstVertex =
        normal * theme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + segmentLength / 4);
    // On line through centre of resistor
    final secondVertex =
        leadEnd + direction * (i * segmentLength + 2 * segmentLength / 4);

    final thirdVertex =
        -normal * theme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + 3 * segmentLength / 4);
    final fourthVertex = leadEnd + direction * ((i + 1) * segmentLength);

    path.lineTo(firstVertex.dx, firstVertex.dy);
    path.lineTo(secondVertex.dx, secondVertex.dy);
    path.lineTo(thirdVertex.dx, thirdVertex.dy);
    path.lineTo(fourthVertex.dx, fourthVertex.dy);
  }

  path.lineTo(to.dx, to.dy);
  canvas.drawPath(path, circuitPaint);
  canvas.restore();
}
