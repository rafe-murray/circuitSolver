// This is a generated file - do not edit.
//
// Generated from circuit_solver/v1/circuit_graph_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CircuitGraphMessage_Edge_CurrentSource extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_CurrentSource({
    $core.double? voltage,
  }) {
    final result = create();
    if (voltage != null) result.voltage = voltage;
    return result;
  }

  CircuitGraphMessage_Edge_CurrentSource._();

  factory CircuitGraphMessage_Edge_CurrentSource.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_CurrentSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.CurrentSource',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'voltage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_CurrentSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_CurrentSource copyWith(
          void Function(CircuitGraphMessage_Edge_CurrentSource) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_CurrentSource))
          as CircuitGraphMessage_Edge_CurrentSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_CurrentSource create() =>
      CircuitGraphMessage_Edge_CurrentSource._();
  @$core.override
  CircuitGraphMessage_Edge_CurrentSource createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_CurrentSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          CircuitGraphMessage_Edge_CurrentSource>(create);
  static CircuitGraphMessage_Edge_CurrentSource? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get voltage => $_getN(0);
  @$pb.TagNumber(1)
  set voltage($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoltage() => $_clearField(1);
}

class CircuitGraphMessage_Edge_IdealDiode extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_IdealDiode({
    $core.double? voltage,
  }) {
    final result = create();
    if (voltage != null) result.voltage = voltage;
    return result;
  }

  CircuitGraphMessage_Edge_IdealDiode._();

  factory CircuitGraphMessage_Edge_IdealDiode.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_IdealDiode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.IdealDiode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'voltage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_IdealDiode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_IdealDiode copyWith(
          void Function(CircuitGraphMessage_Edge_IdealDiode) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_IdealDiode))
          as CircuitGraphMessage_Edge_IdealDiode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_IdealDiode create() =>
      CircuitGraphMessage_Edge_IdealDiode._();
  @$core.override
  CircuitGraphMessage_Edge_IdealDiode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_IdealDiode getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          CircuitGraphMessage_Edge_IdealDiode>(create);
  static CircuitGraphMessage_Edge_IdealDiode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get voltage => $_getN(0);
  @$pb.TagNumber(1)
  set voltage($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoltage() => $_clearField(1);
}

class CircuitGraphMessage_Edge_RealDiode extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_RealDiode({
    $core.double? i0,
    $core.double? vt,
    $core.double? n,
  }) {
    final result = create();
    if (i0 != null) result.i0 = i0;
    if (vt != null) result.vt = vt;
    if (n != null) result.n = n;
    return result;
  }

  CircuitGraphMessage_Edge_RealDiode._();

  factory CircuitGraphMessage_Edge_RealDiode.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_RealDiode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.RealDiode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'i0')
    ..aD(2, _omitFieldNames ? '' : 'vt')
    ..aD(3, _omitFieldNames ? '' : 'n')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_RealDiode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_RealDiode copyWith(
          void Function(CircuitGraphMessage_Edge_RealDiode) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_RealDiode))
          as CircuitGraphMessage_Edge_RealDiode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_RealDiode create() =>
      CircuitGraphMessage_Edge_RealDiode._();
  @$core.override
  CircuitGraphMessage_Edge_RealDiode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_RealDiode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CircuitGraphMessage_Edge_RealDiode>(
          create);
  static CircuitGraphMessage_Edge_RealDiode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get i0 => $_getN(0);
  @$pb.TagNumber(1)
  set i0($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasI0() => $_has(0);
  @$pb.TagNumber(1)
  void clearI0() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get vt => $_getN(1);
  @$pb.TagNumber(2)
  set vt($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVt() => $_has(1);
  @$pb.TagNumber(2)
  void clearVt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get n => $_getN(2);
  @$pb.TagNumber(3)
  set n($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasN() => $_has(2);
  @$pb.TagNumber(3)
  void clearN() => $_clearField(3);
}

class CircuitGraphMessage_Edge_Resistor extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_Resistor({
    $core.double? resistance,
  }) {
    final result = create();
    if (resistance != null) result.resistance = resistance;
    return result;
  }

  CircuitGraphMessage_Edge_Resistor._();

  factory CircuitGraphMessage_Edge_Resistor.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_Resistor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.Resistor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'resistance')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_Resistor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_Resistor copyWith(
          void Function(CircuitGraphMessage_Edge_Resistor) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_Resistor))
          as CircuitGraphMessage_Edge_Resistor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_Resistor create() =>
      CircuitGraphMessage_Edge_Resistor._();
  @$core.override
  CircuitGraphMessage_Edge_Resistor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_Resistor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CircuitGraphMessage_Edge_Resistor>(
          create);
  static CircuitGraphMessage_Edge_Resistor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get resistance => $_getN(0);
  @$pb.TagNumber(1)
  set resistance($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResistance() => $_has(0);
  @$pb.TagNumber(1)
  void clearResistance() => $_clearField(1);
}

class CircuitGraphMessage_Edge_VoltageSource extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_VoltageSource({
    $core.double? voltage,
  }) {
    final result = create();
    if (voltage != null) result.voltage = voltage;
    return result;
  }

  CircuitGraphMessage_Edge_VoltageSource._();

  factory CircuitGraphMessage_Edge_VoltageSource.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_VoltageSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.VoltageSource',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'voltage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_VoltageSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_VoltageSource copyWith(
          void Function(CircuitGraphMessage_Edge_VoltageSource) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_VoltageSource))
          as CircuitGraphMessage_Edge_VoltageSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_VoltageSource create() =>
      CircuitGraphMessage_Edge_VoltageSource._();
  @$core.override
  CircuitGraphMessage_Edge_VoltageSource createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_VoltageSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          CircuitGraphMessage_Edge_VoltageSource>(create);
  static CircuitGraphMessage_Edge_VoltageSource? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get voltage => $_getN(0);
  @$pb.TagNumber(1)
  set voltage($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoltage() => $_clearField(1);
}

class CircuitGraphMessage_Edge_ZenerDiode extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge_ZenerDiode({
    $core.double? vzt,
    $core.double? rzt,
    $core.double? izt,
  }) {
    final result = create();
    if (vzt != null) result.vzt = vzt;
    if (rzt != null) result.rzt = rzt;
    if (izt != null) result.izt = izt;
    return result;
  }

  CircuitGraphMessage_Edge_ZenerDiode._();

  factory CircuitGraphMessage_Edge_ZenerDiode.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge_ZenerDiode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge.ZenerDiode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'vzt')
    ..aD(2, _omitFieldNames ? '' : 'rzt')
    ..aD(3, _omitFieldNames ? '' : 'izt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_ZenerDiode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge_ZenerDiode copyWith(
          void Function(CircuitGraphMessage_Edge_ZenerDiode) updates) =>
      super.copyWith((message) =>
              updates(message as CircuitGraphMessage_Edge_ZenerDiode))
          as CircuitGraphMessage_Edge_ZenerDiode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_ZenerDiode create() =>
      CircuitGraphMessage_Edge_ZenerDiode._();
  @$core.override
  CircuitGraphMessage_Edge_ZenerDiode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge_ZenerDiode getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          CircuitGraphMessage_Edge_ZenerDiode>(create);
  static CircuitGraphMessage_Edge_ZenerDiode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get vzt => $_getN(0);
  @$pb.TagNumber(1)
  set vzt($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVzt() => $_has(0);
  @$pb.TagNumber(1)
  void clearVzt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rzt => $_getN(1);
  @$pb.TagNumber(2)
  set rzt($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRzt() => $_has(1);
  @$pb.TagNumber(2)
  void clearRzt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get izt => $_getN(2);
  @$pb.TagNumber(3)
  set izt($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIzt() => $_has(2);
  @$pb.TagNumber(3)
  void clearIzt() => $_clearField(3);
}

enum CircuitGraphMessage_Edge_SpecificBranch {
  currentSource,
  idealDiode,
  realDiode,
  resistor,
  voltageSource,
  zenerDiode,
  notSet
}

class CircuitGraphMessage_Edge extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Edge({
    $core.String? id,
    $core.String? fromId,
    $core.String? toId,
    $core.double? current,
    CircuitGraphMessage_Edge_CurrentSource? currentSource,
    CircuitGraphMessage_Edge_IdealDiode? idealDiode,
    CircuitGraphMessage_Edge_RealDiode? realDiode,
    CircuitGraphMessage_Edge_Resistor? resistor,
    CircuitGraphMessage_Edge_VoltageSource? voltageSource,
    CircuitGraphMessage_Edge_ZenerDiode? zenerDiode,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fromId != null) result.fromId = fromId;
    if (toId != null) result.toId = toId;
    if (current != null) result.current = current;
    if (currentSource != null) result.currentSource = currentSource;
    if (idealDiode != null) result.idealDiode = idealDiode;
    if (realDiode != null) result.realDiode = realDiode;
    if (resistor != null) result.resistor = resistor;
    if (voltageSource != null) result.voltageSource = voltageSource;
    if (zenerDiode != null) result.zenerDiode = zenerDiode;
    return result;
  }

  CircuitGraphMessage_Edge._();

  factory CircuitGraphMessage_Edge.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Edge.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CircuitGraphMessage_Edge_SpecificBranch>
      _CircuitGraphMessage_Edge_SpecificBranchByTag = {
    5: CircuitGraphMessage_Edge_SpecificBranch.currentSource,
    6: CircuitGraphMessage_Edge_SpecificBranch.idealDiode,
    7: CircuitGraphMessage_Edge_SpecificBranch.realDiode,
    8: CircuitGraphMessage_Edge_SpecificBranch.resistor,
    9: CircuitGraphMessage_Edge_SpecificBranch.voltageSource,
    10: CircuitGraphMessage_Edge_SpecificBranch.zenerDiode,
    0: CircuitGraphMessage_Edge_SpecificBranch.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Edge',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..oo(0, [5, 6, 7, 8, 9, 10])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fromId')
    ..aOS(3, _omitFieldNames ? '' : 'toId')
    ..aD(4, _omitFieldNames ? '' : 'current')
    ..aOM<CircuitGraphMessage_Edge_CurrentSource>(
        5, _omitFieldNames ? '' : 'currentSource',
        subBuilder: CircuitGraphMessage_Edge_CurrentSource.create)
    ..aOM<CircuitGraphMessage_Edge_IdealDiode>(
        6, _omitFieldNames ? '' : 'idealDiode',
        subBuilder: CircuitGraphMessage_Edge_IdealDiode.create)
    ..aOM<CircuitGraphMessage_Edge_RealDiode>(
        7, _omitFieldNames ? '' : 'realDiode',
        subBuilder: CircuitGraphMessage_Edge_RealDiode.create)
    ..aOM<CircuitGraphMessage_Edge_Resistor>(
        8, _omitFieldNames ? '' : 'resistor',
        subBuilder: CircuitGraphMessage_Edge_Resistor.create)
    ..aOM<CircuitGraphMessage_Edge_VoltageSource>(
        9, _omitFieldNames ? '' : 'voltageSource',
        subBuilder: CircuitGraphMessage_Edge_VoltageSource.create)
    ..aOM<CircuitGraphMessage_Edge_ZenerDiode>(
        10, _omitFieldNames ? '' : 'zenerDiode',
        subBuilder: CircuitGraphMessage_Edge_ZenerDiode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Edge copyWith(
          void Function(CircuitGraphMessage_Edge) updates) =>
      super.copyWith((message) => updates(message as CircuitGraphMessage_Edge))
          as CircuitGraphMessage_Edge;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge create() => CircuitGraphMessage_Edge._();
  @$core.override
  CircuitGraphMessage_Edge createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Edge getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CircuitGraphMessage_Edge>(create);
  static CircuitGraphMessage_Edge? _defaultInstance;

  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  CircuitGraphMessage_Edge_SpecificBranch whichSpecificBranch() =>
      _CircuitGraphMessage_Edge_SpecificBranchByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  void clearSpecificBranch() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toId => $_getSZ(2);
  @$pb.TagNumber(3)
  set toId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToId() => $_has(2);
  @$pb.TagNumber(3)
  void clearToId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get current => $_getN(3);
  @$pb.TagNumber(4)
  set current($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrent() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrent() => $_clearField(4);

  @$pb.TagNumber(5)
  CircuitGraphMessage_Edge_CurrentSource get currentSource => $_getN(4);
  @$pb.TagNumber(5)
  set currentSource(CircuitGraphMessage_Edge_CurrentSource value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentSource() => $_clearField(5);
  @$pb.TagNumber(5)
  CircuitGraphMessage_Edge_CurrentSource ensureCurrentSource() => $_ensure(4);

  @$pb.TagNumber(6)
  CircuitGraphMessage_Edge_IdealDiode get idealDiode => $_getN(5);
  @$pb.TagNumber(6)
  set idealDiode(CircuitGraphMessage_Edge_IdealDiode value) =>
      $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasIdealDiode() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdealDiode() => $_clearField(6);
  @$pb.TagNumber(6)
  CircuitGraphMessage_Edge_IdealDiode ensureIdealDiode() => $_ensure(5);

  @$pb.TagNumber(7)
  CircuitGraphMessage_Edge_RealDiode get realDiode => $_getN(6);
  @$pb.TagNumber(7)
  set realDiode(CircuitGraphMessage_Edge_RealDiode value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRealDiode() => $_has(6);
  @$pb.TagNumber(7)
  void clearRealDiode() => $_clearField(7);
  @$pb.TagNumber(7)
  CircuitGraphMessage_Edge_RealDiode ensureRealDiode() => $_ensure(6);

  @$pb.TagNumber(8)
  CircuitGraphMessage_Edge_Resistor get resistor => $_getN(7);
  @$pb.TagNumber(8)
  set resistor(CircuitGraphMessage_Edge_Resistor value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasResistor() => $_has(7);
  @$pb.TagNumber(8)
  void clearResistor() => $_clearField(8);
  @$pb.TagNumber(8)
  CircuitGraphMessage_Edge_Resistor ensureResistor() => $_ensure(7);

  @$pb.TagNumber(9)
  CircuitGraphMessage_Edge_VoltageSource get voltageSource => $_getN(8);
  @$pb.TagNumber(9)
  set voltageSource(CircuitGraphMessage_Edge_VoltageSource value) =>
      $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasVoltageSource() => $_has(8);
  @$pb.TagNumber(9)
  void clearVoltageSource() => $_clearField(9);
  @$pb.TagNumber(9)
  CircuitGraphMessage_Edge_VoltageSource ensureVoltageSource() => $_ensure(8);

  @$pb.TagNumber(10)
  CircuitGraphMessage_Edge_ZenerDiode get zenerDiode => $_getN(9);
  @$pb.TagNumber(10)
  set zenerDiode(CircuitGraphMessage_Edge_ZenerDiode value) =>
      $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasZenerDiode() => $_has(9);
  @$pb.TagNumber(10)
  void clearZenerDiode() => $_clearField(10);
  @$pb.TagNumber(10)
  CircuitGraphMessage_Edge_ZenerDiode ensureZenerDiode() => $_ensure(9);
}

class CircuitGraphMessage_Vertex extends $pb.GeneratedMessage {
  factory CircuitGraphMessage_Vertex({
    $core.String? id,
    $core.double? voltage,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (voltage != null) result.voltage = voltage;
    return result;
  }

  CircuitGraphMessage_Vertex._();

  factory CircuitGraphMessage_Vertex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage_Vertex.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage.Vertex',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aD(2, _omitFieldNames ? '' : 'voltage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Vertex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage_Vertex copyWith(
          void Function(CircuitGraphMessage_Vertex) updates) =>
      super.copyWith(
              (message) => updates(message as CircuitGraphMessage_Vertex))
          as CircuitGraphMessage_Vertex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Vertex create() => CircuitGraphMessage_Vertex._();
  @$core.override
  CircuitGraphMessage_Vertex createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage_Vertex getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CircuitGraphMessage_Vertex>(create);
  static CircuitGraphMessage_Vertex? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get voltage => $_getN(1);
  @$pb.TagNumber(2)
  set voltage($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVoltage() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoltage() => $_clearField(2);
}

class CircuitGraphMessage extends $pb.GeneratedMessage {
  factory CircuitGraphMessage({
    $core.Iterable<$core.MapEntry<$core.String, CircuitGraphMessage_Edge>>?
        edges,
    $core.Iterable<$core.MapEntry<$core.String, CircuitGraphMessage_Vertex>>?
        vertices,
  }) {
    final result = create();
    if (edges != null) result.edges.addEntries(edges);
    if (vertices != null) result.vertices.addEntries(vertices);
    return result;
  }

  CircuitGraphMessage._();

  factory CircuitGraphMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CircuitGraphMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CircuitGraphMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'circuit_solver.v1'),
      createEmptyInstance: create)
    ..m<$core.String, CircuitGraphMessage_Edge>(
        1, _omitFieldNames ? '' : 'edges',
        entryClassName: 'CircuitGraphMessage.EdgesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: CircuitGraphMessage_Edge.create,
        valueDefaultOrMaker: CircuitGraphMessage_Edge.getDefault,
        packageName: const $pb.PackageName('circuit_solver.v1'))
    ..m<$core.String, CircuitGraphMessage_Vertex>(
        2, _omitFieldNames ? '' : 'vertices',
        entryClassName: 'CircuitGraphMessage.VerticesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: CircuitGraphMessage_Vertex.create,
        valueDefaultOrMaker: CircuitGraphMessage_Vertex.getDefault,
        packageName: const $pb.PackageName('circuit_solver.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CircuitGraphMessage copyWith(void Function(CircuitGraphMessage) updates) =>
      super.copyWith((message) => updates(message as CircuitGraphMessage))
          as CircuitGraphMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage create() => CircuitGraphMessage._();
  @$core.override
  CircuitGraphMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CircuitGraphMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CircuitGraphMessage>(create);
  static CircuitGraphMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, CircuitGraphMessage_Edge> get edges => $_getMap(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, CircuitGraphMessage_Vertex> get vertices =>
      $_getMap(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
