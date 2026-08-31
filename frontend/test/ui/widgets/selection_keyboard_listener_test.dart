import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/widgets/tools/selection_keyboard_listener.dart';

void main() {
  late FocusNode focusNode;

  setUp(() => focusNode = FocusNode());
  tearDown(() => focusNode.dispose());

  Widget harness({
    required VoidCallback onClear,
    required VoidCallback onSelectAll,
  }) => MaterialApp(
    home: SelectionKeyboardListener(
      focusNode: focusNode,
      onClear: onClear,
      onSelectAll: onSelectAll,
      child: const SizedBox.expand(),
    ),
  );

  testWidgets('Escape clears the selection', (tester) async {
    var clears = 0;
    var selectAlls = 0;
    await tester.pumpWidget(
      harness(onClear: () => clears++, onSelectAll: () => selectAlls++),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(clears, 1);
    expect(selectAlls, 0);
  });

  testWidgets('Ctrl + A selects everything', (tester) async {
    var clears = 0;
    var selectAlls = 0;
    await tester.pumpWidget(
      harness(onClear: () => clears++, onSelectAll: () => selectAlls++),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(selectAlls, 1);
    expect(clears, 0);
  });

  testWidgets('Cmd + A selects everything', (tester) async {
    var selectAlls = 0;
    await tester.pumpWidget(
      harness(onClear: () {}, onSelectAll: () => selectAlls++),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump();

    expect(selectAlls, 1);
  });

  testWidgets('A without a modifier does nothing', (tester) async {
    var clears = 0;
    var selectAlls = 0;
    await tester.pumpWidget(
      harness(onClear: () => clears++, onSelectAll: () => selectAlls++),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();

    expect(clears, 0);
    expect(selectAlls, 0);
  });

  testWidgets('an unrelated key does nothing', (tester) async {
    var clears = 0;
    var selectAlls = 0;
    await tester.pumpWidget(
      harness(onClear: () => clears++, onSelectAll: () => selectAlls++),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(clears, 0);
    expect(selectAlls, 0);
  });

  testWidgets('releasing Escape does not fire the clear callback again', (
    tester,
  ) async {
    var clears = 0;
    await tester.pumpWidget(
      harness(onClear: () => clears++, onSelectAll: () {}),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(clears, 1);
  });

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(harness(onClear: () {}, onSelectAll: () {}));

    expect(
      find.descendant(
        of: find.byType(SelectionKeyboardListener),
        matching: find.byType(SizedBox),
      ),
      findsOneWidget,
    );
  });
}
