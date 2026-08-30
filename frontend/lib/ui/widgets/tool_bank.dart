import 'package:flutter/material.dart';
import 'package:frontend/ui/view_models/tool/tool.dart';

/// Floating card of tool groups shown over the circuit editor canvas.
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

  /// Outer corner radius of the card.
  static const _cornerRadius = 6.0;

  /// Inset between the card edge and the tool buttons.
  static const _padding = 4.0;

  /// The tool currently active in the editor, or `null` when none is selected.
  final ToolMeta? selectedTool;

  /// Called with the [ToolMeta] of the tool the user picked.
  final ValueChanged<ToolMeta> onToolSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Card(
        // elevation: 6,
        margin: EdgeInsets.zero,
        color: colors.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(_cornerRadius)),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              for (final group in toolGroups)
                ToolPicker(
                  group: group,
                  selectedTool: selectedTool,
                  onToolSelected: onToolSelected,
                  // End buttons nest flush inside the card's rounded corners.
                  cornerRadius: _cornerRadius - _padding,
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
    this.cornerRadius = 2,
  });

  /// The group of tools this entry picks between.
  final ToolGroup group;

  /// The tool currently active in the editor, or `null` when none is selected.
  final ToolMeta? selectedTool;

  /// Called with the [ToolMeta] of the tool the user picked from the flyout.
  final ValueChanged<ToolMeta> onToolSelected;

  /// Corner radius applied to this entry's [ToolButton]s.
  final double cornerRadius;

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
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(
          // HACK: set top padding to 0 here so we can use SizedBoxes for padding between menu elements
          EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 4.0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.cornerRadius + 4),
          ),
        ),
      ),
      menuChildren: widget.group.tools
          .map(
            (tool) => ToolButton(
              meta: tool,
              selected: widget.selectedTool?.id == tool.id,
              onPressed: () => _select(tool),
              cornerRadius: widget.cornerRadius,
            ),
          )
          .fold([], (list, el) {
            list.add(const SizedBox(height: 4));
            list.add(el);
            return list;
          }),
      builder: (context, controller, child) => ToolButton(
        meta: _representative,
        selected: _inGroup(widget.selectedTool),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        cornerRadius: widget.cornerRadius,
      ),
    );
  }
}

/// A tappable icon for a single tool; its name is shown as a tooltip.
class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.meta,
    required this.selected,
    required this.onPressed,
    this.cornerRadius = 2,
  });

  /// The tool this button represents.
  final ToolMeta meta;

  /// Whether this tool is the one currently active in the editor.
  final bool selected;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Corner radius of the button.
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(cornerRadius);
    return Tooltip(
      message: meta.name,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected ? colors.surfaceContainerHighest : null,
          ),
          child: SizedBox.square(
            dimension: 28,
            child: Center(child: meta.icon),
          ),
        ),
      ),
    );
  }
}
