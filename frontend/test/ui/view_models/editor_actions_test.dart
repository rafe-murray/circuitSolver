import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/repository_providers.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/data/services/local/local_storage_service.dart';
import 'package:frontend/data/services/local/model/circuit_local_storage_model.dart';
import 'package:frontend/ui/view_models/editor_actions.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:uuid/uuid.dart';

/// Mounts the editor [Actions] over a live [editorViewModelProvider] (kept
/// alive by a `watch`), and exposes a [BuildContext] under the actions so tests
/// can dispatch intents the way the real widgets do.
class _ActionsHarness extends ConsumerWidget {
  const _ActionsHarness({required this.circuitId, required this.onContext});

  final UuidValue circuitId;
  final void Function(BuildContext) onContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(editorViewModelProvider(circuitId: circuitId));
    return Actions(
      actions: buildEditorActions(ref, circuitId),
      child: Builder(
        builder: (context) {
          onContext(context);
          return const SizedBox();
        },
      ),
    );
  }
}

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

  tearDown(() async => db.close());

  Future<(BuildContext, ProviderContainer)> pumpHarness(
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    late BuildContext ctx;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _ActionsHarness(circuitId: circuitId, onContext: (c) => ctx = c),
      ),
    );
    await container.read(editorViewModelProvider(circuitId: circuitId).future);
    await tester.pumpAndSettle();
    return (ctx, container);
  }

  testWidgets('AddComponentAction adds a component via the view model', (
    tester,
  ) async {
    final (ctx, container) = await pumpHarness(tester);

    Actions.invoke(
      ctx,
      const AddComponentIntent(
        branch: Resistor(),
        from: Offset(10, 20),
        to: Offset(30, 40),
      ),
    );
    await tester.pumpAndSettle();

    final updated =
        (await container.read(circuitRepositoryProvider).getCircuit(circuitId))
            .valueOrThrow();
    expect(updated.components, hasLength(1));
    expect(updated.components.single.branch, isA<Resistor>());
    expect(updated.endpoints, hasLength(2));
  });

  testWidgets('select-all then clear updates the current selection', (
    tester,
  ) async {
    final (ctx, container) = await pumpHarness(tester);

    // Seed a component so there is something to select.
    Actions.invoke(
      ctx,
      const AddComponentIntent(
        branch: Resistor(),
        from: Offset(100, 80),
        to: Offset(140, 100),
      ),
    );
    await tester.pumpAndSettle();

    Actions.invoke(ctx, const SelectAllIntent());
    await tester.pump();
    final selection = container.read(
      currentSelectionProvider(circuitId: circuitId),
    );
    expect(selection.componentIds, hasLength(1));
    expect(selection.endpointIds, hasLength(2));

    Actions.invoke(ctx, const ClearSelectionIntent());
    await tester.pump();
    expect(
      container.read(currentSelectionProvider(circuitId: circuitId)),
      Selection.empty,
    );
  });
}
