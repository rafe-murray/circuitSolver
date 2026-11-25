import 'dart:ui';

import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/circuit_models.dart';
import '../../data/model/selection.dart';
import '../../diff/circuit_diff.dart';
import 'tool/tool_meta.dart';

part 'editor_view_model.g.dart';

@riverpod
Offset nextFrom(Ref ref) {
  return Offset(100, 100);
}

@riverpod
Offset nextTo(Ref ref) {
  return Offset(200, 100);
}

typedef CommandAction = Future<void> Function();

typedef UpdateAction = CircuitModel Function();

/// The tool currently active in the editor's tool bank for [circuitId], or
/// `null` when no tool is selected and canvas input is inert.
@riverpod
class SelectedTool extends _$SelectedTool {
  @override
  ToolMeta? build({required UuidValue circuitId}) => null;

  /// Sets [meta] as the active tool, or clears the selection when `null`.
  void select(ToolMeta? meta) => state = meta;
}

/// The user's current selection of components and endpoints for [circuitId].
///
/// Transient UI state: it is not persisted and takes no part in the circuit
/// model or the undo history. Kept alive because it can be set from an
/// editor-wide shortcut (select-all) at a moment when nothing is watching it.
@Riverpod(keepAlive: true)
class CurrentSelection extends _$CurrentSelection {
  @override
  Selection build({required UuidValue circuitId}) => Selection.empty;

  /// Replaces the selection with [selection].
  void set(Selection selection) => state = selection;

  /// Clears the selection.
  void clear() => state = Selection.empty;
}

@riverpod
class EditorViewModel extends _$EditorViewModel {
  final _manager = UndoManager();
  bool get canRedo => _manager.canRedo;
  bool get canUndo => _manager.canUndo;
  Future<CircuitModel> get circuitModel async =>
      (await ref.watch(circuitRepositoryProvider).getCircuit(id))
          .valueOrThrow();
  UuidValue get id => circuitId;

  Future<void> addComponent(BranchModel branch) async {
    _undoableCommand(() async {
      print("Adding component of type $branch");
      final from = await _createEndpoint(Offset(50, 50));
      final to = await _createEndpoint(Offset(50, 100));
      final circuit = await circuitModel;
      circuit.components.add(
        ComponentModel(
          id: ref.read(uuidProvider).v7obj(),
          fromId: from.id,
          toId: to.id,
          branch: branch,
        ),
      );
      ref.read(circuitRepositoryProvider).saveCircuit(circuit).valueOrThrow();
    });
  }

  Future<void> addWire() async {
    _undoableCommand(() async {
      // TODO: don't harcode this
      final from = Offset(50, 50);
      final to = Offset(50, 100);
      final circuit = await circuitModel;
      final endpoint1 = await _createEndpoint(from);
      final endpoint2 = await _createEndpoint(to);
      circuit.wires.add(
        WireModel(
          id: ref.read(uuidProvider).v7obj(),
          endpoint1Id: endpoint1.id,
          endpoint2Id: endpoint2.id,
        ),
      );
      ref.read(circuitRepositoryProvider).saveCircuit(circuit);
    });
  }

  @override
  Future<CircuitModel> build({required UuidValue circuitId}) async {
    return await circuitModel;
  }

  Future<void> moveEndpoint(UuidValue endpointId, Offset newPos) async {
    _undoableCommand(() async {
      final circuit = (await circuitModel);

      final endpoint = circuit.endpoints[endpointId];
      if (endpoint == null) {
        return;
      }
      final newEndpoint = endpoint.copyWith(pos: newPos);
      circuit.endpoints.update(endpointId, (value) => newEndpoint);
      ref.read(circuitRepositoryProvider).saveCircuit(circuit);
    });
  }

  Future<void> undo() async {
    assert(canUndo);
    final previousCircuit = _manager.undo(await circuitModel);
    await ref.read(circuitRepositoryProvider).saveCircuit(previousCircuit);
    ref.invalidate(circuitRepositoryProvider);
  }

  Future<void> redo() async {
    assert(canRedo);
    final newCircuit = _manager.redo(await circuitModel);
    await ref.read(circuitRepositoryProvider).saveCircuit(newCircuit);
    ref.invalidate(circuitRepositoryProvider);
  }

  Future<void> updateCircuit(UpdateAction action) async {
    final beforeUpdate = await circuitModel;
    final afterUpdate = action();
    await ref.read(circuitRepositoryProvider).saveCircuit(afterUpdate);
    _manager.pushChange(beforeUpdate, afterUpdate);
    ref.invalidate(circuitRepositoryProvider);
  }

  Future<EndpointModel> _createEndpoint(Offset position) async {
    final endpoint = EndpointModel(
      pos: position,
      id: ref.read(uuidProvider).v7obj(),
    );
    await ref
        .read(circuitRepositoryProvider)
        .patchCircuit(
          PatchCircuitModel(
            id: id,
            endpoints: Add(value: [(endpoint.id, endpoint)]),
          ),
        )
        .valueOrThrow();
    return endpoint;
  }

  Future<void> _undoableCommand(CommandAction action) async {
    final beforeMutation = await circuitModel;
    await action();
    final afterMutation = await circuitModel;
    _manager.pushChange(beforeMutation, afterMutation);
    ref.invalidate(circuitRepositoryProvider);
  }
}

class UndoManager {
  final _history = <CircuitDiff>[];
  // Index of current position on the history list
  var currentPosition = -1;
  bool get canRedo => _history.length - 1 > currentPosition;
  bool get canUndo => currentPosition >= 0;

  void pushChange(CircuitModel oldCircuit, CircuitModel newCircuit) {
    _history.removeRange(++currentPosition, _history.length);
    _history.add(calculateDiff(oldCircuit, newCircuit));
  }

  CircuitModel redo(CircuitModel currentCircuit) {
    assert(canRedo);
    final diff = _history[++currentPosition];
    return diff.applyTo(currentCircuit);
  }

  CircuitModel undo(CircuitModel currentCircuit) {
    assert(canUndo);
    final diff = _history[currentPosition--];
    return diff.revertFrom(currentCircuit);
  }
}
