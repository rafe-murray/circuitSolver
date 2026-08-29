import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/ui/screens/editor_screen.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:frontend/ui/widgets/tools/add_component_canvas_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/add_component_keyboard_listener.dart';
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

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  ToolMeta resistorMeta() => addComponentToolGroup.tools.firstWhere(
    (tool) => tool.id == AddComponentTool.resistorId,
  );

  group('AddComponentTool via updateCircuit', () {
    test('adds a resistor and its two endpoints to the circuit', () async {
      final container = makeContainer();
      final viewModel = container.read(
        editorViewModelProvider(circuitId: circuitId).notifier,
      );
      final circuit = await container.read(
        editorViewModelProvider(circuitId: circuitId).future,
      );

      final tool = Tool.fromMeta(
        meta: resistorMeta(),
        uuid: const Uuid(),
        circuit: circuit,
      );
      tool as AddComponentTool;
      await viewModel.updateCircuit(
        tool.addComponentAtPos(circuit, const Offset(120, 90)),
      );

      final updated =
          (await container
                  .read(circuitRepositoryProvider)
                  .getCircuit(circuitId))
              .valueOrThrow();
      expect(updated.components, hasLength(1));
      expect(updated.components.single.branch, isA<Resistor>());
      expect(updated.endpoints, hasLength(2));

      expect(viewModel.canUndo, isTrue);
    });
  });

  group('EditorScreen tool input layer', () {
    Widget app() => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: EditorScreen(circuitId: circuitId)),
    );

    testWidgets('shows a bare canvas when no tool is selected', (tester) async {
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.byType(CircuitView), findsOneWidget);
      expect(find.byType(AddComponentCanvasGestureDetector), findsNothing);
      expect(find.byType(AddComponentKeyboardListener), findsNothing);
    });

    testWidgets('wraps the canvas in the add-component input widgets once the '
        'resistor tool is selected', (tester) async {
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ToolButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Resistor'));
      await tester.pumpAndSettle();

      expect(find.byType(AddComponentKeyboardListener), findsOneWidget);
      expect(find.byType(AddComponentCanvasGestureDetector), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AddComponentCanvasGestureDetector),
          matching: find.byType(CircuitView),
        ),
        findsOneWidget,
      );
    });
  });
}
