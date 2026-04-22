// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SensorReading {

 double get voltage; double get current; double get wattage; DateTime get timestamp;
/// Create a copy of SensorReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorReadingCopyWith<SensorReading> get copyWith => _$SensorReadingCopyWithImpl<SensorReading>(this as SensorReading, _$identity);

  /// Serializes this SensorReading to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorReading&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.wattage, wattage) || other.wattage == wattage)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voltage,current,wattage,timestamp);

@override
String toString() {
  return 'SensorReading(voltage: $voltage, current: $current, wattage: $wattage, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SensorReadingCopyWith<$Res>  {
  factory $SensorReadingCopyWith(SensorReading value, $Res Function(SensorReading) _then) = _$SensorReadingCopyWithImpl;
@useResult
$Res call({
 double voltage, double current, double wattage, DateTime timestamp
});




}
/// @nodoc
class _$SensorReadingCopyWithImpl<$Res>
    implements $SensorReadingCopyWith<$Res> {
  _$SensorReadingCopyWithImpl(this._self, this._then);

  final SensorReading _self;
  final $Res Function(SensorReading) _then;

/// Create a copy of SensorReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voltage = null,Object? current = null,Object? wattage = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,wattage: null == wattage ? _self.wattage : wattage // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorReading].
extension SensorReadingPatterns on SensorReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorReading value)  $default,){
final _that = this;
switch (_that) {
case _SensorReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorReading value)?  $default,){
final _that = this;
switch (_that) {
case _SensorReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double voltage,  double current,  double wattage,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorReading() when $default != null:
return $default(_that.voltage,_that.current,_that.wattage,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double voltage,  double current,  double wattage,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _SensorReading():
return $default(_that.voltage,_that.current,_that.wattage,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double voltage,  double current,  double wattage,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SensorReading() when $default != null:
return $default(_that.voltage,_that.current,_that.wattage,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SensorReading implements SensorReading {
  const _SensorReading({required this.voltage, required this.current, required this.wattage, required this.timestamp});
  factory _SensorReading.fromJson(Map<String, dynamic> json) => _$SensorReadingFromJson(json);

@override final  double voltage;
@override final  double current;
@override final  double wattage;
@override final  DateTime timestamp;

/// Create a copy of SensorReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorReadingCopyWith<_SensorReading> get copyWith => __$SensorReadingCopyWithImpl<_SensorReading>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SensorReadingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorReading&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.wattage, wattage) || other.wattage == wattage)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voltage,current,wattage,timestamp);

@override
String toString() {
  return 'SensorReading(voltage: $voltage, current: $current, wattage: $wattage, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SensorReadingCopyWith<$Res> implements $SensorReadingCopyWith<$Res> {
  factory _$SensorReadingCopyWith(_SensorReading value, $Res Function(_SensorReading) _then) = __$SensorReadingCopyWithImpl;
@override @useResult
$Res call({
 double voltage, double current, double wattage, DateTime timestamp
});




}
/// @nodoc
class __$SensorReadingCopyWithImpl<$Res>
    implements _$SensorReadingCopyWith<$Res> {
  __$SensorReadingCopyWithImpl(this._self, this._then);

  final _SensorReading _self;
  final $Res Function(_SensorReading) _then;

/// Create a copy of SensorReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voltage = null,Object? current = null,Object? wattage = null,Object? timestamp = null,}) {
  return _then(_SensorReading(
voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,wattage: null == wattage ? _self.wattage : wattage // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
