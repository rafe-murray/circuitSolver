// End-to-end test of the local solve path: frontend model translation ->
// ffi_bridge -> native libcircuitsolver -> back to the frontend model.
//
// Unlike the unit tests under test/, this exercises the real native solver, so
// it lives in test_native/ and is run via `flutter test test_native` (which
// builds the C++ library through the ffi_bridge build hook) rather than as part
// of the unit suite.
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/repositories/circuit_repository_local.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('solves a series circuit through the native solver', () async {
    final db = CircuitSolverDatabase.memory();
    addTearDown(db.close);

    final repository = CircuitRepositoryLocal(
      localSolverService: LocalSolverService(),
      localStorageService: LocalStorageService(db: db),
    );

    // ref (0 V) --[VS 5 V]--> v1 --[R 2 Ω]--> v2 --[R 3 Ω]--> ref
    // Expected: v1 = 5 V, v2 = 3 V, every branch current = 1 A.
    final uuid = Uuid();
    final ref = EndpointModel(
      pos: const Offset(1, 0),
      id: uuid.v7obj(),
      voltage: const Voltage(volts: 0),
    );
    final v1 = EndpointModel(pos: const Offset(0, 1), id: uuid.v7obj());
    final v2 = EndpointModel(pos: const Offset(0, -1), id: uuid.v7obj());

    final vs = ComponentModel(
      id: uuid.v7obj(),
      fromId: ref.id,
      toId: v1.id,
      branch: const VoltageSource(voltage: Voltage(volts: 5)),
    );
    final r1 = ComponentModel(
      id: uuid.v7obj(),
      fromId: v1.id,
      toId: v2.id,
      branch: Resistor(resistance: const Resistance(ohms: 2)),
    );
    final r2 = ComponentModel(
      id: uuid.v7obj(),
      fromId: v2.id,
      toId: ref.id,
      branch: Resistor(resistance: const Resistance(ohms: 3)),
    );

    final circuit = CircuitModel(
      id: uuid.v7obj(),
      name: 'series',
      wires: [],
      endpoints: {ref.id: ref, v1.id: v1, v2.id: v2},
      components: [vs, r1, r2],
    );

    final result = await repository.solveCircuit(circuit);

    final solved = switch (result) {
      Ok<CircuitModel>() => result.value,
      Error<CircuitModel>() => fail('circuit should solve: ${result.error}'),
    };

    const rtol = 1e-4;
    expect(
      solved.endpoints[ref.id]!.voltage!.volts,
      moreOrLessEquals(0, epsilon: rtol),
    );
    expect(
      solved.endpoints[v1.id]!.voltage!.volts,
      moreOrLessEquals(5, epsilon: rtol),
    );
    expect(
      solved.endpoints[v2.id]!.voltage!.volts,
      moreOrLessEquals(3, epsilon: rtol),
    );

    for (final component in solved.components) {
      expect(component.current!.amps, moreOrLessEquals(1, epsilon: rtol));
    }
  });
}
