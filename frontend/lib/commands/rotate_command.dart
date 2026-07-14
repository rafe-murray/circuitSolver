import 'dart:math' as math;
import 'dart:ui';

import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// RotateClockwiseCommand
// ---------------------------------------------------------------------------

/// Rotates all currently selected components by 90° clockwise around the
/// selection centroid and records a [RotateAction] on the [HistoryStack] so
/// the rotation can be undone.
///
/// When a single component is selected the centroid equals its own centre, so
/// behaviour is identical to the old per-component rotation — the component
/// rotates in place. When multiple components are selected they all orbit
/// around the group centroid, preserving relative positions.
class RotateClockwiseCommand extends UndoableCommand {
  const RotateClockwiseCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel that owns the selected components.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [RotateAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    if (vm.selectedIds.isEmpty) return;

    const quarter = math.pi / 2;
    final rotations = <(int, Offset, Offset, Offset, Offset)>[];

    // Compute the centroid of all selected components.
    var centroidSum = Offset.zero;
    var centroidCount = 0;
    for (final id in vm.selectedIds) {
      final comp = vm.components.firstWhere((c) => c.id == id);
      centroidSum += comp.position;
      centroidCount += 1;
    }
    final centroid = centroidSum / centroidCount.toDouble();

    for (final id in vm.selectedIds) {
      final comp = vm.components.firstWhere((c) => c.id == id);
      final oldEp0 = comp.endpoint0;
      final oldEp1 = comp.endpoint1;

      // Rotate both endpoints around the group centroid by 90° clockwise.
      comp.endpoint0 = _rotateAround(oldEp0, centroid, quarter);
      comp.endpoint1 = _rotateAround(oldEp1, centroid, quarter);

      rotations.add((id, oldEp0, comp.endpoint0, oldEp1, comp.endpoint1));
    }

    if (rotations.isNotEmpty) {
      vm.notifyCanvasListeners();
      historyStack.push(RotateAction(rotations));
    }
  }

  /// Rotates [point] around [pivot] by [radians].
  static Offset _rotateAround(Offset point, Offset pivot, double radians) {
    final d = point - pivot;
    final c = math.cos(radians);
    final s = math.sin(radians);
    return pivot + Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
  }
}

// ---------------------------------------------------------------------------
// EndRotateDragCommand
// ---------------------------------------------------------------------------

/// Finalises a free-rotation drag and pushes a [RotateAction] onto the
/// [HistoryStack] when any rotation changed.
///
/// The drag phases ([CanvasViewModel.beginRotateDrag] and
/// [CanvasViewModel.updateRotateDrag]) are driven directly from the canvas
/// gesture handler and are not individually undoable.
class EndRotateDragCommand extends UndoableCommand {
  const EndRotateDragCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel that owns the component list and rotate drag state.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [RotateAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final rotations = vm.commitRotateDrag();
    if (rotations.isNotEmpty) {
      historyStack.push(RotateAction(rotations));
    }
  }
}

// ---------------------------------------------------------------------------
// Transient rotate drag phase commands (non-undoable)
// ---------------------------------------------------------------------------

/// Begins a free-rotation drag from [pointerPosition] in canvas coordinates.
class BeginRotateDragCommand extends Command {
  const BeginRotateDragCommand({
    required this.pointerPosition,
    required this.vm,
  });

  /// The initial pointer position in canvas coordinates.
  final Offset pointerPosition;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.beginRotateDrag(pointerPosition);
}

/// Updates the in-progress rotation drag to [pointerPosition].
class UpdateRotateDragCommand extends Command {
  const UpdateRotateDragCommand({
    required this.pointerPosition,
    required this.vm,
  });

  /// The current pointer position in canvas coordinates.
  final Offset pointerPosition;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.updateRotateDrag(pointerPosition);
}
