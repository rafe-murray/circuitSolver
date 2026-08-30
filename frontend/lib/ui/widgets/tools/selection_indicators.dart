import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/view_models/editor_view_model.dart';

/// Draws a small blue dot on every selected component (at its centre point) and
/// every selected endpoint (at its position).
///
/// This widget only visualises the selection held in [currentSelectionProvider]
/// — it does no hit testing and never handles pointer events.
class SelectionIndicators extends ConsumerWidget {
  /// The circuit whose selected items are being marked.
  final CircuitModel circuitModel;

  /// Scale applied to canvas coordinates, matching the circuit view.
  final double scalingFactor;

  /// Radius, in logical pixels, of each dot.
  static const dotRadius = 4.0;

  const SelectionIndicators({
    super.key,
    required this.circuitModel,
    this.scalingFactor = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(
      currentSelectionProvider(circuitId: circuitModel.id),
    );
    if (selection.isEmpty) return const SizedBox.shrink();

    final color = Theme.of(context).colorScheme.primary;
    final dots = <Widget>[];

    for (final component in circuitModel.components) {
      if (!selection.hasComponent(component.id)) continue;
      final from = circuitModel.endpoints[component.fromId]?.pos;
      final to = circuitModel.endpoints[component.toId]?.pos;
      if (from == null || to == null) continue;
      dots.add(_dot((from + to) / 2, color));
    }

    for (final entry in circuitModel.endpoints.entries) {
      if (selection.hasEndpoint(entry.key)) {
        dots.add(_dot(entry.value.pos, color));
      }
    }

    return IgnorePointer(child: Stack(children: dots));
  }

  Widget _dot(Offset canvasPos, Color color) {
    final pos = canvasPos * scalingFactor;
    return Positioned(
      left: pos.dx - dotRadius,
      top: pos.dy - dotRadius,
      width: dotRadius * 2,
      height: dotRadius * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
