import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/selection.dart';
import 'package:uuid/uuid.dart';

void main() {
  // A 100x100 square lasso with its top-left corner at (0, 0).
  final square = const LassoRegion([
    Offset(0, 0),
    Offset(100, 0),
    Offset(100, 100),
    Offset(0, 100),
  ]);

  group('Selection', () {
    test('empty has nothing selected', () {
      expect(Selection.empty.isEmpty, isTrue);
    });

    test('value equality ignores set ordering', () {
      final a = const Uuid().v7obj();
      final b = const Uuid().v7obj();
      expect(
        Selection(componentIds: {a, b}),
        equals(Selection(componentIds: {b, a})),
      );
    });
  });

  group('LassoRegion.containsPoint', () {
    test('true for an interior point', () {
      expect(square.containsPoint(const Offset(50, 50)), isTrue);
    });

    test('false for an exterior point', () {
      expect(square.containsPoint(const Offset(150, 50)), isFalse);
    });

    test('false when the region has fewer than three vertices', () {
      const line = LassoRegion([Offset(0, 0), Offset(10, 10)]);
      expect(line.containsPoint(const Offset(5, 5)), isFalse);
    });
  });

  group('LassoRegion.intersectsCircle', () {
    test('true when the circle centre is inside', () {
      expect(square.intersectsCircle(const Offset(50, 50), 5), isTrue);
    });

    test('true when only the circle edge reaches an outside centre', () {
      expect(square.intersectsCircle(const Offset(108, 50), 10), isTrue);
    });

    test('false when the circle is clear of the region', () {
      expect(square.intersectsCircle(const Offset(200, 200), 10), isFalse);
    });
  });

  group('LassoRegion.intersectsPolygon', () {
    test('true when a rectangle straddles an edge', () {
      final rect = [
        const Offset(90, 40),
        const Offset(130, 40),
        const Offset(130, 60),
        const Offset(90, 60),
      ];
      expect(square.intersectsPolygon(rect), isTrue);
    });

    test('true when the lasso is entirely inside the rectangle', () {
      final rect = [
        const Offset(-50, -50),
        const Offset(200, -50),
        const Offset(200, 200),
        const Offset(-50, 200),
      ];
      expect(square.intersectsPolygon(rect), isTrue);
    });

    test('false when the rectangle is disjoint', () {
      final rect = [
        const Offset(200, 200),
        const Offset(240, 200),
        const Offset(240, 220),
        const Offset(200, 220),
      ];
      expect(square.intersectsPolygon(rect), isFalse);
    });
  });

  group('orientedRectCorners', () {
    test('produces a rectangle centred on the segment', () {
      final corners = orientedRectCorners(
        const Offset(0, 0),
        const Offset(10, 0),
        2,
      );
      expect(corners, [
        const Offset(0, 2),
        const Offset(10, 2),
        const Offset(10, -2),
        const Offset(0, -2),
      ]);
    });
  });
}
