import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/repositories/circuit_repository.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/utils/exceptions.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

class CircuitRepositoryLocal implements CircuitRepository {
  CircuitRepositoryLocal({
    required LocalSolverService localSolverService,
    required LocalStorageService localStorageService,
  }) : _localSolverService = localSolverService,
       _localStorageService = localStorageService;
  final LocalSolverService _localSolverService;
  final LocalStorageService _localStorageService;

  @override
  Future<Result<CircuitModel>> solveCircuit(CircuitModel circuit) async {
    return (await _localSolverService.solve(
      circuit.toCircuitGraph(),
    )).transform(
      (circuitGraphMessage) => circuit.copyWithGraph(circuitGraphMessage),
    );
  }

  @override
  Future<Result<List<CircuitModel>>> getAllCircuits() async {
    return (await _localStorageService.getCircuits()).transform(
      (localStorageCircuitList) => localStorageCircuitList
          .map((localStorageCircuit) => localStorageCircuit.circuit)
          .toList(),
    );
  }

  @override
  Future<Result<CircuitModel>> getCircuit(UuidValue id) async {
    return (await _localStorageService.getCircuit(id)).transform(
      (circuitLocalStorageModel) => circuitLocalStorageModel.circuit,
    );
  }

  @override
  Future<Result<void>> saveCircuit(CircuitModel circuit) async {
    final oldCircuit = await _localStorageService.getCircuit(circuit.id);
    switch (oldCircuit) {
      case Ok<CircuitLocalStorageModel>():
        _localStorageService.putCircuit(
          CircuitLocalStorageModel(
            id: circuit.id,
            name: circuit.name ?? "",
            created: oldCircuit.value.created,
            modified: DateTime.now(),
            circuit: circuit,
          ),
        );
        return Result.ok(null);
      case Error<CircuitLocalStorageModel>():
        if (oldCircuit.error is NotFoundException) {
          _localStorageService.putCircuit(
            CircuitLocalStorageModel(
              id: circuit.id,
              name: circuit.name ?? "",
              created: DateTime.now(),
              modified: DateTime.now(),
              circuit: circuit,
            ),
          );
          return Result.ok(null);
        }
        return Result.error(oldCircuit.error);
    }
  }

  @override
  Future<Result<void>> patchCircuit(PatchCircuitModel circuit) async {
    final oldCircuitResult = await _localStorageService.getCircuit(circuit.id);
    if (oldCircuitResult is Error) {
      return oldCircuitResult;
    }
    final oldCircuitLocalStorageModel = oldCircuitResult.valueOrThrow();
    final oldCircuit = oldCircuitLocalStorageModel.circuit;
    final endpointsPatch = circuit.endpoints;
    final Map<UuidValue, EndpointModel>? newEndpoints;
    switch (endpointsPatch) {
      case Add():
        oldCircuit.endpoints.addEntries(
          endpointsPatch.value.map((record) => MapEntry(record.$1, record.$2)),
        );
        newEndpoints = oldCircuit.endpoints;
        break;
      case Remove():
        oldCircuit.endpoints.remove(endpointsPatch.position);
        newEndpoints = oldCircuit.endpoints;
        break;
      case Change():
        oldCircuit.endpoints[endpointsPatch.position] = endpointsPatch.value;
        newEndpoints = oldCircuit.endpoints;
        break;
      case Replace():
        newEndpoints = Map.fromEntries(
          endpointsPatch.values.map((record) => MapEntry(record.$1, record.$2)),
        );
        break;
      case null:
        newEndpoints = null;
        break;
    }

    final componentsPatch = circuit.components;
    final List<ComponentModel>? newComponents;
    switch (componentsPatch) {
      case null:
        newComponents = null;
      case Add<int, ComponentModel>():
        oldCircuit.components.addAll(
          componentsPatch.value.map((record) => record.$2),
        );
        newComponents = oldCircuit.components;
      case Remove<int, ComponentModel>():
        oldCircuit.components.removeAt(componentsPatch.position);
        newComponents = oldCircuit.components;
      case Change<int, ComponentModel>():
        oldCircuit.components[componentsPatch.position] = componentsPatch.value;
        newComponents = oldCircuit.components;
      case Replace<int, ComponentModel>():
        newComponents = componentsPatch.values
            .map((record) => record.$2)
            .toList();
    }

    final wiresPatch = circuit.wires;
    final List<WireModel>? newWires;
    switch (wiresPatch) {
      case null:
        newWires = null;
      case Add<int, WireModel>():
        oldCircuit.wires.addAll(wiresPatch.value.map((record) => record.$2));
        newWires = oldCircuit.wires;
      case Remove<int, WireModel>():
        oldCircuit.wires.removeAt(wiresPatch.position);
        newWires = oldCircuit.wires;
      case Change<int, WireModel>():
        oldCircuit.wires[wiresPatch.position] = wiresPatch.value;
        newWires = oldCircuit.wires;
      case Replace<int, WireModel>():
        newWires = wiresPatch.values.map((record) => record.$2).toList();
    }

    final newCircuitLocalStorageModel = oldCircuitLocalStorageModel.copyWith(
      modified: DateTime.now(),
      circuit: oldCircuit.copyWith(
        endpoints: newEndpoints,
        components: newComponents,
        wires: newWires,
      ),
    );
    return _localStorageService.putCircuit(newCircuitLocalStorageModel);
  }
}

extension on EndpointModel {
  CircuitGraphMessage_Vertex toVertex(
    Map<UuidValue, UuidValue> removedToReplacementVertexIds,
  ) {
    final vertexId = removedToReplacementVertexIds[id] ?? id;
    return CircuitGraphMessage_Vertex(
      id: vertexId.toString(),
      voltage: voltage?.volts,
    );
  }

  EndpointModel copyWithVertex(CircuitGraphMessage_Vertex vertex) {
    return copyWith(voltage: Voltage(volts: vertex.voltage));
  }
}

extension on ComponentModel {
  CircuitGraphMessage_Edge toEdge(
    Map<UuidValue, UuidValue> removedToReplacementVertexIds,
  ) {
    final edgeToId = removedToReplacementVertexIds[toId] ?? toId;
    final edgeFromId = removedToReplacementVertexIds[fromId] ?? fromId;
    final edge = CircuitGraphMessage_Edge(
      id: id.toString(),
      fromId: edgeFromId.toString(),
      toId: edgeToId.toString(),
      current: current?.amps,
    );
    final currentBranch = branch;
    switch (currentBranch) {
      case CurrentSource():
        edge.currentSource = CircuitGraphMessage_Edge_CurrentSource(
          voltage: currentBranch.voltage?.volts,
        );
      case IdealDiode():
        edge.idealDiode = CircuitGraphMessage_Edge_IdealDiode(
          voltage: currentBranch.voltage?.volts,
        );
      case RealDiode():
        edge.realDiode = CircuitGraphMessage_Edge_RealDiode(
          i0: currentBranch.i0?.amps,
          vt: currentBranch.vt?.volts,
          n: currentBranch.n,
        );
      case Resistor():
        edge.resistor = CircuitGraphMessage_Edge_Resistor(
          resistance: currentBranch.resistance?.ohms,
        );
      case VoltageSource():
        edge.voltageSource = CircuitGraphMessage_Edge_VoltageSource(
          voltage: currentBranch.voltage?.volts,
        );
      case ZenerDiode():
        edge.zenerDiode = CircuitGraphMessage_Edge_ZenerDiode(
          vzt: currentBranch.vzt?.volts,
          rzt: currentBranch.rzt?.ohms,
          izt: currentBranch.izt?.amps,
        );
    }
    return edge;
  }

  // We need vertices to correct the endpointModel's voltage
  ComponentModel copyWithEdge(CircuitGraphMessage_Edge edge) {
    BranchModel branch;
    switch (edge.whichSpecificBranch()) {
      case CircuitGraphMessage_Edge_SpecificBranch.currentSource:
        branch = CurrentSource(
          voltage: Voltage(volts: edge.currentSource.voltage),
        );
      case CircuitGraphMessage_Edge_SpecificBranch.idealDiode:
        branch = IdealDiode(voltage: Voltage(volts: edge.idealDiode.voltage));
      case CircuitGraphMessage_Edge_SpecificBranch.realDiode:
        branch = RealDiode(
          i0: Current(a: edge.realDiode.i0),
          vt: Voltage(volts: edge.realDiode.vt),
          n: edge.realDiode.n,
        );
      case CircuitGraphMessage_Edge_SpecificBranch.resistor:
        branch = Resistor(
          resistance: Resistance(ohms: edge.resistor.resistance),
        );
      case CircuitGraphMessage_Edge_SpecificBranch.voltageSource:
        branch = VoltageSource(
          voltage: Voltage(volts: edge.voltageSource.voltage),
        );
      case CircuitGraphMessage_Edge_SpecificBranch.zenerDiode:
        branch = ZenerDiode(
          vzt: Voltage(volts: edge.zenerDiode.vzt),
          izt: Current(a: edge.zenerDiode.izt),
          rzt: Resistance(ohms: edge.zenerDiode.rzt),
        );
      case CircuitGraphMessage_Edge_SpecificBranch.notSet:
        throw StateError("No branch type set for edge");
    }
    return copyWith(
      id: UuidValue.withValidation(edge.id),
      branch: branch,
      current: Current(a: edge.current),
    );
  }
}

extension on CircuitModel {
  // TODO: check if this needs validation
  CircuitGraphMessage toCircuitGraph() {
    CircuitGraphMessage circuitGraph = CircuitGraphMessage();
    final Map<UuidValue, UuidValue> removedToReplacementVertexIds = {};
    for (WireModel wire in wires) {
      removedToReplacementVertexIds[wire.endpoint1Id] = wire.id;
      removedToReplacementVertexIds[wire.endpoint2Id] = wire.id;
    }

    for (ComponentModel component in components) {
      final toVertex = endpoints[component.toId]!.toVertex(
        removedToReplacementVertexIds,
      );
      final fromVertex = endpoints[component.fromId]!.toVertex(
        removedToReplacementVertexIds,
      );
      circuitGraph.vertices[toVertex.id] = toVertex;
      circuitGraph.vertices[fromVertex.id] = fromVertex;

      final edge = component.toEdge(removedToReplacementVertexIds);
      circuitGraph.edges[edge.id] = edge;
    }

    return circuitGraph;
  }

  CircuitModel copyWithGraph(CircuitGraphMessage circuitGraph) {
    final Map<UuidValue, UuidValue> endpointToWireIds = {};
    for (WireModel wire in wires) {
      endpointToWireIds[wire.endpoint1Id] = wire.id;
      endpointToWireIds[wire.endpoint2Id] = wire.id;
    }

    final Map<UuidValue, EndpointModel> newEndpoints = {};
    for (MapEntry<UuidValue, EndpointModel> endpointMapEntry
        in endpoints.entries) {
      final vertex = circuitGraph.vertices[endpointMapEntry.key.toString()];
      final EndpointModel newEndpoint;
      if (vertex == null) {
        newEndpoint = endpointMapEntry.value;
      } else {
        newEndpoint = endpointMapEntry.value.copyWithVertex(vertex);
      }
      newEndpoints[endpointMapEntry.key] = newEndpoint;
    }

    final newComponents = <ComponentModel>[];
    for (ComponentModel component in components) {
      // Use the wire id if one matches up
      final toId = endpointToWireIds[component.toId] ?? component.toId;
      final fromId = endpointToWireIds[component.fromId] ?? component.fromId;

      final edge = circuitGraph.edges[component.id.toString()];
      final ComponentModel componentWithEdge;
      if (edge == null) {
        componentWithEdge = component;
      } else {
        componentWithEdge = component.copyWithEdge(edge);
      }
      newComponents.add(componentWithEdge.copyWith(toId: toId, fromId: fromId));
    }
    return copyWith(endpoints: newEndpoints, components: newComponents);
  }
}
