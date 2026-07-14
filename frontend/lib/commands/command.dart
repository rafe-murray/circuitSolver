import 'package:flutter/foundation.dart';

import '../viewmodels/canvas_viewmodel.dart';

// ---------------------------------------------------------------------------
// Base command abstractions
// ---------------------------------------------------------------------------

/// Base class for all editor commands.
///
/// Commands are stateless value objects — all state they need is supplied
/// through constructor arguments (typically the [CanvasViewModel] and/or the
/// [HistoryStack]).  Calling [execute] performs the action; commands that
/// support undo/redo also push a [CanvasAction] to the [HistoryStack].
abstract class Command {
  const Command();

  /// Performs the action described by this command.
  void execute();
}

/// A [Command] whose effect can be reversed via the [HistoryStack].
///
/// Undoable commands push a [CanvasAction] data record to the [HistoryStack]
/// inside their [execute] implementation so that [HistoryStack.undo] and
/// [HistoryStack.redo] can reverse or replay the mutation.
abstract class UndoableCommand extends Command {
  const UndoableCommand();
}

// ---------------------------------------------------------------------------
// HistoryStack
// ---------------------------------------------------------------------------

/// The global undo/redo history for the circuit editor.
///
/// Provided as a [ChangeNotifier] singleton via Provider so that any widget
/// can observe [canUndo] and [canRedo] without coupling to [CanvasViewModel].
///
/// [CanvasAction] data records are pushed here by [UndoableCommand.execute]
/// implementations.  [undo] and [redo] delegate the actual state mutation back
/// to [CanvasViewModel] via [CanvasViewModel.applyAction] and
/// [CanvasViewModel.reverseAction].
class HistoryStack extends ChangeNotifier {
  final List<CanvasAction> _undoStack = [];
  final List<CanvasAction> _redoStack = [];

  /// Whether there is at least one action that can be undone.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether there is at least one action that can be redone.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Pushes [action] onto the undo stack and clears the redo stack.
  ///
  /// Called by [UndoableCommand] subclasses after mutating the canvas.
  void push(CanvasAction action) {
    _undoStack.add(action);
    _redoStack.clear();
    notifyListeners();
  }

  /// Reverses the most recent action, moving it to the redo stack.
  void undo(CanvasViewModel vm) {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    vm.reverseAction(action);
    notifyListeners();
  }

  /// Reapplies the most recently undone action, moving it back to the undo stack.
  void redo(CanvasViewModel vm) {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    vm.applyAction(action);
    notifyListeners();
  }

  /// Clears both stacks (e.g. when a new circuit is loaded).
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}
