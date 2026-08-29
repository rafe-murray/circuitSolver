import 'package:flutter/cupertino.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/circuit_models.dart';
import '../../diff/circuit_diff.dart';

part 'editor_view_model.g.dart';

@riverpod
Offset nextFrom(Ref ref) {
  return Offset(100, 100);
}

@riverpod
Offset nextTo(Ref ref) {
  return Offset(200, 100);
}

// TODO: move to config dir
@riverpod
Uuid uuid(Ref ref) {
  return Uuid();
}

typedef CommandAction = Future<void> Function();

typedef UpdateAction = Future<CircuitModel> Function();

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
    ref.read(circuitRepositoryProvider).saveCircuit(previousCircuit);
  }

  Future<void> redo() async {
    assert(canRedo);
    final newCircuit = _manager.redo(await circuitModel);
    ref.read(circuitRepositoryProvider).saveCircuit(newCircuit);
  }

  Future<void> updateCircuit(UpdateAction action) async {
    final beforeUpdate = await circuitModel;
    final afterUpdate = await action();
    ref.read(circuitRepositoryProvider).saveCircuit(afterUpdate);
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
