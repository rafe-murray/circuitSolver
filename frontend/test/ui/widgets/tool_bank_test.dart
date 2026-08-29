import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';
import 'package:frontend/ui/widgets/tool_bank.dart';

void main() {
  Widget wrap({
    ToolMeta? selectedTool,
    required ValueChanged<ToolMeta> onToolSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ToolBank(
          selectedTool: selectedTool,
          onToolSelected: onToolSelected,
        ),
      ),
    );
  }

  testWidgets('shows one entry per tool group with the flyout collapsed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    expect(find.byType(ToolPicker), findsNWidgets(toolGroups.length));
    // Collapsed: one representative button per group, no group tool labels.
    expect(find.byType(ToolButton), findsNWidgets(toolGroups.length));
    expect(find.text('Add Resistor'), findsNothing);
  });

  testWidgets('tapping an entry reveals every tool in its group', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();

    for (final tool in addComponentToolGroup.tools) {
      expect(find.text(tool.name), findsOneWidget);
    }
  });

  testWidgets('picking a tool reports it and closes the flyout', (
    tester,
  ) async {
    ToolMeta? picked;
    await tester.pumpWidget(wrap(onToolSelected: (meta) => picked = meta));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Resistor'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.id, AddComponentTool.resistorId);
    // Flyout closed again.
    expect(find.text('Add Voltage Source'), findsNothing);
  });

  testWidgets('tapping the entry again closes the flyout', (tester) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Add Resistor'), findsOneWidget);

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Add Resistor'), findsNothing);
  });

  testWidgets('the active tool renders its group entry as selected', (
    tester,
  ) async {
    final resistor = addComponentToolGroup.tools.firstWhere(
      (tool) => tool.id == AddComponentTool.resistorId,
    );
    await tester.pumpWidget(
      wrap(selectedTool: resistor, onToolSelected: (_) {}),
    );

    final button = tester.widget<ToolButton>(find.byType(ToolButton));
    expect(button.selected, isTrue);
    expect(button.meta.id, AddComponentTool.resistorId);
  });
}
