import 'package:flutter/material.dart';

class AddComponentCanvasGestureDetector extends StatelessWidget {
  final void Function(Offset position) addComponentCallback;

  final Widget? child;
  const AddComponentCanvasGestureDetector({
    super.key,
    required this.addComponentCallback,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Ensures the entire space catches the hit test
      onTapUp: (details) {
        addComponentCallback(details.localPosition);
      },
      child: child,
    );
  }
}
