import 'package:flutter/cupertino.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/circuit_models.dart';
import '../../diff/circuit_diff.dart';

part 'circuit_view_model.g.dart';

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

class UndoManager {
  final _history = <CircuitDiff>[];
  // Index of current position on the history list
  var currentPosition = -1;
  bool get canUndo => currentPosition >= 0;
  bool get canRedo => _history.length - 1 > currentPosition;

  CircuitModel undo(CircuitModel currentCircuit) {
    assert(canUndo);
    final diff = _history[currentPosition--];
    return diff.revertFrom(currentCircuit);
  }

  CircuitModel redo(CircuitModel currentCircuit) {
    assert(canRedo);
    final diff = _history[++currentPosition];
    return diff.applyTo(currentCircuit);
  }

  void pushChange(CircuitModel oldCircuit, CircuitModel newCircuit) {
    _history.removeRange(++currentPosition, _history.length);
    _history.add(calculateDiff(oldCircuit, newCircuit));
  }
}

typedef CommandAction = Future<void> Function();

@riverpod
class CircuitViewModel extends _$CircuitViewModel {
  final _manager = UndoManager();
  UuidValue get id => circuitId;
  Future<CircuitModel> get circuitModel async =>
      (await ref.watch(circuitRepositoryProvider).getCircuit(id))
          .valueOrThrow();

  @override
  Future<CircuitModel> build({required UuidValue circuitId}) async {
    return await circuitModel;
  }

  Future<void> _undoableCommand(CommandAction action) async {
    final beforeMutation = await circuitModel;
    await action();
    final afterMutation = await circuitModel;
    _manager.pushChange(beforeMutation, afterMutation);
    ref.invalidateSelf();
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

  // @override
  // Future<CircuitModel> build(UuidValue id) async {
  //   final uuid = Uuid();
  //   final ep1 = EndpointModel(pos: Offset(50, 100), id: uuid.v7obj());
  //   final ep2 = EndpointModel(pos: Offset(300, 20), id: uuid.v7obj());
  //   final ep3 = EndpointModel(pos: Offset(200, 300), id: uuid.v7obj());
  //   final ep4 = EndpointModel(pos: Offset(20, 300), id: uuid.v7obj());
  //   final r1 = ComponentModel(
  //     id: uuid.v7obj(),
  //     from: ep1,
  //     to: ep2,
  //     branch: Resistor(),
  //   );
  //   final vs = ComponentModel(
  //     id: uuid.v7obj(),
  //     from: ep2,
  //     to: ep3,
  //     branch: VoltageSource(),
  //   );
  //   final cs = ComponentModel(
  //     id: uuid.v7obj(),
  //     from: ep3,
  //     to: ep4,
  //     branch: CurrentSource(),
  //   );
  //   return CircuitModel(id: id, components: [r1, vs, cs], wires: []);
  //   // return (await ref.watch(circuitRepositoryProvider).getCircuit(id))
  //   //     .valueOrThrow();
  // }

  // Future<void> _updateCircuit(CircuitModel circuit) async {
  //   _circuitRepository.saveCircuit(circuit);
  // }

  // Future<void> addComponent(BranchModel branch) async {
  //   var uuid = ref.read(uuidProvider);
  //
  //   final fromPos = ref.read(nextFromProvider);
  //   final toPos = ref.read(nextToProvider);
  //
  //   final from = EndpointModel(pos: fromPos, id: uuid.v7obj());
  //   final to = EndpointModel(pos: toPos, id: uuid.v7obj());
  //
  //   return ref.read(circuitRepositoryProvider).patchCircuit()
  // }
}

// @riverpod
// Future<ComponentModel> component(Ref ref, UuidValue id) async {
//   final circuitId = ref.watch(circuitIdProvider);
//   final circuitModel = await ref.watch(
//     circuitViewModelProvider.call(circuitId).future,
//   );
//   return circuitModel.components.firstWhere((component) => component.id == id);
// }
