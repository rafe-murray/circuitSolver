import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';

import 'component_painter.dart';

class CircuitView extends StatelessWidget {
  final CircuitModel circuitModel;
  final double scalingFactor;

  /// The size the canvas will be clipped to
  final Size clippedSize;

  const CircuitView({
    super.key,
    required this.circuitModel,
    this.scalingFactor = 1.0,
    this.clippedSize = const Size(1080, 720),
  });
  @override
  Widget build(BuildContext context) {
    // Ensure the widget takes up the same space even if circuit is empty
    if (circuitModel.components.isEmpty) {
      return SizedBox.fromSize(size: clippedSize);
    }
    return Stack(
      children: circuitModel.components.map((component) {
        if (circuitModel.endpoints[component.fromId] == null) {
          print(
            "Missing endpoint with id ${component.fromId} for component ${component.id}\nAvailable endpoints: ${circuitModel.endpoints.keys.toList()}",
          );
        }
        if (circuitModel.endpoints[component.toId] == null) {
          print(
            "Missing endpoint with id ${component.toId} for component ${component.id}",
          );
        }
        return ClipRect(
          child: CustomPaint(
            painter: ComponentPainter(
              componentModel: component,
              endpoints: circuitModel.endpoints,
              scalingFactor: scalingFactor,
            ),
            size: clippedSize,
          ),
        );
      }).toList(),
    );
  }
}
