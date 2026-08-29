import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LocalStorageService', () {
    late CircuitSolverDatabase db;
    late DateTime startTime;
    setUp(() {
      db = CircuitSolverDatabase.memory();
      final now = DateTime.now();
      // Ignore milliseconds since SQLite doesn't store them
      startTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
      );
    });
    tearDown(() async {
      await db.close();
    });

    test('Saved circuits should be retrievable', () async {
      expect(db, isNotNull);
      final localStorageService = LocalStorageService(db: db);
      final uuid = Uuid();
      final ep1 = EndpointModel(pos: Offset(0, 1), id: uuid.v7obj());
      final ep2 = EndpointModel(pos: Offset(1, 0), id: uuid.v7obj());
      final ep3 = EndpointModel(pos: Offset(0, -1), id: uuid.v7obj());
      final wires = <WireModel>[
        WireModel(id: uuid.v7obj(), endpoint1: ep1, endpoint2: ep2),
      ];

      final components = <ComponentModel>[
        ComponentModel(
          id: uuid.v7obj(),
          from: ep1,
          to: ep3,
          branch: Resistor(resistance: Resistance(ohms: 5)),
        ),
      ];

      final circuit = CircuitLocalStorageModel(
        id: uuid.v7obj(),
        name: "Test circuit",
        created: startTime,
        modified: startTime,
        wires: wires,
        components: components,
      );

      final putResult = await localStorageService.putCircuit(circuit);
      expect(putResult, isA<Ok>());
      final getResult = await localStorageService.getCircuit(circuit.id);
      switch (getResult) {
        case Error():
          fail("getting a circuit after saving it should succeed");
        case Ok():
          expect(
            getResult.value,
            circuit,
            reason: "circuit should not change when saving/retrieving",
          );
      }
      final getAllResult = await localStorageService.getCircuits();
      switch (getAllResult) {
        case Error():
          fail("getting all circuits should succeed");
        case Ok():
          expect(getAllResult.value.length, 1);
          expect(
            getAllResult.value.first,
            circuit,
            reason:
                "getting all circuits should contain the original saved circuit",
          );
      }
    });
    test('Retrieving a fake id should fail', () async {
      expect(db, isNotNull);
      final localStorageService = LocalStorageService(db: db);
      final result = await localStorageService.getCircuit(Uuid().v7obj());
      expect(result, isA<Error>());
      final getAllResult = await localStorageService.getCircuits();
      switch (getAllResult) {
        case Ok():
          expect(getAllResult.value.isEmpty, isTrue);
        case Error():
          fail(
            "getting all circuits when none are saved should return an empty list",
          );
      }
    });
    test('Saving multiple circuits should allow all to be retrieved', () async {
      final localStorageService = LocalStorageService(db: db);
      final uuid = Uuid();
      final ep1 = EndpointModel(pos: Offset(0, 1), id: uuid.v7obj());
      final ep2 = EndpointModel(pos: Offset(1, 0), id: uuid.v7obj());
      final ep3 = EndpointModel(pos: Offset(0, -1), id: uuid.v7obj());
      final wires1 = <WireModel>[
        WireModel(id: uuid.v7obj(), endpoint1: ep1, endpoint2: ep2),
      ];

      final wires2 = <WireModel>[
        WireModel(id: uuid.v7obj(), endpoint1: ep2, endpoint2: ep3),
      ];

      final components1 = <ComponentModel>[
        ComponentModel(
          id: uuid.v7obj(),
          from: ep1,
          to: ep3,
          branch: Resistor(resistance: Resistance(ohms: 5)),
        ),
      ];

      final components2 = <ComponentModel>[
        ComponentModel(
          id: uuid.v7obj(),
          from: ep1,
          to: ep2,
          branch: VoltageSource(voltage: Voltage(volts: 1.5)),
        ),
      ];

      final circuit1 = CircuitLocalStorageModel(
        id: uuid.v7obj(),
        name: "Test circuit",
        created: startTime,
        modified: startTime,
        wires: wires1,
        components: components1,
      );

      final circuit2 = CircuitLocalStorageModel(
        id: uuid.v7obj(),
        name: "Test circuit 2",
        created: DateTime(2026, DateTime.august, 9),
        modified: startTime,
        wires: wires2,
        components: components2,
      );

      final putResult1 = await localStorageService.putCircuit(circuit1);
      expect(putResult1, isA<Ok>());
      final putResult2 = await localStorageService.putCircuit(circuit2);
      expect(putResult2, isA<Ok>());
      final getAllResult = await localStorageService.getCircuits();
      switch (getAllResult) {
        case Error():
          fail("getting all circuits should succeed");
        case Ok():
          expect(getAllResult.value.length, 2);
          expect(
            getAllResult.value.singleWhere(
              (circuit) => circuit.id == circuit1.id,
            ),
            circuit1,
          );
          expect(
            getAllResult.value.singleWhere(
              (circuit) => circuit.id == circuit2.id,
            ),
            circuit2,
          );
      }
      final getResult1 = (await localStorageService.getCircuit(circuit1.id))
          .transform((c) {
            expect(c, circuit1);
          });
      expect(getResult1, isA<Ok>());

      final getResult2 = (await localStorageService.getCircuit(circuit2.id))
          .transform((c) {
            expect(c, circuit2);
          });
      expect(getResult2, isA<Ok>());
    });
  });
}
