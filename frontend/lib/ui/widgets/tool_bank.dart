import 'package:flutter/material.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';

/// Vertical rail of tool groups shown alongside the circuit editor.
///
/// Renders one [ToolPicker] per entry in [toolGroups]. The tool the user picks
/// is reported through [onToolSelected]; the currently active tool is passed
/// back in via [selectedTool] so the matching entry renders as selected.
class ToolBank extends StatelessWidget {
  const ToolBank({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
  });

  /// The tool currently active in the editor, or `null` when none is selected.
  final ToolMeta? selectedTool;

  /// Called with the [ToolMeta] of the tool the user picked.
  final ValueChanged<ToolMeta> onToolSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: SizedBox(
        width: 64,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final group in toolGroups)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ToolPicker(
                    group: group,
                    selectedTool: selectedTool,
                    onToolSelected: onToolSelected,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single [ToolGroup] entry in the [ToolBank].
///
/// Shows a representative [ToolButton] for the group; tapping it toggles a
/// flyout listing every tool in the group. The representative is the group's
/// active tool when one is selected, otherwise [ToolGroup.tools]'s first entry.
class ToolPicker extends StatefulWidget {
  const ToolPicker({
    super.key,
    required this.group,
    required this.selectedTool,
    required this.onToolSelected,
  });

  /// The group of tools this entry picks between.
  final ToolGroup group;

  /// The tool currently active in the editor, or `null` when none is selected.
  final ToolMeta? selectedTool;

  /// Called with the [ToolMeta] of the tool the user picked from the flyout.
  final ValueChanged<ToolMeta> onToolSelected;

  @override
  State<ToolPicker> createState() => _ToolPickerState();
}

class _ToolPickerState extends State<ToolPicker> {
  final _menuController = MenuController();

  bool _inGroup(ToolMeta? meta) =>
      meta != null && widget.group.tools.any((tool) => tool.id == meta.id);

  ToolMeta get _representative {
    final selected = widget.selectedTool;
    if (selected != null && _inGroup(selected)) return selected;
    return widget.group.tools.first;
  }

  void _select(ToolMeta meta) {
    _menuController.close();
    widget.onToolSelected(meta);
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(8, 0),
      menuChildren: [
        for (final tool in widget.group.tools)
          ToolButton(
            meta: tool,
            selected: widget.selectedTool?.id == tool.id,
            onPressed: () => _select(tool),
          ),
      ],
      builder: (context, controller, child) => ToolButton(
        meta: _representative,
        selected: _inGroup(widget.selectedTool),
        showLabel: false,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// A tappable icon, and optional label, for a single tool.
class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.meta,
    required this.selected,
    required this.onPressed,
    this.showLabel = true,
  });

  /// The tool this button represents.
  final ToolMeta meta;

  /// Whether this tool is the one currently active in the editor.
  final bool selected;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Whether to show [ToolMeta.name] beside the icon.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: meta.name,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
            color: selected ? colors.primaryContainer : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: 32, child: Center(child: meta.icon)),
              if (showLabel) ...[const SizedBox(width: 8), Text(meta.name)],
            ],
          ),
        ),
      ),
    );
  }
}
