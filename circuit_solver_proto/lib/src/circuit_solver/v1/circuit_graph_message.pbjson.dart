// This is a generated file - do not edit.
//
// Generated from circuit_solver/v1/circuit_graph_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage$json = {
  '1': 'CircuitGraphMessage',
  '2': [
    {
      '1': 'edges',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.EdgesEntry',
      '10': 'edges'
    },
    {
      '1': 'vertices',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.VerticesEntry',
      '10': 'vertices'
    },
  ],
  '3': [
    CircuitGraphMessage_EdgesEntry$json,
    CircuitGraphMessage_VerticesEntry$json,
    CircuitGraphMessage_Edge$json,
    CircuitGraphMessage_Vertex$json
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_EdgesEntry$json = {
  '1': 'EdgesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_VerticesEntry$json = {
  '1': 'VerticesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Vertex',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge$json = {
  '1': 'Edge',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'from_id', '3': 2, '4': 1, '5': 9, '10': 'fromId'},
    {'1': 'to_id', '3': 3, '4': 1, '5': 9, '10': 'toId'},
    {'1': 'current', '3': 4, '4': 1, '5': 1, '10': 'current'},
    {
      '1': 'current_source',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.CurrentSource',
      '9': 0,
      '10': 'currentSource'
    },
    {
      '1': 'ideal_diode',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.IdealDiode',
      '9': 0,
      '10': 'idealDiode'
    },
    {
      '1': 'real_diode',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.RealDiode',
      '9': 0,
      '10': 'realDiode'
    },
    {
      '1': 'resistor',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.Resistor',
      '9': 0,
      '10': 'resistor'
    },
    {
      '1': 'voltage_source',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.VoltageSource',
      '9': 0,
      '10': 'voltageSource'
    },
    {
      '1': 'zener_diode',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.circuit_solver.v1.CircuitGraphMessage.Edge.ZenerDiode',
      '9': 0,
      '10': 'zenerDiode'
    },
  ],
  '3': [
    CircuitGraphMessage_Edge_CurrentSource$json,
    CircuitGraphMessage_Edge_IdealDiode$json,
    CircuitGraphMessage_Edge_RealDiode$json,
    CircuitGraphMessage_Edge_Resistor$json,
    CircuitGraphMessage_Edge_VoltageSource$json,
    CircuitGraphMessage_Edge_ZenerDiode$json
  ],
  '8': [
    {'1': 'specific_branch'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_CurrentSource$json = {
  '1': 'CurrentSource',
  '2': [
    {'1': 'voltage', '3': 1, '4': 1, '5': 1, '10': 'voltage'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_IdealDiode$json = {
  '1': 'IdealDiode',
  '2': [
    {'1': 'voltage', '3': 1, '4': 1, '5': 1, '10': 'voltage'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_RealDiode$json = {
  '1': 'RealDiode',
  '2': [
    {'1': 'i0', '3': 1, '4': 1, '5': 1, '10': 'i0'},
    {'1': 'vt', '3': 2, '4': 1, '5': 1, '10': 'vt'},
    {'1': 'n', '3': 3, '4': 1, '5': 1, '10': 'n'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_Resistor$json = {
  '1': 'Resistor',
  '2': [
    {'1': 'resistance', '3': 1, '4': 1, '5': 1, '10': 'resistance'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_VoltageSource$json = {
  '1': 'VoltageSource',
  '2': [
    {'1': 'voltage', '3': 1, '4': 1, '5': 1, '10': 'voltage'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Edge_ZenerDiode$json = {
  '1': 'ZenerDiode',
  '2': [
    {'1': 'vzt', '3': 1, '4': 1, '5': 1, '10': 'vzt'},
    {'1': 'rzt', '3': 2, '4': 1, '5': 1, '10': 'rzt'},
    {'1': 'izt', '3': 3, '4': 1, '5': 1, '10': 'izt'},
  ],
};

@$core.Deprecated('Use circuitGraphMessageDescriptor instead')
const CircuitGraphMessage_Vertex$json = {
  '1': 'Vertex',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'voltage', '3': 2, '4': 1, '5': 1, '10': 'voltage'},
  ],
};

/// Descriptor for `CircuitGraphMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List circuitGraphMessageDescriptor = $convert.base64Decode(
    'ChNDaXJjdWl0R3JhcGhNZXNzYWdlEkcKBWVkZ2VzGAEgAygLMjEuY2lyY3VpdF9zb2x2ZXIudj'
    'EuQ2lyY3VpdEdyYXBoTWVzc2FnZS5FZGdlc0VudHJ5UgVlZGdlcxJQCgh2ZXJ0aWNlcxgCIAMo'
    'CzI0LmNpcmN1aXRfc29sdmVyLnYxLkNpcmN1aXRHcmFwaE1lc3NhZ2UuVmVydGljZXNFbnRyeV'
    'IIdmVydGljZXMaZQoKRWRnZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRJBCgV2YWx1ZRgCIAEo'
    'CzIrLmNpcmN1aXRfc29sdmVyLnYxLkNpcmN1aXRHcmFwaE1lc3NhZ2UuRWRnZVIFdmFsdWU6Aj'
    'gBGmoKDVZlcnRpY2VzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSQwoFdmFsdWUYAiABKAsyLS5j'
    'aXJjdWl0X3NvbHZlci52MS5DaXJjdWl0R3JhcGhNZXNzYWdlLlZlcnRleFIFdmFsdWU6AjgBGs'
    'QHCgRFZGdlEg4KAmlkGAEgASgJUgJpZBIXCgdmcm9tX2lkGAIgASgJUgZmcm9tSWQSEwoFdG9f'
    'aWQYAyABKAlSBHRvSWQSGAoHY3VycmVudBgEIAEoAVIHY3VycmVudBJiCg5jdXJyZW50X3NvdX'
    'JjZRgFIAEoCzI5LmNpcmN1aXRfc29sdmVyLnYxLkNpcmN1aXRHcmFwaE1lc3NhZ2UuRWRnZS5D'
    'dXJyZW50U291cmNlSABSDWN1cnJlbnRTb3VyY2USWQoLaWRlYWxfZGlvZGUYBiABKAsyNi5jaX'
    'JjdWl0X3NvbHZlci52MS5DaXJjdWl0R3JhcGhNZXNzYWdlLkVkZ2UuSWRlYWxEaW9kZUgAUgpp'
    'ZGVhbERpb2RlElYKCnJlYWxfZGlvZGUYByABKAsyNS5jaXJjdWl0X3NvbHZlci52MS5DaXJjdW'
    'l0R3JhcGhNZXNzYWdlLkVkZ2UuUmVhbERpb2RlSABSCXJlYWxEaW9kZRJSCghyZXNpc3RvchgI'
    'IAEoCzI0LmNpcmN1aXRfc29sdmVyLnYxLkNpcmN1aXRHcmFwaE1lc3NhZ2UuRWRnZS5SZXNpc3'
    'RvckgAUghyZXNpc3RvchJiCg52b2x0YWdlX3NvdXJjZRgJIAEoCzI5LmNpcmN1aXRfc29sdmVy'
    'LnYxLkNpcmN1aXRHcmFwaE1lc3NhZ2UuRWRnZS5Wb2x0YWdlU291cmNlSABSDXZvbHRhZ2VTb3'
    'VyY2USWQoLemVuZXJfZGlvZGUYCiABKAsyNi5jaXJjdWl0X3NvbHZlci52MS5DaXJjdWl0R3Jh'
    'cGhNZXNzYWdlLkVkZ2UuWmVuZXJEaW9kZUgAUgp6ZW5lckRpb2RlGikKDUN1cnJlbnRTb3VyY2'
    'USGAoHdm9sdGFnZRgBIAEoAVIHdm9sdGFnZRomCgpJZGVhbERpb2RlEhgKB3ZvbHRhZ2UYASAB'
    'KAFSB3ZvbHRhZ2UaOQoJUmVhbERpb2RlEg4KAmkwGAEgASgBUgJpMBIOCgJ2dBgCIAEoAVICdn'
    'QSDAoBbhgDIAEoAVIBbhoqCghSZXNpc3RvchIeCgpyZXNpc3RhbmNlGAEgASgBUgpyZXNpc3Rh'
    'bmNlGikKDVZvbHRhZ2VTb3VyY2USGAoHdm9sdGFnZRgBIAEoAVIHdm9sdGFnZRpCCgpaZW5lck'
    'Rpb2RlEhAKA3Z6dBgBIAEoAVIDdnp0EhAKA3J6dBgCIAEoAVIDcnp0EhAKA2l6dBgDIAEoAVID'
    'aXp0QhEKD3NwZWNpZmljX2JyYW5jaBoyCgZWZXJ0ZXgSDgoCaWQYASABKAlSAmlkEhgKB3ZvbH'
    'RhZ2UYAiABKAFSB3ZvbHRhZ2U=');
