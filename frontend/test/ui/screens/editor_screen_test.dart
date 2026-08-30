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
import 'package:frontend/ui/widgets/circuit_hit_test_view.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';
import 'package:frontend/ui/widgets/tools/add_component_canvas_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/add_component_keyboard_listener.dart';
import 'package:frontend/ui/widgets/tools/lasso_selection_gesture_detector.dart';
import 'package:frontend/ui/widgets/tools/selection_indicators.dart';
import 'package:frontend/ui/widgets/tools/selection_keyboard_listener.dart';
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

    test('addComponentBetween places endpoints at the given offsets', () async {
      final container = makeContainer();
      final viewModel = container.read(
        editorViewModelProvider(circuitId: circuitId).notifier,
      );
      final circuit = await container.read(
        editorViewModelProvider(circuitId: circuitId).future,
      );

      final tool =
          Tool.fromMeta(
                meta: resistorMeta(),
                uuid: const Uuid(),
                circuit: circuit,
              )
              as AddComponentTool;
      await viewModel.updateCircuit(
        tool.addComponentBetween(
          circuit,
          from: const Offset(10, 20),
          to: const Offset(200, 220),
        ),
      );

      final updated =
          (await container
                  .read(circuitRepositoryProvider)
                  .getCircuit(circuitId))
              .valueOrThrow();
      final component = updated.components.single;
      expect(updated.endpoints[component.fromId]!.pos, const Offset(10, 20));
      expect(updated.endpoints[component.toId]!.pos, const Offset(200, 220));
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

    testWidgets('wraps the canvas in the add-component input widgets once a '
        'tool is selected', (tester) async {
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ToolButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add Voltage Source'));
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

  group('EditorScreen selection tool input layer', () {
    Widget app() => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: EditorScreen(circuitId: circuitId)),
    );

    testWidgets('wraps the canvas in the lasso selection widgets once the '
        'lasso tool is selected', (tester) async {
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // Open the selection group's flyout, then pick the lasso sub-tool.
      await tester.tap(find.byTooltip('Lasso select'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Lasso select').last);
      await tester.pumpAndSettle();

      expect(find.byType(SelectionKeyboardListener), findsOneWidget);
      expect(find.byType(LassoSelectionGestureDetector), findsOneWidget);
      expect(find.byType(CircuitHitTestView), findsOneWidget);
      expect(find.byType(SelectionIndicators), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LassoSelectionGestureDetector),
          matching: find.byType(CircuitView),
        ),
        findsOneWidget,
      );
    });
  });

  group('AddComponentCanvasGestureDetector', () {
    Widget harness({
      required void Function(Offset) onTap,
      required void Function({required Offset from, required Offset to}) onDrag,
    }) => MaterialApp(
      home: AddComponentCanvasGestureDetector(
        branch: const Resistor(),
        addComponentCallback: onTap,
        addComponentBetweenCallback: onDrag,
        child: const SizedBox.expand(),
      ),
    );

    testWidgets('a drag reports its start and end offsets', (tester) async {
      Offset? tapped;
      ({Offset from, Offset to})? dragged;

      await tester.pumpWidget(
        harness(
          onTap: (pos) => tapped = pos,
          onDrag: ({required from, required to}) =>
              dragged = (from: from, to: to),
        ),
      );

      await tester.dragFrom(const Offset(100, 100), const Offset(80, 120));
      await tester.pumpAndSettle();

      expect(tapped, isNull);
      expect(dragged, isNotNull);
      expect(dragged!.from, const Offset(100, 100));
      expect(dragged!.to, const Offset(180, 220));
    });

    testWidgets('a drag that returns near its start falls back to tap '
        'placement', (tester) async {
      Offset? tapped;
      ({Offset from, Offset to})? dragged;

      await tester.pumpWidget(
        harness(
          onTap: (pos) => tapped = pos,
          onDrag: ({required from, required to}) =>
              dragged = (from: from, to: to),
        ),
      );

      final gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(-38, 2));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dragged, isNull);
      expect(tapped, isNotNull);
    });

    testWidgets('a tap reports the tapped offset', (tester) async {
      Offset? tapped;

      await tester.pumpWidget(
        harness(
          onTap: (pos) => tapped = pos,
          onDrag: ({required from, required to}) {},
        ),
      );

      await tester.tapAt(const Offset(140, 160));
      await tester.pumpAndSettle();

      expect(tapped, const Offset(140, 160));
    });
  });
}
