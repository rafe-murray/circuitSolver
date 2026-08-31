import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late ProviderContainer container;
  final circuitId = const Uuid().v7obj();

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  group('CurrentSelection', () {
    test('starts empty', () {
      expect(
        container.read(currentSelectionProvider(circuitId: circuitId)),
        Selection.empty,
      );
    });

    test('set replaces the selection', () {
      final componentId = const Uuid().v7obj();
      container
          .read(currentSelectionProvider(circuitId: circuitId).notifier)
          .set(Selection(componentIds: {componentId}));

      expect(
        container
            .read(currentSelectionProvider(circuitId: circuitId))
            .componentIds,
        {componentId},
      );
    });

    test('clear empties the selection', () {
      final notifier = container.read(
        currentSelectionProvider(circuitId: circuitId).notifier,
      );
      notifier.set(Selection(endpointIds: {const Uuid().v7obj()}));
      notifier.clear();

      expect(
        container.read(currentSelectionProvider(circuitId: circuitId)).isEmpty,
        isTrue,
      );
    });

    test('selections are kept separate per circuit', () {
      final otherId = const Uuid().v7obj();
      container
          .read(currentSelectionProvider(circuitId: circuitId).notifier)
          .set(Selection(componentIds: {const Uuid().v7obj()}));

      expect(
        container.read(currentSelectionProvider(circuitId: otherId)).isEmpty,
        isTrue,
      );
    });
  });
}
