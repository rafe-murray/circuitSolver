import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/view_models/tool/tool_catalog.dart';
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

  final voltageSource = addComponentToolGroup.tools.firstWhere(
    (tool) => tool.id == voltageSourceToolId,
  );

  testWidgets('shows one entry per tool group with the flyout collapsed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    expect(find.byType(ToolPicker), findsNWidgets(toolGroups.length));
    // Collapsed: one representative button per group.
    expect(find.byType(ToolButton), findsNWidgets(toolGroups.length));
    // A tool that is only in the flyout is not shown yet.
    expect(find.byTooltip(voltageSource.name), findsNothing);
  });

  testWidgets('tapping an entry reveals every tool in its group', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();

    // One representative button per group, plus one per tool in the open group.
    expect(
      find.byType(ToolButton),
      findsNWidgets(toolGroups.length + addComponentToolGroup.tools.length),
    );
    expect(find.byTooltip('Add Ideal Diode'), findsOneWidget);
  });

  testWidgets('picking a tool reports it and closes the flyout', (
    tester,
  ) async {
    ToolMeta? picked;
    await tester.pumpWidget(wrap(onToolSelected: (meta) => picked = meta));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(voltageSource.name));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.id, voltageSourceToolId);
    // Flyout closed again: back to one representative button per group.
    expect(find.byType(ToolButton), findsNWidgets(toolGroups.length));
  });

  testWidgets('tapping the entry again closes the flyout', (tester) async {
    await tester.pumpWidget(wrap(onToolSelected: (_) {}));

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    expect(find.byTooltip(voltageSource.name), findsOneWidget);

    await tester.tap(find.byType(ToolButton).first);
    await tester.pumpAndSettle();
    expect(find.byTooltip(voltageSource.name), findsNothing);
  });

  testWidgets('the active tool renders its group entry as selected', (
    tester,
  ) async {
    final resistor = addComponentToolGroup.tools.firstWhere(
      (tool) => tool.id == resistorToolId,
    );
    await tester.pumpWidget(
      wrap(selectedTool: resistor, onToolSelected: (_) {}),
    );

    final button = tester.widget<ToolButton>(find.byType(ToolButton).first);
    expect(button.selected, isTrue);
    expect(button.meta.id, resistorToolId);
  });
}
