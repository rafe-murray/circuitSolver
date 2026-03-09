import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../viewmodels/canvas_viewmodel.dart';

// ---------------------------------------------------------------------------
// CircuitCanvas
// ---------------------------------------------------------------------------

/// The interactive circuit editing canvas.
///
/// Handles:
/// - Drop from [ComponentBank] (DragTarget<ComponentType>)
/// - Click to select / deselect
/// - Drag to move selected components
/// - Drag on empty space to rubber-band-select
/// - Renders grid, components, connections, selection highlight, and ghost
class CircuitCanvas extends StatefulWidget {
  const CircuitCanvas({super.key});

  @override
  State<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends State<CircuitCanvas> {
  // Tracks whether the current pointer-down started on a component (move) or
  // on empty space (rubber-band).
  _DragMode _dragMode = _DragMode.none;
  Offset _dragStart = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context);

    return DragTarget<ComponentType>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        // Convert global drop offset to local canvas coordinates.
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.offset);
        vm.dropFromBank(details.data, local);
      },
      builder: (context, candidateData, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (e) => _onTapUp(context, e, vm),
          onPanStart: (e) => _onPanStart(e, vm),
          onPanUpdate: (e) => _onPanUpdate(e, vm),
          onPanEnd: (e) => _onPanEnd(vm),
          child: CustomPaint(
            painter: _CanvasPainter(
              components: vm.components,
              connections: vm.connections,
              selectedIds: vm.selectedIds,
              selectionRect: vm.selectionRect,
              ghostType: vm.bankDragType,
              ghostPosition: vm.bankDragPosition,
              isDropCandidate: candidateData.isNotEmpty,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Gesture handlers
  // -------------------------------------------------------------------------

  void _onTapUp(BuildContext context, TapUpDetails e, CanvasViewModel vm) {
    final hit = vm.hitTest(e.localPosition);
    if (hit != null) {
      final additive = _isAdditiveModifier();
      vm.selectComponent(hit.id, additive: additive);
    } else {
      vm.clearSelection();
    }
  }

  void _onPanStart(DragStartDetails e, CanvasViewModel vm) {
    _dragStart = e.localPosition;
    final hit = vm.hitTest(e.localPosition);
    if (hit != null) {
      // If the hit component is not already selected, select it first.
      if (!vm.isSelected(hit.id)) {
        vm.selectComponent(hit.id);
      }
      _dragMode = _DragMode.move;
      vm.beginMove();
    } else {
      _dragMode = _DragMode.rubberBand;
      vm.startRubberBand(e.localPosition);
    }
  }

  void _onPanUpdate(DragUpdateDetails e, CanvasViewModel vm) {
    switch (_dragMode) {
      case _DragMode.move:
        final delta = e.localPosition - _dragStart;
        vm.updateMove(delta);
      case _DragMode.rubberBand:
        vm.updateRubberBand(e.localPosition);
      case _DragMode.none:
        break;
    }
  }

  void _onPanEnd(CanvasViewModel vm) {
    switch (_dragMode) {
      case _DragMode.move:
        vm.endMove();
      case _DragMode.rubberBand:
        vm.endRubberBand();
      case _DragMode.none:
        break;
    }
    _dragMode = _DragMode.none;
  }

  /// Returns true when a modifier key (Shift/Meta/Ctrl) is held.
  bool _isAdditiveModifier() =>
      HardwareKeyboard.instance.isShiftPressed ||
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isControlPressed;
}

enum _DragMode { none, move, rubberBand }

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.components,
    required this.connections,
    required this.selectedIds,
    required this.selectionRect,
    required this.ghostType,
    required this.ghostPosition,
    required this.isDropCandidate,
  });

  final List<CircuitComponent> components;
  final List<Connection> connections;
  final Set<int> selectedIds;
  final Rect? selectionRect;
  final ComponentType? ghostType;
  final Offset? ghostPosition;
  final bool isDropCandidate;

  // -- Paints ---------------------------------------------------------------

  static final _gridPaint = Paint()
    ..color = const Color(0x22000000)
    ..strokeWidth = 0.5;

  static final _wirePaint = Paint()
    ..color = Colors.black87
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  static final _connectionDotPaint = Paint()..color = Colors.black87;

  static final _selectionStrokePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  static final _selectionFillPaint = Paint()
    ..color = const Color(0x220000FF)
    ..style = PaintingStyle.fill;

  static final _rubberBandFillPaint = Paint()
    ..color = const Color(0x220055FF)
    ..style = PaintingStyle.fill;

  static final _rubberBandStrokePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  static final _endpointPaint = Paint()..color = Colors.black54;

  // -- Paint ----------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawConnections(canvas);
    _drawComponents(canvas);
    _drawGhost(canvas);
    _drawRubberBand(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    const g = kGridSize;
    for (double x = 0; x < size.width; x += g) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }
    for (double y = 0; y < size.height; y += g) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
  }

  void _drawConnections(Canvas canvas) {
    // Build a map of (componentId, endpointIndex) → absolute position.
    final epMap = <int, List<Offset>>{};
    for (final c in components) {
      epMap[c.id] = c.absoluteEndpoints;
    }
    // Draw a line for each connection.
    for (final conn in connections) {
      final a = epMap[conn.componentA]?[conn.endpointIndexA];
      final b = epMap[conn.componentB]?[conn.endpointIndexB];
      if (a != null && b != null) {
        canvas.drawLine(a, b, _wirePaint);
        canvas.drawCircle(a, 3, _connectionDotPaint);
      }
    }
  }

  void _drawComponents(Canvas canvas) {
    for (final comp in components) {
      final selected = selectedIds.contains(comp.id);
      _drawComponent(canvas, comp, selected: selected);
    }
  }

  void _drawComponent(
    Canvas canvas,
    CircuitComponent comp, {
    required bool selected,
  }) {
    canvas.save();
    canvas.translate(comp.position.dx, comp.position.dy);
    canvas.rotate(comp.rotation);

    if (selected) {
      // Draw a selection highlight box.
      const hs = kGridSize * 2.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: hs * 2, height: hs * 0.9),
          const Radius.circular(4),
        ),
        _selectionFillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: hs * 2, height: hs * 0.9),
          const Radius.circular(4),
        ),
        _selectionStrokePaint,
      );
    }

    // Draw the circuit symbol.
    _ComponentPainter.draw(canvas, comp.type);

    // Draw endpoints.
    final eps = comp.absoluteEndpoints;
    canvas.restore(); // restore before drawing endpoints in world coords
    for (final ep in eps) {
      canvas.drawCircle(ep, 3.5, _endpointPaint);
    }
    return; // already restored above
  }

  void _drawGhost(Canvas canvas) {
    final type = ghostType;
    final pos = ghostPosition;
    if (type == null || pos == null) return;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    final ghostPaint = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    _ComponentPainter.drawWithPaint(canvas, type, ghostPaint);
    canvas.restore();
  }

  void _drawRubberBand(Canvas canvas) {
    final rect = selectionRect;
    if (rect == null) return;
    canvas.drawRect(rect, _rubberBandFillPaint);
    canvas.drawRect(rect, _rubberBandStrokePaint);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter old) =>
      old.components != components ||
      old.connections != connections ||
      old.selectedIds != selectedIds ||
      old.selectionRect != selectionRect ||
      old.ghostType != ghostType ||
      old.ghostPosition != ghostPosition ||
      old.isDropCandidate != isDropCandidate;
}

// ---------------------------------------------------------------------------
// Component symbol painter
// ---------------------------------------------------------------------------

/// Draws standard (schematic-style) circuit symbols on a [Canvas].
///
/// The canvas is assumed to already be translated so that the component
/// centre is at (0, 0) and rotated appropriately.
abstract final class _ComponentPainter {
  static final _bodyPaint = Paint()
    ..color = Colors.black87
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final _fillPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final _arrowFill = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.fill;

  static void draw(Canvas canvas, ComponentType type) =>
      drawWithPaint(canvas, type, _bodyPaint);

  static void drawWithPaint(Canvas canvas, ComponentType type, Paint paint) {
    switch (type) {
      case ComponentType.resistor:
        _drawResistor(canvas, paint);
      case ComponentType.wire:
        _drawWire(canvas, paint);
      case ComponentType.voltageSource:
        _drawVoltageSource(canvas, paint);
      case ComponentType.currentSource:
        _drawCurrentSource(canvas, paint);
      case ComponentType.realDiode:
        _drawDiode(canvas, paint, fill: true);
      case ComponentType.idealDiode:
        _drawDiode(canvas, paint, fill: false);
      case ComponentType.zenerDiode:
        _drawZenerDiode(canvas, paint);
    }
  }

  // -- Resistor: zigzag between -halfLen and +halfLen -----------------------
  static void _drawResistor(Canvas canvas, Paint paint) {
    const half = kGridSize * 2;
    const bodyHalf = kGridSize;
    const h = kGridSize * 0.5;
    const steps = 6;
    final path = Path()..moveTo(-half, 0);
    path.lineTo(-bodyHalf, 0);
    for (int i = 0; i < steps; i++) {
      final x = -bodyHalf + (i + 0.5) * (bodyHalf * 2 / steps);
      path.lineTo(x, i.isEven ? -h : h);
    }
    path.lineTo(bodyHalf, 0);
    path.lineTo(half, 0);
    canvas.drawPath(path, paint);
  }

  // -- Wire: straight line --------------------------------------------------
  static void _drawWire(Canvas canvas, Paint paint) {
    const half = kGridSize * 2;
    canvas.drawLine(const Offset(-half, 0), const Offset(half, 0), paint);
  }

  // -- Voltage source: circle with + / - labels ----------------------------
  static void _drawVoltageSource(Canvas canvas, Paint paint) {
    const half = kGridSize * 2;
    const r = kGridSize * 0.9;
    // Lead lines.
    canvas.drawLine(const Offset(-half, 0), const Offset(-r, 0), paint);
    canvas.drawLine(const Offset(r, 0), const Offset(half, 0), paint);
    // Circle body.
    canvas.drawCircle(Offset.zero, r, _fillPaint);
    canvas.drawCircle(Offset.zero, r, paint);
    // + and − labels inside.
    _drawText(canvas, '+', const Offset(0.15 * kGridSize, 0), size: 14);
    _drawText(canvas, '−', const Offset(-0.55 * kGridSize, 0), size: 14);
  }

  // -- Current source: circle with an arrow ---------------------------------
  static void _drawCurrentSource(Canvas canvas, Paint paint) {
    const half = kGridSize * 2;
    const r = kGridSize * 0.9;
    canvas.drawLine(const Offset(-half, 0), const Offset(-r, 0), paint);
    canvas.drawLine(const Offset(r, 0), const Offset(half, 0), paint);
    canvas.drawCircle(Offset.zero, r, _fillPaint);
    canvas.drawCircle(Offset.zero, r, paint);
    // Arrow pointing right inside circle.
    _drawArrow(
      canvas,
      const Offset(-r * 0.5, 0),
      const Offset(r * 0.5, 0),
      paint,
    );
  }

  // -- Diode: triangle + bar ------------------------------------------------
  static void _drawDiode(Canvas canvas, Paint paint, {required bool fill}) {
    const half = kGridSize * 2;
    const bodyH = kGridSize * 0.8;
    // Leads.
    canvas.drawLine(const Offset(-half, 0), const Offset(-bodyH, 0), paint);
    canvas.drawLine(const Offset(bodyH, 0), const Offset(half, 0), paint);
    // Triangle body.
    final tri = Path()
      ..moveTo(-bodyH, -bodyH)
      ..lineTo(-bodyH, bodyH)
      ..lineTo(bodyH, 0)
      ..close();
    if (fill) {
      canvas.drawPath(tri, _fillPaint);
    }
    canvas.drawPath(tri, paint);
    // Cathode bar.
    canvas.drawLine(
      const Offset(bodyH, -bodyH),
      const Offset(bodyH, bodyH),
      paint,
    );
  }

  // -- Zener diode: diode + kinked bar at cathode ---------------------------
  static void _drawZenerDiode(Canvas canvas, Paint paint) {
    _drawDiode(canvas, paint, fill: false);
    const bodyH = kGridSize * 0.8;
    const kink = kGridSize * 0.3;
    // Kinked cathode bar.
    final path = Path()
      ..moveTo(bodyH, -bodyH - kink)
      ..lineTo(bodyH, bodyH + kink);
    canvas.drawPath(path, paint);
  }

  // -- Arrow helper ---------------------------------------------------------
  static void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final dir = (to - from) / (to - from).distance;
    const headLen = 6.0;
    final perp = Offset(-dir.dy, dir.dx);
    final tip = to;
    final left = tip - dir * headLen + perp * headLen * 0.4;
    final right = tip - dir * headLen - perp * headLen * 0.4;
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(head, _arrowFill);
  }

  // -- Text helper ----------------------------------------------------------
  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double size = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }
}
