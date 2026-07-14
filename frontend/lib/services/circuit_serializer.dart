import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import '../models/circuit_component.dart';
import '../models/component_type.dart';

/// Serialises and deserialises a circuit (components + connections) to/from
/// a JSON byte payload stored in the [Circuits.protoBytes] blob column.
///
/// When proper protobuf codegen is in place this class can be swapped out
/// without changing any callers.
class CircuitSerializer {
  const CircuitSerializer._();

  /// Encodes [components] and [connections] to a UTF-8 JSON blob.
  static Uint8List encode(
    List<CircuitComponent> components,
    List<Connection> connections,
  ) {
    final map = {
      'components': components.map(_encodeComponent).toList(),
      'connections': connections.map(_encodeConnection).toList(),
    };
    return utf8.encode(jsonEncode(map));
  }

  /// Decodes a blob produced by [encode] back into components and connections.
  ///
  /// Returns a record `(components, connections)`.
  static (List<CircuitComponent>, List<Connection>) decode(Uint8List bytes) {
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    final components = (map['components'] as List<dynamic>)
        .map((e) => _decodeComponent(e as Map<String, dynamic>))
        .toList();

    final connections = (map['connections'] as List<dynamic>)
        .map((e) => _decodeConnection(e as Map<String, dynamic>))
        .toList();

    return (components, connections);
  }

  // ---------------------------------------------------------------------------
  // Encode helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeComponent(CircuitComponent c) => {
    'id': c.id,
    'type': c.type.name,
    'ep0x': c.endpoint0.dx,
    'ep0y': c.endpoint0.dy,
    'ep1x': c.endpoint1.dx,
    'ep1y': c.endpoint1.dy,
    'properties': c.properties,
  };

  static Map<String, dynamic> _encodeConnection(Connection cn) => {
    'componentA': cn.componentA,
    'endpointIndexA': cn.endpointIndexA,
    'componentB': cn.componentB,
    'endpointIndexB': cn.endpointIndexB,
  };

  // ---------------------------------------------------------------------------
  // Decode helpers
  // ---------------------------------------------------------------------------

  static CircuitComponent _decodeComponent(Map<String, dynamic> map) {
    final typeName = map['type'] as String;
    final type = ComponentType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => throw FormatException('Unknown component type: $typeName'),
    );

    final props = (map['properties'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    return CircuitComponent(
      id: map['id'] as int,
      type: type,
      endpoint0: Offset(
        (map['ep0x'] as num).toDouble(),
        (map['ep0y'] as num).toDouble(),
      ),
      endpoint1: Offset(
        (map['ep1x'] as num).toDouble(),
        (map['ep1y'] as num).toDouble(),
      ),
      properties: props,
    );
  }

  static Connection _decodeConnection(Map<String, dynamic> map) => Connection(
    componentA: map['componentA'] as int,
    endpointIndexA: map['endpointIndexA'] as int,
    componentB: map['componentB'] as int,
    endpointIndexB: map['endpointIndexB'] as int,
  );
}
