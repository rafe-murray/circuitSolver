import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/repositories/circuit_repository.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
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
    // return (await _localStorageService.getCircuits()).transform(
    //   (localStorageCircuitList) => localStorageCircuitList
    //       .map(
    //         (localStorageCircuit) => CircuitModel(
    //           id: localStorageCircuit.id,
    //           components: components,
    //           wires: wires,
    //         ),
    //       )
    //       .toList(),
    // );
    throw UnimplementedError();
  }

  @override
  Future<Result<CircuitModel>> getCircuit(UuidValue id) {
    // TODO: implement getCircuit
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> saveCircuit(CircuitModel circuit) {
    // TODO: implement saveCircuit
    throw UnimplementedError();
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
    final toId = removedToReplacementVertexIds[to.id] ?? to.id;
    final fromId = removedToReplacementVertexIds[from.id] ?? from.id;
    final edge = CircuitGraphMessage_Edge(
      id: id.toString(),
      fromId: fromId.toString(),
      toId: toId.toString(),
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
      removedToReplacementVertexIds[wire.endpoint1.id] = wire.id;
      removedToReplacementVertexIds[wire.endpoint2.id] = wire.id;
    }

    for (ComponentModel component in components) {
      final toVertex = component.to.toVertex(removedToReplacementVertexIds);
      final fromVertex = component.from.toVertex(removedToReplacementVertexIds);
      circuitGraph.vertices[toVertex.id] = toVertex;
      circuitGraph.vertices[fromVertex.id] = fromVertex;

      final edge = component.toEdge(removedToReplacementVertexIds);
      circuitGraph.edges[edge.id] = edge;
    }

    return circuitGraph;
  }

  CircuitModel copyWithGraph(CircuitGraphMessage circuitGraph) {
    final newWires = <WireModel>[];
    final Map<UuidValue, UuidValue> endpointToWireIds = {};
    for (WireModel wire in wires) {
      endpointToWireIds[wire.endpoint1.id] = wire.id;
      endpointToWireIds[wire.endpoint2.id] = wire.id;
      final vertex1 = circuitGraph.vertices[wire.endpoint1.id.toString()];
      final EndpointModel endpoint1;
      if (vertex1 == null) {
        endpoint1 = wire.endpoint1;
      } else {
        endpoint1 = wire.endpoint1.copyWithVertex(vertex1);
      }
      final vertex2 = circuitGraph.vertices[wire.endpoint2.id.toString()];
      final EndpointModel endpoint2;
      if (vertex2 == null) {
        endpoint2 = wire.endpoint2;
      } else {
        endpoint2 = wire.endpoint2.copyWithVertex(vertex2);
      }
      newWires.add(wire.copyWith(endpoint1: endpoint1, endpoint2: endpoint2));
    }

    final newComponents = <ComponentModel>[];
    for (ComponentModel component in components) {
      // Use the wire id if one matches up
      final toId = endpointToWireIds[component.to.id] ?? component.to.id;
      final fromId = endpointToWireIds[component.from.id] ?? component.from.id;
      final toVertex = circuitGraph.vertices[toId.toString()];
      final fromVertex = circuitGraph.vertices[fromId.toString()];
      final EndpointModel to;
      final EndpointModel from;

      if (toVertex == null) {
        to = component.to;
      } else {
        to = component.to.copyWithVertex(toVertex);
      }

      if (fromVertex == null) {
        from = component.from;
      } else {
        from = component.from.copyWithVertex(fromVertex);
      }

      final edge = circuitGraph.edges[component.id.toString()];
      final ComponentModel componentWithEdge;
      if (edge == null) {
        componentWithEdge = component;
      } else {
        componentWithEdge = component.copyWithEdge(edge);
      }
      newComponents.add(componentWithEdge.copyWith(from: from, to: to));
    }
    return copyWith(wires: newWires, components: newComponents);
  }
}
