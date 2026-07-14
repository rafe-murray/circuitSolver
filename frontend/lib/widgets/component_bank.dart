import 'package:flutter/material.dart';

import '../models/component_type.dart';

/// The left panel listing all available circuit components.
///
/// Shown only when the Add Component tool is active. Each tile is draggable
/// onto the canvas; tapping selects that component type for insertion.
/// The [selectedType] tile is highlighted to reflect the current insertion
/// selection.
class ComponentBank extends StatelessWidget {
  const ComponentBank({super.key, required this.onTap, this.selectedType});

  /// Called when the user taps a component tile to select it for insertion.
  final void Function(ComponentType type) onTap;

  /// The component type currently selected for insertion, if any.
  final ComponentType? selectedType;

  @override
  Widget build(BuildContext context) {
    const types = ComponentType.values;
    return Material(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Text(
              'Components',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: types.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final type = types[index];
                final isSelected = type == selectedType;
                return Draggable<ComponentType>(
                  data: type,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(6),
                    // The feedback widget renders in the Overlay (unbounded
                    // width), so it must be given an explicit width. Match
                    // the bank panel width minus its horizontal padding.
                    child: SizedBox(
                      width: 168,
                      child: _ComponentChip(
                        type: type,
                        isGhost: true,
                        isSelected: false,
                      ),
                    ),
                  ),
                  childWhenDragging: _ComponentChip(
                    type: type,
                    isGhost: false,
                    isSelected: isSelected,
                    opacity: 0.4,
                  ),
                  child: GestureDetector(
                    onTap: () => onTap(type),
                    child: _ComponentChip(
                      type: type,
                      isGhost: false,
                      isSelected: isSelected,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentChip extends StatelessWidget {
  const _ComponentChip({
    required this.type,
    required this.isGhost,
    required this.isSelected,
    this.opacity = 1.0,
  });

  final ComponentType type;
  final bool isGhost;

  /// Whether this chip represents the currently selected insertion type.
  final bool isSelected;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isGhost || isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surface;
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
        ),
        child: Row(
          children: [
            Text(type.label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            const Icon(Icons.drag_handle, size: 18),
          ],
        ),
      ),
    );
  }
}
