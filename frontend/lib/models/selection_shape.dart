import 'dart:ui';

// ---------------------------------------------------------------------------
// SelectionShape
// ---------------------------------------------------------------------------

/// Describes the visual shape used to render the current selection overlay.
///
/// The shape is determined by *how* the selection was made:
/// - [EmptySelectionShape] — nothing is selected.
/// - [RubberBandSelectionShape] — the user dragged a rectangular marquee.
/// - [LassoSelectionShape] — the user traced a free-form lasso.
/// - [HullSelectionShape] — the selection came from a click, wand, or
///   SelectAll; the shape is a convex hull of the selected endpoints, with
///   inner hulls punched out for each detected circuit loop.
sealed class SelectionShape {
  const SelectionShape();
}

/// No components are selected — nothing should be drawn.
final class EmptySelectionShape extends SelectionShape {
  const EmptySelectionShape();
}

/// The selection was made with a rectangular rubber-band marquee.
///
/// [rect] is the final committed marquee rectangle in canvas coordinates.
final class RubberBandSelectionShape extends SelectionShape {
  const RubberBandSelectionShape({required this.rect});

  /// The committed marquee rectangle in canvas coordinates.
  final Rect rect;
}

/// The selection was made with a free-form lasso.
///
/// [points] are the lasso vertices in canvas coordinates (the path should be
/// closed by connecting the last point back to the first).
final class LassoSelectionShape extends SelectionShape {
  const LassoSelectionShape({required this.points});

  /// The lasso vertices in canvas coordinates.
  final List<Offset> points;
}

/// The selection came from a click, wand, or SelectAll operation.
///
/// [outerHull] is the convex hull of all selected component endpoints.
/// [innerHulls] is one convex hull per detected circuit loop among the
/// selected components — each inner hull is rendered as a cutout using
/// even-odd fill, so the selection appears to wrap around the circuit rather
/// than fill it solid.
final class HullSelectionShape extends SelectionShape {
  const HullSelectionShape({required this.outerHull, required this.innerHulls});

  /// Convex hull of all selected component endpoints.
  final List<Offset> outerHull;

  /// One convex hull per detected cycle among selected components.
  final List<List<Offset>> innerHulls;
}
