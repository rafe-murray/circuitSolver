// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circuit_local_storage_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CircuitLocalStorageModel {

@UuidValueConverter() UuidValue get id; String get name; DateTime get created; DateTime get modified; CircuitModel get circuit;
/// Create a copy of CircuitLocalStorageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircuitLocalStorageModelCopyWith<CircuitLocalStorageModel> get copyWith => _$CircuitLocalStorageModelCopyWithImpl<CircuitLocalStorageModel>(this as CircuitLocalStorageModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircuitLocalStorageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.created, created) || other.created == created)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.circuit, circuit) || other.circuit == circuit));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,created,modified,circuit);

@override
String toString() {
  return 'CircuitLocalStorageModel(id: $id, name: $name, created: $created, modified: $modified, circuit: $circuit)';
}


}

/// @nodoc
abstract mixin class $CircuitLocalStorageModelCopyWith<$Res>  {
  factory $CircuitLocalStorageModelCopyWith(CircuitLocalStorageModel value, $Res Function(CircuitLocalStorageModel) _then) = _$CircuitLocalStorageModelCopyWithImpl;
@useResult
$Res call({
@UuidValueConverter() UuidValue id, String name, DateTime created, DateTime modified, CircuitModel circuit
});




}
/// @nodoc
class _$CircuitLocalStorageModelCopyWithImpl<$Res>
    implements $CircuitLocalStorageModelCopyWith<$Res> {
  _$CircuitLocalStorageModelCopyWithImpl(this._self, this._then);

  final CircuitLocalStorageModel _self;
  final $Res Function(CircuitLocalStorageModel) _then;

/// Create a copy of CircuitLocalStorageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? created = null,Object? modified = null,Object? circuit = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UuidValue,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,circuit: null == circuit ? _self.circuit : circuit // ignore: cast_nullable_to_non_nullable
as CircuitModel,
  ));
}

}


/// Adds pattern-matching-related methods to [CircuitLocalStorageModel].
extension CircuitLocalStorageModelPatterns on CircuitLocalStorageModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CircuitLocalStorageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CircuitLocalStorageModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CircuitLocalStorageModel value)  $default,){
final _that = this;
switch (_that) {
case _CircuitLocalStorageModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CircuitLocalStorageModel value)?  $default,){
final _that = this;
switch (_that) {
case _CircuitLocalStorageModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@UuidValueConverter()  UuidValue id,  String name,  DateTime created,  DateTime modified,  CircuitModel circuit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CircuitLocalStorageModel() when $default != null:
return $default(_that.id,_that.name,_that.created,_that.modified,_that.circuit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@UuidValueConverter()  UuidValue id,  String name,  DateTime created,  DateTime modified,  CircuitModel circuit)  $default,) {final _that = this;
switch (_that) {
case _CircuitLocalStorageModel():
return $default(_that.id,_that.name,_that.created,_that.modified,_that.circuit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@UuidValueConverter()  UuidValue id,  String name,  DateTime created,  DateTime modified,  CircuitModel circuit)?  $default,) {final _that = this;
switch (_that) {
case _CircuitLocalStorageModel() when $default != null:
return $default(_that.id,_that.name,_that.created,_that.modified,_that.circuit);case _:
  return null;

}
}

}

/// @nodoc


class _CircuitLocalStorageModel implements CircuitLocalStorageModel {
  const _CircuitLocalStorageModel({@UuidValueConverter() required this.id, required this.name, required this.created, required this.modified, required this.circuit});
  

@override@UuidValueConverter() final  UuidValue id;
@override final  String name;
@override final  DateTime created;
@override final  DateTime modified;
@override final  CircuitModel circuit;

/// Create a copy of CircuitLocalStorageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CircuitLocalStorageModelCopyWith<_CircuitLocalStorageModel> get copyWith => __$CircuitLocalStorageModelCopyWithImpl<_CircuitLocalStorageModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CircuitLocalStorageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.created, created) || other.created == created)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.circuit, circuit) || other.circuit == circuit));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,created,modified,circuit);

@override
String toString() {
  return 'CircuitLocalStorageModel(id: $id, name: $name, created: $created, modified: $modified, circuit: $circuit)';
}


}

/// @nodoc
abstract mixin class _$CircuitLocalStorageModelCopyWith<$Res> implements $CircuitLocalStorageModelCopyWith<$Res> {
  factory _$CircuitLocalStorageModelCopyWith(_CircuitLocalStorageModel value, $Res Function(_CircuitLocalStorageModel) _then) = __$CircuitLocalStorageModelCopyWithImpl;
@override @useResult
$Res call({
@UuidValueConverter() UuidValue id, String name, DateTime created, DateTime modified, CircuitModel circuit
});




}
/// @nodoc
class __$CircuitLocalStorageModelCopyWithImpl<$Res>
    implements _$CircuitLocalStorageModelCopyWith<$Res> {
  __$CircuitLocalStorageModelCopyWithImpl(this._self, this._then);

  final _CircuitLocalStorageModel _self;
  final $Res Function(_CircuitLocalStorageModel) _then;

/// Create a copy of CircuitLocalStorageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? created = null,Object? modified = null,Object? circuit = null,}) {
  return _then(_CircuitLocalStorageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UuidValue,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,circuit: null == circuit ? _self.circuit : circuit // ignore: cast_nullable_to_non_nullable
as CircuitModel,
  ));
}


}

// dart format on
