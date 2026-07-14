import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:ffi_bridge/ffi_bridge.dart';
import 'package:ffi_bridge/src/circuit_solver_ffi.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns true if [actual] is within [relativeTolerance] of [expected].
///
/// Falls back to absolute tolerance when [expected] is zero to avoid
/// division by zero.
bool isWithinRelativeTolerance(
  double expected,
  double actual, {
  double relativeTolerance = 1e-4,
}) {
  if (expected == 0.0) {
    return actual.abs() <= relativeTolerance;
  }
  return ((actual - expected) / expected).abs() <= relativeTolerance;
}

/// Builds an unsolved 5 V source + 2 Ω + 3 Ω series circuit protobuf message.
///
/// Topology:
///   V0 (ground, 0 V) --[VS 5 V]--> V1 --[R 2 Ω]--> V2 --[R 3 Ω]--> V0
///
/// Expected solution: V0=0, V1=5, V2=3, all branch currents = 1 A.
CircuitGraphMessage buildSeriesCircuit() {
  const String v0Id = 'v0';
  const String v1Id = 'v1';
  const String v2Id = 'v2';
  const String vsId = 'e0';
  const String r1Id = 'e1';
  const String r2Id = 'e2';

  // Vertices
  final CircuitGraphMessage_Vertex v0 = CircuitGraphMessage_Vertex(
    id: v0Id,
    voltage: 0,
  );
  final CircuitGraphMessage_Vertex v1 = CircuitGraphMessage_Vertex(id: v1Id);
  final CircuitGraphMessage_Vertex v2 = CircuitGraphMessage_Vertex(id: v2Id);

  // Edges
  final CircuitGraphMessage_Edge vs = CircuitGraphMessage_Edge(
    id: vsId,
    fromId: v0Id,
    toId: v1Id,
    voltageSource: CircuitGraphMessage_Edge_VoltageSource(voltage: 5),
  );
  final CircuitGraphMessage_Edge r1 = CircuitGraphMessage_Edge(
    id: r1Id,
    fromId: v1Id,
    toId: v2Id,
    resistor: CircuitGraphMessage_Edge_Resistor(resistance: 2),
  );
  final CircuitGraphMessage_Edge r2 = CircuitGraphMessage_Edge(
    id: r2Id,
    fromId: v2Id,
    toId: v0Id,
    resistor: CircuitGraphMessage_Edge_Resistor(resistance: 3),
  );

  return CircuitGraphMessage(
    vertices: {v0Id: v0, v1Id: v1, v2Id: v2}.entries,
    edges: {vsId: vs, r1Id: r1, r2Id: r2}.entries,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('solveCircuitSync (synchronous FFI)', () {
    test('solves a basic series circuit', () {
      final CircuitGraphMessage input = buildSeriesCircuit();
      final CircuitGraphMessage result = CircuitGraphMessage.fromBuffer(
        solveCircuitSync(input.writeToBuffer()),
      );

      final CircuitGraphMessage_Vertex v0 = result.vertices['v0']!;
      final CircuitGraphMessage_Vertex v1 = result.vertices['v1']!;
      final CircuitGraphMessage_Vertex v2 = result.vertices['v2']!;
      final CircuitGraphMessage_Edge vs = result.edges['e0']!;
      final CircuitGraphMessage_Edge r1 = result.edges['e1']!;
      final CircuitGraphMessage_Edge r2 = result.edges['e2']!;

      expect(
        isWithinRelativeTolerance(0, v0.voltage),
        isTrue,
        reason: 'V0 (ground) should be 0 V',
      );
      expect(
        isWithinRelativeTolerance(5, v1.voltage),
        isTrue,
        reason: 'V1 should be 5 V',
      );
      expect(
        isWithinRelativeTolerance(3, v2.voltage),
        isTrue,
        reason: 'V2 should be 3 V',
      );
      expect(
        isWithinRelativeTolerance(1, vs.current),
        isTrue,
        reason: 'Voltage source current should be 1 A',
      );
      expect(
        isWithinRelativeTolerance(1, r1.current),
        isTrue,
        reason: 'R1 current should be 1 A',
      );
      expect(
        isWithinRelativeTolerance(1, r2.current),
        isTrue,
        reason: 'R2 current should be 1 A',
      );
    });

    test('throws CircuitSolverException for an empty circuit', () {
      final CircuitGraphMessage empty = CircuitGraphMessage();
      expect(
        () => solveCircuitSync(empty.writeToBuffer()),
        throwsA(isA<CircuitSolverException>()),
      );
    });
  });

  group('solveCircuit (async isolate API)', () {
    test('solves a basic series circuit', () async {
      final CircuitGraphMessage input = buildSeriesCircuit();
      final CircuitGraphMessage result = await solveCircuit(input);

      expect(
        isWithinRelativeTolerance(5, result.vertices['v1']!.voltage),
        isTrue,
        reason: 'V1 should be 5 V',
      );
      expect(
        isWithinRelativeTolerance(3, result.vertices['v2']!.voltage),
        isTrue,
        reason: 'V2 should be 3 V',
      );
      expect(
        isWithinRelativeTolerance(1, result.edges['e1']!.current),
        isTrue,
        reason: 'R1 current should be 1 A',
      );
    });

    test('propagates CircuitSolverException from the helper isolate', () async {
      final CircuitGraphMessage empty = CircuitGraphMessage();
      await expectLater(
        solveCircuit(empty),
        throwsA(isA<CircuitSolverException>()),
      );
    });
  });
}
