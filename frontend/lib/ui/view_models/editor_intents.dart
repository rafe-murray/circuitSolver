import 'package:flutter/widgets.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';

/// Places a [branch] component with endpoints at [from] and [to], in canvas
/// coordinates.
///
/// Dispatched by the add-component gesture detector (tap / drag) and by the
/// tool's `Enter` shortcut.
@immutable
class AddComponentIntent extends Intent {
  /// The component to place.
  final BranchModel branch;

  /// One endpoint, in canvas coordinates.
  final Offset from;

  /// The other endpoint, in canvas coordinates.
  final Offset to;

  const AddComponentIntent({
    required this.branch,
    required this.from,
    required this.to,
  });
}

/// Replaces the selection with every circuit item whose hitbox meets [region].
@immutable
class SelectWithinLassoIntent extends Intent {
  /// The closed lasso polygon, in canvas coordinates.
  final LassoRegion region;

  const SelectWithinLassoIntent(this.region);
}

/// Replaces the selection with every component and endpoint in the circuit.
class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

/// Clears the current selection.
class ClearSelectionIntent extends Intent {
  const ClearSelectionIntent();
}

/// Reverts the most recent circuit edit.
class UndoIntent extends Intent {
  const UndoIntent();
}

/// Re-applies the most recently reverted circuit edit.
class RedoIntent extends Intent {
  const RedoIntent();
}
