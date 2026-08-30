import 'package:flutter/rendering.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:uuid/uuid.dart';

import '../core/themes/circuit_theme.dart';

class ComponentPainter extends BranchPainter {
  final ComponentModel componentModel;
  final Map<UuidValue, EndpointModel> endpoints;

  ComponentPainter({
    required this.componentModel,
    required this.endpoints,
    super.scalingFactor,
  }) : super(
         branch: componentModel.branch,
         from: endpoints[componentModel.fromId]!.pos,
         to: endpoints[componentModel.toId]!.pos,
         theme: CircuitTheme.editor(),
       );
}

class BranchPainter extends CustomPainter {
  final BranchModel branch;
  final Offset from;
  final Offset to;
  final CircuitTheme theme;
  final double scalingFactor;

  BranchPainter({
    required this.branch,
    required this.from,
    required this.to,
    required this.theme,
    this.scalingFactor = 1.0,
  });
  @override
  void paint(Canvas canvas, Size size) async {
    final localBranch = branch;
    final globalFrom = from * scalingFactor;
    final globalTo = to * scalingFactor;
    final scaledTheme = theme.scale(scalingFactor);
    switch (localBranch) {
      case CurrentSource():
        _paintCurrentSource(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
      case IdealDiode():
        // TODO: draw the real ideal-diode symbol.
        _paintPlaceholder(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
      case RealDiode():
        // TODO: draw the real diode symbol.
        _paintPlaceholder(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
      case Resistor():
        _paintResistor(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
      case VoltageSource():
        _paintVoltageSource(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
      case ZenerDiode():
        // TODO: draw the real Zener-diode symbol.
        _paintPlaceholder(
          _BranchPaintParameters(
            canvas: canvas,
            size: size,
            globalFrom: globalFrom,
            globalTo: globalTo,
            branch: localBranch,
            theme: scaledTheme,
          ),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    final shouldRepaint =
        (oldDelegate.branch.kind != branch.kind ||
        oldDelegate.from != from ||
        oldDelegate.to != to);
    return shouldRepaint;
  }
}

class _BranchPaintParameters<T extends BranchModel> {
  final Canvas canvas;
  final Size size;
  final Offset globalFrom;
  final Offset globalTo;
  final T branch;
  final CircuitTheme theme;

  const _BranchPaintParameters({
    required this.canvas,
    required this.size,
    required this.globalFrom,
    required this.globalTo,
    required this.branch,
    required this.theme,
  });
}

Offset _direction({required Offset from, required Offset to}) {
  return (to - from) / (to - from).distance;
}

Offset _normal({required Offset from, required Offset to}) {
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

void _paintVoltageSource(_BranchPaintParameters<VoltageSource> parameters) {
  parameters.canvas.save();
  _paintLeads(parameters);
  final radius = parameters.theme.componentRadius;
  parameters.canvas.drawCircle(
    (parameters.globalTo - parameters.globalFrom) / 2 + parameters.globalFrom,
    radius,
    parameters.theme.circuitPaint,
  );
  final direction = _direction(
    from: parameters.globalFrom,
    to: parameters.globalTo,
  );
  final normal = _normal(from: parameters.globalFrom, to: parameters.globalTo);
  final centre = (parameters.globalFrom + parameters.globalTo) / 2;
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
  parameters.canvas.drawLine(
    minusLeft,
    minusRight,
    parameters.theme.circuitPaint,
  );

  final plusDirectionOffset = directionOffset * plusVisualCorrection;

  final plusLeft = centre + plusDirectionOffset - normalOffset;
  final plusRight = centre + plusDirectionOffset + normalOffset;
  parameters.canvas.drawLine(
    plusLeft,
    plusRight,
    parameters.theme.circuitPaint,
  );

  final plusTop =
      centre + plusDirectionOffset + direction * radius * widthProportion;
  final plusBottom =
      centre + plusDirectionOffset - direction * radius * widthProportion;
  parameters.canvas.drawLine(
    plusTop,
    plusBottom,
    parameters.theme.circuitPaint,
  );

  parameters.canvas.restore();
}

/// Draws leads plus a generic box for branch types that do not yet have a
/// dedicated symbol, so they still render instead of throwing.
void _paintPlaceholder(_BranchPaintParameters parameters) {
  parameters.canvas.save();
  _paintLeads(parameters);
  final centre = (parameters.globalFrom + parameters.globalTo) / 2;
  final side = parameters.theme.componentRadius * 1.6;
  parameters.canvas.drawRect(
    Rect.fromCenter(center: centre, width: side, height: side),
    parameters.theme.circuitPaint,
  );
  parameters.canvas.restore();
}

void _paintLeads(_BranchPaintParameters parameters) {
  final direction = _direction(
    from: parameters.globalFrom,
    to: parameters.globalTo,
  );
  parameters.canvas.drawLine(
    parameters.globalFrom,
    _leadEndPosition(
      from: parameters.globalFrom,
      to: parameters.globalTo,
      direction: direction,
      componentRadius: parameters.theme.componentRadius,
    ),
    parameters.theme.circuitPaint,
  );
  parameters.canvas.drawLine(
    parameters.globalTo,
    _leadEndPosition(
      from: parameters.globalTo,
      to: parameters.globalFrom,
      direction: -direction,
      componentRadius: parameters.theme.componentRadius,
    ),
    parameters.theme.circuitPaint,
  );
}

void _paintCurrentSource(_BranchPaintParameters<CurrentSource> parameters) {
  parameters.canvas.save();
  _paintLeads(parameters);
  final radius = parameters.theme.componentRadius;
  const arrowProportion = 0.8;
  const arrowheadLengthProportion = 0.5;
  const arrowheadWidthProportion = 0.4;

  parameters.canvas.drawCircle(
    (parameters.globalTo - parameters.globalFrom) / 2 + parameters.globalFrom,
    radius,
    parameters.theme.circuitPaint,
  );

  final centre = (parameters.globalTo + parameters.globalFrom) / 2;
  final direction = _direction(
    from: parameters.globalFrom,
    to: parameters.globalTo,
  );
  final tip = centre + direction * arrowProportion * radius;

  final headLength = arrowheadLengthProportion * radius;
  parameters.canvas.drawLine(
    centre - direction * arrowProportion * radius,
    // Finish line at start of arrowhead. This avoids drawing a wide line at the
    // tip of the triangle
    tip - direction * headLength,
    parameters.theme.circuitPaint,
  );

  final normal = _normal(from: parameters.globalFrom, to: parameters.globalTo);
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
  parameters.canvas.drawPath(head, fillPaint);
  parameters.canvas.restore();
}

void _paintResistor(_BranchPaintParameters<Resistor> parameters) {
  parameters.canvas.save();
  final path = Path();

  path.moveTo(parameters.globalFrom.dx, parameters.globalFrom.dy);
  final direction = _direction(
    from: parameters.globalFrom,
    to: parameters.globalTo,
  );
  final normal = _normal(from: parameters.globalFrom, to: parameters.globalTo);

  final leadEnd = _leadEndPosition(
    from: parameters.globalFrom,
    to: parameters.globalTo,
    direction: direction,
    componentRadius: parameters.theme.resistorParallelSize / 2,
  );
  path.lineTo(leadEnd.dx, leadEnd.dy);

  final segmentLength =
      parameters.theme.resistorParallelSize / parameters.theme.resistorSteps;
  for (int i = 0; i < parameters.theme.resistorSteps; i++) {
    // final double d = i.toDouble();
    final firstVertex =
        normal * parameters.theme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + segmentLength / 4);
    // On line through centre of resistor
    final secondVertex =
        leadEnd + direction * (i * segmentLength + 2 * segmentLength / 4);

    final thirdVertex =
        -normal * parameters.theme.resistorPerpendicularSize +
        leadEnd +
        direction * (i * segmentLength + 3 * segmentLength / 4);
    final fourthVertex = leadEnd + direction * ((i + 1) * segmentLength);

    path.lineTo(firstVertex.dx, firstVertex.dy);
    path.lineTo(secondVertex.dx, secondVertex.dy);
    path.lineTo(thirdVertex.dx, thirdVertex.dy);
    path.lineTo(fourthVertex.dx, fourthVertex.dy);
  }

  path.lineTo(parameters.globalTo.dx, parameters.globalTo.dy);
  parameters.canvas.drawPath(path, parameters.theme.circuitPaint);
  parameters.canvas.restore();
}
