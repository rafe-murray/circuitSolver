import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/view_models/selection_geometry.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();

  // Resistor A spans (100,100)->(160,100); resistor B spans (400,400)->(460,400).
  final aFrom = EndpointModel(pos: const Offset(100, 100), id: uuid.v7obj());
  final aTo = EndpointModel(pos: const Offset(160, 100), id: uuid.v7obj());
  final bFrom = EndpointModel(pos: const Offset(400, 400), id: uuid.v7obj());
  final bTo = EndpointModel(pos: const Offset(460, 400), id: uuid.v7obj());
  final componentA = ComponentModel(
    id: uuid.v7obj(),
    fromId: aFrom.id,
    toId: aTo.id,
    branch: const Resistor(),
  );
  final componentB = ComponentModel(
    id: uuid.v7obj(),
    fromId: bFrom.id,
    toId: bTo.id,
    branch: const Resistor(),
  );

  CircuitModel circuit() => CircuitModel(
    id: uuid.v7obj(),
    name: 'test',
    components: [componentA, componentB],
    wires: [],
    endpoints: {aFrom.id: aFrom, aTo.id: aTo, bFrom.id: bFrom, bTo.id: bTo},
  );

  test(
    'lassoSelection captures only the enclosed component and its endpoints',
    () {
      final region = const LassoRegion([
        Offset(70, 70),
        Offset(190, 70),
        Offset(190, 130),
        Offset(70, 130),
      ]);

      final selection = lassoSelection(circuit(), region);

      expect(selection.componentIds, {componentA.id});
      expect(selection.endpointIds, {aFrom.id, aTo.id});
    },
  );

  test('lassoSelection returns nothing for a region clear of the circuit', () {
    final selection = lassoSelection(
      circuit(),
      const LassoRegion([
        Offset(700, 700),
        Offset(760, 700),
        Offset(760, 760),
        Offset(700, 760),
      ]),
    );

    expect(selection.isEmpty, isTrue);
  });

  test('lassoSelection ignores a degenerate region', () {
    final selection = lassoSelection(
      circuit(),
      const LassoRegion([Offset(100, 100), Offset(160, 100)]),
    );
    expect(selection.isEmpty, isTrue);
  });

  test('selectAllOf returns every component and endpoint', () {
    final selection = selectAllOf(circuit());
    expect(selection.componentIds, {componentA.id, componentB.id});
    expect(selection.endpointIds, {aFrom.id, aTo.id, bFrom.id, bTo.id});
  });
}
