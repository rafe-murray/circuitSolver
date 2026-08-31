import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';
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

  LassoTool tool(CircuitModel c) =>
      Tool.fromMeta(
            meta: selectionToolGroup.tools.single,
            uuid: uuid,
            circuit: c,
          )
          as LassoTool;

  test('the lasso group exposes a single sub-tool', () {
    expect(selectionToolGroup.tools.single.id, LassoTool.lassoId);
  });

  test(
    'selectWithin captures only the enclosed component and its endpoints',
    () {
      final c = circuit();
      final region = const LassoRegion([
        Offset(70, 70),
        Offset(190, 70),
        Offset(190, 130),
        Offset(70, 130),
      ]);

      final selection = tool(c).selectWithin(region);

      expect(selection.componentIds, {componentA.id});
      expect(selection.endpointIds, {aFrom.id, aTo.id});
    },
  );

  test('selectWithin returns nothing for a region clear of the circuit', () {
    final selection = tool(circuit()).selectWithin(
      const LassoRegion([
        Offset(700, 700),
        Offset(760, 700),
        Offset(760, 760),
        Offset(700, 760),
      ]),
    );

    expect(selection.isEmpty, isTrue);
  });

  test('selectWithin ignores a degenerate region', () {
    final selection = tool(
      circuit(),
    ).selectWithin(const LassoRegion([Offset(100, 100), Offset(160, 100)]));
    expect(selection.isEmpty, isTrue);
  });

  test('selectAll returns every component and endpoint', () {
    final c = circuit();
    final selection = tool(c).selectAll();
    expect(selection.componentIds, {componentA.id, componentB.id});
    expect(selection.endpointIds, {aFrom.id, aTo.id, bFrom.id, bTo.id});
  });
}
