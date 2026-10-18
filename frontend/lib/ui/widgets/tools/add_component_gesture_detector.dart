import 'package:flutter/material.dart';
import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/core/themes/circuit_theme.dart';
import 'package:frontend/ui/view_models/component_placement.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';
import 'package:frontend/ui/widgets/component_painter.dart';

/// Catches canvas gestures for the "add component" tool and dispatches an
/// [AddComponentIntent] describing where to place the component.
///
/// A tap drops a default-sized component at the tapped point. A drag places a
/// component whose two endpoints are the drag's start and end points, with a
/// live preview drawn under the pointer while the drag is in progress.
class AddComponentGestureDetector extends StatefulWidget {
  /// The branch rendered in the drag preview and carried on the dispatched
  /// intent.
  final BranchModel branch;

  final Widget child;

  const AddComponentGestureDetector({
    super.key,
    required this.branch,
    required this.child,
  });

  @override
  State<AddComponentGestureDetector> createState() =>
      _AddComponentGestureDetectorState();
}

class _AddComponentGestureDetectorState
    extends State<AddComponentGestureDetector> {
  /// Distance below which a drag is treated as a tap.
  static const _dragSlop = 8.0;

  Offset? _dragStart;
  Offset? _dragCurrent;

  void _placeAt(Offset point) {
    const half = Offset(tapComponentHalfExtent, tapComponentHalfExtent);
    Actions.maybeInvoke(
      context,
      AddComponentIntent(
        branch: widget.branch,
        from: point - half,
        to: point + half,
      ),
    );
  }

  void _placeBetween(Offset from, Offset to) {
    Actions.maybeInvoke(
      context,
      AddComponentIntent(branch: widget.branch, from: from, to: to),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dragStart = _dragStart;
    final dragCurrent = _dragCurrent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _placeAt(details.localPosition),
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
          _placeAt(start);
        } else {
          _placeBetween(start, end);
        }
      },
      child: Stack(
        children: [
          widget.child,
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
