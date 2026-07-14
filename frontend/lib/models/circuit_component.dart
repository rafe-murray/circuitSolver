import 'dart:math' as math;
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

/// The fixed half-length of the component body (zigzag / circle section),
/// not including lead wires.
///
/// This stays constant regardless of how far the endpoints are from the centre.
const double kBodyHalfLen = kGridSize;

/// The default half-length of a newly placed component (body + one lead on
/// each side), in logical pixels.
const double kDefaultHalfLen = kGridSize * 2;

/// A unique, monotonically increasing id source.
int _nextId = 1;
int generateId() => _nextId++;

/// Ensures the id counter is above [minValue] so newly generated ids never
/// clash with ids loaded from persisted data.
void ensureNextIdAbove(int minValue) {
  if (minValue >= _nextId) _nextId = minValue + 1;
}

// ---------------------------------------------------------------------------
// CircuitComponent — endpoint-primary model
// ---------------------------------------------------------------------------

/// A circuit component placed on the canvas.
///
/// The component is **endpoint-primary**: the two pin positions ([endpoint0]
/// and [endpoint1]) are the canonical stored state.  The centre [position],
/// [rotation], and [halfLen] are all *derived* from the endpoint pair and are
/// recomputed on every access.
///
/// This design allows one endpoint to be moved independently of the other
/// (e.g. when a connected neighbour is dragged), so the lead wires stretch
/// naturally while the body symbol stays centred and correctly oriented.
class CircuitComponent {
  /// Creates a component from two absolute canvas-space endpoint positions.
  CircuitComponent({
    int? id,
    required this.type,
    required this.endpoint0,
    required this.endpoint1,
    Map<String, double>? properties,
  }) : id = id ?? generateId(),
       properties = properties ?? _defaultProperties(type);

  /// Creates a component from a grid-snapped centre [position] and [rotation],
  /// placing the endpoints at [kDefaultHalfLen] along the axis.
  ///
  /// This is a convenience constructor used when adding new components from the
  /// bank or via keyboard shortcut, where the user places a centre point.
  factory CircuitComponent.fromCentre({
    int? id,
    required ComponentType type,
    required Offset position,
    double rotation = 0.0,
    Map<String, double>? properties,
  }) {
    final axis = Offset(math.cos(rotation), math.sin(rotation));
    final ep0 = position - axis * kDefaultHalfLen;
    final ep1 = position + axis * kDefaultHalfLen;
    return CircuitComponent(
      id: id,
      type: type,
      endpoint0: ep0,
      endpoint1: ep1,
      properties: properties,
    );
  }

  final int id;
  final ComponentType type;

  /// The first pin position in absolute canvas coordinates.
  Offset endpoint0;

  /// The second pin position in absolute canvas coordinates.
  Offset endpoint1;

  /// Component-specific electrical properties (e.g. resistance, voltage).
  Map<String, double> properties;

  // ---------------------------------------------------------------------------
  // Derived geometry
  // ---------------------------------------------------------------------------

  /// The midpoint between [endpoint0] and [endpoint1] in canvas coordinates.
  Offset get position => (endpoint0 + endpoint1) / 2;

  /// The angle of the component axis in radians, measured from the positive
  /// x-axis toward [endpoint1].
  double get rotation {
    final d = endpoint1 - endpoint0;
    return math.atan2(d.dy, d.dx);
  }

  /// Half the distance between [endpoint0] and [endpoint1].
  ///
  /// For a default-placed component this equals [kDefaultHalfLen].  After a
  /// follower-endpoint drag it may differ.
  double get halfLen => (endpoint1 - endpoint0).distance / 2;

  // ---------------------------------------------------------------------------
  // Endpoints API (for compatibility with Connection indices)
  // ---------------------------------------------------------------------------

  /// Returns the absolute canvas positions of both endpoints.
  List<Offset> get absoluteEndpoints => [endpoint0, endpoint1];

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  CircuitComponent copyWith({
    Offset? endpoint0,
    Offset? endpoint1,
    Map<String, double>? properties,
  }) => CircuitComponent(
    id: id,
    type: type,
    endpoint0: endpoint0 ?? this.endpoint0,
    endpoint1: endpoint1 ?? this.endpoint1,
    properties: properties ?? Map.of(this.properties),
  );

  @override
  bool operator ==(Object other) => other is CircuitComponent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// Connection
// ---------------------------------------------------------------------------

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
