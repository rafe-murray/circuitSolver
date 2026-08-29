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

// The native solver parses vertex/edge ids as UUIDs and rejects anything that
// is not a well-formed UUID, so the fixtures below use fixed valid UUIDs.
const String v0Id = '00000000-0000-4000-8000-000000000000';
const String v1Id = '11111111-1111-4111-8111-111111111111';
const String v2Id = '22222222-2222-4222-8222-222222222222';
const String vsId = 'aaaaaaaa-0000-4000-8000-000000000000';
const String r1Id = 'bbbbbbbb-0000-4000-8000-000000000000';
const String r2Id = 'cccccccc-0000-4000-8000-000000000000';

/// Builds an unsolved 5 V source + 2 Ω + 3 Ω series circuit protobuf message.
///
/// Topology:
///   V0 (ground, 0 V) --[VS 5 V]--> V1 --[R 2 Ω]--> V2 --[R 3 Ω]--> V0
///
/// Expected solution: V0=0, V1=5, V2=3, all branch currents = 1 A.
CircuitGraphMessage buildSeriesCircuit() {
  final v0 = CircuitGraphMessage_Vertex(id: v0Id, voltage: 0);
  final v1 = CircuitGraphMessage_Vertex(id: v1Id);
  final v2 = CircuitGraphMessage_Vertex(id: v2Id);

  final vs = CircuitGraphMessage_Edge(
    id: vsId,
    fromId: v0Id,
    toId: v1Id,
    voltageSource: CircuitGraphMessage_Edge_VoltageSource(voltage: 5),
  );
  final r1 = CircuitGraphMessage_Edge(
    id: r1Id,
    fromId: v1Id,
    toId: v2Id,
    resistor: CircuitGraphMessage_Edge_Resistor(resistance: 2),
  );
  final r2 = CircuitGraphMessage_Edge(
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

/// A circuit whose ids are not valid UUIDs, which the native solver rejects
/// with [CIRCUITSOLVER_ERROR_INVALID_INPUT].
CircuitGraphMessage buildInvalidCircuit() {
  return CircuitGraphMessage(
    vertices: {
      'ground': CircuitGraphMessage_Vertex(id: 'ground', voltage: 0),
      'top': CircuitGraphMessage_Vertex(id: 'top'),
    }.entries,
    edges: {
      'source': CircuitGraphMessage_Edge(
        id: 'source',
        fromId: 'ground',
        toId: 'top',
        voltageSource: CircuitGraphMessage_Edge_VoltageSource(voltage: 5),
      ),
    }.entries,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('solveCircuitSync (synchronous FFI)', () {
    test('solves a basic series circuit', () {
      final result = CircuitGraphMessage.fromBuffer(
        solveCircuitSync(buildSeriesCircuit().writeToBuffer()),
      );

      expect(
        isWithinRelativeTolerance(0, result.vertices[v0Id]!.voltage),
        isTrue,
        reason: 'V0 (ground) should be 0 V',
      );
      expect(
        isWithinRelativeTolerance(5, result.vertices[v1Id]!.voltage),
        isTrue,
        reason: 'V1 should be 5 V',
      );
      expect(
        isWithinRelativeTolerance(3, result.vertices[v2Id]!.voltage),
        isTrue,
        reason: 'V2 should be 3 V',
      );
      expect(
        isWithinRelativeTolerance(1, result.edges[vsId]!.current),
        isTrue,
        reason: 'Voltage source current should be 1 A',
      );
      expect(
        isWithinRelativeTolerance(1, result.edges[r1Id]!.current),
        isTrue,
        reason: 'R1 current should be 1 A',
      );
      expect(
        isWithinRelativeTolerance(1, result.edges[r2Id]!.current),
        isTrue,
        reason: 'R2 current should be 1 A',
      );
    });

    test('throws CircuitSolverException for malformed input', () {
      expect(
        () => solveCircuitSync(buildInvalidCircuit().writeToBuffer()),
        throwsA(isA<CircuitSolverException>()),
      );
    });
  });

  group('solveCircuit (async isolate API)', () {
    test('solves a basic series circuit', () async {
      final result = await solveCircuit(buildSeriesCircuit());

      expect(
        isWithinRelativeTolerance(5, result.vertices[v1Id]!.voltage),
        isTrue,
        reason: 'V1 should be 5 V',
      );
      expect(
        isWithinRelativeTolerance(3, result.vertices[v2Id]!.voltage),
        isTrue,
        reason: 'V2 should be 3 V',
      );
      expect(
        isWithinRelativeTolerance(1, result.edges[r1Id]!.current),
        isTrue,
        reason: 'R1 current should be 1 A',
      );
    });

    test('propagates CircuitSolverException from the helper isolate', () {
      expect(
        solveCircuit(buildInvalidCircuit()),
        throwsA(isA<CircuitSolverException>()),
      );
    });
  });
}
