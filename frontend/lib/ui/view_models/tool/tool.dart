import 'package:flutter/material.dart';

import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/ui/widgets/component_icon.dart';
import 'package:uuid/uuid.dart';

part 'add_component_tool.dart';

final class ToolMeta {
  final String id;
  final String name;
  final Widget icon;
  const ToolMeta._({required this.id, required this.name, required this.icon});
}

final class ToolGroup {
  final List<ToolMeta> tools;
  const ToolGroup(this.tools);
}

final toolGroups = <ToolGroup>[addComponentToolGroup];

sealed class Tool {
  final ToolMeta meta;
  final Uuid uuid;
  final CircuitModel circuit;

  const Tool._({required this.meta, required this.uuid, required this.circuit});
  factory Tool.fromMeta({
    required ToolMeta meta,
    required Uuid uuid,
    required CircuitModel circuit,
  }) {
    final constructor = _toolsById[meta.id];
    return constructor!(circuit: circuit, uuid: uuid);
  }
}

final Map<
  String,
  Tool Function({required Uuid uuid, required CircuitModel circuit})
>
_toolsById = Map.fromEntries(
  componentToolIdToBranch.entries.map(
    (entry) => MapEntry(
      entry.key,
      ({required Uuid uuid, required CircuitModel circuit}) =>
          AddComponentTool._(
            branch: entry.value(),
            id: entry.key,
            uuid: uuid,
            circuit: circuit,
          ),
    ),
  ),
);
