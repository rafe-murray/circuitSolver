// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circuit_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
BranchModel _$BranchModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'currentSource':
          return CurrentSource.fromJson(
            json
          );
                case 'idealDiode':
          return IdealDiode.fromJson(
            json
          );
                case 'realDiode':
          return RealDiode.fromJson(
            json
          );
                case 'resistor':
          return Resistor.fromJson(
            json
          );
                case 'voltageSource':
          return VoltageSource.fromJson(
            json
          );
                case 'zenerDiode':
          return ZenerDiode.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'BranchModel',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$BranchModel {



  /// Serializes this BranchModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchModel);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BranchModel()';
}


}

/// @nodoc
class $BranchModelCopyWith<$Res>  {
$BranchModelCopyWith(BranchModel _, $Res Function(BranchModel) __);
}


/// Adds pattern-matching-related methods to [BranchModel].
extension BranchModelPatterns on BranchModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CurrentSource value)?  currentSource,TResult Function( IdealDiode value)?  idealDiode,TResult Function( RealDiode value)?  realDiode,TResult Function( Resistor value)?  resistor,TResult Function( VoltageSource value)?  voltageSource,TResult Function( ZenerDiode value)?  zenerDiode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CurrentSource() when currentSource != null:
return currentSource(_that);case IdealDiode() when idealDiode != null:
return idealDiode(_that);case RealDiode() when realDiode != null:
return realDiode(_that);case Resistor() when resistor != null:
return resistor(_that);case VoltageSource() when voltageSource != null:
return voltageSource(_that);case ZenerDiode() when zenerDiode != null:
return zenerDiode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CurrentSource value)  currentSource,required TResult Function( IdealDiode value)  idealDiode,required TResult Function( RealDiode value)  realDiode,required TResult Function( Resistor value)  resistor,required TResult Function( VoltageSource value)  voltageSource,required TResult Function( ZenerDiode value)  zenerDiode,}){
final _that = this;
switch (_that) {
case CurrentSource():
return currentSource(_that);case IdealDiode():
return idealDiode(_that);case RealDiode():
return realDiode(_that);case Resistor():
return resistor(_that);case VoltageSource():
return voltageSource(_that);case ZenerDiode():
return zenerDiode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CurrentSource value)?  currentSource,TResult? Function( IdealDiode value)?  idealDiode,TResult? Function( RealDiode value)?  realDiode,TResult? Function( Resistor value)?  resistor,TResult? Function( VoltageSource value)?  voltageSource,TResult? Function( ZenerDiode value)?  zenerDiode,}){
final _that = this;
switch (_that) {
case CurrentSource() when currentSource != null:
return currentSource(_that);case IdealDiode() when idealDiode != null:
return idealDiode(_that);case RealDiode() when realDiode != null:
return realDiode(_that);case Resistor() when resistor != null:
return resistor(_that);case VoltageSource() when voltageSource != null:
return voltageSource(_that);case ZenerDiode() when zenerDiode != null:
return zenerDiode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Voltage? voltage)?  currentSource,TResult Function( Voltage? voltage)?  idealDiode,TResult Function( Current? i0,  Voltage? vt,  double? n)?  realDiode,TResult Function( Resistance? resistance)?  resistor,TResult Function( Voltage? voltage)?  voltageSource,TResult Function( Voltage? vzt,  Resistance? rzt,  Current? izt)?  zenerDiode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CurrentSource() when currentSource != null:
return currentSource(_that.voltage);case IdealDiode() when idealDiode != null:
return idealDiode(_that.voltage);case RealDiode() when realDiode != null:
return realDiode(_that.i0,_that.vt,_that.n);case Resistor() when resistor != null:
return resistor(_that.resistance);case VoltageSource() when voltageSource != null:
return voltageSource(_that.voltage);case ZenerDiode() when zenerDiode != null:
return zenerDiode(_that.vzt,_that.rzt,_that.izt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Voltage? voltage)  currentSource,required TResult Function( Voltage? voltage)  idealDiode,required TResult Function( Current? i0,  Voltage? vt,  double? n)  realDiode,required TResult Function( Resistance? resistance)  resistor,required TResult Function( Voltage? voltage)  voltageSource,required TResult Function( Voltage? vzt,  Resistance? rzt,  Current? izt)  zenerDiode,}) {final _that = this;
switch (_that) {
case CurrentSource():
return currentSource(_that.voltage);case IdealDiode():
return idealDiode(_that.voltage);case RealDiode():
return realDiode(_that.i0,_that.vt,_that.n);case Resistor():
return resistor(_that.resistance);case VoltageSource():
return voltageSource(_that.voltage);case ZenerDiode():
return zenerDiode(_that.vzt,_that.rzt,_that.izt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Voltage? voltage)?  currentSource,TResult? Function( Voltage? voltage)?  idealDiode,TResult? Function( Current? i0,  Voltage? vt,  double? n)?  realDiode,TResult? Function( Resistance? resistance)?  resistor,TResult? Function( Voltage? voltage)?  voltageSource,TResult? Function( Voltage? vzt,  Resistance? rzt,  Current? izt)?  zenerDiode,}) {final _that = this;
switch (_that) {
case CurrentSource() when currentSource != null:
return currentSource(_that.voltage);case IdealDiode() when idealDiode != null:
return idealDiode(_that.voltage);case RealDiode() when realDiode != null:
return realDiode(_that.i0,_that.vt,_that.n);case Resistor() when resistor != null:
return resistor(_that.resistance);case VoltageSource() when voltageSource != null:
return voltageSource(_that.voltage);case ZenerDiode() when zenerDiode != null:
return zenerDiode(_that.vzt,_that.rzt,_that.izt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CurrentSource implements BranchModel {
  const CurrentSource({this.voltage, final  String? $type}): $type = $type ?? 'currentSource';
  factory CurrentSource.fromJson(Map<String, dynamic> json) => _$CurrentSourceFromJson(json);

 final  Voltage? voltage;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentSourceCopyWith<CurrentSource> get copyWith => _$CurrentSourceCopyWithImpl<CurrentSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentSource&&(identical(other.voltage, voltage) || other.voltage == voltage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voltage);

@override
String toString() {
  return 'BranchModel.currentSource(voltage: $voltage)';
}


}

/// @nodoc
abstract mixin class $CurrentSourceCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $CurrentSourceCopyWith(CurrentSource value, $Res Function(CurrentSource) _then) = _$CurrentSourceCopyWithImpl;
@useResult
$Res call({
 Voltage? voltage
});


$VoltageCopyWith<$Res>? get voltage;

}
/// @nodoc
class _$CurrentSourceCopyWithImpl<$Res>
    implements $CurrentSourceCopyWith<$Res> {
  _$CurrentSourceCopyWithImpl(this._self, this._then);

  final CurrentSource _self;
  final $Res Function(CurrentSource) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? voltage = freezed,}) {
  return _then(CurrentSource(
voltage: freezed == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as Voltage?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoltageCopyWith<$Res>? get voltage {
    if (_self.voltage == null) {
    return null;
  }

  return $VoltageCopyWith<$Res>(_self.voltage!, (value) {
    return _then(_self.copyWith(voltage: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class IdealDiode implements BranchModel {
  const IdealDiode({this.voltage, final  String? $type}): $type = $type ?? 'idealDiode';
  factory IdealDiode.fromJson(Map<String, dynamic> json) => _$IdealDiodeFromJson(json);

 final  Voltage? voltage;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdealDiodeCopyWith<IdealDiode> get copyWith => _$IdealDiodeCopyWithImpl<IdealDiode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdealDiodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdealDiode&&(identical(other.voltage, voltage) || other.voltage == voltage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voltage);

@override
String toString() {
  return 'BranchModel.idealDiode(voltage: $voltage)';
}


}

/// @nodoc
abstract mixin class $IdealDiodeCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $IdealDiodeCopyWith(IdealDiode value, $Res Function(IdealDiode) _then) = _$IdealDiodeCopyWithImpl;
@useResult
$Res call({
 Voltage? voltage
});


$VoltageCopyWith<$Res>? get voltage;

}
/// @nodoc
class _$IdealDiodeCopyWithImpl<$Res>
    implements $IdealDiodeCopyWith<$Res> {
  _$IdealDiodeCopyWithImpl(this._self, this._then);

  final IdealDiode _self;
  final $Res Function(IdealDiode) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? voltage = freezed,}) {
  return _then(IdealDiode(
voltage: freezed == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as Voltage?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoltageCopyWith<$Res>? get voltage {
    if (_self.voltage == null) {
    return null;
  }

  return $VoltageCopyWith<$Res>(_self.voltage!, (value) {
    return _then(_self.copyWith(voltage: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class RealDiode implements BranchModel {
  const RealDiode({this.i0, this.vt, this.n, final  String? $type}): $type = $type ?? 'realDiode';
  factory RealDiode.fromJson(Map<String, dynamic> json) => _$RealDiodeFromJson(json);

 final  Current? i0;
 final  Voltage? vt;
 final  double? n;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealDiodeCopyWith<RealDiode> get copyWith => _$RealDiodeCopyWithImpl<RealDiode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealDiodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealDiode&&(identical(other.i0, i0) || other.i0 == i0)&&(identical(other.vt, vt) || other.vt == vt)&&(identical(other.n, n) || other.n == n));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,i0,vt,n);

@override
String toString() {
  return 'BranchModel.realDiode(i0: $i0, vt: $vt, n: $n)';
}


}

/// @nodoc
abstract mixin class $RealDiodeCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $RealDiodeCopyWith(RealDiode value, $Res Function(RealDiode) _then) = _$RealDiodeCopyWithImpl;
@useResult
$Res call({
 Current? i0, Voltage? vt, double? n
});


$CurrentCopyWith<$Res>? get i0;$VoltageCopyWith<$Res>? get vt;

}
/// @nodoc
class _$RealDiodeCopyWithImpl<$Res>
    implements $RealDiodeCopyWith<$Res> {
  _$RealDiodeCopyWithImpl(this._self, this._then);

  final RealDiode _self;
  final $Res Function(RealDiode) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? i0 = freezed,Object? vt = freezed,Object? n = freezed,}) {
  return _then(RealDiode(
i0: freezed == i0 ? _self.i0 : i0 // ignore: cast_nullable_to_non_nullable
as Current?,vt: freezed == vt ? _self.vt : vt // ignore: cast_nullable_to_non_nullable
as Voltage?,n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentCopyWith<$Res>? get i0 {
    if (_self.i0 == null) {
    return null;
  }

  return $CurrentCopyWith<$Res>(_self.i0!, (value) {
    return _then(_self.copyWith(i0: value));
  });
}/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoltageCopyWith<$Res>? get vt {
    if (_self.vt == null) {
    return null;
  }

  return $VoltageCopyWith<$Res>(_self.vt!, (value) {
    return _then(_self.copyWith(vt: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class Resistor implements BranchModel {
  const Resistor({this.resistance, final  String? $type}): $type = $type ?? 'resistor';
  factory Resistor.fromJson(Map<String, dynamic> json) => _$ResistorFromJson(json);

 final  Resistance? resistance;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResistorCopyWith<Resistor> get copyWith => _$ResistorCopyWithImpl<Resistor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResistorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Resistor&&(identical(other.resistance, resistance) || other.resistance == resistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,resistance);

@override
String toString() {
  return 'BranchModel.resistor(resistance: $resistance)';
}


}

/// @nodoc
abstract mixin class $ResistorCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $ResistorCopyWith(Resistor value, $Res Function(Resistor) _then) = _$ResistorCopyWithImpl;
@useResult
$Res call({
 Resistance? resistance
});


$ResistanceCopyWith<$Res>? get resistance;

}
/// @nodoc
class _$ResistorCopyWithImpl<$Res>
    implements $ResistorCopyWith<$Res> {
  _$ResistorCopyWithImpl(this._self, this._then);

  final Resistor _self;
  final $Res Function(Resistor) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? resistance = freezed,}) {
  return _then(Resistor(
resistance: freezed == resistance ? _self.resistance : resistance // ignore: cast_nullable_to_non_nullable
as Resistance?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResistanceCopyWith<$Res>? get resistance {
    if (_self.resistance == null) {
    return null;
  }

  return $ResistanceCopyWith<$Res>(_self.resistance!, (value) {
    return _then(_self.copyWith(resistance: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class VoltageSource implements BranchModel {
  const VoltageSource({this.voltage, final  String? $type}): $type = $type ?? 'voltageSource';
  factory VoltageSource.fromJson(Map<String, dynamic> json) => _$VoltageSourceFromJson(json);

 final  Voltage? voltage;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoltageSourceCopyWith<VoltageSource> get copyWith => _$VoltageSourceCopyWithImpl<VoltageSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoltageSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoltageSource&&(identical(other.voltage, voltage) || other.voltage == voltage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voltage);

@override
String toString() {
  return 'BranchModel.voltageSource(voltage: $voltage)';
}


}

/// @nodoc
abstract mixin class $VoltageSourceCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $VoltageSourceCopyWith(VoltageSource value, $Res Function(VoltageSource) _then) = _$VoltageSourceCopyWithImpl;
@useResult
$Res call({
 Voltage? voltage
});


$VoltageCopyWith<$Res>? get voltage;

}
/// @nodoc
class _$VoltageSourceCopyWithImpl<$Res>
    implements $VoltageSourceCopyWith<$Res> {
  _$VoltageSourceCopyWithImpl(this._self, this._then);

  final VoltageSource _self;
  final $Res Function(VoltageSource) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? voltage = freezed,}) {
  return _then(VoltageSource(
voltage: freezed == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as Voltage?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoltageCopyWith<$Res>? get voltage {
    if (_self.voltage == null) {
    return null;
  }

  return $VoltageCopyWith<$Res>(_self.voltage!, (value) {
    return _then(_self.copyWith(voltage: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ZenerDiode implements BranchModel {
  const ZenerDiode({this.vzt, this.rzt, this.izt, final  String? $type}): $type = $type ?? 'zenerDiode';
  factory ZenerDiode.fromJson(Map<String, dynamic> json) => _$ZenerDiodeFromJson(json);

 final  Voltage? vzt;
 final  Resistance? rzt;
 final  Current? izt;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZenerDiodeCopyWith<ZenerDiode> get copyWith => _$ZenerDiodeCopyWithImpl<ZenerDiode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ZenerDiodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZenerDiode&&(identical(other.vzt, vzt) || other.vzt == vzt)&&(identical(other.rzt, rzt) || other.rzt == rzt)&&(identical(other.izt, izt) || other.izt == izt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vzt,rzt,izt);

@override
String toString() {
  return 'BranchModel.zenerDiode(vzt: $vzt, rzt: $rzt, izt: $izt)';
}


}

/// @nodoc
abstract mixin class $ZenerDiodeCopyWith<$Res> implements $BranchModelCopyWith<$Res> {
  factory $ZenerDiodeCopyWith(ZenerDiode value, $Res Function(ZenerDiode) _then) = _$ZenerDiodeCopyWithImpl;
@useResult
$Res call({
 Voltage? vzt, Resistance? rzt, Current? izt
});


$VoltageCopyWith<$Res>? get vzt;$ResistanceCopyWith<$Res>? get rzt;$CurrentCopyWith<$Res>? get izt;

}
/// @nodoc
class _$ZenerDiodeCopyWithImpl<$Res>
    implements $ZenerDiodeCopyWith<$Res> {
  _$ZenerDiodeCopyWithImpl(this._self, this._then);

  final ZenerDiode _self;
  final $Res Function(ZenerDiode) _then;

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? vzt = freezed,Object? rzt = freezed,Object? izt = freezed,}) {
  return _then(ZenerDiode(
vzt: freezed == vzt ? _self.vzt : vzt // ignore: cast_nullable_to_non_nullable
as Voltage?,rzt: freezed == rzt ? _self.rzt : rzt // ignore: cast_nullable_to_non_nullable
as Resistance?,izt: freezed == izt ? _self.izt : izt // ignore: cast_nullable_to_non_nullable
as Current?,
  ));
}

/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoltageCopyWith<$Res>? get vzt {
    if (_self.vzt == null) {
    return null;
  }

  return $VoltageCopyWith<$Res>(_self.vzt!, (value) {
    return _then(_self.copyWith(vzt: value));
  });
}/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResistanceCopyWith<$Res>? get rzt {
    if (_self.rzt == null) {
    return null;
  }

  return $ResistanceCopyWith<$Res>(_self.rzt!, (value) {
    return _then(_self.copyWith(rzt: value));
  });
}/// Create a copy of BranchModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentCopyWith<$Res>? get izt {
    if (_self.izt == null) {
    return null;
  }

  return $CurrentCopyWith<$Res>(_self.izt!, (value) {
    return _then(_self.copyWith(izt: value));
  });
}
}


/// @nodoc
mixin _$Resistance {

 double get ohms;
/// Create a copy of Resistance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResistanceCopyWith<Resistance> get copyWith => _$ResistanceCopyWithImpl<Resistance>(this as Resistance, _$identity);

  /// Serializes this Resistance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Resistance&&(identical(other.ohms, ohms) || other.ohms == ohms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ohms);

@override
String toString() {
  return 'Resistance(ohms: $ohms)';
}


}

/// @nodoc
abstract mixin class $ResistanceCopyWith<$Res>  {
  factory $ResistanceCopyWith(Resistance value, $Res Function(Resistance) _then) = _$ResistanceCopyWithImpl;
@useResult
$Res call({
 double ohms
});




}
/// @nodoc
class _$ResistanceCopyWithImpl<$Res>
    implements $ResistanceCopyWith<$Res> {
  _$ResistanceCopyWithImpl(this._self, this._then);

  final Resistance _self;
  final $Res Function(Resistance) _then;

/// Create a copy of Resistance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ohms = null,}) {
  return _then(_self.copyWith(
ohms: null == ohms ? _self.ohms : ohms // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Resistance].
extension ResistancePatterns on Resistance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Resistance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Resistance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Resistance value)  $default,){
final _that = this;
switch (_that) {
case _Resistance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Resistance value)?  $default,){
final _that = this;
switch (_that) {
case _Resistance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double ohms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Resistance() when $default != null:
return $default(_that.ohms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double ohms)  $default,) {final _that = this;
switch (_that) {
case _Resistance():
return $default(_that.ohms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double ohms)?  $default,) {final _that = this;
switch (_that) {
case _Resistance() when $default != null:
return $default(_that.ohms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Resistance extends Resistance {
  const _Resistance({required this.ohms}): super._();
  factory _Resistance.fromJson(Map<String, dynamic> json) => _$ResistanceFromJson(json);

@override final  double ohms;

/// Create a copy of Resistance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResistanceCopyWith<_Resistance> get copyWith => __$ResistanceCopyWithImpl<_Resistance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResistanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resistance&&(identical(other.ohms, ohms) || other.ohms == ohms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ohms);

@override
String toString() {
  return 'Resistance(ohms: $ohms)';
}


}

/// @nodoc
abstract mixin class _$ResistanceCopyWith<$Res> implements $ResistanceCopyWith<$Res> {
  factory _$ResistanceCopyWith(_Resistance value, $Res Function(_Resistance) _then) = __$ResistanceCopyWithImpl;
@override @useResult
$Res call({
 double ohms
});




}
/// @nodoc
class __$ResistanceCopyWithImpl<$Res>
    implements _$ResistanceCopyWith<$Res> {
  __$ResistanceCopyWithImpl(this._self, this._then);

  final _Resistance _self;
  final $Res Function(_Resistance) _then;

/// Create a copy of Resistance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ohms = null,}) {
  return _then(_Resistance(
ohms: null == ohms ? _self.ohms : ohms // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Voltage {

 double get volts;
/// Create a copy of Voltage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoltageCopyWith<Voltage> get copyWith => _$VoltageCopyWithImpl<Voltage>(this as Voltage, _$identity);

  /// Serializes this Voltage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Voltage&&(identical(other.volts, volts) || other.volts == volts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,volts);

@override
String toString() {
  return 'Voltage(volts: $volts)';
}


}

/// @nodoc
abstract mixin class $VoltageCopyWith<$Res>  {
  factory $VoltageCopyWith(Voltage value, $Res Function(Voltage) _then) = _$VoltageCopyWithImpl;
@useResult
$Res call({
 double volts
});




}
/// @nodoc
class _$VoltageCopyWithImpl<$Res>
    implements $VoltageCopyWith<$Res> {
  _$VoltageCopyWithImpl(this._self, this._then);

  final Voltage _self;
  final $Res Function(Voltage) _then;

/// Create a copy of Voltage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? volts = null,}) {
  return _then(_self.copyWith(
volts: null == volts ? _self.volts : volts // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Voltage].
extension VoltagePatterns on Voltage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Voltage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Voltage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Voltage value)  $default,){
final _that = this;
switch (_that) {
case _Voltage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Voltage value)?  $default,){
final _that = this;
switch (_that) {
case _Voltage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double volts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Voltage() when $default != null:
return $default(_that.volts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double volts)  $default,) {final _that = this;
switch (_that) {
case _Voltage():
return $default(_that.volts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double volts)?  $default,) {final _that = this;
switch (_that) {
case _Voltage() when $default != null:
return $default(_that.volts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Voltage extends Voltage {
  const _Voltage({required this.volts}): super._();
  factory _Voltage.fromJson(Map<String, dynamic> json) => _$VoltageFromJson(json);

@override final  double volts;

/// Create a copy of Voltage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoltageCopyWith<_Voltage> get copyWith => __$VoltageCopyWithImpl<_Voltage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoltageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Voltage&&(identical(other.volts, volts) || other.volts == volts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,volts);

@override
String toString() {
  return 'Voltage(volts: $volts)';
}


}

/// @nodoc
abstract mixin class _$VoltageCopyWith<$Res> implements $VoltageCopyWith<$Res> {
  factory _$VoltageCopyWith(_Voltage value, $Res Function(_Voltage) _then) = __$VoltageCopyWithImpl;
@override @useResult
$Res call({
 double volts
});




}
/// @nodoc
class __$VoltageCopyWithImpl<$Res>
    implements _$VoltageCopyWith<$Res> {
  __$VoltageCopyWithImpl(this._self, this._then);

  final _Voltage _self;
  final $Res Function(_Voltage) _then;

/// Create a copy of Voltage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? volts = null,}) {
  return _then(_Voltage(
volts: null == volts ? _self.volts : volts // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Current {

 double get a;
/// Create a copy of Current
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentCopyWith<Current> get copyWith => _$CurrentCopyWithImpl<Current>(this as Current, _$identity);

  /// Serializes this Current to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Current&&(identical(other.a, a) || other.a == a));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,a);

@override
String toString() {
  return 'Current(a: $a)';
}


}

/// @nodoc
abstract mixin class $CurrentCopyWith<$Res>  {
  factory $CurrentCopyWith(Current value, $Res Function(Current) _then) = _$CurrentCopyWithImpl;
@useResult
$Res call({
 double a
});




}
/// @nodoc
class _$CurrentCopyWithImpl<$Res>
    implements $CurrentCopyWith<$Res> {
  _$CurrentCopyWithImpl(this._self, this._then);

  final Current _self;
  final $Res Function(Current) _then;

/// Create a copy of Current
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = null,}) {
  return _then(_self.copyWith(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Current].
extension CurrentPatterns on Current {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Current value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Current() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Current value)  $default,){
final _that = this;
switch (_that) {
case _Current():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Current value)?  $default,){
final _that = this;
switch (_that) {
case _Current() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double a)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Current() when $default != null:
return $default(_that.a);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double a)  $default,) {final _that = this;
switch (_that) {
case _Current():
return $default(_that.a);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double a)?  $default,) {final _that = this;
switch (_that) {
case _Current() when $default != null:
return $default(_that.a);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Current extends Current {
  const _Current({required this.a}): super._();
  factory _Current.fromJson(Map<String, dynamic> json) => _$CurrentFromJson(json);

@override final  double a;

/// Create a copy of Current
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentCopyWith<_Current> get copyWith => __$CurrentCopyWithImpl<_Current>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Current&&(identical(other.a, a) || other.a == a));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,a);

@override
String toString() {
  return 'Current(a: $a)';
}


}

/// @nodoc
abstract mixin class _$CurrentCopyWith<$Res> implements $CurrentCopyWith<$Res> {
  factory _$CurrentCopyWith(_Current value, $Res Function(_Current) _then) = __$CurrentCopyWithImpl;
@override @useResult
$Res call({
 double a
});




}
/// @nodoc
class __$CurrentCopyWithImpl<$Res>
    implements _$CurrentCopyWith<$Res> {
  __$CurrentCopyWithImpl(this._self, this._then);

  final _Current _self;
  final $Res Function(_Current) _then;

/// Create a copy of Current
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = null,}) {
  return _then(_Current(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
