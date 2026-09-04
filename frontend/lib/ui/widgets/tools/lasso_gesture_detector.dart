import 'package:flutter/material.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:frontend/ui/view_models/editor_intents.dart';

/// Catches canvas gestures for the lasso selection tool and dispatches
/// selection [Intent]s.
///
/// A drag traces a free-form path; on release the closed path is dispatched as
/// a [SelectWithinLassoIntent]. A plain tap dispatches a [ClearSelectionIntent].
/// The path in progress is drawn as a translucent blue overlay under the
/// pointer.
class LassoGestureDetector extends StatefulWidget {
  /// The widget drawn beneath the lasso overlay (the circuit).
  final Widget child;

  const LassoGestureDetector({super.key, required this.child});

  @override
  State<LassoGestureDetector> createState() => _LassoGestureDetectorState();
}

class _LassoGestureDetectorState extends State<LassoGestureDetector> {
  /// Fewest points a path needs before it encloses an area worth reporting.
  static const _minPoints = 3;

  List<Offset>? _points;

  @override
  Widget build(BuildContext context) {
    final points = _points;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (_) =>
          Actions.maybeInvoke(context, const ClearSelectionIntent()),
      onPanDown: (details) {
        setState(() => _points = [details.localPosition]);
      },
      onPanUpdate: (details) {
        setState(() => _points = [...?_points, details.localPosition]);
      },
      onPanCancel: () => setState(() => _points = null),
      onPanEnd: (_) {
        final path = _points;
        setState(() => _points = null);
        if (path != null && path.length >= _minPoints) {
          Actions.maybeInvoke(
            context,
            SelectWithinLassoIntent(LassoRegion(List.unmodifiable(path))),
          );
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (points != null && points.length >= 2)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _LassoPainter(points)),
              ),
            ),
        ],
      ),
    );
  }
}

class _LassoPainter extends CustomPainter {
  _LassoPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.blue.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      Path()..addPolygon(points, false),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.blue,
    );
  }

  @override
  bool shouldRepaint(_LassoPainter oldDelegate) => oldDelegate.points != points;
}
