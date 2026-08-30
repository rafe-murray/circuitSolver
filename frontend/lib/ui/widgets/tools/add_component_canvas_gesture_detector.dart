import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:frontend/ui/widgets/component_painter.dart';

/// Catches canvas gestures for the "add component" tool.
///
/// A tap drops a default-sized component at the tapped point. A drag places a
/// component whose two endpoints are the drag's start and end points, with a
/// live preview drawn under the pointer while the drag is in progress.
class AddComponentCanvasGestureDetector extends StatefulWidget {
  /// Called when the user taps (or performs a negligibly short drag) at
  /// [position] in canvas coordinates.
  final void Function(Offset position) addComponentCallback;

  /// Called when the user completes a drag, with the endpoints in canvas
  /// coordinates.
  final void Function({required Offset from, required Offset to})
  addComponentBetweenCallback;

  /// The branch rendered in the drag preview.
  final BranchModel branch;

  final Widget? child;

  const AddComponentCanvasGestureDetector({
    super.key,
    required this.addComponentCallback,
    required this.addComponentBetweenCallback,
    required this.branch,
    required this.child,
  });

  @override
  State<AddComponentCanvasGestureDetector> createState() =>
      _AddComponentCanvasGestureDetectorState();
}

class _AddComponentCanvasGestureDetectorState
    extends State<AddComponentCanvasGestureDetector> {
  /// Distance below which a drag is treated as a tap.
  static const _dragSlop = 8.0;

  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  Widget build(BuildContext context) {
    final dragStart = _dragStart;
    final dragCurrent = _dragCurrent;
    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Ensures the entire space catches the hit test
      onTapUp: (details) {
        widget.addComponentCallback(details.localPosition);
      },
      // onPanDown reports the true press position; onPanStart only fires once
      // the drag has moved past the gesture arena's slop.
      onPanDown: (details) {
        setState(() {
          _dragStart = details.localPosition;
          _dragCurrent = details.localPosition;
        });
      },
      onPanCancel: () {
        setState(() {
          _dragStart = null;
          _dragCurrent = null;
        });
      },
      onPanUpdate: (details) {
        setState(() => _dragCurrent = details.localPosition);
      },
      onPanEnd: (details) {
        final start = _dragStart;
        final end = _dragCurrent;
        setState(() {
          _dragStart = null;
          _dragCurrent = null;
        });
        if (start == null || end == null) return;
        if ((end - start).distance < _dragSlop) {
          widget.addComponentCallback(start);
        } else {
          widget.addComponentBetweenCallback(from: start, to: end);
        }
      },
      child: Stack(
        children: [
          if (widget.child != null) widget.child!,
          if (dragStart != null &&
              dragCurrent != null &&
              (dragCurrent - dragStart).distance >= _dragSlop)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: BranchPainter(
                    branch: widget.branch,
                    from: dragStart,
                    to: dragCurrent,
                    theme: CircuitTheme.editor(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
