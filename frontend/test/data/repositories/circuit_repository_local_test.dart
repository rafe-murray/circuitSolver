import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/repositories/circuit_repository_local.dart';
import 'package:frontend/data/services/local/local_solver_service.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/utils/exceptions.dart';
import 'package:frontend/utils/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockLocalSolverService extends Mock implements LocalSolverService {}

class _MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  setUpAll(() {
    registerFallbackValue(CircuitGraphMessage());
  });

  group('CircuitRepositoryLocal.solveCircuit', () {
    late _MockLocalSolverService solverService;
    late _MockLocalStorageService storageService;
    late CircuitRepositoryLocal repository;

    setUp(() {
      solverService = _MockLocalSolverService();
      storageService = _MockLocalStorageService();
      repository = CircuitRepositoryLocal(
        localSolverService: solverService,
        localStorageService: storageService,
      );
    });

    /// Series circuit: ref (0 V) --[VS 5 V]--> v1 --[R 2 Ω]--> v2 --[R 3 Ω]--> ref
    /// Expected solution: v1 = 5 V, v2 = 3 V, every branch current = 1 A.
    final uuid = Uuid();
    final refId = uuid.v7obj();
    final v1Id = uuid.v7obj();
    final v2Id = uuid.v7obj();
    final vsId = uuid.v7obj();
    final r1Id = uuid.v7obj();
    final r2Id = uuid.v7obj();

    CircuitModel buildCircuit() {
      return CircuitModel(
        id: uuid.v7obj(),
        name: 'series',
        wires: [],
        endpoints: {
          refId: EndpointModel(
            pos: const Offset(1, 0),
            id: refId,
            voltage: const Voltage(volts: 0),
          ),
          v1Id: EndpointModel(pos: const Offset(0, 1), id: v1Id),
          v2Id: EndpointModel(pos: const Offset(0, -1), id: v2Id),
        },
        components: [
          ComponentModel(
            id: vsId,
            fromId: refId,
            toId: v1Id,
            branch: const VoltageSource(voltage: Voltage(volts: 5)),
          ),
          ComponentModel(
            id: r1Id,
            fromId: v1Id,
            toId: v2Id,
            branch: Resistor(resistance: const Resistance(ohms: 2)),
          ),
          ComponentModel(
            id: r2Id,
            fromId: v2Id,
            toId: refId,
            branch: Resistor(resistance: const Resistance(ohms: 3)),
          ),
        ],
      );
    }

    test(
      'translates the CircuitModel to a CircuitGraphMessage for the solver',
      () async {
        when(() => solverService.solve(any())).thenAnswer(
          (invocation) async => Result.ok(
            invocation.positionalArguments.first as CircuitGraphMessage,
          ),
        );

        await repository.solveCircuit(buildCircuit());

        final sent =
            verify(() => solverService.solve(captureAny())).captured.single
                as CircuitGraphMessage;

        expect(
          sent.vertices.keys,
          containsAll([refId, v1Id, v2Id].map((id) => id.toString())),
        );
        // Only the reference endpoint carries a known voltage before solving.
        expect(sent.vertices[refId.toString()]!.voltage, 0);
        expect(sent.vertices[v1Id.toString()]!.hasVoltage(), isFalse);

        expect(
          sent.edges.keys,
          containsAll([vsId, r1Id, r2Id].map((id) => id.toString())),
        );
        expect(sent.edges[vsId.toString()]!.voltageSource.voltage, 5);
        expect(sent.edges[r1Id.toString()]!.resistor.resistance, 2);
        expect(sent.edges[r2Id.toString()]!.resistor.resistance, 3);
      },
    );

    test(
      'maps the solved CircuitGraphMessage back onto the CircuitModel',
      () async {
        when(() => solverService.solve(any())).thenAnswer((invocation) async {
          final graph =
              invocation.positionalArguments.first as CircuitGraphMessage;
          final solved = graph.deepCopy();
          solved.vertices[refId.toString()]!.voltage = 0;
          solved.vertices[v1Id.toString()]!.voltage = 5;
          solved.vertices[v2Id.toString()]!.voltage = 3;
          for (final edge in solved.edges.values) {
            edge.current = 1;
          }
          return Result.ok(solved);
        });

        final result = await repository.solveCircuit(buildCircuit());

        final circuit = switch (result) {
          Ok<CircuitModel>() => result.value,
          Error<CircuitModel>() => fail('expected Ok, got ${result.error}'),
        };

        const rtol = 1e-9;
        expect(
          circuit.endpoints[refId]!.voltage!.volts,
          moreOrLessEquals(0, epsilon: rtol),
        );
        expect(
          circuit.endpoints[v1Id]!.voltage!.volts,
          moreOrLessEquals(5, epsilon: rtol),
        );
        expect(
          circuit.endpoints[v2Id]!.voltage!.volts,
          moreOrLessEquals(3, epsilon: rtol),
        );

        for (final component in circuit.components) {
          expect(component.current!.amps, moreOrLessEquals(1, epsilon: rtol));
        }
        // Branch definitions are preserved through the round trip.
        expect(
          circuit.components.firstWhere((c) => c.id == vsId).branch,
          isA<VoltageSource>(),
        );
        expect(
          circuit.components.firstWhere((c) => c.id == r1Id).branch,
          isA<Resistor>(),
        );
      },
    );

    test('propagates a solver error unchanged', () async {
      final failure = NotFoundException('unsolvable');
      when(
        () => solverService.solve(any()),
      ).thenAnswer((_) async => Result.error(failure));

      final result = await repository.solveCircuit(buildCircuit());

      expect(result, isA<Error<CircuitModel>>());
      expect((result as Error<CircuitModel>).error, same(failure));
    });
  });
}
