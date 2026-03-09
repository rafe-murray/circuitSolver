import 'package:flutter/material.dart';

import '../models/component_type.dart';

/// The left panel listing all available circuit components.
///
/// Each tile is draggable onto the canvas; tapping adds the component
/// near the canvas centre.
class ComponentBank extends StatelessWidget {
  const ComponentBank({super.key, required this.onTap});

  /// Called when the user taps a component tile to place it on the canvas.
  final void Function(ComponentType type) onTap;

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
                return Draggable<ComponentType>(
                  data: type,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(6),
                    // The feedback widget renders in the Overlay (unbounded
                    // width), so it must be given an explicit width.  Match
                    // the bank panel width minus its horizontal padding.
                    child: SizedBox(
                      width: 168,
                      child: _ComponentChip(type: type, isGhost: true),
                    ),
                  ),
                  childWhenDragging: _ComponentChip(
                    type: type,
                    isGhost: false,
                    opacity: 0.4,
                  ),
                  child: GestureDetector(
                    onTap: () => onTap(type),
                    child: _ComponentChip(type: type, isGhost: false),
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
    this.opacity = 1.0,
  });

  final ComponentType type;
  final bool isGhost;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isGhost
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
