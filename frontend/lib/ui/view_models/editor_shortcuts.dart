import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/view_models/tool/tool_catalog.dart';

/// Keyboard shortcuts active across the whole editor, regardless of tool.
///
/// Mount on a [Shortcuts] widget wrapping the editor screen.
const Map<ShortcutActivator, Intent> commonEditorShortcuts = {
  SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
      RedoIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
      RedoIntent(),
  SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, control: true): SelectAllIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
  SingleActivator(LogicalKeyboardKey.escape): ClearSelectionIntent(),
};

/// Keyboard shortcuts specific to [tool], or an empty map when the tool has
/// none (or no tool is selected).
///
/// Mount on a [Shortcuts] widget scoped to the active tool, nested inside the
/// editor-wide [commonEditorShortcuts].
Map<ShortcutActivator, Intent> shortcutsForTool(ToolMeta? tool) {
  if (tool == null) return const {};
  switch (toolKindOf(tool)) {
    case EditorToolKind.addComponent:
      final branch = branchOf(tool);
      if (branch == null) return const {};
      return {
        const SingleActivator(LogicalKeyboardKey.enter): AddComponentIntent(
          branch: branch,
          from: const Offset(30, 30),
          to: const Offset(70, 70),
        ),
      };
    case EditorToolKind.lasso:
    case EditorToolKind.none:
      return const {};
  }
}
