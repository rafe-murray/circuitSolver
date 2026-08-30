import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:frontend/ui/widgets/component_painter.dart';

class ComponentIcon extends StatelessWidget {
  const ComponentIcon({super.key, required this.branch, this.size = 28.0});

  final BranchModel branch;

  /// Side length, in logical pixels, of the square the icon is painted into.
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BranchPainter(
        branch: branch,
        from: Offset(0.0, size * 2),
        to: Offset(size * 2, 0.0),
        theme: CircuitTheme.editor(),
        scalingFactor: 0.5,
      ),
      size: Size.square(size),
    );
  }
}
