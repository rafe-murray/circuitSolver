import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/widgets/tools/lasso_selection_gesture_detector.dart';

void main() {
  Widget harness({
    required void Function(LassoRegion) onLassoComplete,
    required VoidCallback onTapClear,
  }) => MaterialApp(
    home: LassoSelectionGestureDetector(
      onLassoComplete: onLassoComplete,
      onTapClear: onTapClear,
      child: const SizedBox.expand(),
    ),
  );

  testWidgets('a drag reports a closed region tracing the pointer path', (
    tester,
  ) async {
    LassoRegion? region;
    var taps = 0;
    await tester.pumpWidget(
      harness(onLassoComplete: (r) => region = r, onTapClear: () => taps++),
    );

    // Drag a loop enclosing the region around (115, 150).
    final gesture = await tester.startGesture(const Offset(100, 100));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.moveBy(const Offset(0, 60));
    await gesture.moveBy(const Offset(0, 40));
    await gesture.moveBy(const Offset(-60, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(taps, 0);
    expect(region, isNotNull);
    expect(region!.isValid, isTrue);
    expect(region!.containsPoint(const Offset(115, 150)), isTrue);
    expect(region!.containsPoint(const Offset(400, 400)), isFalse);
  });

  testWidgets('a plain tap clears instead of reporting a region', (
    tester,
  ) async {
    LassoRegion? region;
    var taps = 0;
    await tester.pumpWidget(
      harness(onLassoComplete: (r) => region = r, onTapClear: () => taps++),
    );

    await tester.tapAt(const Offset(140, 160));
    await tester.pumpAndSettle();

    expect(region, isNull);
    expect(taps, 1);
  });

  testWidgets('draws the in-progress lasso overlay only while dragging', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(onLassoComplete: (_) {}, onTapClear: () {}),
    );

    Finder overlay() => find.descendant(
      of: find.byType(LassoSelectionGestureDetector),
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
