import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/widgets/tools/lasso_gesture_detector.dart';

void main() {
  Widget harness({
    void Function(SelectWithinLassoIntent)? onLasso,
    VoidCallback? onClear,
  }) => MaterialApp(
    home: Actions(
      actions: {
        SelectWithinLassoIntent: CallbackAction<SelectWithinLassoIntent>(
          onInvoke: (intent) {
            onLasso?.call(intent);
            return null;
          },
        ),
        ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(
          onInvoke: (_) {
            onClear?.call();
            return null;
          },
        ),
      },
      child: const LassoGestureDetector(child: SizedBox.expand()),
    ),
  );

  testWidgets('a drag dispatches a closed region tracing the pointer path', (
    tester,
  ) async {
    SelectWithinLassoIntent? intent;
    var clears = 0;
    await tester.pumpWidget(
      harness(onLasso: (i) => intent = i, onClear: () => clears++),
    );

    final gesture = await tester.startGesture(const Offset(100, 100));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.moveBy(const Offset(0, 60));
    await gesture.moveBy(const Offset(0, 40));
    await gesture.moveBy(const Offset(-60, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(clears, 0);
    expect(intent, isNotNull);
    expect(intent!.region.isValid, isTrue);
    expect(intent!.region.containsPoint(const Offset(115, 150)), isTrue);
  });

  testWidgets('a plain tap dispatches a clear intent', (tester) async {
    SelectWithinLassoIntent? intent;
    var clears = 0;
    await tester.pumpWidget(
      harness(onLasso: (i) => intent = i, onClear: () => clears++),
    );

    await tester.tapAt(const Offset(140, 160));
    await tester.pumpAndSettle();

    expect(intent, isNull);
    expect(clears, 1);
  });

  testWidgets('draws the in-progress lasso overlay only while dragging', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    Finder overlay() => find.descendant(
      of: find.byType(LassoGestureDetector),
      matching: find.byType(CustomPaint),
    );

    expect(overlay(), findsNothing);

    final gesture = await tester.startGesture(const Offset(100, 100));
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    expect(overlay(), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(overlay(), findsNothing);
  });
}
