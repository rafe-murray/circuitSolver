import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:frontend/ui/widgets/component_painter.dart';

class ComponentIcon extends StatelessWidget {
  const ComponentIcon({super.key, required this.branch});

  final BranchModel branch;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BranchPainter(
        branch: branch,
        from: Offset(0.0, 1.0),
        to: Offset(1.0, 0.0),
        theme: CircuitTheme.icon(),
      ),
      size: Size.square(6.0),
    );
  }
}
