import 'dart:ui';

import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../viewmodels/canvas_viewmodel.dart';
import 'command.dart';

// ---------------------------------------------------------------------------
// AddComponentCommand
// ---------------------------------------------------------------------------

/// Adds a new [CircuitComponent] of [type] at [canvasPosition] and records an
/// [AddAction] on the [HistoryStack] so the placement can be undone.
///
/// The position is snapped to the grid inside [CanvasViewModel.applyAdd].
class AddComponentCommand extends UndoableCommand {
  const AddComponentCommand({
    required this.type,
    required this.canvasPosition,
    required this.vm,
    required this.historyStack,
  });

  /// The type of component to insert.
  final ComponentType type;

  /// The desired centre position in canvas coordinates (will be grid-snapped).
  final Offset canvasPosition;

  /// The canvas viewmodel that owns the component list.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [AddAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final snapped = snapOffsetToGrid(canvasPosition);
    final component = CircuitComponent.fromCentre(
      type: type,
      position: snapped,
    );
    vm.applyAdd(component);
    historyStack.push(AddAction(component));
  }
}

// ---------------------------------------------------------------------------
// InsertSelectedComponentCommand
// ---------------------------------------------------------------------------

/// Inserts [CanvasViewModel.selectedComponentForInsertion] at [canvasPosition].
///
/// Does nothing if no component type is currently selected for insertion.
/// After insertion, the new component becomes the sole selected component.
class InsertSelectedComponentCommand extends UndoableCommand {
  const InsertSelectedComponentCommand({
    required this.canvasPosition,
    required this.vm,
    required this.historyStack,
  });

  /// The desired centre position in canvas coordinates (will be grid-snapped).
  final Offset canvasPosition;

  /// The canvas viewmodel that owns the component list.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [AddAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final type = vm.selectedComponentForInsertion;
    if (type == null) return;
    final snapped = snapOffsetToGrid(canvasPosition);
    final component = CircuitComponent.fromCentre(
      type: type,
      position: snapped,
    );
    vm.applyAdd(component);
    vm.setOnlySelectedId(component.id);
    historyStack.push(AddAction(component));
  }
}

// ---------------------------------------------------------------------------
// DropFromBankCommand
// ---------------------------------------------------------------------------

/// Handles dropping a component dragged from the component bank onto the
/// canvas at [canvasPosition].
///
/// Cancels the bank drag ghost after placing the component.
class DropFromBankCommand extends UndoableCommand {
  const DropFromBankCommand({
    required this.type,
    required this.canvasPosition,
    required this.vm,
    required this.historyStack,
  });

  /// The type of component dragged from the bank.
  final ComponentType type;

  /// The drop position in canvas coordinates (will be grid-snapped).
  final Offset canvasPosition;

  /// The canvas viewmodel that owns the component list.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [AddAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final snapped = snapOffsetToGrid(canvasPosition);
    final component = CircuitComponent.fromCentre(
      type: type,
      position: snapped,
    );
    vm.applyAdd(component);
    vm.cancelBankDrag();
    historyStack.push(AddAction(component));
  }
}

// ---------------------------------------------------------------------------
// AddFromBankCommand
// ---------------------------------------------------------------------------

/// Handles clicking a component in the bank (adds it near the canvas centre).
class AddFromBankCommand extends UndoableCommand {
  const AddFromBankCommand({
    required this.type,
    required this.canvasCentre,
    required this.vm,
    required this.historyStack,
  });

  /// The type of component to add.
  final ComponentType type;

  /// The canvas centre position (will be grid-snapped).
  final Offset canvasCentre;

  /// The canvas viewmodel that owns the component list.
  final CanvasViewModel vm;

  /// The history stack to push the resulting [AddAction] onto.
  final HistoryStack historyStack;

  @override
  void execute() {
    final snapped = snapOffsetToGrid(canvasCentre);
    final component = CircuitComponent.fromCentre(
      type: type,
      position: snapped,
    );
    vm.applyAdd(component);
    historyStack.push(AddAction(component));
  }
}
