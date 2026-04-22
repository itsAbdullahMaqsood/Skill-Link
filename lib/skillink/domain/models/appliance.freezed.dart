// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appliance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Appliance {

 String get id; String get userId; String get type; String get brand; String get model; String? get iotDeviceId;
/// Create a copy of Appliance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplianceCopyWith<Appliance> get copyWith => _$ApplianceCopyWithImpl<Appliance>(this as Appliance, _$identity);

  /// Serializes this Appliance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appliance&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.iotDeviceId, iotDeviceId) || other.iotDeviceId == iotDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,brand,model,iotDeviceId);

@override
String toString() {
  return 'Appliance(id: $id, userId: $userId, type: $type, brand: $brand, model: $model, iotDeviceId: $iotDeviceId)';
}


}

/// @nodoc
abstract mixin class $ApplianceCopyWith<$Res>  {
  factory $ApplianceCopyWith(Appliance value, $Res Function(Appliance) _then) = _$ApplianceCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String type, String brand, String model, String? iotDeviceId
});




}
/// @nodoc
class _$ApplianceCopyWithImpl<$Res>
    implements $ApplianceCopyWith<$Res> {
  _$ApplianceCopyWithImpl(this._self, this._then);

  final Appliance _self;
  final $Res Function(Appliance) _then;

/// Create a copy of Appliance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? brand = null,Object? model = null,Object? iotDeviceId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,iotDeviceId: freezed == iotDeviceId ? _self.iotDeviceId : iotDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appliance].
extension AppliancePatterns on Appliance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appliance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appliance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appliance value)  $default,){
final _that = this;
switch (_that) {
case _Appliance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appliance value)?  $default,){
final _that = this;
switch (_that) {
case _Appliance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  String brand,  String model,  String? iotDeviceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appliance() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.brand,_that.model,_that.iotDeviceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  String brand,  String model,  String? iotDeviceId)  $default,) {final _that = this;
switch (_that) {
case _Appliance():
return $default(_that.id,_that.userId,_that.type,_that.brand,_that.model,_that.iotDeviceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String type,  String brand,  String model,  String? iotDeviceId)?  $default,) {final _that = this;
switch (_that) {
case _Appliance() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.brand,_that.model,_that.iotDeviceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Appliance implements Appliance {
  const _Appliance({required this.id, required this.userId, required this.type, required this.brand, required this.model, this.iotDeviceId});
  factory _Appliance.fromJson(Map<String, dynamic> json) => _$ApplianceFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
@override final  String brand;
@override final  String model;
@override final  String? iotDeviceId;

/// Create a copy of Appliance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplianceCopyWith<_Appliance> get copyWith => __$ApplianceCopyWithImpl<_Appliance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplianceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appliance&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.iotDeviceId, iotDeviceId) || other.iotDeviceId == iotDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,brand,model,iotDeviceId);

@override
String toString() {
  return 'Appliance(id: $id, userId: $userId, type: $type, brand: $brand, model: $model, iotDeviceId: $iotDeviceId)';
}


}

/// @nodoc
abstract mixin class _$ApplianceCopyWith<$Res> implements $ApplianceCopyWith<$Res> {
  factory _$ApplianceCopyWith(_Appliance value, $Res Function(_Appliance) _then) = __$ApplianceCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, String brand, String model, String? iotDeviceId
});




}
/// @nodoc
class __$ApplianceCopyWithImpl<$Res>
    implements _$ApplianceCopyWith<$Res> {
  __$ApplianceCopyWithImpl(this._self, this._then);

  final _Appliance _self;
  final $Res Function(_Appliance) _then;

/// Create a copy of Appliance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? brand = null,Object? model = null,Object? iotDeviceId = freezed,}) {
  return _then(_Appliance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,iotDeviceId: freezed == iotDeviceId ? _self.iotDeviceId : iotDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
