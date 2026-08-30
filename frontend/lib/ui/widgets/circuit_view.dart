import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';

import 'component_painter.dart';

class CircuitView extends StatelessWidget {
  final CircuitModel circuitModel;
  final Size size;

  const CircuitView({
    super.key,
    required this.circuitModel,
    this.size = const Size(1080, 720),
  });
  @override
  Widget build(BuildContext context) {
    // Ensure the widget takes up the same space even if circuit is empty
    if (circuitModel.components.isEmpty) {
      return SizedBox.fromSize(size: size);
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
        return CustomPaint(
          painter: ComponentPainter(
            componentModel: component,
            endpoints: circuitModel.endpoints,
          ),
          size: size,
        );
      }).toList(),
    );
  }
}
