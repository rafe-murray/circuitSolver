import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid_value.dart';

/// The result of a selection gesture in the editor: the set of components and
/// endpoints the user currently has selected.
///
/// This is transient UI state — it is never persisted and takes no part in the
/// circuit model or the undo history.
@immutable
class Selection {
  /// Ids of the selected components.
  final Set<UuidValue> componentIds;

  /// Ids of the selected endpoints.
  final Set<UuidValue> endpointIds;

  /// Creates a selection containing the given component and endpoint ids.
  const Selection({this.componentIds = const {}, this.endpointIds = const {}});

  /// A selection with nothing in it.
  static const empty = Selection();

  /// Whether no component or endpoint is selected.
  bool get isEmpty => componentIds.isEmpty && endpointIds.isEmpty;

  /// Whether the component with [id] is selected.
  bool hasComponent(UuidValue id) => componentIds.contains(id);

  /// Whether the endpoint with [id] is selected.
  bool hasEndpoint(UuidValue id) => endpointIds.contains(id);

  @override
  bool operator ==(Object other) =>
      other is Selection &&
      setEquals(other.componentIds, componentIds) &&
      setEquals(other.endpointIds, endpointIds);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(componentIds),
    Object.hashAllUnordered(endpointIds),
  );
}

/// The four corners of the rectangle that runs along the segment [from]–[to]
/// and extends [halfWidth] to either side of it.
///
/// Used as a component's hitbox: the segment is the lead-to-lead axis and
/// [halfWidth] the half-height of the body.
List<Offset> orientedRectCorners(Offset from, Offset to, double halfWidth) {
  final axis = to - from;
  final length = axis.distance;
  final direction = length == 0 ? const Offset(1, 0) : axis / length;
  final normal = Offset(-direction.dy, direction.dx) * halfWidth;
  return [from + normal, to + normal, to - normal, from - normal];
}

/// A closed, free-form polygon drawn by the lasso selection tool, in canvas
/// coordinates.
///
/// Owns the geometry needed to decide which shapes it captures: callers test a
/// point, segment, circle or convex polygon against the region and select the
/// items whose hitboxes it meets.
@immutable
class LassoRegion {
  /// The polygon's vertices, in draw order. The final vertex is implicitly
  /// joined back to the first.
  final List<Offset> vertices;

  /// Creates a lasso region from an ordered list of [vertices].
  const LassoRegion(this.vertices);

  /// Whether the region has enough vertices to enclose an area.
  bool get isValid => vertices.length >= 3;

  /// Whether [point] lies inside the closed polygon.
  ///
  /// Uses the even-odd (ray casting) rule.
  bool containsPoint(Offset point) {
    if (vertices.length < 3) return false;
    var inside = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final a = vertices[i];
      final b = vertices[j];
      final intersects =
          (a.dy > point.dy) != (b.dy > point.dy) &&
          point.dx < (b.dx - a.dx) * (point.dy - a.dy) / (b.dy - a.dy) + a.dx;
      if (intersects) inside = !inside;
    }
    return inside;
  }

  /// Whether the closed polygon's boundary or interior meets segment [a]–[b].
  bool intersectsSegment(Offset a, Offset b) {
    if (containsPoint(a) || containsPoint(b)) return true;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      if (_segmentsCross(a, b, vertices[j], vertices[i])) return true;
    }
    return false;
  }

  /// Whether any part of the circle centred at [centre] with the given [radius]
  /// lies inside or on the polygon.
  bool intersectsCircle(Offset centre, double radius) {
    if (containsPoint(centre)) return true;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      if (_distanceToSegment(centre, vertices[j], vertices[i]) <= radius) {
        return true;
      }
    }
    return false;
  }

  /// Whether the polygon meets the convex polygon described by [corners]
  /// (used for a component's oriented body-plus-leads rectangle).
  bool intersectsPolygon(List<Offset> corners) {
    for (final corner in corners) {
      if (containsPoint(corner)) return true;
    }
    for (final vertex in vertices) {
      if (_convexContains(corners, vertex)) return true;
    }
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      if (intersectsSegment(a, b)) return true;
    }
    return false;
  }

  static bool _convexContains(List<Offset> corners, Offset p) {
    var sign = 0;
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      final cross =
          (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
      if (cross != 0) {
        final s = cross > 0 ? 1 : -1;
        if (sign == 0) {
          sign = s;
        } else if (s != sign) {
          return false;
        }
      }
    }
    return true;
  }

  static bool _segmentsCross(Offset p1, Offset p2, Offset p3, Offset p4) {
    double cross(Offset o, Offset a, Offset b) =>
        (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
    final d1 = cross(p3, p4, p1);
    final d2 = cross(p3, p4, p2);
    final d3 = cross(p1, p2, p3);
    final d4 = cross(p1, p2, p4);
    if (((d1 > 0) != (d2 > 0)) && ((d3 > 0) != (d4 > 0))) return true;
    return false;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) return (p - a).distance;
    var t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(a.dx + t * ab.dx, a.dy + t * ab.dy);
    return (p - projection).distance;
  }
}
