import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../commands/add_component_command.dart';
import '../commands/command.dart';
import '../commands/move_command.dart';
import '../commands/rotate_command.dart';
import '../commands/selection_commands.dart';
import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../models/editor_tool.dart';
import '../models/selection_shape.dart';
import '../viewmodels/canvas_viewmodel.dart';

// ---------------------------------------------------------------------------
// CircuitCanvas
// ---------------------------------------------------------------------------

/// The interactive circuit editing canvas.
///
/// Wraps an [InteractiveViewer] for pan and zoom, then dispatches pointer
/// events to tool-specific handlers based on [CanvasViewModel.activeTool].
///
/// Tool dispatch summary:
/// - **Move**: drag selected component(s), or rubber-band on empty space.
/// - **AddComponent**: tap to insert the selected component type.
/// - **Selection**: drag rubber-band rect; Shift=additive, Alt=subtractive.
/// - **Lasso**: trace a free-form shape; Shift/Alt modifiers.
/// - **Wand**: tap to BFS-select all connected components.
/// - **Rotate**: drag to freely rotate selection around centroid; snaps to 90°.
/// - **Transform**: drag endpoint to move it; drag midpoint to move component.
/// - **Zoom**: single tap to zoom in, Alt+tap to zoom out.
class CircuitCanvas extends StatefulWidget {
  const CircuitCanvas({super.key});

  @override
  State<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends State<CircuitCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  /// Whether the current pan gesture is being handled by this widget rather
  /// than delegated to [InteractiveViewer] (i.e. we "consumed" it for a tool).
  _DragMode _dragMode = _DragMode.none;
  Offset _dragStart = Offset.zero;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context);
    final hs = Provider.of<HistoryStack>(context, listen: false);

    return DragTarget<ComponentType>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.offset);
        // Convert from widget-local to canvas-local (accounting for pan/zoom).
        final canvasLocal = _toCanvasLocal(local);
        DropFromBankCommand(
          type: details.data,
          canvasPosition: canvasLocal,
          vm: vm,
          historyStack: hs,
        ).execute();
      },
      builder: (context, candidateData, _) {
        return InteractiveViewer(
          transformationController: _transformationController,
          // Disable InteractiveViewer's built-in pan/scale when a tool needs
          // to intercept drags.  We re-enable by never calling
          // onInteractionStart when _dragMode != none.
          panEnabled: vm.activeTool == EditorTool.zoom,
          scaleEnabled: vm.activeTool == EditorTool.zoom,
          minScale: 0.2,
          maxScale: 8.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (e) => _onTapUp(context, e, vm, hs),
            onPanStart: (e) => _onPanStart(e, vm, hs),
            onPanUpdate: (e) => _onPanUpdate(e, vm),
            onPanEnd: (e) => _onPanEnd(vm, hs),
            child: CustomPaint(
              painter: _CanvasPainter(
                components: vm.components,
                connections: vm.connections,
                selectedIds: vm.selectedIds,
                selectionRect: vm.selectionRect,
                lassoPath: vm.lassoPath,
                selectionShape: vm.selectionShape,
                ghostType: vm.bankDragType,
                ghostPosition: vm.bankDragPosition,
                isDropCandidate: candidateData.isNotEmpty,
                activeTool: vm.activeTool,
                rotateCentroid: vm.rotateCentroid,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Coordinate helpers
  // -------------------------------------------------------------------------

  /// Converts a position in widget-local space to canvas (scene) space,
  /// accounting for the current pan/zoom transformation.
  Offset _toCanvasLocal(Offset widgetLocal) {
    final matrix = _transformationController.value;
    // Matrix4 in Flutter is column-major. We can invert and multiply manually.
    final inverted = Matrix4.inverted(matrix);
    // Transform the 2D point using the 4x4 matrix (homogeneous coords).
    final x = widgetLocal.dx;
    final y = widgetLocal.dy;
    final s = inverted.storage;
    final rx = s[0] * x + s[4] * y + s[12];
    final ry = s[1] * x + s[5] * y + s[13];
    return Offset(rx, ry);
  }

  // -------------------------------------------------------------------------
  // Gesture handlers
  // -------------------------------------------------------------------------

  void _onTapUp(
    BuildContext context,
    TapUpDetails e,
    CanvasViewModel vm,
    HistoryStack hs,
  ) {
    final canvasPos = _toCanvasLocal(e.localPosition);

    switch (vm.activeTool) {
      case EditorTool.move:
        _handleMoveTap(canvasPos, vm, hs);
      case EditorTool.addComponent:
        InsertSelectedComponentCommand(
          canvasPosition: canvasPos,
          vm: vm,
          historyStack: hs,
        ).execute();
      case EditorTool.selection:
        _handleSelectionTap(canvasPos, vm, hs);
      case EditorTool.lasso:
        _handleSelectionTap(canvasPos, vm, hs);
      case EditorTool.wand:
        _handleWandTap(canvasPos, vm, hs);
      case EditorTool.rotate:
        // Tap does nothing for rotate; user must drag.
        break;
      case EditorTool.transform:
        // Tap selects the component.
        _handleMoveTap(canvasPos, vm, hs);
      case EditorTool.zoom:
        _handleZoomTap(e.localPosition, vm);
    }
  }

  void _onPanStart(DragStartDetails e, CanvasViewModel vm, HistoryStack hs) {
    _dragStart = _toCanvasLocal(e.localPosition);

    switch (vm.activeTool) {
      case EditorTool.move:
        _startMoveDrag(_dragStart, vm, hs);
      case EditorTool.addComponent:
        // No pan behaviour for add component.
        break;
      case EditorTool.selection:
        _startRubberBand(_dragStart, vm);
      case EditorTool.lasso:
        _startLasso(_dragStart, vm);
      case EditorTool.wand:
        // No pan behaviour for wand.
        break;
      case EditorTool.rotate:
        _startRotateDrag(_dragStart, vm);
      case EditorTool.transform:
        _startTransformDrag(_dragStart, vm, hs);
      case EditorTool.zoom:
        // Pan handled by InteractiveViewer.
        break;
    }
  }

  void _onPanUpdate(DragUpdateDetails e, CanvasViewModel vm) {
    final canvasPos = _toCanvasLocal(e.localPosition);

    switch (_dragMode) {
      case _DragMode.move:
        final delta = canvasPos - _dragStart;
        UpdateMoveCommand(delta: delta, vm: vm).execute();
      case _DragMode.rubberBand:
        UpdateRubberBandCommand(
          position: canvasPos,
          vm: vm,
          mode: _selectionMode(),
        ).execute();
      case _DragMode.lasso:
        UpdateLassoCommand(
          position: canvasPos,
          vm: vm,
          mode: _selectionMode(),
        ).execute();
      case _DragMode.rotate:
        UpdateRotateDragCommand(pointerPosition: canvasPos, vm: vm).execute();
      case _DragMode.transform:
        UpdateTransformDragCommand(position: canvasPos, vm: vm).execute();
      case _DragMode.none:
        break;
    }
  }

  void _onPanEnd(CanvasViewModel vm, HistoryStack hs) {
    switch (_dragMode) {
      case _DragMode.move:
        EndMoveCommand(vm: vm, historyStack: hs).execute();
      case _DragMode.rubberBand:
        EndRubberBandCommand(vm: vm, historyStack: hs).execute();
      case _DragMode.lasso:
        EndLassoCommand(vm: vm, historyStack: hs).execute();
      case _DragMode.rotate:
        EndRotateDragCommand(vm: vm, historyStack: hs).execute();
      case _DragMode.transform:
        EndTransformDragCommand(vm: vm, historyStack: hs).execute();
      case _DragMode.none:
        break;
    }
    _dragMode = _DragMode.none;
  }

  // -------------------------------------------------------------------------
  // Tool-specific handlers
  // -------------------------------------------------------------------------

  void _handleMoveTap(Offset canvasPos, CanvasViewModel vm, HistoryStack hs) {
    final hit = vm.hitTest(canvasPos);
    if (hit != null) {
      SelectComponentCommand(
        id: hit.id,
        vm: vm,
        historyStack: hs,
        additive: _isAdditiveModifier(),
      ).execute();
    } else {
      ClearSelectionCommand(vm: vm, historyStack: hs).execute();
    }
  }

  void _startMoveDrag(Offset canvasStart, CanvasViewModel vm, HistoryStack hs) {
    final hit = vm.hitTest(canvasStart);
    if (hit != null) {
      if (!vm.isSelected(hit.id)) {
        SelectComponentCommand(id: hit.id, vm: vm, historyStack: hs).execute();
      }
      _dragMode = _DragMode.move;
      BeginMoveCommand(vm: vm).execute();
    } else {
      // Rubber-band in move tool as a convenience.
      _dragMode = _DragMode.rubberBand;
      StartRubberBandCommand(position: canvasStart, vm: vm).execute();
    }
  }

  void _handleSelectionTap(
    Offset canvasPos,
    CanvasViewModel vm,
    HistoryStack hs,
  ) {
    final hit = vm.hitTest(canvasPos);
    if (hit != null) {
      final mode = _selectionMode();
      switch (mode) {
        case SelectionMode.replace:
          SelectComponentCommand(
            id: hit.id,
            vm: vm,
            historyStack: hs,
          ).execute();
        case SelectionMode.additive:
          SelectComponentCommand(
            id: hit.id,
            vm: vm,
            historyStack: hs,
            additive: true,
          ).execute();
        case SelectionMode.subtractive:
          // Deselect by clearing and re-adding everything except this one.
          final newSelection = Set.of(vm.selectedIds)..remove(hit.id);
          ClearSelectionCommand(vm: vm, historyStack: hs).execute();
          for (final id in newSelection) {
            SelectComponentCommand(
              id: id,
              vm: vm,
              historyStack: hs,
              additive: true,
            ).execute();
          }
      }
    } else {
      if (_selectionMode() == SelectionMode.replace) {
        ClearSelectionCommand(vm: vm, historyStack: hs).execute();
      }
    }
  }

  void _startRubberBand(Offset canvasStart, CanvasViewModel vm) {
    _dragMode = _DragMode.rubberBand;
    StartRubberBandCommand(
      position: canvasStart,
      vm: vm,
      mode: _selectionMode(),
    ).execute();
  }

  void _startLasso(Offset canvasStart, CanvasViewModel vm) {
    _dragMode = _DragMode.lasso;
    StartLassoCommand(
      position: canvasStart,
      vm: vm,
      mode: _selectionMode(),
    ).execute();
  }

  void _handleWandTap(Offset canvasPos, CanvasViewModel vm, HistoryStack hs) {
    final hit = vm.hitTest(canvasPos);
    if (hit != null) {
      WandSelectCommand(
        componentId: hit.id,
        vm: vm,
        historyStack: hs,
        mode: _selectionMode(),
      ).execute();
    } else {
      if (_selectionMode() == SelectionMode.replace) {
        ClearSelectionCommand(vm: vm, historyStack: hs).execute();
      }
    }
  }

  void _startRotateDrag(Offset canvasStart, CanvasViewModel vm) {
    if (vm.selectedIds.isEmpty) return;
    _dragMode = _DragMode.rotate;
    BeginRotateDragCommand(pointerPosition: canvasStart, vm: vm).execute();
  }

  void _startTransformDrag(
    Offset canvasStart,
    CanvasViewModel vm,
    HistoryStack hs,
  ) {
    final hit = vm.endpointHitTest(canvasStart);
    if (hit == null) return;
    final (comp, epIdx) = hit;
    final singleMode = HardwareKeyboard.instance.isAltPressed;
    _dragMode = _DragMode.transform;
    BeginTransformDragCommand(
      componentId: comp.id,
      endpointIndex: epIdx,
      singleMode: singleMode,
      vm: vm,
    ).execute();
  }

  void _handleZoomTap(Offset widgetLocal, CanvasViewModel vm) {
    final alt = HardwareKeyboard.instance.isAltPressed;
    final factor = alt ? 1.0 / 1.5 : 1.5;
    _applyZoom(widgetLocal, factor);
  }

  // -------------------------------------------------------------------------
  // Zoom helpers
  // -------------------------------------------------------------------------

  void _applyZoom(Offset focalPoint, double factor) {
    final currentMatrix = _transformationController.value.clone();
    // Build a zoom matrix centred on focalPoint.
    final fx = focalPoint.dx;
    final fy = focalPoint.dy;
    final Matrix4 zoom = Matrix4.identity()
      ..translateByDouble(fx, fy, 0, 1)
      ..scaleByDouble(factor, factor, 1, 1)
      ..translateByDouble(-fx, -fy, 0, 1);
    _transformationController.value = zoom * currentMatrix;
  }

  // -------------------------------------------------------------------------
  // Modifier helpers
  // -------------------------------------------------------------------------

  /// Returns `true` when a modifier key that adds to selection is held.
  bool _isAdditiveModifier() =>
      HardwareKeyboard.instance.isShiftPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  /// Determines the [SelectionMode] from the currently held modifier keys.
  SelectionMode _selectionMode() {
    if (HardwareKeyboard.instance.isShiftPressed) {
      return SelectionMode.additive;
    }
    if (HardwareKeyboard.instance.isAltPressed) {
      return SelectionMode.subtractive;
    }
    return SelectionMode.replace;
  }
}

enum _DragMode { none, move, rubberBand, lasso, rotate, transform }

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.components,
    required this.connections,
    required this.selectedIds,
    required this.selectionRect,
    required this.lassoPath,
    required this.selectionShape,
    required this.ghostType,
    required this.ghostPosition,
    required this.isDropCandidate,
    required this.activeTool,
    required this.rotateCentroid,
  });

  final List<CircuitComponent> components;
  final List<Connection> connections;
  final Set<int> selectedIds;
  final Rect? selectionRect;
  final List<Offset>? lassoPath;
  final SelectionShape selectionShape;
  final ComponentType? ghostType;
  final Offset? ghostPosition;
  final bool isDropCandidate;
  final EditorTool activeTool;
  final Offset? rotateCentroid;

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

  static final _transformHandleFill = Paint()
    ..color = const Color(0xFF1565C0)
    ..style = PaintingStyle.fill;

  static final _transformHandleStroke = Paint()
    ..color = Colors.white
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  static final _transformMidpointFill = Paint()
    ..color = const Color(0xFF42A5F5)
    ..style = PaintingStyle.fill;

  static final _lassoPaint = Paint()
    ..color = const Color(0xFF0055FF)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  static final _lassoFillPaint = Paint()
    ..color = const Color(0x220055FF)
    ..style = PaintingStyle.fill;

  static final _rotateCentroidPaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  // -- Paint ----------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawConnections(canvas);
    _drawComponents(canvas);
    _drawSelectionOverlay(canvas);
    _drawGhost(canvas);
    _drawRubberBand(canvas);
    _drawLasso(canvas);
    if (activeTool == EditorTool.transform) _drawTransformHandles(canvas);
    if (activeTool == EditorTool.rotate) _drawRotateCentroid(canvas);
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
    final epMap = <int, List<Offset>>{};
    for (final c in components) {
      epMap[c.id] = c.absoluteEndpoints;
    }
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
      _drawComponent(canvas, comp);
    }
  }

  void _drawComponent(Canvas canvas, CircuitComponent comp) {
    canvas.save();
    canvas.translate(comp.position.dx, comp.position.dy);
    canvas.rotate(comp.rotation);

    _ComponentPainter.draw(canvas, comp.type, comp.halfLen);

    final eps = comp.absoluteEndpoints;
    canvas.restore();
    for (final ep in eps) {
      canvas.drawCircle(ep, 3.5, _endpointPaint);
    }
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
    _ComponentPainter.drawWithPaint(canvas, type, ghostPaint, kDefaultHalfLen);
    canvas.restore();
  }

  void _drawRubberBand(Canvas canvas) {
    final rect = selectionRect;
    if (rect == null) return;
    canvas.drawRect(rect, _rubberBandFillPaint);
    canvas.drawRect(rect, _rubberBandStrokePaint);
  }

  void _drawLasso(Canvas canvas) {
    final path = lassoPath;
    if (path == null || path.length < 2) return;

    final linePath = Path()..moveTo(path.first.dx, path.first.dy);
    for (int i = 1; i < path.length; i++) {
      linePath.lineTo(path[i].dx, path[i].dy);
    }
    linePath.close();
    canvas.drawPath(linePath, _lassoFillPaint);
    canvas.drawPath(linePath, _lassoPaint);
  }

  /// Draws the committed selection shape overlay on top of components.
  ///
  /// The shape type depends on how the selection was made:
  /// - [RubberBandSelectionShape] → dashed blue rect outline
  /// - [LassoSelectionShape] → dashed blue path outline
  /// - [HullSelectionShape] → convex hull fill with even-odd inner cutouts
  /// - [EmptySelectionShape] → nothing drawn
  void _drawSelectionOverlay(Canvas canvas) {
    final shape = selectionShape;
    switch (shape) {
      case EmptySelectionShape():
        break;
      case RubberBandSelectionShape(:final rect):
        final path = Path()..addRect(rect);
        canvas.drawRect(rect, _selectionFillPaint);
        _drawDashedPath(canvas, path, _selectionStrokePaint);
      case LassoSelectionShape(:final points):
        if (points.length < 2) break;
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        path.close();
        canvas.drawPath(path, _selectionFillPaint);
        _drawDashedPath(canvas, path, _selectionStrokePaint);
      case HullSelectionShape(:final outerHull, :final innerHulls):
        if (outerHull.length < 2) break;
        final path = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(outerHull.first.dx, outerHull.first.dy);
        for (int i = 1; i < outerHull.length; i++) {
          path.lineTo(outerHull[i].dx, outerHull[i].dy);
        }
        path.close();
        for (final inner in innerHulls) {
          if (inner.length < 3) continue;
          path.moveTo(inner.first.dx, inner.first.dy);
          for (int i = 1; i < inner.length; i++) {
            path.lineTo(inner[i].dx, inner[i].dy);
          }
          path.close();
        }
        canvas.drawPath(path, _selectionFillPaint);
        // Draw dashed outline of the outer hull only.
        final outlinePath = Path()
          ..moveTo(outerHull.first.dx, outerHull.first.dy);
        for (int i = 1; i < outerHull.length; i++) {
          outlinePath.lineTo(outerHull[i].dx, outerHull[i].dy);
        }
        outlinePath.close();
        _drawDashedPath(canvas, outlinePath, _selectionStrokePaint);
    }
  }

  /// Strokes [path] with a dashed pattern by alternating drawn/skipped
  /// segments of [dashLen] canvas units each.
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dashLen = 6.0,
    double gapLen = 4.0,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final segLen = draw ? dashLen : gapLen;
        final end = (distance + segLen).clamp(0.0, metric.length);
        if (draw) {
          final segment = metric.extractPath(distance, end);
          canvas.drawPath(segment, paint);
        }
        distance = end;
        draw = !draw;
      }
    }
  }

  /// Draws blue transform handles (endpoints + midpoints) for all components.
  void _drawTransformHandles(Canvas canvas) {
    for (final comp in components) {
      // Midpoint handle (slightly lighter blue).
      canvas.drawCircle(comp.position, 6, _transformMidpointFill);
      canvas.drawCircle(comp.position, 6, _transformHandleStroke);

      // Endpoint handles.
      final eps = comp.absoluteEndpoints;
      for (int i = 0; i < eps.length; i++) {
        canvas.drawCircle(eps[i], 5, _transformHandleFill);
        canvas.drawCircle(eps[i], 5, _transformHandleStroke);
      }
    }
  }

  /// Draws the rotation centroid indicator (crosshair + circle).
  void _drawRotateCentroid(Canvas canvas) {
    final centroid = rotateCentroid;
    if (centroid == null) return;
    const r = 8.0;
    canvas.drawCircle(centroid, r, _rotateCentroidPaint);
    canvas.drawLine(
      Offset(centroid.dx - r, centroid.dy),
      Offset(centroid.dx + r, centroid.dy),
      _rotateCentroidPaint,
    );
    canvas.drawLine(
      Offset(centroid.dx, centroid.dy - r),
      Offset(centroid.dx, centroid.dy + r),
      _rotateCentroidPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter old) =>
      old.components != components ||
      old.connections != connections ||
      old.selectedIds != selectedIds ||
      old.selectionRect != selectionRect ||
      old.lassoPath != lassoPath ||
      old.selectionShape != selectionShape ||
      old.ghostType != ghostType ||
      old.ghostPosition != ghostPosition ||
      old.isDropCandidate != isDropCandidate ||
      old.activeTool != activeTool ||
      old.rotateCentroid != rotateCentroid;
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

  static void draw(Canvas canvas, ComponentType type, double halfLen) =>
      drawWithPaint(canvas, type, _bodyPaint, halfLen);

  static void drawWithPaint(
    Canvas canvas,
    ComponentType type,
    Paint paint,
    double halfLen,
  ) {
    switch (type) {
      case ComponentType.resistor:
        _drawResistor(canvas, paint, halfLen);
      case ComponentType.wire:
        _drawWire(canvas, paint, halfLen);
      case ComponentType.voltageSource:
        _drawVoltageSource(canvas, paint, halfLen);
      case ComponentType.currentSource:
        _drawCurrentSource(canvas, paint, halfLen);
      case ComponentType.realDiode:
        _drawDiode(canvas, paint, halfLen, fill: true);
      case ComponentType.idealDiode:
        _drawDiode(canvas, paint, halfLen, fill: false);
      case ComponentType.zenerDiode:
        _drawZenerDiode(canvas, paint, halfLen);
    }
  }

  // -- Resistor: zigzag between -halfLen and +halfLen -----------------------
  static void _drawResistor(Canvas canvas, Paint paint, double halfLen) {
    const bodyHalf = kBodyHalfLen;
    const h = kGridSize * 0.5;
    const steps = 6;
    final path = Path()..moveTo(-halfLen, 0);
    path.lineTo(-bodyHalf, 0);
    for (int i = 0; i < steps; i++) {
      final x = -bodyHalf + (i + 0.5) * (bodyHalf * 2 / steps);
      path.lineTo(x, i.isEven ? -h : h);
    }
    path.lineTo(bodyHalf, 0);
    path.lineTo(halfLen, 0);
    canvas.drawPath(path, paint);
  }

  // -- Wire: straight line --------------------------------------------------
  static void _drawWire(Canvas canvas, Paint paint, double halfLen) {
    canvas.drawLine(Offset(-halfLen, 0), Offset(halfLen, 0), paint);
  }

  // -- Voltage source: circle with + / - labels ----------------------------
  static void _drawVoltageSource(Canvas canvas, Paint paint, double halfLen) {
    const r = kGridSize * 0.9;
    canvas.drawLine(Offset(-halfLen, 0), const Offset(-r, 0), paint);
    canvas.drawLine(const Offset(r, 0), Offset(halfLen, 0), paint);
    canvas.drawCircle(Offset.zero, r, _fillPaint);
    canvas.drawCircle(Offset.zero, r, paint);
    _drawText(canvas, '+', const Offset(0.15 * kGridSize, 0), size: 14);
    _drawText(canvas, '−', const Offset(-0.55 * kGridSize, 0), size: 14);
  }

  // -- Current source: circle with an arrow ---------------------------------
  static void _drawCurrentSource(Canvas canvas, Paint paint, double halfLen) {
    const r = kGridSize * 0.9;
    canvas.drawLine(Offset(-halfLen, 0), const Offset(-r, 0), paint);
    canvas.drawLine(const Offset(r, 0), Offset(halfLen, 0), paint);
    canvas.drawCircle(Offset.zero, r, _fillPaint);
    canvas.drawCircle(Offset.zero, r, paint);
    _drawArrow(
      canvas,
      const Offset(-r * 0.5, 0),
      const Offset(r * 0.5, 0),
      paint,
    );
  }

  // -- Diode: triangle + bar ------------------------------------------------
  static void _drawDiode(
    Canvas canvas,
    Paint paint,
    double halfLen, {
    required bool fill,
  }) {
    const bodyH = kGridSize * 0.8;
    canvas.drawLine(Offset(-halfLen, 0), const Offset(-bodyH, 0), paint);
    canvas.drawLine(const Offset(bodyH, 0), Offset(halfLen, 0), paint);
    final tri = Path()
      ..moveTo(-bodyH, -bodyH)
      ..lineTo(-bodyH, bodyH)
      ..lineTo(bodyH, 0)
      ..close();
    if (fill) {
      canvas.drawPath(tri, _fillPaint);
    }
    canvas.drawPath(tri, paint);
    canvas.drawLine(
      const Offset(bodyH, -bodyH),
      const Offset(bodyH, bodyH),
      paint,
    );
  }

  // -- Zener diode: diode + kinked bar at cathode ---------------------------
  static void _drawZenerDiode(Canvas canvas, Paint paint, double halfLen) {
    _drawDiode(canvas, paint, halfLen, fill: false);
    const bodyH = kGridSize * 0.8;
    const kink = kGridSize * 0.3;
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

// ---------------------------------------------------------------------------
// Geometry helpers
// ---------------------------------------------------------------------------
