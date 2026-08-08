import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

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
