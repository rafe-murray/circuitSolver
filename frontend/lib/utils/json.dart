import 'dart:ui';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

class UuidValueMapper extends SimpleMapper<UuidValue> {
  const UuidValueMapper();
  @override
  UuidValue decode(Object value) {
    return UuidValue.withValidation(value as String);
  }

  @override
  Object? encode(UuidValue self) {
    return self.toString();
  }
}

class OffsetMapper extends SimpleMapper<Offset> {
  const OffsetMapper();
  @override
  Offset decode(Object value) {
    final map = value as Map<String, dynamic>;
    final dx = map['dx'] as num;
    final dy = map['dy'] as num;
    return Offset(dx.toDouble(), dy.toDouble());
  }

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

//
// class UuidValueEndpointModelMapConverter
//     implements
//         JsonConverter<
//           Map<UuidValue, EndpointModel>,
//           Map<String, Map<String, dynamic>>
//         > {
//   const UuidValueEndpointModelMapConverter();
//
//   @override
//   Map<UuidValue, EndpointModel> fromJson(
//     Map<String, Map<String, dynamic>> json,
//   ) => json.map(
//     (key, value) => MapEntry(
//       const UuidValueConverter().fromJson(key),
//       EndpointModel.fromJson(value),
//     ),
//   );
//
//   @override
//   Map<String, Map<String, dynamic>> toJson(
//     Map<UuidValue, EndpointModel> object,
//   ) => object.map(
//     (key, value) =>
//         MapEntry(const UuidValueConverter().toJson(key), value.toJson()),
//   );
// }
