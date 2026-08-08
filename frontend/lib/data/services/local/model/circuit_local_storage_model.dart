import 'package:frontend/data/model/circuit_models.dart';
import 'package:frontend/utils/json.dart';
import 'package:uuid/uuid_value.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'circuit_local_storage_model.freezed.dart';

@freezed
abstract class CircuitLocalStorageModel with _$CircuitLocalStorageModel {
  const factory CircuitLocalStorageModel({
    @UuidValueConverter() required UuidValue id,
    required String name,
    required DateTime created,
    required DateTime modified,
    required List<WireModel> wires,
    required List<ComponentModel> components,
  }) = _CircuitLocalStorageModel;
}
