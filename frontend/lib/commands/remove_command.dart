import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// RemoveCommand
// ---------------------------------------------------------------------------

/// Removes all currently selected components (and any connections involving
/// them) from the canvas, recording a [RemoveAction] so the deletion can be
/// undone.
class RemoveSelectedCommand extends UndoableCommand {
  const RemoveSelectedCommand({required this.vm, required this.historyStack});

  /// The canvas viewmodel that owns the component and connection lists.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [RemoveAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final selectedIds = vm.selectedIds;
    if (selectedIds.isEmpty) return;

    final toRemove = vm.components
        .where((c) => selectedIds.contains(c.id))
        .toList();
    final removedConns = vm.connections
        .where(
          (cn) =>
              selectedIds.contains(cn.componentA) ||
              selectedIds.contains(cn.componentB),
        )
        .toList();

    final action = RemoveAction(List.of(toRemove), List.of(removedConns));
    vm.applyRemove(selectedIds);
    vm.clearSelection();
    historyStack.push(action);
  }
}

// ---------------------------------------------------------------------------
// RemoveComponentCommand
// ---------------------------------------------------------------------------

/// Removes a single component (identified by [componentId]) and any
/// connections involving it, recording a [RemoveAction] for undo.
class RemoveComponentCommand extends UndoableCommand {
  const RemoveComponentCommand({
    required this.componentId,
    required this.vm,
    required this.historyStack,
  });

  /// The id of the component to remove.
  final int componentId;

  /// The canvas viewmodel that owns the component and connection lists.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [RemoveAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final comp = vm.components.firstWhere((c) => c.id == componentId);
    final removedConns = vm.connections
        .where(
          (cn) => cn.componentA == componentId || cn.componentB == componentId,
        )
        .toList();

    final action = RemoveAction([comp], removedConns);
    vm.applyRemove({componentId});
    vm.deselect(componentId);
    historyStack.push(action);
  }
}
