import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/repositories/circuit_repository_local.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('CircuitRepositoryLocal', () {
    test('Circuit should be solved', () async {
      final localSolverService = LocalSolverService();
      final localStorageService = LocalStorageService();
      final circuitRepositoryLocal = CircuitRepositoryLocal(
        localSolverService: localSolverService,
        localStorageService: localStorageService,
      );
      final uuid = Uuid();
      // Create endpoints
      final ref = EndpointModel(
        pos: Offset(1, 0),
        id: uuid.v7obj(),
        voltage: Voltage(volts: 0),
      );
      final v1 = EndpointModel(pos: Offset(0, 1), id: uuid.v7obj());
      final v2 = EndpointModel(pos: Offset(0, -1), id: uuid.v7obj());

      // Create components
      final vs = ComponentModel(
        id: uuid.v7obj(),
        from: ref,
        to: v1,
        branch: VoltageSource(voltage: Voltage(volts: 5)),
      );

      final r1 = ComponentModel(
        id: uuid.v7obj(),
        from: v1,
        to: v2,
        branch: Resistor(resistance: Resistance(ohms: 2)),
      );

      final r2 = ComponentModel(
        id: uuid.v7obj(),
        from: v2,
        to: ref,
        branch: Resistor(resistance: Resistance(ohms: 3)),
      );

      final circuitModel = CircuitModel(
        id: uuid.v7obj(),
        components: [vs, r1, r2],
        wires: [],
      );

      final result = await circuitRepositoryLocal.solveCircuit(circuitModel);
      switch (result) {
        case Error():
          fail(
            'Circuit should solve correctly: Error: ${result.error.toString()}',
          );
        case Ok():
          final rtol = 1e-4;
          final resultVs = result.value.components.firstWhere(
            (component) => component.id == vs.id,
          );
          final resultR1 = result.value.components.firstWhere(
            (component) => component.id == r1.id,
          );
          final resultR2 = result.value.components.firstWhere(
            (component) => component.id == r2.id,
          );

          expect(resultVs.current?.amps, moreOrLessEquals(1, epsilon: rtol));
          expect(
            resultVs.from.copyWith(voltage: ref.voltage),
            ref,
            reason: "Endpoint ids and positions should stay constant",
          );
          expect(
            resultVs.to.copyWith(voltage: v1.voltage),
            v1,
            reason: "Endpoint ids and positions should stay constant",
          );

          expect(resultR1.current?.amps, moreOrLessEquals(1, epsilon: rtol));
          expect(
            resultR1.from.copyWith(voltage: v1.voltage),
            v1,
            reason: "Endpoint ids and positions should stay constant",
          );
          expect(
            resultR1.to.copyWith(voltage: v2.voltage),
            v2,
            reason: "Endpoint ids and positions should stay constant",
          );

          expect(resultR2.current?.amps, moreOrLessEquals(1, epsilon: rtol));
          expect(
            resultR2.from.copyWith(voltage: v2.voltage),
            v2,
            reason: "Endpoint ids and positions should stay constant",
          );
          expect(
            resultR2.to.copyWith(voltage: ref.voltage),
            ref,
            reason: "Endpoint ids and positions should stay constant",
          );

          // ref
          expect(resultVs.from.voltage, moreOrLessEquals(0, epsilon: rtol));
          // v1
          expect(resultVs.to.voltage, moreOrLessEquals(5, epsilon: rtol));
          // v2
          expect(resultR1.to.voltage, moreOrLessEquals(3, epsilon: rtol));
      }
    });
  });
}
