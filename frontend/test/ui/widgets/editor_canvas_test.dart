import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/editor_canvas.dart';
import 'package:uuid/uuid.dart';

void main() {
  late CircuitSolverDatabase db;
  late UuidValue circuitId;

  setUp(() async {
    db = CircuitSolverDatabase.memory();
    circuitId = const Uuid().v7obj();
    await LocalStorageService(db: db).putCircuit(
      CircuitLocalStorageModel(
        id: circuitId,
        name: 'Test circuit',
        created: DateTime(2026),
        modified: DateTime(2026),
        circuit: CircuitModel(
          id: circuitId,
          name: 'Test circuit',
          components: [],
          wires: [],
          endpoints: {},
        ),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget app() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(body: EditorCanvas(circuitId: circuitId)),
    ),
  );

  testWidgets('renders the circuit inside an InteractiveViewer', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byType(CircuitView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a middle-mouse drag pans the canvas', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final before = tester.getTopLeft(find.byType(CircuitView));

    final gesture = await tester.startGesture(
      const Offset(400, 300),
      kind: PointerDeviceKind.mouse,
      buttons: kMiddleMouseButton,
    );
    await gesture.moveBy(const Offset(60, 40));
    await gesture.up();
    await tester.pumpAndSettle();

    final after = tester.getTopLeft(find.byType(CircuitView));
    expect(after - before, const Offset(60, 40));
  });
}
