import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/widgets/tools/selection_indicators.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();

  final from = EndpointModel(pos: const Offset(100, 100), id: uuid.v7obj());
  final to = EndpointModel(pos: const Offset(200, 100), id: uuid.v7obj());
  final component = ComponentModel(
    id: uuid.v7obj(),
    fromId: from.id,
    toId: to.id,
    branch: const Resistor(),
  );
  final circuit = CircuitModel(
    id: uuid.v7obj(),
    name: 'test',
    components: [component],
    wires: [],
    endpoints: {from.id: from, to.id: to},
  );

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    double scalingFactor = 1.0,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: 400,
                child: SelectionIndicators(
                  circuitModel: circuit,
                  scalingFactor: scalingFactor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  Finder dots() => find.descendant(
    of: find.byType(SelectionIndicators),
    matching: find.byType(DecoratedBox),
  );

  void select(ProviderContainer container, Selection selection) => container
      .read(currentSelectionProvider(circuitId: circuit.id).notifier)
      .set(selection);

  testWidgets('draws nothing when the selection is empty', (tester) async {
    await pump(tester);
    expect(dots(), findsNothing);
  });

  testWidgets('draws a dot at the midpoint of a selected component', (
    tester,
  ) async {
    final container = await pump(tester);
    select(container, Selection(componentIds: {component.id}));
    await tester.pump();

    final dot = tester.getRect(dots());
    expect(dot.center, const Offset(150, 100));
  });

  testWidgets('draws a dot at each selected endpoint', (tester) async {
    final container = await pump(tester);
    select(container, Selection(endpointIds: {from.id, to.id}));
    await tester.pump();

    expect(dots(), findsNWidgets(2));
  });

  testWidgets('applies the scaling factor to dot placement', (tester) async {
    final container = await pump(tester, scalingFactor: 2.0);
    select(container, Selection(endpointIds: {from.id}));
    await tester.pump();

    final dot = tester.getRect(dots());
    expect(dot.center, const Offset(200, 200));
  });
}
