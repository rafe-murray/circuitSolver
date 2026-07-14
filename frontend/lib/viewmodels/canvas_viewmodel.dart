import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/circuit_component.dart';
import '../models/component_type.dart';
import '../models/editor_tool.dart';
import '../models/selection.dart';
import '../models/selection_shape.dart';
import '../services/circuit_serializer.dart';
import '../services/storage.dart';

// ---------------------------------------------------------------------------
// Undo / redo action data records
// ---------------------------------------------------------------------------

/// Base class for reversible canvas action data records.
///
/// These are pure data objects — they carry the information needed for
/// [CanvasViewModel.reverseAction] and [CanvasViewModel.applyAction] to
/// mutate canvas state.  All history management (stack push/pop, canUndo /
/// canRedo) lives in the [HistoryStack] in `commands/command.dart`.
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
  // List of (id, oldEndpoint0, newEndpoint0, oldEndpoint1, newEndpoint1)
  final List<(int, Offset, Offset, Offset, Offset)> moves;
}

/// Records a rotation (and the implicit position change caused by orbiting the
/// group centroid) for one or more components.
///
/// Each entry stores the old and new endpoint positions — rotation is derived
/// from the endpoints automatically, so there is no need to store angles
/// separately.
final class RotateAction extends CanvasAction {
  RotateAction(this.rotations);
  // List of (id, oldEndpoint0, newEndpoint0, oldEndpoint1, newEndpoint1)
  final List<(int, Offset, Offset, Offset, Offset)> rotations;
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

/// Records a change to the set of selected component ids.
final class SelectionAction extends CanvasAction {
  SelectionAction({required this.oldIds, required this.newIds});

  final Set<int> oldIds;
  final Set<int> newIds;
}

/// Records a change to the active editor tool.
final class SetToolAction extends CanvasAction {
  SetToolAction({required this.oldTool, required this.newTool});

  final EditorTool oldTool;
  final EditorTool newTool;
}

/// Records a change to the component type selected for insertion.
final class SelectForInsertionAction extends CanvasAction {
  SelectForInsertionAction({required this.oldType, required this.newType});

  final ComponentType? oldType;
  final ComponentType? newType;
}

// ---------------------------------------------------------------------------
// Selection mode
// ---------------------------------------------------------------------------

/// How a new selection gesture modifies the current selection set.
enum SelectionMode {
  /// Replace the current selection with the new one.
  replace,

  /// Add new components to the existing selection.
  additive,

  /// Remove new components from the existing selection.
  subtractive,
}

// ---------------------------------------------------------------------------
// Internal selection-origin tracking
// ---------------------------------------------------------------------------

/// How the most recent committed selection was made.
///
/// Determines which [SelectionShape] variant [CanvasViewModel.selectionShape]
/// returns.
enum _SelectionOrigin {
  /// No selection has been made yet (or the selection was cleared).
  none,

  /// The selection was committed from a rubber-band marquee.
  rubberBand,

  /// The selection was committed from a lasso gesture.
  lasso,

  /// The selection was made by clicking, wand, SelectAll, or undo/redo.
  other,
}

// ---------------------------------------------------------------------------
// CanvasViewModel
// ---------------------------------------------------------------------------

/// The central ViewModel for the circuit canvas.
///
/// Holds all components, connections, selection state, active tool, and the
/// transient drag state for move / rotate / transform operations.
///
/// Undo/redo history is managed externally by the [HistoryStack] singleton
/// (see `commands/command.dart`).  Commands call the public mutation helpers
/// ([applyAdd], [applyRemove], [commitMove], etc.) and then push the
/// resulting [CanvasAction] to the stack themselves.
///
/// Widgets listen via [ListenableBuilder] or `Provider.of`.
class CanvasViewModel extends ChangeNotifier {
  CanvasViewModel();

  // -- Components & connections ---------------------------------------------

  final List<CircuitComponent> _components = [];
  final List<Connection> _connections = [];

  List<CircuitComponent> get components => List.unmodifiable(_components);
  List<Connection> get connections => List.unmodifiable(_connections);

  // -- Active tool ----------------------------------------------------------

  /// The currently active editing tool.
  EditorTool activeTool = EditorTool.move;

  /// Sets [activeTool] and notifies listeners.
  ///
  /// Does **not** record history — callers (commands) are responsible for
  /// pushing the corresponding [SetToolAction] to the [HistoryStack].
  void setTool(EditorTool tool) {
    if (activeTool == tool) return;
    // Cancel any in-progress operations when switching tools.
    _cancelInProgressOperations();
    activeTool = tool;
    notifyListeners();
  }

  // -- Component selected for insertion -------------------------------------

  /// The component type currently selected for insertion with [EditorTool.addComponent].
  ///
  /// `null` means no component is primed for insertion.
  ComponentType? selectedComponentForInsertion;

  /// Selects [type] for insertion (or deselects if already selected).
  ///
  /// Does **not** record history — callers (commands) are responsible for
  /// pushing the corresponding [SelectForInsertionAction] to the [HistoryStack].
  void selectComponentForInsertion(ComponentType? type) {
    if (selectedComponentForInsertion == type) {
      selectedComponentForInsertion = null;
    } else {
      selectedComponentForInsertion = type;
    }
    notifyListeners();
  }

  // -- Selection ------------------------------------------------------------

  /// The current selection state.
  ///
  /// Commands and widgets should read and modify the selection through this
  /// object. [selectedIds] is a convenience alias for [selection.ids].
  final Selection selection = Selection();

  /// An unmodifiable view of the currently selected component ids.
  Set<int> get selectedIds => selection.ids;

  bool isSelected(int id) => selection.contains(id);

  // -- Selection origin & shape ---------------------------------------------

  _SelectionOrigin _selectionOrigin = _SelectionOrigin.none;

  /// The committed rubber-band rect from the most recent marquee selection.
  Rect? _lastRubberBandRect;

  /// The committed lasso path from the most recent lasso selection.
  List<Offset>? _lastLassoPath;

  /// The [SelectionShape] that describes how the current selection should be
  /// drawn.
  ///
  /// Returns [EmptySelectionShape] when nothing is selected,
  /// [RubberBandSelectionShape] or [LassoSelectionShape] when the selection
  /// was made by drawing a marquee or lasso, and [HullSelectionShape]
  /// otherwise.
  SelectionShape get selectionShape {
    if (selection.isEmpty) return const EmptySelectionShape();
    switch (_selectionOrigin) {
      case _SelectionOrigin.rubberBand:
        final rect = _lastRubberBandRect;
        if (rect != null) return RubberBandSelectionShape(rect: rect);
      case _SelectionOrigin.lasso:
        final path = _lastLassoPath;
        if (path != null) return LassoSelectionShape(points: path);
      case _SelectionOrigin.none || _SelectionOrigin.other:
        break;
    }
    return _buildHullShape();
  }

  // -- Active drag-from-bank ghost ------------------------------------------

  /// The component type being dragged from the bank (null when no bank drag).
  ComponentType? bankDragType;

  /// Current canvas position of the bank drag ghost.
  Offset? bankDragPosition;

  // -- In-canvas move state (Move tool) ------------------------------------

  /// Saved endpoint pairs of selected components at drag start.
  ///
  /// Structure: componentId → (endpoint0, endpoint1).
  Map<int, (Offset, Offset)> _moveOrigins = {};

  // -- Rubber-band selection ------------------------------------------------

  Offset? selectionStart;
  Offset? selectionCurrent;

  Rect? get selectionRect {
    final a = selectionStart;
    final b = selectionCurrent;
    if (a == null || b == null) return null;
    return Rect.fromPoints(a, b);
  }

  // -- Lasso selection ------------------------------------------------------

  /// Points of the current lasso path. `null` when not in a lasso drag.
  List<Offset>? lassoPath;

  // -- Rotate tool state ----------------------------------------------------

  /// The centroid of the selection at the time the rotate drag started.
  ///
  /// Exposed for the canvas painter to draw a rotation indicator.
  Offset? _rotateCentroid;

  /// The centroid around which the current rotate drag is occurring.
  Offset? get rotateCentroid => _rotateCentroid;

  /// The angle from the centroid to the pointer at drag start.
  double _rotateStartAngle = 0.0;

  /// Original endpoint pairs of selected components at drag start, keyed by id.
  Map<int, (Offset, Offset)> _rotateOrigins = {};

  // -- Transform tool state (endpoint / midpoint drag) ----------------------

  /// The component whose endpoint is being dragged, if any.
  CircuitComponent? _transformComponent;

  /// Index of the endpoint being dragged (0 or 1), or `null` for midpoint drag.
  int? _transformEndpointIndex;

  /// Original endpoint0 of [_transformComponent] at the start of the drag.
  Offset? _transformOriginEp0;

  /// Original endpoint1 of [_transformComponent] at the start of the drag.
  Offset? _transformOriginEp1;

  /// Whether the transform drag should move the component in isolation
  /// (i.e. not drag connected endpoints). Activated by the Alt modifier.
  bool _transformSingleMode = false;

  // -- Transform: exposed state for the painter ----------------------------

  /// The set of component ids for which transform handles should be shown.
  ///
  /// Currently this exposes all components, but the painter only draws handles
  /// when the transform tool is active.
  List<CircuitComponent> get transformComponents =>
      List.unmodifiable(_components);

  // =========================================================================
  // Public API
  // =========================================================================

  // -- Selection ------------------------------------------------------------

  /// Selects a single component. Clears previous selection unless [additive].
  ///
  /// Sets the selection origin to [_SelectionOrigin.other].
  void selectComponent(int id, {bool additive = false}) {
    selection.select(id, additive: additive);
    _selectionOrigin = _SelectionOrigin.other;
    notifyListeners();
  }

  /// Replaces the selection with [id] as the sole selected component.
  void setOnlySelectedId(int id) {
    selection.setAll({id});
    _selectionOrigin = _SelectionOrigin.other;
    notifyListeners();
  }

  /// Removes [id] from the selection without affecting other selected ids.
  void deselect(int id) {
    selection.deselect(id);
    _selectionOrigin = _SelectionOrigin.other;
    notifyListeners();
  }

  /// Clears the entire selection.
  void clearSelection() {
    selection.clear();
    _selectionOrigin = _SelectionOrigin.none;
    notifyListeners();
  }

  // -- Rubber-band ----------------------------------------------------------

  /// Begins a rubber-band selection at [position].
  ///
  /// [mode] controls whether the existing selection is replaced, extended, or reduced.
  void startRubberBand(
    Offset position, {
    SelectionMode mode = SelectionMode.replace,
  }) {
    selectionStart = position;
    selectionCurrent = position;
    if (mode == SelectionMode.replace) selection.clear();
    notifyListeners();
  }

  /// Updates the rubber-band rectangle and the interim selection.
  void updateRubberBand(
    Offset position, {
    SelectionMode mode = SelectionMode.replace,
  }) {
    selectionCurrent = position;
    final rect = selectionRect!;
    final inside = _components
        .where((c) => rect.contains(c.position))
        .map((c) => c.id)
        .toSet();

    switch (mode) {
      case SelectionMode.replace:
        selection.setAll(inside);
      case SelectionMode.additive:
        selection.addAll(inside);
      case SelectionMode.subtractive:
        selection.removeAll(inside);
    }
    notifyListeners();
  }

  /// Finalises the rubber-band selection and records the committed rect.
  void endRubberBand() {
    _lastRubberBandRect = selectionRect;
    _selectionOrigin = selection.isEmpty
        ? _SelectionOrigin.none
        : _SelectionOrigin.rubberBand;
    selectionStart = null;
    selectionCurrent = null;
    notifyListeners();
  }

  // -- Lasso selection ------------------------------------------------------

  /// Begins tracing a lasso shape at [position].
  void startLasso(
    Offset position, {
    SelectionMode mode = SelectionMode.replace,
  }) {
    lassoPath = [position];
    if (mode == SelectionMode.replace) selection.clear();
    notifyListeners();
  }

  /// Appends a point to the lasso path and updates the interim selection.
  void updateLasso(
    Offset position, {
    SelectionMode mode = SelectionMode.replace,
  }) {
    lassoPath?.add(position);
    final path = lassoPath;
    if (path == null || path.length < 3) {
      notifyListeners();
      return;
    }

    final inside = _components
        .where((c) => _isPointInPolygon(c.position, path))
        .map((c) => c.id)
        .toSet();

    switch (mode) {
      case SelectionMode.replace:
        selection.setAll(inside);
      case SelectionMode.additive:
        selection.addAll(inside);
      case SelectionMode.subtractive:
        selection.removeAll(inside);
    }
    notifyListeners();
  }

  /// Finalises the lasso selection and records the committed path.
  void endLasso() {
    final path = lassoPath;
    if (path != null && path.length >= 3) {
      _lastLassoPath = List.of(path);
      _selectionOrigin = selection.isEmpty
          ? _SelectionOrigin.none
          : _SelectionOrigin.lasso;
    } else {
      _selectionOrigin = selection.isEmpty
          ? _SelectionOrigin.none
          : _SelectionOrigin.other;
    }
    lassoPath = null;
    notifyListeners();
  }

  // -- Wand selection -------------------------------------------------------

  /// Selects all components connected (directly or transitively) to [componentId].
  ///
  /// [mode] controls how the result merges with the existing selection.
  void wandSelect(
    int componentId, {
    SelectionMode mode = SelectionMode.replace,
  }) {
    final reached = _bfsConnected(componentId);

    switch (mode) {
      case SelectionMode.replace:
        selection.setAll(reached);
      case SelectionMode.additive:
        selection.addAll(reached);
      case SelectionMode.subtractive:
        selection.removeAll(reached);
    }
    _selectionOrigin = _SelectionOrigin.other;
    notifyListeners();
  }

  // -- Moving components (Move tool) ----------------------------------------

  /// Records component endpoint positions at the start of a drag.
  void beginMove() {
    _moveOrigins = {for (final id in selection.ids) id: _endpointPair(id)};
  }

  /// Translates selected components by [delta] from their recorded origins.
  ///
  /// For connections between a selected component and a non-selected component,
  /// only the **shared endpoint** of the non-selected component is updated to
  /// track the selected component's endpoint.  The non-selected component's
  /// body (the other endpoint, and therefore the derived centre and rotation)
  /// adjusts naturally because [position] and [rotation] are derived from the
  /// two endpoint positions.
  void updateMove(Offset delta) {
    // Move all selected components (both endpoints translate by delta).
    for (final id in selection.ids) {
      final origins = _moveOrigins[id];
      if (origins == null) continue;
      final (ep0, ep1) = origins;
      final comp = _componentById(id);
      comp.endpoint0 = snapOffsetToGrid(ep0 + delta);
      comp.endpoint1 = snapOffsetToGrid(ep1 + delta);
    }

    // For each connection between a selected and a non-selected component,
    // update only the shared endpoint of the non-selected component so it
    // tracks the selected component's endpoint exactly.
    for (final conn in _connections) {
      final aSelected = selection.contains(conn.componentA);
      final bSelected = selection.contains(conn.componentB);
      if (aSelected == bSelected) continue; // both selected or neither

      final int selectedId = aSelected ? conn.componentA : conn.componentB;
      final int followerId = aSelected ? conn.componentB : conn.componentA;
      final int selectedEpIdx = aSelected
          ? conn.endpointIndexA
          : conn.endpointIndexB;
      final int followerEpIdx = aSelected
          ? conn.endpointIndexB
          : conn.endpointIndexA;

      final selectedComp = _componentById(selectedId);
      final followerComp = _componentById(followerId);

      // The selected endpoint's new absolute position (already moved above).
      final selectedEp = selectedComp.absoluteEndpoints[selectedEpIdx];

      // Update only the connected endpoint of the follower.
      if (followerEpIdx == 0) {
        followerComp.endpoint0 = selectedEp;
      } else {
        followerComp.endpoint1 = selectedEp;
      }
    }

    notifyListeners();
  }

  /// Snaps endpoints, computes the list of moves, clears drag state, and
  /// returns the move list for the caller to push to history.
  ///
  /// Called by [EndMoveCommand] to finalise the drag.
  List<(int, Offset, Offset, Offset, Offset)> commitMove() {
    final moves = <(int, Offset, Offset, Offset, Offset)>[];

    // Collect all ids that were involved: selected + their connected followers.
    final involvedIds = <int>{...selection.ids};
    for (final conn in _connections) {
      final aSelected = selection.contains(conn.componentA);
      final bSelected = selection.contains(conn.componentB);
      if (aSelected && !bSelected) involvedIds.add(conn.componentB);
      if (bSelected && !aSelected) involvedIds.add(conn.componentA);
    }

    // Snap both endpoints for selected components; followers are already at the
    // correct position (coincident with the selected endpoint they track).
    for (final id in involvedIds) {
      final origins = _moveOrigins[id];
      final comp = _componentById(id);

      if (selection.contains(id)) {
        // Selected: snap both endpoints to grid, then try to snap to a nearby
        // component endpoint.
        comp.endpoint0 = snapOffsetToGrid(comp.endpoint0);
        comp.endpoint1 = snapOffsetToGrid(comp.endpoint1);
        _snapToNearestEndpoint(comp);
      }
      // Followers: endpoints were already set precisely during updateMove.

      final oldEp0 = origins?.$1 ?? comp.endpoint0;
      final oldEp1 = origins?.$2 ?? comp.endpoint1;
      if (comp.endpoint0 != oldEp0 || comp.endpoint1 != oldEp1) {
        moves.add((id, oldEp0, comp.endpoint0, oldEp1, comp.endpoint1));
      }
    }

    _moveOrigins = {};
    notifyListeners();
    return moves;
  }

  // -- Rotation -------------------------------------------------------------

  /// Begins a free-rotation drag. [pointerPosition] is the initial pointer
  /// position in canvas coordinates.
  void beginRotateDrag(Offset pointerPosition) {
    if (selection.isEmpty) return;
    _rotateCentroid = _selectionCentroid();
    final centroid = _rotateCentroid!;
    _rotateStartAngle = math.atan2(
      pointerPosition.dy - centroid.dy,
      pointerPosition.dx - centroid.dx,
    );
    _rotateOrigins = {for (final id in selection.ids) id: _endpointPair(id)};
  }

  /// Updates the rotation of selected components based on the current pointer.
  ///
  /// All selected components orbit around the group centroid (not their own
  /// centres). The snap-to-90° threshold prevents the rotation from being
  /// locked to cardinal angles the whole time — only near multiples of 90°.
  void updateRotateDrag(Offset pointerPosition) {
    final centroid = _rotateCentroid;
    if (centroid == null) return;

    final currentAngle = math.atan2(
      pointerPosition.dy - centroid.dy,
      pointerPosition.dx - centroid.dx,
    );
    var delta = currentAngle - _rotateStartAngle;

    // Snap to 90° if within 10°, but leave the rotation free otherwise.
    const snapThreshold = 10.0 * math.pi / 180.0;
    const quarter = math.pi / 2;
    final snappedDelta = (delta / quarter).round() * quarter;
    if ((delta - snappedDelta).abs() < snapThreshold) {
      delta = snappedDelta;
    }

    for (final id in selection.ids) {
      final origins = _rotateOrigins[id];
      if (origins == null) continue;
      final (originEp0, originEp1) = origins;
      final comp = _componentById(id);

      // Rotate both endpoints around the centroid.
      comp.endpoint0 = _rotateAround(originEp0, centroid, delta);
      comp.endpoint1 = _rotateAround(originEp1, centroid, delta);
    }
    notifyListeners();
  }

  /// Computes the list of endpoint changes, clears drag state, and returns
  /// them for the caller to push to history.
  ///
  /// Called by [EndRotateDragCommand] to finalise the drag.
  List<(int, Offset, Offset, Offset, Offset)> commitRotateDrag() {
    final rotations = <(int, Offset, Offset, Offset, Offset)>[];
    for (final id in selection.ids) {
      final origins = _rotateOrigins[id];
      if (origins == null) continue;
      final comp = _componentById(id);
      final (oldEp0, oldEp1) = origins;
      if (comp.endpoint0 != oldEp0 || comp.endpoint1 != oldEp1) {
        rotations.add((id, oldEp0, comp.endpoint0, oldEp1, comp.endpoint1));
      }
    }
    _rotateCentroid = null;
    _rotateStartAngle = 0.0;
    _rotateOrigins = {};
    notifyListeners();
    return rotations;
  }

  // -- Transform tool -------------------------------------------------------

  /// Hit-tests [position] against the endpoints and midpoints of all components.
  ///
  /// Returns `(component, endpointIndex)` when an endpoint is hit, or
  /// `(component, -1)` when the midpoint (centre) is hit. Returns `null` when
  /// nothing is hit.
  (CircuitComponent, int)? endpointHitTest(Offset position) {
    const hitRadius = kGridSize * 0.8;
    for (final comp in _components.reversed) {
      // Check endpoints.
      final eps = comp.absoluteEndpoints;
      for (int i = 0; i < eps.length; i++) {
        if ((eps[i] - position).distance <= hitRadius) return (comp, i);
      }
      // Check midpoint (component centre).
      if ((comp.position - position).distance <= hitRadius) return (comp, -1);
    }
    return null;
  }

  /// Begins a transform drag.
  ///
  /// [component] is the component to transform. [endpointIndex] is the index
  /// of the endpoint being dragged, or `-1` for a midpoint (move) drag.
  /// [singleMode] — when `true`, connected components are not dragged along.
  void beginTransformDrag(
    CircuitComponent component,
    int endpointIndex, {
    bool singleMode = false,
  }) {
    _transformComponent = component;
    _transformEndpointIndex = endpointIndex;
    _transformOriginEp0 = component.endpoint0;
    _transformOriginEp1 = component.endpoint1;
    _transformSingleMode = singleMode;

    if (endpointIndex == -1) {
      // Midpoint drag — record origins for connected followers too.
      if (!singleMode) {
        _moveOrigins = {component.id: _endpointPair(component.id)};
        for (final conn in _connections) {
          if (conn.componentA == component.id) {
            _moveOrigins.putIfAbsent(
              conn.componentB,
              () => _endpointPair(conn.componentB),
            );
          } else if (conn.componentB == component.id) {
            _moveOrigins.putIfAbsent(
              conn.componentA,
              () => _endpointPair(conn.componentA),
            );
          }
        }
      }
    }
  }

  /// Updates the transform drag to [position].
  void updateTransformDrag(Offset position) {
    final comp = _transformComponent;
    if (comp == null) return;
    final epIdx = _transformEndpointIndex;

    if (epIdx == null || epIdx == -1) {
      // Midpoint drag: move both endpoints by the same delta.
      final originEp0 = _transformOriginEp0;
      final originEp1 = _transformOriginEp1;
      if (originEp0 == null || originEp1 == null) return;

      final originMid = (originEp0 + originEp1) / 2;
      final delta = position - originMid;
      comp.endpoint0 = snapOffsetToGrid(originEp0 + delta);
      comp.endpoint1 = snapOffsetToGrid(originEp1 + delta);

      if (!_transformSingleMode) {
        // Live-follow: update the shared endpoint of each connected component.
        for (final conn in _connections) {
          final isA = conn.componentA == comp.id;
          final isB = conn.componentB == comp.id;
          if (!isA && !isB) continue;

          final followerEpIdx = isA ? conn.endpointIndexB : conn.endpointIndexA;
          final selectedEpIdx = isA ? conn.endpointIndexA : conn.endpointIndexB;
          final followerId = isA ? conn.componentB : conn.componentA;

          final followerComp = _componentById(followerId);
          final selectedEp = comp.absoluteEndpoints[selectedEpIdx];
          if (followerEpIdx == 0) {
            followerComp.endpoint0 = selectedEp;
          } else {
            followerComp.endpoint1 = selectedEp;
          }
        }
      }
    } else {
      // Endpoint drag: reposition the chosen endpoint to the pointer position.
      // The endpoint is NOT snapped to grid here — it should follow freely so
      // that arbitrary-angle wires and connections are possible. Snapping to
      // other endpoints still happens on commit.
      if (epIdx == 0) {
        comp.endpoint0 = position;
      } else {
        comp.endpoint1 = position;
      }

      if (!_transformSingleMode) {
        // Move connected components that share this endpoint.
        for (final conn in _connections) {
          final isA =
              conn.componentA == comp.id && conn.endpointIndexA == epIdx;
          final isB =
              conn.componentB == comp.id && conn.endpointIndexB == epIdx;
          if (!isA && !isB) continue;

          final followerId = isA ? conn.componentB : conn.componentA;
          final followerEpIdx = isA ? conn.endpointIndexB : conn.endpointIndexA;
          final followerComp = _componentById(followerId);
          if (followerEpIdx == 0) {
            followerComp.endpoint0 = position;
          } else {
            followerComp.endpoint1 = position;
          }
        }
      }
    }

    notifyListeners();
  }

  /// Computes the list of moved endpoint pairs, clears drag state, and returns
  /// it for the caller to push to history.
  ///
  /// Called by [EndTransformDragCommand] to finalise the drag.
  List<(int, Offset, Offset, Offset, Offset)> commitTransformDrag() {
    final comp = _transformComponent;
    final originEp0 = _transformOriginEp0;
    final originEp1 = _transformOriginEp1;
    if (comp == null || originEp0 == null || originEp1 == null) return [];

    final moves = <(int, Offset, Offset, Offset, Offset)>[];

    // Try to snap to nearby endpoints on commit.
    _snapToNearestEndpoint(comp);

    if (comp.endpoint0 != originEp0 || comp.endpoint1 != originEp1) {
      moves.add((
        comp.id,
        originEp0,
        comp.endpoint0,
        originEp1,
        comp.endpoint1,
      ));
    }

    // Record follower moves.
    for (final entry in _moveOrigins.entries) {
      if (entry.key == comp.id) continue;
      final follower = _componentById(entry.key);
      final (oldEp0, oldEp1) = entry.value;
      if (follower.endpoint0 != oldEp0 || follower.endpoint1 != oldEp1) {
        moves.add((
          entry.key,
          oldEp0,
          follower.endpoint0,
          oldEp1,
          follower.endpoint1,
        ));
      }
    }

    _transformComponent = null;
    _transformEndpointIndex = null;
    _transformOriginEp0 = null;
    _transformOriginEp1 = null;
    _transformSingleMode = false;
    _moveOrigins = {};
    notifyListeners();
    return moves;
  }

  // -- Queries --------------------------------------------------------------

  /// Returns the topmost component within [hitRadius] px of [position], or null.
  CircuitComponent? hitTest(Offset position, {double hitRadius = kGridSize}) {
    for (final comp in _components.reversed) {
      if ((comp.position - position).distance <= hitRadius) return comp;
    }
    return null;
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
  ///
  /// Also clears the [HistoryStack] via the provided [clearHistory] callback
  /// so that undo/redo state does not bleed across circuits.
  void loadFromCircuit(
    Circuit circuit, {
    required void Function() clearHistory,
  }) {
    final (components, connections) = CircuitSerializer.decode(
      circuit.protoBytes,
    );
    _components
      ..clear()
      ..addAll(components);
    _connections
      ..clear()
      ..addAll(connections);
    selection.clear();
    _selectionOrigin = _SelectionOrigin.none;
    _lastRubberBandRect = null;
    _lastLassoPath = null;
    _moveOrigins = {};
    selectionStart = null;
    selectionCurrent = null;
    lassoPath = null;
    bankDragType = null;
    bankDragPosition = null;
    currentCircuitId = circuit.id;

    // Advance the id counter past any ids in the loaded data so new components
    // don't clash with existing ones.
    for (final c in _components) {
      ensureNextIdAbove(c.id);
    }

    clearHistory();
    notifyListeners();
  }

  /// Clears the canvas to a blank state (new circuit).
  ///
  /// Also clears the [HistoryStack] via the provided [clearHistory] callback.
  void clearCanvas({required void Function() clearHistory}) {
    _components.clear();
    _connections.clear();
    selection.clear();
    _selectionOrigin = _SelectionOrigin.none;
    _lastRubberBandRect = null;
    _lastLassoPath = null;
    _moveOrigins = {};
    selectionStart = null;
    selectionCurrent = null;
    lassoPath = null;
    bankDragType = null;
    bankDragPosition = null;
    currentCircuitId = null;
    clearHistory();
    notifyListeners();
  }

  // =========================================================================
  // Public mutation helpers (called by Commands)
  // =========================================================================

  /// Adds [component] to the canvas and tries to snap it to nearby endpoints.
  ///
  /// Does **not** record history — callers (Commands) are responsible for
  /// pushing the corresponding [AddAction] to the [HistoryStack].
  void applyAdd(CircuitComponent component) {
    _components.add(component);
    _trySnapNewComponent(component);
    notifyListeners();
  }

  /// Removes all components whose ids are in [ids], together with any
  /// connections referencing them.
  ///
  /// Does **not** record history — callers (Commands) are responsible for
  /// pushing the corresponding [RemoveAction] to the [HistoryStack].
  void applyRemove(Set<int> ids) {
    _components.removeWhere((c) => ids.contains(c.id));
    _connections.removeWhere(
      (cn) => ids.contains(cn.componentA) || ids.contains(cn.componentB),
    );
    notifyListeners();
  }

  /// Reverses [action], restoring the canvas to its state before the action
  /// was executed.
  ///
  /// Called by [HistoryStack.undo].
  void reverseAction(CanvasAction action) {
    switch (action) {
      case AddAction(:final component):
        _components.removeWhere((c) => c.id == component.id);
        _connections.removeWhere(
          (cn) =>
              cn.componentA == component.id || cn.componentB == component.id,
        );
      case RemoveAction(:final components, :final connections):
        _components.addAll(components);
        _connections.addAll(connections);
      case MoveAction(:final moves):
        for (final (id, oldEp0, _, oldEp1, _) in moves) {
          final comp = _componentById(id);
          comp.endpoint0 = oldEp0;
          comp.endpoint1 = oldEp1;
        }
      case RotateAction(:final rotations):
        for (final (id, oldEp0, _, oldEp1, _) in rotations) {
          final comp = _componentById(id);
          comp.endpoint0 = oldEp0;
          comp.endpoint1 = oldEp1;
        }
      case PropertyAction(:final componentId, :final key, :final oldValue):
        _componentById(componentId).properties[key] = oldValue;
      case SelectionAction(:final oldIds):
        selection.setAll(oldIds);
        _selectionOrigin = oldIds.isEmpty
            ? _SelectionOrigin.none
            : _SelectionOrigin.other;
      case SetToolAction(:final oldTool):
        _cancelInProgressOperations();
        activeTool = oldTool;
      case SelectForInsertionAction(:final oldType):
        selectedComponentForInsertion = oldType;
    }
    notifyListeners();
  }

  /// Reapplies [action], restoring the canvas to its state after the action
  /// was originally executed.
  ///
  /// Called by [HistoryStack.redo].
  void applyAction(CanvasAction action) {
    switch (action) {
      case AddAction(:final component):
        _components.add(component);
      case RemoveAction(:final components, :final connections):
        final ids = components.map((c) => c.id).toSet();
        _components.removeWhere((c) => ids.contains(c.id));
        _connections.removeWhere((cn) => connections.contains(cn));
      case MoveAction(:final moves):
        for (final (id, _, newEp0, _, newEp1) in moves) {
          final comp = _componentById(id);
          comp.endpoint0 = newEp0;
          comp.endpoint1 = newEp1;
        }
      case RotateAction(:final rotations):
        for (final (id, _, newEp0, _, newEp1) in rotations) {
          final comp = _componentById(id);
          comp.endpoint0 = newEp0;
          comp.endpoint1 = newEp1;
        }
      case PropertyAction(:final componentId, :final key, :final newValue):
        _componentById(componentId).properties[key] = newValue;
      case SelectionAction(:final newIds):
        selection.setAll(newIds);
        _selectionOrigin = newIds.isEmpty
            ? _SelectionOrigin.none
            : _SelectionOrigin.other;
      case SetToolAction(:final newTool):
        _cancelInProgressOperations();
        activeTool = newTool;
      case SelectForInsertionAction(:final newType):
        selectedComponentForInsertion = newType;
    }
    notifyListeners();
  }

  /// Notifies all listeners without making any state change.
  ///
  /// Used by commands that mutate component fields directly (e.g.
  /// [RotateClockwiseCommand]) and need to trigger a repaint.
  void notifyCanvasListeners() => notifyListeners();

  // =========================================================================
  // Private helpers
  // =========================================================================

  /// Returns the component with [id], throwing if not found.
  CircuitComponent _componentById(int id) =>
      _components.firstWhere((c) => c.id == id);

  /// Returns the current endpoint pair for the component with [id].
  (Offset, Offset) _endpointPair(int id) {
    final c = _componentById(id);
    return (c.endpoint0, c.endpoint1);
  }

  /// Tries to snap a newly placed/moved [comp] to any nearby endpoint.
  ///
  /// Also registers a [Connection] when two endpoints coincide.
  void _trySnapNewComponent(CircuitComponent comp) {
    final myEndpoints = comp.absoluteEndpoints;
    for (int myIdx = 0; myIdx < myEndpoints.length; myIdx++) {
      final myEp = myEndpoints[myIdx];
      for (final other in _components) {
        if (other.id == comp.id) continue;
        final otherEndpoints = other.absoluteEndpoints;
        for (int otherIdx = 0; otherIdx < otherEndpoints.length; otherIdx++) {
          if ((myEp - otherEndpoints[otherIdx]).distance < kSnapRadius) {
            // Snap: move this endpoint to coincide exactly.
            final snapTarget = otherEndpoints[otherIdx];
            final delta = snapTarget - myEp;
            if (myIdx == 0) {
              comp.endpoint0 = comp.endpoint0 + delta;
            } else {
              comp.endpoint1 = comp.endpoint1 + delta;
            }
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

  /// Snaps the endpoints of [comp] after a move, registering new connections
  /// when two endpoints coincide.
  void _snapToNearestEndpoint(CircuitComponent comp) {
    final myEndpoints = comp.absoluteEndpoints;
    for (int myIdx = 0; myIdx < myEndpoints.length; myIdx++) {
      final myEp = myEndpoints[myIdx];
      for (final other in _components) {
        if (other.id == comp.id) continue;
        final otherEndpoints = other.absoluteEndpoints;
        for (int otherIdx = 0; otherIdx < otherEndpoints.length; otherIdx++) {
          if ((myEp - otherEndpoints[otherIdx]).distance < kSnapRadius) {
            final snapTarget = otherEndpoints[otherIdx];
            final delta = snapTarget - myEp;
            // Shift both endpoints so the whole component snaps as one unit.
            comp.endpoint0 = comp.endpoint0 + delta;
            comp.endpoint1 = comp.endpoint1 + delta;
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

  void _addConnectionIfMissing(Connection conn) {
    if (!_connections.contains(conn)) _connections.add(conn);
  }

  /// Computes the centroid (mean position) of all selected components.
  Offset _selectionCentroid() {
    if (selection.isEmpty) return Offset.zero;
    var sum = Offset.zero;
    var count = 0;
    for (final comp in _components) {
      if (selection.contains(comp.id)) {
        sum += comp.position;
        count += 1;
      }
    }
    return count == 0 ? Offset.zero : sum / count.toDouble();
  }

  /// BFS through the connection graph starting at [startId].
  ///
  /// Returns the set of component ids reachable from [startId] via connections.
  Set<int> _bfsConnected(int startId) {
    final visited = <int>{startId};
    final queue = [startId];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      for (final conn in _connections) {
        if (conn.componentA == current && !visited.contains(conn.componentB)) {
          visited.add(conn.componentB);
          queue.add(conn.componentB);
        } else if (conn.componentB == current &&
            !visited.contains(conn.componentA)) {
          visited.add(conn.componentA);
          queue.add(conn.componentA);
        }
      }
    }
    return visited;
  }

  /// Tests whether [point] is inside [polygon] using the winding-number algorithm.
  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    int windingNumber = 0;
    final n = polygon.length;
    for (int i = 0; i < n; i++) {
      final a = polygon[i];
      final b = polygon[(i + 1) % n];
      if (a.dy <= point.dy) {
        if (b.dy > point.dy) {
          // Upward crossing.
          if (_isLeft(a, b, point) > 0) windingNumber += 1;
        }
      } else {
        if (b.dy <= point.dy) {
          // Downward crossing.
          if (_isLeft(a, b, point) < 0) windingNumber -= 1;
        }
      }
    }
    return windingNumber != 0;
  }

  /// Returns a positive value if [p] is to the left of the line from [a] to [b].
  double _isLeft(Offset a, Offset b, Offset p) =>
      (b.dx - a.dx) * (p.dy - a.dy) - (p.dx - a.dx) * (b.dy - a.dy);

  /// Cancels any in-progress interactive operations (drag, rubber-band, etc.).
  void _cancelInProgressOperations() {
    selectionStart = null;
    selectionCurrent = null;
    lassoPath = null;
    _moveOrigins = {};
    _rotateCentroid = null;
    _rotateOrigins = {};
    _rotateStartAngle = 0.0;
    _transformComponent = null;
    _transformEndpointIndex = null;
    _transformOriginEp0 = null;
    _transformOriginEp1 = null;
    _transformSingleMode = false;
    bankDragType = null;
    bankDragPosition = null;
  }

  // =========================================================================
  // Selection shape helpers
  // =========================================================================

  /// Builds a [HullSelectionShape] from the current selection.
  ///
  /// Computes the outer convex hull of all selected component endpoints, then
  /// finds cycles in the connection graph among selected components and punches
  /// out an inner convex hull for each one.
  HullSelectionShape _buildHullShape() {
    // Collect all endpoints of selected components.
    final allPoints = <Offset>[];
    for (final comp in _components) {
      if (!selection.contains(comp.id)) continue;
      allPoints.add(comp.endpoint0);
      allPoints.add(comp.endpoint1);
    }

    final outerHull = _convexHull(allPoints);

    // Build adjacency list restricted to selected-to-selected connections.
    final adj = <int, List<int>>{};
    for (final id in selection.ids) {
      adj[id] = [];
    }
    for (final conn in _connections) {
      final aSelected = selection.contains(conn.componentA);
      final bSelected = selection.contains(conn.componentB);
      if (!aSelected || !bSelected) continue;
      adj[conn.componentA]!.add(conn.componentB);
      adj[conn.componentB]!.add(conn.componentA);
    }

    // Find all simple cycles using DFS and collect inner hulls.
    final innerHulls = _findCycleHulls(adj);

    return HullSelectionShape(outerHull: outerHull, innerHulls: innerHulls);
  }

  /// DFS-based cycle detection among selected components.
  ///
  /// For each detected cycle, collects the endpoints of all components in the
  /// cycle and computes their convex hull.
  List<List<Offset>> _findCycleHulls(Map<int, List<int>> adj) {
    final visited = <int>{};
    final result = <List<Offset>>[];

    // We use an iterative DFS with a path stack to detect back edges.
    for (final startId in adj.keys) {
      if (visited.contains(startId)) continue;

      // DFS with parent tracking to find back edges.
      final stack = <(int, int)>[]; // (nodeId, parentId)
      final path = <int>[];
      final inPath = <int>{};

      stack.add((startId, -1));

      while (stack.isNotEmpty) {
        final (node, parent) = stack.removeLast();

        if (inPath.contains(node)) {
          // Found a back edge — extract cycle from path.
          final cycleStart = path.indexOf(node);
          if (cycleStart >= 0) {
            final cycleIds = path.sublist(cycleStart);
            final cyclePoints = <Offset>[];
            for (final id in cycleIds) {
              final comp = _components.firstWhere(
                (c) => c.id == id,
                orElse: () => throw StateError('Component $id not found'),
              );
              cyclePoints.add(comp.endpoint0);
              cyclePoints.add(comp.endpoint1);
            }
            final hull = _convexHull(cyclePoints);
            if (hull.length >= 3) result.add(hull);
          }
          continue;
        }

        if (visited.contains(node)) continue;
        visited.add(node);
        path.add(node);
        inPath.add(node);

        final neighbours = adj[node] ?? [];
        for (final neighbour in neighbours) {
          if (neighbour == parent) continue;
          stack.add((neighbour, node));
        }
      }
    }

    return result;
  }
}

// ---------------------------------------------------------------------------
// Internal geometry helpers
// ---------------------------------------------------------------------------

/// Rotates [point] around [pivot] by [radians].
Offset _rotateAround(Offset point, Offset pivot, double radians) {
  final d = point - pivot;
  final c = math.cos(radians);
  final s = math.sin(radians);
  return pivot + Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
}

/// Computes the convex hull of [points] using the Graham scan algorithm.
///
/// Returns the hull vertices in counter-clockwise order.
/// Returns an empty list when fewer than 3 distinct points are provided.
List<Offset> _convexHull(List<Offset> points) {
  if (points.length < 3) return List.of(points);

  // Find the lowest (then leftmost) point as the pivot.
  var pivot = points.first;
  for (final p in points) {
    if (p.dy < pivot.dy || (p.dy == pivot.dy && p.dx < pivot.dx)) {
      pivot = p;
    }
  }

  // Sort remaining points by polar angle relative to pivot.
  final sorted = List.of(points)..remove(pivot);
  sorted.sort((a, b) {
    final angleA = math.atan2(a.dy - pivot.dy, a.dx - pivot.dx);
    final angleB = math.atan2(b.dy - pivot.dy, b.dx - pivot.dx);
    if (angleA != angleB) return angleA.compareTo(angleB);
    // Tie-break by distance.
    final distA = (a - pivot).distanceSquared;
    final distB = (b - pivot).distanceSquared;
    return distA.compareTo(distB);
  });

  // Graham scan.
  final hull = <Offset>[pivot];
  for (final p in sorted) {
    while (hull.length >= 2) {
      final a = hull[hull.length - 2];
      final b = hull[hull.length - 1];
      // Cross product: positive = left turn (keep), zero/negative = right turn
      // or collinear (remove).
      final cross =
          (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
      if (cross > 0) break;
      hull.removeLast();
    }
    hull.add(p);
  }

  return hull.length >= 3 ? hull : [];
}
