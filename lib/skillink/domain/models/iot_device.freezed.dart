// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IotDevice {

 String get id; String get applianceId; String get status; DateTime? get lastSeen;
/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotDeviceCopyWith<IotDevice> get copyWith => _$IotDeviceCopyWithImpl<IotDevice>(this as IotDevice, _$identity);

  /// Serializes this IotDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.applianceId, applianceId) || other.applianceId == applianceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applianceId,status,lastSeen);

@override
String toString() {
  return 'IotDevice(id: $id, applianceId: $applianceId, status: $status, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class $IotDeviceCopyWith<$Res>  {
  factory $IotDeviceCopyWith(IotDevice value, $Res Function(IotDevice) _then) = _$IotDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String applianceId, String status, DateTime? lastSeen
});




}
/// @nodoc
class _$IotDeviceCopyWithImpl<$Res>
    implements $IotDeviceCopyWith<$Res> {
  _$IotDeviceCopyWithImpl(this._self, this._then);

  final IotDevice _self;
  final $Res Function(IotDevice) _then;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applianceId = null,Object? status = null,Object? lastSeen = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applianceId: null == applianceId ? _self.applianceId : applianceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IotDevice].
extension IotDevicePatterns on IotDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IotDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IotDevice value)  $default,){
final _that = this;
switch (_that) {
case _IotDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IotDevice value)?  $default,){
final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applianceId,  String status,  DateTime? lastSeen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
return $default(_that.id,_that.applianceId,_that.status,_that.lastSeen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applianceId,  String status,  DateTime? lastSeen)  $default,) {final _that = this;
switch (_that) {
case _IotDevice():
return $default(_that.id,_that.applianceId,_that.status,_that.lastSeen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applianceId,  String status,  DateTime? lastSeen)?  $default,) {final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
return $default(_that.id,_that.applianceId,_that.status,_that.lastSeen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IotDevice implements IotDevice {
  const _IotDevice({required this.id, required this.applianceId, required this.status, this.lastSeen});
  factory _IotDevice.fromJson(Map<String, dynamic> json) => _$IotDeviceFromJson(json);

@override final  String id;
@override final  String applianceId;
@override final  String status;
@override final  DateTime? lastSeen;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IotDeviceCopyWith<_IotDevice> get copyWith => __$IotDeviceCopyWithImpl<_IotDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IotDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.applianceId, applianceId) || other.applianceId == applianceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applianceId,status,lastSeen);

@override
String toString() {
  return 'IotDevice(id: $id, applianceId: $applianceId, status: $status, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class _$IotDeviceCopyWith<$Res> implements $IotDeviceCopyWith<$Res> {
  factory _$IotDeviceCopyWith(_IotDevice value, $Res Function(_IotDevice) _then) = __$IotDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String applianceId, String status, DateTime? lastSeen
});




}
/// @nodoc
class __$IotDeviceCopyWithImpl<$Res>
    implements _$IotDeviceCopyWith<$Res> {
  __$IotDeviceCopyWithImpl(this._self, this._then);

  final _IotDevice _self;
  final $Res Function(_IotDevice) _then;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applianceId = null,Object? status = null,Object? lastSeen = freezed,}) {
  return _then(_IotDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applianceId: null == applianceId ? _self.applianceId : applianceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
