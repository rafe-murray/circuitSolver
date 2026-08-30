import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts for the selection tool.
///
/// `Escape` clears the current selection; `Ctrl`/`Cmd` + `A` selects every
/// component and endpoint in the circuit.
class SelectionKeyboardListener extends StatelessWidget {
  /// Focus node the listener attaches to; owned by the caller.
  final FocusNode focusNode;

  /// Called when `Escape` is pressed.
  final VoidCallback onClear;

  /// Called when `Ctrl`/`Cmd` + `A` is pressed.
  final VoidCallback onSelectAll;

  final Widget child;

  const SelectionKeyboardListener({
    super.key,
    required this.focusNode,
    required this.onClear,
    required this.onSelectAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          onClear();
          return;
        }
        final modifierHeld =
            HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed;
        if (modifierHeld && event.logicalKey == LogicalKeyboardKey.keyA) {
          onSelectAll();
        }
      },
      child: child,
    );
  }
}
