import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:frontend/ui/widgets/circuit_view.dart';
import 'package:uuid/uuid_value.dart';

/// Wraps a [CircuitView] with a layer of transparent hit-target widgets, one
/// per endpoint and one per component, so tools can detect pointer hits on
/// individual circuit items.
///
/// Each endpoint gets a circular target around its position; each component
/// gets a rectangular target covering its body and leads (the rectangle's
/// height also covers the circular body region at the component's centre).
///
/// The targets are inert until a tool supplies [onEndpointHit] or
/// [onComponentHit]; without a callback the layer ignores pointers entirely so
/// it never steals gestures from a wrapping detector (such as the lasso).
class CircuitHitTestView extends StatelessWidget {
  /// The circuit to render and build hit targets for.
  final CircuitModel circuitModel;

  /// Scale applied to canvas coordinates, matching [CircuitView.scalingFactor].
  final double scalingFactor;

  /// Called with an endpoint's id when its target is tapped.
  final void Function(UuidValue endpointId)? onEndpointHit;

  /// Called with a component's id when its target is tapped.
  final void Function(UuidValue componentId)? onComponentHit;

  /// Radius, in canvas units, of an endpoint's circular hit target.
  static const endpointHitRadius = 12.0;

  const CircuitHitTestView({
    super.key,
    required this.circuitModel,
    this.scalingFactor = 1.0,
    this.onEndpointHit,
    this.onComponentHit,
  });

  @override
  Widget build(BuildContext context) {
    final halfWidth = CircuitTheme.editor().componentRadius;
    return Stack(
      children: [
        CircuitView(circuitModel: circuitModel, scalingFactor: scalingFactor),
        for (final component in circuitModel.components)
          ..._componentTarget(component, halfWidth),
        for (final entry in circuitModel.endpoints.entries)
          _endpointTarget(entry.key, entry.value),
      ],
    );
  }

  Iterable<Widget> _componentTarget(
    ComponentModel component,
    double halfWidth,
  ) {
    final from = circuitModel.endpoints[component.fromId]?.pos;
    final to = circuitModel.endpoints[component.toId]?.pos;
    if (from == null || to == null) return const [];

    final a = from * scalingFactor;
    final b = to * scalingFactor;
    final centre = (a + b) / 2;
    final axis = b - a;
    final length = axis.distance;
    final angle = math.atan2(axis.dy, axis.dx);
    final width = length + 2 * halfWidth * scalingFactor;
    final height = 2 * halfWidth * scalingFactor;

    final target = _wrap(
      onHit: onComponentHit == null
          ? null
          : () => onComponentHit!(component.id),
      child: const SizedBox.expand(),
    );

    return [
      Positioned(
        left: centre.dx - width / 2,
        top: centre.dy - height / 2,
        width: width,
        height: height,
        child: Transform.rotate(angle: angle, child: target),
      ),
    ];
  }

  Widget _endpointTarget(UuidValue id, EndpointModel endpoint) {
    final pos = endpoint.pos * scalingFactor;
    final r = endpointHitRadius * scalingFactor;
    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      width: 2 * r,
      height: 2 * r,
      child: _wrap(
        onHit: onEndpointHit == null ? null : () => onEndpointHit!(id),
        shape: BoxShape.circle,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _wrap({
    required VoidCallback? onHit,
    required Widget child,
    BoxShape shape = BoxShape.rectangle,
  }) {
    if (onHit == null) return IgnorePointer(child: child);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onHit,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: shape, color: Colors.transparent),
        child: child,
      ),
    );
  }
}
