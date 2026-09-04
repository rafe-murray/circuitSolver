import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/ui/view_models/component_placement.dart';
import 'package:frontend/ui/screens/editor_screen.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:frontend/ui/widgets/circuit_hit_test_view.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:frontend/ui/widgets/tools/add_component_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/lasso_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/selection_indicators.dart';
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

  Widget app() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(home: EditorScreen(circuitId: circuitId)),
  );

  Widget appWith(ProviderContainer container) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: EditorScreen(circuitId: circuitId)),
  );

  void bigView(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Adds a single resistor (and its two endpoints) to the test circuit.
  Future<void> seedResistor(ProviderContainer container) async {
    final viewModel = container.read(
      editorViewModelProvider(circuitId: circuitId).notifier,
    );
    final circuit = await container.read(
      editorViewModelProvider(circuitId: circuitId).future,
    );
    await viewModel.updateCircuit(
      insertComponent(
        circuit: circuit,
        branch: const Resistor(),
        from: const Offset(100, 80),
        to: const Offset(140, 100),
        uuid: const Uuid(),
      ),
    );
  }

  Future<void> selectComponentTool(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    // The flyout entry is the last match (the group's representative button may
    // carry the same tooltip).
    await tester.tap(find.byTooltip(tooltip).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectLassoTool(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Lasso select'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lasso select').last);
    await tester.pumpAndSettle();
  }

  group('tool input layer', () {
    testWidgets('shows a bare canvas when no tool is selected', (tester) async {
      bigView(tester);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.byType(CircuitView), findsOneWidget);
      expect(find.byType(AddComponentGestureDetector), findsNothing);
      expect(find.byType(LassoGestureDetector), findsNothing);
    });

    testWidgets('mounts the add-component gesture detector once a component '
        'tool is selected', (tester) async {
      bigView(tester);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await selectComponentTool(tester, 'Add Voltage Source');

      expect(find.byType(AddComponentGestureDetector), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AddComponentGestureDetector),
          matching: find.byType(CircuitView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('mounts the lasso gesture detector once the lasso tool is '
        'selected', (tester) async {
      bigView(tester);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await selectLassoTool(tester);

      expect(find.byType(LassoGestureDetector), findsOneWidget);
      expect(find.byType(CircuitHitTestView), findsOneWidget);
      expect(find.byType(SelectionIndicators), findsOneWidget);
    });
  });

  group('editor-wide keyboard shortcuts', () {
    testWidgets('Ctrl+A selects all and Escape clears, with no tool selected', (
      tester,
    ) async {
      bigView(tester);
      final container = makeContainer();
      await seedResistor(container);

      await tester.pumpWidget(appWith(container));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final selected = container.read(
        currentSelectionProvider(circuitId: circuitId),
      );
      expect(selected.componentIds, hasLength(1));
      expect(selected.endpointIds, hasLength(2));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        container.read(currentSelectionProvider(circuitId: circuitId)).isEmpty,
        isTrue,
      );
    });

    testWidgets('Ctrl+Z undoes the last edit', (tester) async {
      bigView(tester);
      final container = makeContainer();
      await seedResistor(container);

      await tester.pumpWidget(appWith(container));
      await tester.pumpAndSettle();
      expect(
        container
            .read(editorViewModelProvider(circuitId: circuitId).notifier)
            .canUndo,
        isTrue,
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      final circuit = await container.read(
        editorViewModelProvider(circuitId: circuitId).future,
      );
      expect(circuit.components, isEmpty);
    });
  });

  group('Enter adds a component for the active component tool', () {
    testWidgets('places a resistor', (tester) async {
      bigView(tester);
      final container = makeContainer();

      await tester.pumpWidget(appWith(container));
      await tester.pumpAndSettle();
      await selectComponentTool(tester, 'Add Resistor');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final circuit = await container.read(
        editorViewModelProvider(circuitId: circuitId).future,
      );
      expect(circuit.components, hasLength(1));
      expect(circuit.components.single.branch, isA<Resistor>());
    });
  });
}
