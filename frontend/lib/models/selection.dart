import 'package:flutter/foundation.dart';

/// Manages the set of currently selected component ids on the canvas.
///
/// This is a thin [ChangeNotifier] wrapper around a [Set<int>] so that
/// widgets can listen for selection changes independently of the broader
/// [CanvasViewModel] rebuild cycle.
///
/// [CanvasViewModel] owns the single [Selection] instance and all mutation
/// goes through the helpers here. Commands receive the [CanvasViewModel] and
/// access the selection via [CanvasViewModel.selection].
class Selection extends ChangeNotifier {
  final Set<int> _ids = {};

  /// An unmodifiable view of the currently selected component ids.
  Set<int> get ids => Set.unmodifiable(_ids);

  /// Whether [id] is currently selected.
  bool contains(int id) => _ids.contains(id);

  /// Whether the selection is empty.
  bool get isEmpty => _ids.isEmpty;

  /// Whether the selection is non-empty.
  bool get isNotEmpty => _ids.isNotEmpty;

  /// The number of selected components.
  int get length => _ids.length;

  // ---------------------------------------------------------------------------
  // Mutation
  // ---------------------------------------------------------------------------

  /// Selects [id], optionally preserving the existing selection.
  ///
  /// When [additive] is `false` (default), the existing selection is cleared
  /// first so [id] becomes the sole selected component.
  void select(int id, {bool additive = false}) {
    if (!additive) _ids.clear();
    _ids.add(id);
    notifyListeners();
  }

  /// Replaces the entire selection with [ids].
  void setAll(Set<int> ids) {
    _ids
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  /// Removes [id] from the selection without affecting other selected ids.
  void deselect(int id) {
    if (_ids.remove(id)) notifyListeners();
  }

  /// Clears the entire selection.
  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
  }

  /// Adds all [ids] to the current selection (additive merge).
  void addAll(Set<int> ids) {
    _ids.addAll(ids);
    notifyListeners();
  }

  /// Removes all [ids] from the current selection (subtractive merge).
  void removeAll(Set<int> ids) {
    _ids.removeAll(ids);
    notifyListeners();
  }
}
