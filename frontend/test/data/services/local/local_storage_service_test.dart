import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/utils/result.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LocalStorageService', () {
    late CircuitSolverDatabase db;
    late LocalStorageService storage;
    late DateTime startTime;
    final uuid = Uuid();

    setUp(() {
      db = CircuitSolverDatabase.memory();
      storage = LocalStorageService(db: db);
      final now = DateTime.now();
      // SQLite does not preserve sub-second precision, so truncate up front.
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

    /// Builds a minimal but structurally complete circuit: two endpoints joined
    /// by a wire and a third endpoint wired to the first through a resistor.
    CircuitModel buildCircuit({required String name, BranchModel? branch}) {
      final ep1 = EndpointModel(pos: const Offset(0, 1), id: uuid.v7obj());
      final ep2 = EndpointModel(pos: const Offset(1, 0), id: uuid.v7obj());
      final ep3 = EndpointModel(pos: const Offset(0, -1), id: uuid.v7obj());
      return CircuitModel(
        id: uuid.v7obj(),
        name: name,
        endpoints: {ep1.id: ep1, ep2.id: ep2, ep3.id: ep3},
        wires: [
          WireModel(id: uuid.v7obj(), endpoint1Id: ep1.id, endpoint2Id: ep2.id),
        ],
        components: [
          ComponentModel(
            id: uuid.v7obj(),
            fromId: ep1.id,
            toId: ep3.id,
            branch: branch ?? Resistor(resistance: const Resistance(ohms: 5)),
          ),
        ],
      );
    }

    CircuitLocalStorageModel wrap(
      CircuitModel circuit, {
      DateTime? created,
      DateTime? modified,
    }) {
      return CircuitLocalStorageModel(
        id: circuit.id,
        name: circuit.name ?? '',
        created: created ?? startTime,
        modified: modified ?? startTime,
        circuit: circuit,
      );
    }

    test('a saved circuit can be read back unchanged', () async {
      final stored = wrap(buildCircuit(name: 'Test circuit'));

      expect(await storage.putCircuit(stored), isA<Ok<void>>());

      final getResult = await storage.getCircuit(stored.id);
      switch (getResult) {
        case Error():
          fail('reading a circuit after saving it should succeed');
        case Ok():
          expect(getResult.value, stored);
      }

      final getAllResult = await storage.getCircuits();
      switch (getAllResult) {
        case Error():
          fail('reading all circuits should succeed');
        case Ok():
          expect(getAllResult.value, [stored]);
      }
    });

    test('reading an unknown id returns an error', () async {
      final result = await storage.getCircuit(uuid.v7obj());
      expect(result, isA<Error<CircuitLocalStorageModel>>());

      final getAllResult = await storage.getCircuits();
      switch (getAllResult) {
        case Ok():
          expect(getAllResult.value, isEmpty);
        case Error():
          fail('reading all circuits when none are saved should succeed');
      }
    });

    test('multiple circuits are all retrievable', () async {
      final circuit1 = wrap(buildCircuit(name: 'Test circuit'));
      final circuit2 = wrap(
        buildCircuit(
          name: 'Test circuit 2',
          branch: const VoltageSource(voltage: Voltage(volts: 1.5)),
        ),
        created: DateTime(2026, DateTime.august, 9),
      );

      expect(await storage.putCircuit(circuit1), isA<Ok<void>>());
      expect(await storage.putCircuit(circuit2), isA<Ok<void>>());

      final getAllResult = await storage.getCircuits();
      switch (getAllResult) {
        case Error():
          fail('reading all circuits should succeed');
        case Ok():
          expect(getAllResult.value, hasLength(2));
          expect(
            getAllResult.value.singleWhere((c) => c.id == circuit1.id),
            circuit1,
          );
          expect(
            getAllResult.value.singleWhere((c) => c.id == circuit2.id),
            circuit2,
          );
      }

      expect((await storage.getCircuit(circuit1.id)).valueOrThrow(), circuit1);
      expect((await storage.getCircuit(circuit2.id)).valueOrThrow(), circuit2);
    });

    test('deleting a circuit removes it', () async {
      final stored = wrap(buildCircuit(name: 'Test circuit'));
      expect(await storage.putCircuit(stored), isA<Ok<void>>());

      expect(await storage.deleteCircuit(stored.id), isA<Ok<void>>());
      expect(
        await storage.getCircuit(stored.id),
        isA<Error<CircuitLocalStorageModel>>(),
      );
      expect(await storage.deleteCircuit(stored.id), isA<Error<void>>());
    });
  });
}
