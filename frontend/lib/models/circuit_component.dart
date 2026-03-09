import 'dart:ui';

import 'component_type.dart';

/// The grid spacing used for snapping, in logical canvas pixels.
const double kGridSize = 24.0;

/// Snaps [value] to the nearest multiple of [kGridSize].
double snapToGrid(double value) => (value / kGridSize).round() * kGridSize;

/// Snaps an [Offset] to the grid.
Offset snapOffsetToGrid(Offset offset) =>
    Offset(snapToGrid(offset.dx), snapToGrid(offset.dy));

/// How far (in logical pixels) two endpoints must be to snap together.
const double kSnapRadius = kGridSize * 1.5;

/// A unique, monotonically increasing id source.
int _nextId = 1;
int generateId() => _nextId++;

/// Ensures the id counter is above [minValue] so newly generated ids never
/// clash with ids loaded from persisted data.
void ensureNextIdAbove(int minValue) {
  if (minValue >= _nextId) _nextId = minValue + 1;
}

/// An endpoint (pin) of a [CircuitComponent].
///
/// [localOffset] is the endpoint position relative to the component's [CircuitComponent.position].
class Endpoint {
  Endpoint({required this.localOffset});

  final Offset localOffset;

  /// Returns the absolute canvas position given the component's position and rotation.
  Offset absolutePosition(Offset componentPosition, double rotation) {
    final rotated = _rotateOffset(localOffset, rotation);
    return componentPosition + rotated;
  }
}

Offset _rotateOffset(Offset o, double radians) {
  final c = _cos(radians);
  final s = _sin(radians);
  return Offset(o.dx * c - o.dy * s, o.dx * s + o.dy * c);
}

double _cos(double r) {
  // Dart's dart:math is available; avoid importing it at model level by using
  // a small lookup for common angles, falling back to a Taylor approximation.
  // In practice only 0, π/2, π, 3π/2 are used.
  const half = 1.5707963267948966;
  final n = (r / half).round() % 4;
  return switch (n) {
    0 => 1.0,
    1 => 0.0,
    2 => -1.0,
    3 => 0.0,
    _ => 1.0,
  };
}

double _sin(double r) {
  const half = 1.5707963267948966;
  final n = (r / half).round() % 4;
  return switch (n) {
    0 => 0.0,
    1 => 1.0,
    2 => 0.0,
    3 => -1.0,
    _ => 0.0,
  };
}

/// A circuit component placed on the canvas.
class CircuitComponent {
  CircuitComponent({
    int? id,
    required this.type,
    required this.position,
    this.rotation = 0.0,
    Map<String, double>? properties,
  }) : id = id ?? generateId(),
       properties = properties ?? _defaultProperties(type);

  final int id;
  final ComponentType type;

  /// Centre position of the component on the canvas (grid-snapped).
  Offset position;

  /// Rotation in radians (snapped to multiples of π/2).
  double rotation;

  /// Component-specific electrical properties (e.g. resistance, voltage).
  Map<String, double> properties;

  /// Returns the two endpoint offsets relative to [position] for this component type.
  List<Endpoint> get endpoints => _endpointsForType(type);

  List<Offset> get absoluteEndpoints =>
      endpoints.map((e) => e.absolutePosition(position, rotation)).toList();

  CircuitComponent copyWith({
    Offset? position,
    double? rotation,
    Map<String, double>? properties,
  }) => CircuitComponent(
    id: id,
    type: type,
    position: position ?? this.position,
    rotation: rotation ?? this.rotation,
    properties: properties ?? Map.of(this.properties),
  );

  @override
  bool operator ==(Object other) => other is CircuitComponent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A logical connection between two component endpoints.
class Connection {
  Connection({
    required this.componentA,
    required this.endpointIndexA,
    required this.componentB,
    required this.endpointIndexB,
  });

  final int componentA;
  final int endpointIndexA;
  final int componentB;
  final int endpointIndexB;

  @override
  bool operator ==(Object other) =>
      other is Connection &&
      ((other.componentA == componentA &&
              other.endpointIndexA == endpointIndexA &&
              other.componentB == componentB &&
              other.endpointIndexB == endpointIndexB) ||
          (other.componentA == componentB &&
              other.endpointIndexA == endpointIndexB &&
              other.componentB == componentA &&
              other.endpointIndexB == endpointIndexA));

  @override
  int get hashCode =>
      Object.hash(componentA ^ componentB, endpointIndexA ^ endpointIndexB);
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// Half the visual body length of a component along its axis.
const double _kHalfLen = kGridSize * 2;

List<Endpoint> _endpointsForType(ComponentType type) => switch (type) {
  ComponentType.wire => [
    Endpoint(localOffset: const Offset(-_kHalfLen, 0)),
    Endpoint(localOffset: const Offset(_kHalfLen, 0)),
  ],
  _ => [
    Endpoint(localOffset: const Offset(-_kHalfLen, 0)),
    Endpoint(localOffset: const Offset(_kHalfLen, 0)),
  ],
};

Map<String, double> _defaultProperties(ComponentType type) => switch (type) {
  ComponentType.resistor => {'resistance': 1000.0},
  ComponentType.wire => {},
  ComponentType.voltageSource => {'voltage': 5.0},
  ComponentType.currentSource => {'current': 0.001},
  ComponentType.realDiode => {
    'forwardVoltage': 0.7,
    'saturationCurrent': 1e-12,
  },
  ComponentType.idealDiode => {},
  ComponentType.zenerDiode => {'breakdownVoltage': 5.1},
};
