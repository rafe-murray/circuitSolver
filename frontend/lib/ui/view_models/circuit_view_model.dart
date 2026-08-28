import 'package:flutter/cupertino.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/repositories/circuit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/model/circuit_models.dart';
import '../../diff/circuit_diff.dart';
import '../widgets/editor_screen.dart';

part 'circuit_view_model.g.dart';

// @riverpod
// UuidValue circuitId(Ref ref) {
//   return Uuid().v7obj();
// }

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

@riverpod
Future<List<CircuitModel>> circuits(Ref ref) async {
  return (await ref.watch(circuitRepositoryProvider).getAllCircuits())
      .valueOrThrow();
}

@riverpod
Future<CircuitModel> circuitModel(Ref ref) async {
  final id = ref.watch(circuitIdProvider);
  return (await ref.watch(circuitRepositoryProvider).getCircuit(id))
      .valueOrThrow();
}

@riverpod
Future<List<ComponentModel>> components(Ref ref) async {
  return (await ref.watch(circuitModelProvider.future)).components;
}

@riverpod
class Wires extends _$Wires {
  @override
  Future<List<WireModel>> build() async {
    return (await ref.watch(circuitModelProvider.future)).wires;
  }

  Future<void> addWire() async {}
  Future<void> replaceWire(WireModel oldWire, WireModel newWire) async {
    // 1. update state in UI -> change `state`
    // 2. Propagate to database -> use circuitRepository
    // 3. Save a diff in memory for undo/redo
  }
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

class UndoableCommand {
  final CommandAction _action;
  final UndoManager _manager;
  final CircuitViewModel _viewModel;

  UndoableCommand({
    required CommandAction action,
    required UndoManager manager,
    required CircuitViewModel viewModel,
  }) : _action = action,
       _manager = manager,
       _viewModel = viewModel;

  Future<void> execute() async {
    final CircuitModel beforeMutation = await _viewModel.circuitModel;
    await _action();
    final CircuitModel afterMutation = await _viewModel.circuitModel;
    _manager.pushChange(beforeMutation, afterMutation);
  }
}

@riverpod
class CircuitViewModel {
  final CircuitRepository _circuitRepository;
  final Uuid _uuid;
  final UndoManager _manager;
  final UuidValue id;

  CircuitViewModel({
    required CircuitRepository circuitRepository,
    required Uuid uuid,
    required UndoManager undoManager,
    required this.id,
  }) : _circuitRepository = circuitRepository,
       _uuid = uuid,
       _manager = undoManager;

  Future<CircuitModel> get circuitModel async {
    return (await _circuitRepository.getCircuit(id)).valueOrThrow();
  }

  EndpointModel _createEndpoint(Offset position) {
    final endpoint = EndpointModel(pos: position, id: _uuid.v7obj());
    _circuitRepository.patchCircuit(
      PatchCircuitModel(
        id: id,
        endpoints: Add(value: [(endpoint.id, endpoint)]),
      ),
    );
    return endpoint;
  }

  Future<void> addWire() async {
    // TODO: don't harcode this
    final from = Offset(50, 50);
    final to = Offset(50, 100);
    final circuit = await circuitModel;
    final endpoint1 = _createEndpoint(from);
    final endpoint2 = _createEndpoint(to);
    circuit.wires.add(
      WireModel(
        id: _uuid.v7obj(),
        endpoint1Id: endpoint1.id,
        endpoint2Id: endpoint2.id,
      ),
    );
  }

  Future<void> addComponent(BranchModel branch) async {}

  Future<void> moveEndpoint(UuidValue endpointId, Offset newPos) {
    return UndoableCommand(
      action: () async {
        final circuit = (await circuitModel);

        final endpoint = circuit.endpoints[endpointId];
        if (endpoint == null) {
          return;
        }
        final newEndpoint = endpoint.copyWith(pos: newPos);
        circuit.endpoints.update(endpointId, (value) => newEndpoint);
        _circuitRepository.saveCircuit(circuit);
      },
      manager: _manager,
      viewModel: this,
    ).execute();
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

  Future<void> _updateCircuit(CircuitModel circuit) async {
    _circuitRepository.saveCircuit(circuit);
  }

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
