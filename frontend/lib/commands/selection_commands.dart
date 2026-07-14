import 'dart:ui';

import '../models/component_type.dart';
import '../models/editor_tool.dart';
import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// Tool switching
// ---------------------------------------------------------------------------

/// Switches the active editor tool to [tool] and records a [SetToolAction] on
/// the [HistoryStack] so the change can be undone.
class SetToolCommand extends UndoableCommand {
  const SetToolCommand({
    required this.tool,
    required this.vm,
    required this.historyStack,
  });

  /// The tool to activate.
  final EditorTool tool;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SetToolAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldTool = vm.activeTool;
    if (oldTool == tool) return;
    vm.setTool(tool);
    historyStack.push(SetToolAction(oldTool: oldTool, newTool: tool));
  }
}

// ---------------------------------------------------------------------------
// Component type selection for insertion
// ---------------------------------------------------------------------------

/// Selects [type] as the component primed for insertion (or deselects it if
/// it is already selected), and records a [SelectForInsertionAction] on the
/// [HistoryStack] so the change can be undone.
class SelectForInsertionCommand extends UndoableCommand {
  const SelectForInsertionCommand({
    required this.type,
    required this.vm,
    required this.historyStack,
  });

  /// The component type to prime (or deselect).
  final ComponentType type;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectForInsertionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldType = vm.selectedComponentForInsertion;
    vm.selectComponentForInsertion(type);
    final newType = vm.selectedComponentForInsertion;
    if (oldType == newType) return;
    historyStack.push(
      SelectForInsertionAction(oldType: oldType, newType: newType),
    );
  }
}

// ---------------------------------------------------------------------------
// Component selection
// ---------------------------------------------------------------------------

/// Selects a single component and records a [SelectionAction] on the
/// [HistoryStack] so the change can be undone.
///
/// When [additive] is true the existing selection is preserved and the new
/// component is added to it.
class SelectComponentCommand extends UndoableCommand {
  const SelectComponentCommand({
    required this.id,
    required this.vm,
    required this.historyStack,
    this.additive = false,
  });

  /// The id of the component to select.
  final int id;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  /// Whether to add to the existing selection instead of replacing it.
  final bool additive;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    vm.selectComponent(id, additive: additive);
    final newIds = Set.of(vm.selectedIds);
    if (oldIds == newIds) return;
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

/// Selects all components on the canvas and records a [SelectionAction].
class SelectAllCommand extends UndoableCommand {
  const SelectAllCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    for (final comp in vm.components) {
      vm.selectComponent(comp.id, additive: true);
    }
    final newIds = Set.of(vm.selectedIds);
    if (oldIds == newIds) return;
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

/// Clears the entire selection and records a [SelectionAction].
class ClearSelectionCommand extends UndoableCommand {
  const ClearSelectionCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    if (oldIds.isEmpty) return;
    vm.clearSelection();
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: {}));
  }
}

/// Removes a single component from the selection without affecting others,
/// and records a [SelectionAction].
class DeselectComponentCommand extends UndoableCommand {
  const DeselectComponentCommand({
    required this.id,
    required this.vm,
    required this.historyStack,
  });

  /// The id of the component to deselect.
  final int id;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    if (!oldIds.contains(id)) return;
    vm.deselect(id);
    final newIds = Set.of(vm.selectedIds);
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

// ---------------------------------------------------------------------------
// Wand selection
// ---------------------------------------------------------------------------

/// BFS-selects all components connected (directly or transitively) to the
/// component with [componentId], and records a [SelectionAction].
class WandSelectCommand extends UndoableCommand {
  const WandSelectCommand({
    required this.componentId,
    required this.vm,
    required this.historyStack,
    this.mode = SelectionMode.replace,
  });

  /// The id of the starting component.
  final int componentId;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  /// How the result merges with the existing selection.
  final SelectionMode mode;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    vm.wandSelect(componentId, mode: mode);
    final newIds = Set.of(vm.selectedIds);
    if (oldIds == newIds) return;
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

// ---------------------------------------------------------------------------
// Rubber-band selection phases
// ---------------------------------------------------------------------------

/// Begins a rubber-band selection at [position].
///
/// This is a transient gesture phase — it does **not** push to the history
/// stack. Only [EndRubberBandCommand] records the committed selection.
class StartRubberBandCommand extends Command {
  const StartRubberBandCommand({
    required this.position,
    required this.vm,
    this.mode = SelectionMode.replace,
  });

  /// The starting corner of the rubber-band rectangle in canvas coordinates.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// How the result merges with the existing selection.
  final SelectionMode mode;

  @override
  void execute() => vm.startRubberBand(position, mode: mode);
}

/// Updates the rubber-band rectangle to [position].
///
/// Transient gesture phase — does not push to the history stack.
class UpdateRubberBandCommand extends Command {
  const UpdateRubberBandCommand({
    required this.position,
    required this.vm,
    this.mode = SelectionMode.replace,
  });

  /// The current opposite corner of the rubber-band rectangle.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// How the result merges with the existing selection.
  final SelectionMode mode;

  @override
  void execute() => vm.updateRubberBand(position, mode: mode);
}

/// Finalises the rubber-band selection and records a [SelectionAction].
class EndRubberBandCommand extends UndoableCommand {
  const EndRubberBandCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    vm.endRubberBand();
    final newIds = Set.of(vm.selectedIds);
    if (oldIds == newIds) return;
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

// ---------------------------------------------------------------------------
// Lasso selection phases
// ---------------------------------------------------------------------------

/// Begins tracing a lasso shape at [position].
///
/// Transient gesture phase — does not push to the history stack.
class StartLassoCommand extends Command {
  const StartLassoCommand({
    required this.position,
    required this.vm,
    this.mode = SelectionMode.replace,
  });

  /// The starting point of the lasso path in canvas coordinates.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// How the result merges with the existing selection.
  final SelectionMode mode;

  @override
  void execute() => vm.startLasso(position, mode: mode);
}

/// Appends a point to the lasso path.
///
/// Transient gesture phase — does not push to the history stack.
class UpdateLassoCommand extends Command {
  const UpdateLassoCommand({
    required this.position,
    required this.vm,
    this.mode = SelectionMode.replace,
  });

  /// The next point along the lasso path in canvas coordinates.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// How the result merges with the existing selection.
  final SelectionMode mode;

  @override
  void execute() => vm.updateLasso(position, mode: mode);
}

/// Finalises the lasso selection and records a [SelectionAction].
class EndLassoCommand extends UndoableCommand {
  const EndLassoCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [SelectionAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final oldIds = Set.of(vm.selectedIds);
    vm.endLasso();
    final newIds = Set.of(vm.selectedIds);
    if (oldIds == newIds) return;
    historyStack.push(SelectionAction(oldIds: oldIds, newIds: newIds));
  }
}

// ---------------------------------------------------------------------------
// Bank drag ghost
// ---------------------------------------------------------------------------

/// Updates the bank-drag ghost position during a drag from the component bank.
class UpdateBankDragCommand extends Command {
  const UpdateBankDragCommand({
    required this.type,
    required this.position,
    required this.vm,
  });

  /// The type of component being dragged.
  final ComponentType type;

  /// The current position of the ghost in canvas coordinates.
  final Offset position;

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.updateBankDrag(type, position);
}

/// Cancels the bank-drag ghost (e.g. when the drag is released outside the
/// canvas or the component bank).
class CancelBankDragCommand extends Command {
  const CancelBankDragCommand({required this.vm});

  /// The canvas viewmodel.
  final CanvasViewModel vm;

  @override
  void execute() => vm.cancelBankDrag();
}
