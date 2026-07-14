import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/editor_tool.dart';
import '../viewmodels/canvas_viewmodel.dart';

/// A vertical strip of tool buttons displayed on the left side of the editor.
///
/// Each button selects an [EditorTool]. The active tool is highlighted. A
/// tooltip on each button shows the tool name and its keyboard shortcut.
class ToolPalette extends StatelessWidget {
  const ToolPalette({super.key});

  static const double kPaletteWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CanvasViewModel>(context);
    return Material(
      elevation: 2,
      child: SizedBox(
        width: kPaletteWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final tool in EditorTool.values)
              _ToolButton(
                tool: tool,
                isActive: vm.activeTool == tool,
                onTap: () => vm.setTool(tool),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// A single icon button in the [ToolPalette].
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tool,
    required this.isActive,
    required this.onTap,
  });

  final EditorTool tool;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '${tool.label} (${tool.shortcutLabel})',
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,
          child: Icon(
            tool.icon,
            size: 22,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withAlpha(180),
          ),
        ),
      ),
    );
  }
}
