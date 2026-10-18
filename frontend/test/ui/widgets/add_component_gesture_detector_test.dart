import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/widgets/tools/add_component_gesture_detector.dart';

void main() {
  Widget harness(void Function(AddComponentIntent) onIntent) => MaterialApp(
    home: Actions(
      actions: {
        AddComponentIntent: CallbackAction<AddComponentIntent>(
          onInvoke: (intent) {
            onIntent(intent);
            return null;
          },
        ),
      },
      child: const AddComponentGestureDetector(
        branch: Resistor(),
        child: SizedBox.expand(),
      ),
    ),
  );

  testWidgets('a drag dispatches an intent with the drag endpoints', (
    tester,
  ) async {
    AddComponentIntent? intent;
    await tester.pumpWidget(harness((i) => intent = i));

    await tester.dragFrom(const Offset(100, 100), const Offset(80, 120));
    await tester.pumpAndSettle();

    expect(intent, isNotNull);
    expect(intent!.branch, isA<Resistor>());
    expect(intent!.from, const Offset(100, 100));
    expect(intent!.to, const Offset(180, 220));
  });

  testWidgets('a tap dispatches an intent centred on the tapped point', (
    tester,
  ) async {
    AddComponentIntent? intent;
    await tester.pumpWidget(harness((i) => intent = i));

    await tester.tapAt(const Offset(140, 160));
    await tester.pumpAndSettle();

    expect(intent, isNotNull);
    expect((intent!.from + intent!.to) / 2, const Offset(140, 160));
  });

  testWidgets(
    'a drag that returns near its start falls back to tap placement',
    (tester) async {
      AddComponentIntent? intent;
      await tester.pumpWidget(harness((i) => intent = i));

      final gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(-38, 2));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(intent, isNotNull);
      expect((intent!.from + intent!.to) / 2, const Offset(100, 100));
    },
  );
}
