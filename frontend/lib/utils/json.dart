/// `dart_mappable` mappers for types `dart_mappable` does not serialize
/// out of the box.
///
/// Each mapper should be registered on models that need it with:
/// `@MappableClass(includeCustomMappers: [...])` (see `circuit_models.dart`).
library;

import 'dart:ui';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

/// Serializes a [UuidValue] to and from its canonical string form.
class UuidValueMapper extends SimpleMapper<UuidValue> {
  const UuidValueMapper();

  /// Parses a [UuidValue] from a [String]. Throws a [FormatException] if the
  /// string is not a valid uuid
  @override
  UuidValue decode(Object value) {
    return UuidValue.withValidation(value as String);
  }

  /// Converts a [UuidValue] to a [String] using its canonical representation
  @override
  Object? encode(UuidValue self) {
    return self.toString();
  }
}

/// Serializes an [Offset] to and from a [Map]
class OffsetMapper extends SimpleMapper<Offset> {
  const OffsetMapper();

  /// Parses an [Offset] from a [Map]. Throws if [value] cannot be coarsed into a `Map<String, dynamic>` or if the map's values cannot be cast to [num]
  @override
  Offset decode(Object value) {
    final map = value as Map<String, dynamic>;
    final dx = map['dx'] as num;
    final dy = map['dy'] as num;
    return Offset(dx.toDouble(), dy.toDouble());
  }

  /// Converts an [Offset] to a [Map] representation
  @override
  Object? encode(Offset self) {
    return {'dx': self.dx, 'dy': self.dy};
  }
}

class UuidValueConverter implements JsonConverter<UuidValue, String> {
  const UuidValueConverter();
  @override
  UuidValue fromJson(String json) {
    return UuidValue.withValidation(json);
  }

  @override
  String toJson(UuidValue object) {
    return object.toString();
  }
}

class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {'dx': object.dx, 'dy': object.dy};
  }
}
