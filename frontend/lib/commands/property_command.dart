import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// UpdatePropertyCommand
// ---------------------------------------------------------------------------

/// Updates a single numeric property on a component and records a
/// [PropertyAction] on the [HistoryStack] so the change can be undone.
class UpdatePropertyCommand extends UndoableCommand {
  const UpdatePropertyCommand({
    required this.componentId,
    required this.key,
    required this.newValue,
    required this.vm,
    required this.historyStack,
  });

  /// The id of the component whose property to update.
  final int componentId;

  /// The property key (e.g. `'resistance'`, `'voltage'`).
  final String key;

  /// The new value to set.
  final double newValue;

  /// The canvas viewmodel that owns the component list.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [PropertyAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final comp = vm.components.firstWhere((c) => c.id == componentId);
    final oldValue = comp.properties[key];
    if (oldValue == null || oldValue == newValue) return;
    comp.properties[key] = newValue;
    vm.notifyCanvasListeners();
    historyStack.push(
      PropertyAction(
        componentId: componentId,
        key: key,
        oldValue: oldValue,
        newValue: newValue,
      ),
    );
  }
}
