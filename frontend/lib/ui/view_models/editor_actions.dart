import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/component_placement.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/view_models/selection_geometry.dart';
import 'package:uuid/uuid_value.dart';

/// Builds the full set of editor [Action]s for [circuitId], bound to [ref].
///
/// Mount this on an [Actions] widget wrapping the editor. Intents dispatched
/// from shortcuts and from the active tool's gesture detector resolve to these.
Map<Type, Action<Intent>> buildEditorActions(
  WidgetRef ref,
  UuidValue circuitId,
) => {
  AddComponentIntent: AddComponentAction(ref, circuitId),
  SelectWithinLassoIntent: SelectWithinLassoAction(ref, circuitId),
  SelectAllIntent: SelectAllAction(ref, circuitId),
  ClearSelectionIntent: ClearSelectionAction(ref, circuitId),
  UndoIntent: UndoAction(ref, circuitId),
  RedoIntent: RedoAction(ref, circuitId),
};

/// Base class for editor actions: holds the [WidgetRef] (global state) and the
/// circuit id; the [Intent] carries the per-interaction state.
abstract class _EditorAction<T extends Intent> extends Action<T> {
  _EditorAction(this.ref, this.circuitId);

  /// Ref into the provider graph. Use `ref.read` only — actions are invoked
  /// imperatively, never during build.
  final WidgetRef ref;

  /// The circuit being edited.
  final UuidValue circuitId;

  /// The current circuit, or `null` while it is still loading / errored.
  CircuitModel? get circuit =>
      ref.read(editorViewModelProvider(circuitId: circuitId)).value;

  /// The editor viewmodel for [circuitId].
  EditorViewModel get viewModel =>
      ref.read(editorViewModelProvider(circuitId: circuitId).notifier);
}

/// Adds a component described by an [AddComponentIntent].
class AddComponentAction extends _EditorAction<AddComponentIntent> {
  AddComponentAction(super.ref, super.circuitId);

  @override
  void invoke(AddComponentIntent intent) {
    final current = circuit;
    if (current == null) return;
    unawaited(
      viewModel.updateCircuit(
        insertComponent(
          circuit: current,
          branch: intent.branch,
          from: intent.from,
          to: intent.to,
          uuid: ref.read(uuidProvider),
        ),
      ),
    );
  }
}

/// Selects every item enclosed by a [SelectWithinLassoIntent]'s region.
class SelectWithinLassoAction extends _EditorAction<SelectWithinLassoIntent> {
  SelectWithinLassoAction(super.ref, super.circuitId);

  @override
  void invoke(SelectWithinLassoIntent intent) {
    final current = circuit;
    if (current == null) return;
    ref
        .read(currentSelectionProvider(circuitId: circuitId).notifier)
        .set(lassoSelection(current, intent.region));
  }
}

/// Selects every component and endpoint in the circuit.
class SelectAllAction extends _EditorAction<SelectAllIntent> {
  SelectAllAction(super.ref, super.circuitId);

  @override
  void invoke(SelectAllIntent intent) {
    final current = circuit;
    if (current == null) return;
    ref
        .read(currentSelectionProvider(circuitId: circuitId).notifier)
        .set(selectAllOf(current));
  }
}

/// Clears the current selection.
class ClearSelectionAction extends _EditorAction<ClearSelectionIntent> {
  ClearSelectionAction(super.ref, super.circuitId);

  @override
  void invoke(ClearSelectionIntent intent) {
    ref.read(currentSelectionProvider(circuitId: circuitId).notifier).clear();
  }
}

/// Reverts the last circuit edit, if there is one.
class UndoAction extends _EditorAction<UndoIntent> {
  UndoAction(super.ref, super.circuitId);

  @override
  void invoke(UndoIntent intent) {
    if (viewModel.canUndo) unawaited(viewModel.undo());
  }
}

/// Re-applies the last reverted circuit edit, if there is one.
class RedoAction extends _EditorAction<RedoIntent> {
  RedoAction(super.ref, super.circuitId);

  @override
  void invoke(RedoIntent intent) {
    if (viewModel.canRedo) unawaited(viewModel.redo());
  }
}
