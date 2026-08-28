import 'package:flutter/rendering.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:uuid/uuid.dart';

import '../core/themes/circuit_theme.dart';

class ComponentPainter extends CustomPainter {
  final ComponentModel componentModel;
  final Map<UuidValue, EndpointModel> endpoints;

  ComponentPainter({required this.componentModel, required this.endpoints});
  @override
  void paint(Canvas canvas, Size size) async {
    final branch = componentModel.branch;
    final from = endpoints[componentModel.fromId];
    if (from == null) {
      throw StateError("From endpoint ${componentModel.fromId} not found");
    }
    final to = endpoints[componentModel.toId];
    if (to == null) {
      throw StateError("To endpoint ${componentModel.toId} not found");
    }
    switch (branch) {
      case CurrentSource():
        _paintCurrentSource(canvas, size, from, to, branch);
        break;
      case IdealDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
      case RealDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
      case Resistor():
        _paintResistor(canvas, size, from, to, branch);
        break;
      case VoltageSource():
        _paintVoltageSource(canvas, size, from, to, branch);
        break;
      case ZenerDiode():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  bool shouldRepaint(covariant ComponentPainter oldDelegate) {
    return oldDelegate.componentModel != componentModel;
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
  double componentRadius = CircuitTheme.componentRadius,
}) {
  return (to - from) / 2 - direction * componentRadius + from;
}

void _paintVoltageSource(
  Canvas canvas,
  Size size,
  EndpointModel from,
  EndpointModel to,
  VoltageSource voltageSource,
) {
  canvas.save();
  _paintLeads(canvas, size, from.pos, to.pos);
  final radius = CircuitTheme.componentRadius;
  canvas.drawCircle((to.pos - from.pos) / 2 + from.pos, radius, circuitPaint);
  final direction = _direction(from.pos, to.pos);
  final normal = _normal(from.pos, to.pos);
  final centre = (from.pos + to.pos) / 2;
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
  Offset to, {
  double componentRadius = CircuitTheme.componentRadius,
}) {
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
  EndpointModel from,
  EndpointModel to,
  CurrentSource currentSource,
) {
  canvas.save();
  _paintLeads(canvas, size, from.pos, to.pos);
  final radius = CircuitTheme.componentRadius;
  const arrowProportion = 0.8;
  const arrowheadLengthProportion = 0.5;
  const arrowheadWidthProportion = 0.4;

  canvas.drawCircle((to.pos - from.pos) / 2 + from.pos, radius, circuitPaint);

  final centre = (to.pos + from.pos) / 2;
  final direction = _direction(to.pos, from.pos);
  final tip = centre + direction * arrowProportion * radius;

  final headLength = arrowheadLengthProportion * radius;
  canvas.drawLine(
    centre - direction * arrowProportion * radius,
    // Finish line at start of arrowhead. This avoids drawing a wide line at the
    // tip of the triangle
    tip - direction * headLength,
    circuitPaint,
  );

  final normal = _normal(from.pos, to.pos);
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
  EndpointModel from,
  EndpointModel to,
  Resistor resistor,
) {
  canvas.save();
  final path = Path();

  path.moveTo(from.pos.dx, from.pos.dy);
  final direction = _direction(from.pos, to.pos);
  final normal = _normal(from.pos, to.pos);

  final leadEnd = _leadEndPosition(
    from: from.pos,
    to: to.pos,
    direction: direction,
    componentRadius: CircuitTheme.resistorParallelSize / 2,
  );
  path.lineTo(leadEnd.dx, leadEnd.dy);

  final segmentLength =
      CircuitTheme.resistorParallelSize / CircuitTheme.resistorSteps;
  for (int i = 0; i < CircuitTheme.resistorSteps; i++) {
    // final double d = i.toDouble();
    final firstVertex =
        normal * CircuitTheme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + segmentLength / 4);
    // On line through centre of resistor
    final secondVertex =
        leadEnd + direction * (i * segmentLength + 2 * segmentLength / 4);

    final thirdVertex =
        -normal * CircuitTheme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + 3 * segmentLength / 4);
    final fourthVertex = leadEnd + direction * ((i + 1) * segmentLength);

    path.lineTo(firstVertex.dx, firstVertex.dy);
    path.lineTo(secondVertex.dx, secondVertex.dy);
    path.lineTo(thirdVertex.dx, thirdVertex.dy);
    path.lineTo(fourthVertex.dx, fourthVertex.dy);
  }

  path.lineTo(to.pos.dx, to.pos.dy);
  canvas.drawPath(path, circuitPaint);
  canvas.restore();
}
