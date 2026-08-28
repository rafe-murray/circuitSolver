import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';

import 'component_painter.dart';

class CircuitWidget extends StatelessWidget {
  final CircuitModel circuitModel;

  const CircuitWidget({super.key, required this.circuitModel});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: circuitModel.components
          .map(
            (component) => CustomPaint(
              painter: ComponentPainter(
                componentModel: component,
                endpoints: circuitModel.endpoints,
              ),
              size: Size(1080, 720),
            ),
          )
          .toList(),
    );
  }
}
