import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/widgets/circuit_hit_test_view.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();

  // A horizontal resistor from (100,100) to (160,100).
  final from = EndpointModel(pos: const Offset(100, 100), id: uuid.v7obj());
  final to = EndpointModel(pos: const Offset(160, 100), id: uuid.v7obj());
  final component = ComponentModel(
    id: uuid.v7obj(),
    fromId: from.id,
    toId: to.id,
    branch: const Resistor(),
  );

  CircuitModel circuit() => CircuitModel(
    id: uuid.v7obj(),
    name: 'test',
    components: [component],
    wires: [],
    endpoints: {from.id: from, to.id: to},
  );

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 400, height: 400, child: child),
      ),
    ),
  );

  testWidgets('renders the circuit and no gesture targets without callbacks', (
    tester,
  ) async {
    await tester.pumpWidget(host(CircuitHitTestView(circuitModel: circuit())));

    expect(find.byType(CircuitView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CircuitHitTestView),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
  });

  testWidgets('a tap on a component body reports the component id', (
    tester,
  ) async {
    UuidValue? hit;
    await tester.pumpWidget(
      host(
        CircuitHitTestView(
          circuitModel: circuit(),
          onComponentHit: (id) => hit = id,
        ),
      ),
    );

    // The midpoint of the component, clear of both endpoint circles.
    await tester.tapAt(const Offset(130, 100));
    await tester.pump();

    expect(hit, component.id);
  });

  testWidgets('a tap on an endpoint reports the endpoint id', (tester) async {
    UuidValue? hitEndpoint;
    UuidValue? hitComponent;
    await tester.pumpWidget(
      host(
        CircuitHitTestView(
          circuitModel: circuit(),
          onEndpointHit: (id) => hitEndpoint = id,
          onComponentHit: (id) => hitComponent = id,
        ),
      ),
    );

    await tester.tapAt(const Offset(100, 100));
    await tester.pump();

    // The endpoint target sits above the component target.
    expect(hitEndpoint, from.id);
    expect(hitComponent, isNull);
  });

  testWidgets('scales hit-target placement by scalingFactor', (tester) async {
    UuidValue? hit;
    await tester.pumpWidget(
      host(
        CircuitHitTestView(
          circuitModel: circuit(),
          scalingFactor: 2.0,
          onComponentHit: (id) => hit = id,
        ),
      ),
    );

    // The component midpoint moves from (130,100) to (260,200) at 2x.
    await tester.tapAt(const Offset(260, 200));
    await tester.pump();

    expect(hit, component.id);
  });
}
