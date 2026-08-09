import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/v7.dart';

typedef _Vertex = CircuitGraphMessage_Vertex;
typedef _Edge = CircuitGraphMessage_Edge;
typedef _VoltageSource = CircuitGraphMessage_Edge_VoltageSource;
typedef _Resistor = CircuitGraphMessage_Edge_Resistor;

void main() {
  group('LocalSolverService', () {
    test('Circuit should be solved', () async {
      final localSolverService = LocalSolverService();
      // Create vertices
      final ref = _Vertex(id: UuidV7().generate(), voltage: 0);
      final v1 = _Vertex(id: UuidV7().generate());
      final v2 = _Vertex(id: UuidV7().generate());

      // Create edges
      final vs = _Edge(
        id: UuidV7().generate(),
        fromId: ref.id,
        toId: v1.id,
        voltageSource: _VoltageSource(voltage: 5),
      );

      final r1 = _Edge(
        id: UuidV7().generate(),
        fromId: v1.id,
        toId: v2.id,
        resistor: _Resistor(resistance: 2),
      );

      final r2 = _Edge(
        id: UuidV7().generate(),
        fromId: v2.id,
        toId: ref.id,
        resistor: _Resistor(resistance: 3),
      );

      final circuitGraphMessage = CircuitGraphMessage(
        edges: {vs.id: vs, r1.id: r1, r2.id: r2}.entries,
        vertices: {ref.id: ref, v1.id: v1, v2.id: v2}.entries,
      );
      final result = await localSolverService.solve(circuitGraphMessage);
      switch (result) {
        case Error():
          fail(
            'Circuit should solve correctly: Error: ${result.error.toString()}',
          );
        case Ok():
          expect(
            result.value.vertices[ref.id]?.voltage,
            moreOrLessEquals(0, epsilon: 1e-4),
          );
      }
    });
  });
}
