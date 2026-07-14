import 'dart:ui';

import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// EndMoveCommand
// ---------------------------------------------------------------------------

/// Finalises an in-progress move drag: snaps endpoints, records moved
/// positions, and pushes a [MoveAction] onto the [HistoryStack].
///
/// The drag phases ([CanvasViewModel.beginMove] and
/// [CanvasViewModel.updateMove]) are driven directly from the canvas gesture
/// handler and do not use commands, because they are transient and not
/// individually undoable.  Only the final committed move is recorded here.
class EndMoveCommand extends UndoableCommand {
  const EndMoveCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel that owns the component list and drag state.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [MoveAction] onto, if any
  /// components actually moved.
  final HistoryStack historyStack;

  @override
  void execute() {
    final moves = vm.commitMove();
    if (moves.isNotEmpty) {
      historyStack.push(MoveAction(moves));
    }
  }
}

// ---------------------------------------------------------------------------
// EndTransformDragCommand
// ---------------------------------------------------------------------------

/// Finalises an in-progress transform (endpoint/midpoint) drag and pushes a
/// [MoveAction] onto the [HistoryStack] when positions changed.
class EndTransformDragCommand extends UndoableCommand {
  const EndTransformDragCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel that owns the component list and transform state.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [MoveAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final moves = vm.commitTransformDrag();
    if (moves.isNotEmpty) {
      historyStack.push(MoveAction(moves));
    }
  }
}

// ---------------------------------------------------------------------------
// Transient move/transform phase commands (non-undoable)
// ---------------------------------------------------------------------------

/// Begins a move drag by recording the origins of selected and follower
/// components.
class BeginMoveCommand extends Command {
  const BeginMoveCommand({required this.vm});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.beginMove();
}

/// Updates the in-progress move drag by [delta] from the recorded origins.
class UpdateMoveCommand extends Command {
  const UpdateMoveCommand({required this.delta, required this.vm});

  /// The translation delta from the drag start in canvas coordinates.
  final Offset delta;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.updateMove(delta);
}

/// Begins a transform (endpoint/midpoint) drag.
class BeginTransformDragCommand extends Command {
  const BeginTransformDragCommand({
    required this.componentId,
    required this.endpointIndex,
    required this.singleMode,
    required this.vm,
  });

  /// The id of the component being transformed.
  final int componentId;

  /// The endpoint index (0 or 1), or -1 for a midpoint drag.
  final int endpointIndex;

  /// When true, connected components are not dragged along.
  final bool singleMode;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() {
    final comp = vm.components.firstWhere((c) => c.id == componentId);
    vm.beginTransformDrag(comp, endpointIndex, singleMode: singleMode);
  }
}

/// Updates the in-progress transform drag to [position].
class UpdateTransformDragCommand extends Command {
  const UpdateTransformDragCommand({required this.position, required this.vm});

  /// The current pointer position in canvas coordinates.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.updateTransformDrag(position);
}
