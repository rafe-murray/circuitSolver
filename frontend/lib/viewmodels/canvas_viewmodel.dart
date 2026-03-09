import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../services/circuit_serializer.dart';
import '../services/storage.dart';

// ---------------------------------------------------------------------------
// Undo / redo action types
// ---------------------------------------------------------------------------

/// Base class for reversible canvas actions.
sealed class CanvasAction {}

final class AddAction extends CanvasAction {
  AddAction(this.component);
  final CircuitComponent component;
}

final class RemoveAction extends CanvasAction {
  RemoveAction(this.components, this.connections);
  final List<CircuitComponent> components;
  final List<Connection> connections;
}

final class MoveAction extends CanvasAction {
  MoveAction(this.moves);
  // List of (id, oldPosition, newPosition)
  final List<(int, Offset, Offset)> moves;
}

final class RotateAction extends CanvasAction {
  RotateAction(this.rotations);
  // List of (id, oldRotation, newRotation)
  final List<(int, double, double)> rotations;
}

final class PropertyAction extends CanvasAction {
  PropertyAction({
    required this.componentId,
    required this.key,
    required this.oldValue,
    required this.newValue,
  });

  final int componentId;
  final String key;
  final double oldValue;
  final double newValue;
}

// ---------------------------------------------------------------------------
// CanvasViewModel
// ---------------------------------------------------------------------------

/// The central ViewModel for the circuit canvas.
///
/// Holds all components, connections, selection state, and the undo/redo
/// history. Widgets listen via [ListenableBuilder].
class CanvasViewModel extends ChangeNotifier {
  CanvasViewModel();

  // -- Components & connections ---------------------------------------------

  final List<CircuitComponent> _components = [];
  final List<Connection> _connections = [];

  List<CircuitComponent> get components => List.unmodifiable(_components);
  List<Connection> get connections => List.unmodifiable(_connections);

  // -- Selection ------------------------------------------------------------

  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);

  bool isSelected(int id) => _selectedIds.contains(id);

  // -- Active drag-from-bank ghost ------------------------------------------

  /// The component type being dragged from the bank (null when no bank drag).
  ComponentType? bankDragType;

  /// Current canvas position of the bank drag ghost.
  Offset? bankDragPosition;

  // -- In-canvas move state -------------------------------------------------

  Map<int, Offset> _moveOrigins = {};

  // -- Rubber-band selection ------------------------------------------------

  Offset? selectionStart;
  Offset? selectionCurrent;

  Rect? get selectionRect {
    final a = selectionStart;
    final b = selectionCurrent;
    if (a == null || b == null) return null;
    return Rect.fromPoints(a, b);
  }

  // -- Undo / redo ----------------------------------------------------------

  final List<CanvasAction> _undoStack = [];
  final List<CanvasAction> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // =========================================================================
  // Public API
  // =========================================================================

  // -- Adding components ----------------------------------------------------

  /// Called when the user drops a component from the bank onto the canvas.
  void dropFromBank(ComponentType type, Offset canvasPosition) {
    final snapped = snapOffsetToGrid(canvasPosition);
    final component = CircuitComponent(type: type, position: snapped);
    _applyAdd(component, record: true);
    bankDragType = null;
    bankDragPosition = null;
    notifyListeners();
  }

  /// Called when the user clicks a component in the bank (adds near centre).
  void addFromBank(ComponentType type, Offset canvasCentre) {
    final snapped = snapOffsetToGrid(canvasCentre);
    final component = CircuitComponent(type: type, position: snapped);
    _applyAdd(component, record: true);
    notifyListeners();
  }

  // -- Bank drag ghost ------------------------------------------------------

  void updateBankDrag(ComponentType type, Offset position) {
    bankDragType = type;
    bankDragPosition = position;
    notifyListeners();
  }

  void cancelBankDrag() {
    bankDragType = null;
    bankDragPosition = null;
    notifyListeners();
  }

  // -- Selection ------------------------------------------------------------

  /// Selects a single component. Clears previous selection unless [additive].
  void selectComponent(int id, {bool additive = false}) {
    if (!additive) _selectedIds.clear();
    _selectedIds.add(id);
    notifyListeners();
  }

  /// Clears the entire selection.
  void clearSelection() {
    if (_selectedIds.isEmpty) return;
    _selectedIds.clear();
    notifyListeners();
  }

  // -- Rubber-band ----------------------------------------------------------

  void startRubberBand(Offset position) {
    selectionStart = position;
    selectionCurrent = position;
    _selectedIds.clear();
    notifyListeners();
  }

  void updateRubberBand(Offset position) {
    selectionCurrent = position;
    final rect = selectionRect!;
    _selectedIds.clear();
    for (final c in _components) {
      if (rect.contains(c.position)) {
        _selectedIds.add(c.id);
      }
    }
    notifyListeners();
  }

  void endRubberBand() {
    selectionStart = null;
    selectionCurrent = null;
    notifyListeners();
  }

  // -- Moving components ----------------------------------------------------

  /// Records component positions at the start of a drag.
  void beginMove() {
    _moveOrigins = {
      for (final id in _selectedIds)
        id: _components.firstWhere((c) => c.id == id).position,
    };
  }

  /// Translates selected components by [delta] from their recorded origins.
  void updateMove(Offset delta) {
    for (final id in _selectedIds) {
      final origin = _moveOrigins[id];
      if (origin == null) continue;
      final comp = _components.firstWhere((c) => c.id == id);
      comp.position = snapOffsetToGrid(origin + delta);
    }
    notifyListeners();
  }

  /// Finalises the move, snaps endpoints if nearby, and records undo action.
  void endMove() {
    final moves = <(int, Offset, Offset)>[];
    for (final id in _selectedIds) {
      final origin = _moveOrigins[id];
      if (origin == null) continue;
      final comp = _components.firstWhere((c) => c.id == id);
      final snapped = _snapToNearestEndpoint(comp);
      if (snapped != null) comp.position = snapped;
      if (comp.position != origin) {
        moves.add((id, origin, comp.position));
      }
    }
    if (moves.isNotEmpty) _record(MoveAction(moves));
    _moveOrigins = {};
    notifyListeners();
  }

  // -- Rotation -------------------------------------------------------------

  /// Rotates all selected components by 90° clockwise.
  void rotateSelectionClockwise() {
    const quarter = 1.5707963267948966; // π/2
    final rotations = <(int, double, double)>[];
    for (final id in _selectedIds) {
      final comp = _components.firstWhere((c) => c.id == id);
      final oldRot = comp.rotation;
      final newRot = (oldRot + quarter) % (2 * 3.141592653589793);
      comp.rotation = newRot;
      rotations.add((id, oldRot, newRot));
    }
    if (rotations.isNotEmpty) _record(RotateAction(rotations));
    notifyListeners();
  }

  // -- Deletion -------------------------------------------------------------

  /// Removes all selected components and any connections involving them.
  void deleteSelected() {
    if (_selectedIds.isEmpty) return;
    final toRemove = _components
        .where((c) => _selectedIds.contains(c.id))
        .toList();
    final removedConns = _connections
        .where(
          (cn) =>
              _selectedIds.contains(cn.componentA) ||
              _selectedIds.contains(cn.componentB),
        )
        .toList();
    _record(RemoveAction(List.of(toRemove), List.of(removedConns)));
    _applyRemove(_selectedIds);
    _selectedIds.clear();
    notifyListeners();
  }

  /// Removes a single component by [id].
  void deleteComponent(int id) {
    final comp = _components.firstWhere((c) => c.id == id);
    final removedConns = _connections
        .where((cn) => cn.componentA == id || cn.componentB == id)
        .toList();
    _record(RemoveAction([comp], removedConns));
    _applyRemove({id});
    _selectedIds.remove(id);
    notifyListeners();
  }

  // -- Property editing -----------------------------------------------------

  /// Updates a single property on [componentId], recording an undo action.
  void updateProperty(int componentId, String key, double newValue) {
    final comp = _components.firstWhere((c) => c.id == componentId);
    final oldValue = comp.properties[key];
    if (oldValue == null || oldValue == newValue) return;
    comp.properties[key] = newValue;
    _record(
      PropertyAction(
        componentId: componentId,
        key: key,
        oldValue: oldValue,
        newValue: newValue,
      ),
    );
    notifyListeners();
  }

  // -- Undo / redo ----------------------------------------------------------

  void undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    _reverseAction(action);
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    _applyAction(action);
    notifyListeners();
  }

  // -- Queries --------------------------------------------------------------

  /// Returns the topmost component within [hitRadius] px of [position], or null.
  CircuitComponent? hitTest(Offset position, {double hitRadius = kGridSize}) {
    for (final comp in _components.reversed) {
      if ((comp.position - position).distance <= hitRadius) return comp;
    }
    return null;
  }

  // -- Persistence ----------------------------------------------------------

  /// The database id of the currently loaded circuit, or null for a new circuit.
  int? currentCircuitId;

  /// Saves the current canvas to [storage] under [name].
  ///
  /// If [currentCircuitId] is set the existing record is updated; otherwise a
  /// new record is inserted and [currentCircuitId] is updated accordingly.
  Future<void> saveToStorage(StorageService storage, String name) async {
    final bytes = CircuitSerializer.encode(_components, _connections);
    if (currentCircuitId case final id?) {
      await storage.updateCircuit(id, name, bytes);
    } else {
      currentCircuitId = await storage.saveCircuit(name, bytes);
    }
  }

  /// Replaces the current canvas state with the circuit stored in [circuit].
  void loadFromCircuit(Circuit circuit) {
    final (components, connections) = CircuitSerializer.decode(
      circuit.protoBytes,
    );
    _components
      ..clear()
      ..addAll(components);
    _connections
      ..clear()
      ..addAll(connections);
    _selectedIds.clear();
    _undoStack.clear();
    _redoStack.clear();
    _moveOrigins = {};
    selectionStart = null;
    selectionCurrent = null;
    bankDragType = null;
    bankDragPosition = null;
    currentCircuitId = circuit.id;

    // Advance the id counter past any ids in the loaded data so new components
    // don't clash with existing ones.
    for (final c in _components) {
      ensureNextIdAbove(c.id);
    }

    notifyListeners();
  }

  /// Clears the canvas to a blank state (new circuit).
  void clearCanvas() {
    _components.clear();
    _connections.clear();
    _selectedIds.clear();
    _undoStack.clear();
    _redoStack.clear();
    _moveOrigins = {};
    selectionStart = null;
    selectionCurrent = null;
    bankDragType = null;
    bankDragPosition = null;
    currentCircuitId = null;
    notifyListeners();
  }

  // =========================================================================
  // Private helpers
  // =========================================================================

  void _applyAdd(CircuitComponent component, {required bool record}) {
    _components.add(component);
    if (record) _record(AddAction(component));
    _trySnapNewComponent(component);
  }

  void _applyRemove(Set<int> ids) {
    _components.removeWhere((c) => ids.contains(c.id));
    _connections.removeWhere(
      (cn) => ids.contains(cn.componentA) || ids.contains(cn.componentB),
    );
  }

  void _record(CanvasAction action) {
    _undoStack.add(action);
    _redoStack.clear();
  }

  void _reverseAction(CanvasAction action) {
    switch (action) {
      case AddAction(:final component):
        _applyRemove({component.id});
      case RemoveAction(:final components, :final connections):
        _components.addAll(components);
        _connections.addAll(connections);
      case MoveAction(:final moves):
        for (final (id, oldPos, _) in moves) {
          _components.firstWhere((c) => c.id == id).position = oldPos;
        }
      case RotateAction(:final rotations):
        for (final (id, oldRot, _) in rotations) {
          _components.firstWhere((c) => c.id == id).rotation = oldRot;
        }
      case PropertyAction(:final componentId, :final key, :final oldValue):
        _components.firstWhere((c) => c.id == componentId).properties[key] =
            oldValue;
    }
  }

  void _applyAction(CanvasAction action) {
    switch (action) {
      case AddAction(:final component):
        _components.add(component);
      case RemoveAction(:final components, :final connections):
        _applyRemove(components.map((c) => c.id).toSet());
        _connections.removeWhere((cn) => connections.contains(cn));
      case MoveAction(:final moves):
        for (final (id, _, newPos) in moves) {
          _components.firstWhere((c) => c.id == id).position = newPos;
        }
      case RotateAction(:final rotations):
        for (final (id, _, newRot) in rotations) {
          _components.firstWhere((c) => c.id == id).rotation = newRot;
        }
      case PropertyAction(:final componentId, :final key, :final newValue):
        _components.firstWhere((c) => c.id == componentId).properties[key] =
            newValue;
    }
  }

  /// Tries to snap a newly placed/moved [comp] to any nearby endpoint.
  void _trySnapNewComponent(CircuitComponent comp) {
    final myEndpoints = comp.absoluteEndpoints;
    for (int myIdx = 0; myIdx < myEndpoints.length; myIdx++) {
      final myEp = myEndpoints[myIdx];
      for (final other in _components) {
        if (other.id == comp.id) continue;
        final otherEndpoints = other.absoluteEndpoints;
        for (int otherIdx = 0; otherIdx < otherEndpoints.length; otherIdx++) {
          if ((myEp - otherEndpoints[otherIdx]).distance < kSnapRadius) {
            final delta = otherEndpoints[otherIdx] - myEp;
            comp.position = comp.position + delta;
            _addConnectionIfMissing(
              Connection(
                componentA: comp.id,
                endpointIndexA: myIdx,
                componentB: other.id,
                endpointIndexB: otherIdx,
              ),
            );
            return;
          }
        }
      }
    }
  }

  /// Returns a snapped position for [comp] after a move, or null.
  Offset? _snapToNearestEndpoint(CircuitComponent comp) {
    final myEndpoints = comp.absoluteEndpoints;
    for (int myIdx = 0; myIdx < myEndpoints.length; myIdx++) {
      final myEp = myEndpoints[myIdx];
      for (final other in _components) {
        if (other.id == comp.id) continue;
        final otherEndpoints = other.absoluteEndpoints;
        for (int otherIdx = 0; otherIdx < otherEndpoints.length; otherIdx++) {
          if ((myEp - otherEndpoints[otherIdx]).distance < kSnapRadius) {
            final delta = otherEndpoints[otherIdx] - myEp;
            _addConnectionIfMissing(
              Connection(
                componentA: comp.id,
                endpointIndexA: myIdx,
                componentB: other.id,
                endpointIndexB: otherIdx,
              ),
            );
            return comp.position + delta;
          }
        }
      }
    }
    return null;
  }

  void _addConnectionIfMissing(Connection conn) {
    if (!_connections.contains(conn)) _connections.add(conn);
  }
}
