import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddComponentKeyboardListener extends StatelessWidget {
  final FocusNode focusNode;
  final void Function() addComponentCallback;
  final Widget child;
  const AddComponentKeyboardListener({
    super.key,
    required this.addComponentCallback,
    required this.child,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          addComponentCallback();
        }
      },
      child: child,
    );
  }
}
