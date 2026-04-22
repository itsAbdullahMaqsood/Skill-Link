// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'structured_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StructuredAddress {

 String get street; String get area; String get city; String get postalCode;
/// Create a copy of StructuredAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StructuredAddressCopyWith<StructuredAddress> get copyWith => _$StructuredAddressCopyWithImpl<StructuredAddress>(this as StructuredAddress, _$identity);

  /// Serializes this StructuredAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StructuredAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.area, area) || other.area == area)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,area,city,postalCode);

@override
String toString() {
  return 'StructuredAddress(street: $street, area: $area, city: $city, postalCode: $postalCode)';
}


}

/// @nodoc
abstract mixin class $StructuredAddressCopyWith<$Res>  {
  factory $StructuredAddressCopyWith(StructuredAddress value, $Res Function(StructuredAddress) _then) = _$StructuredAddressCopyWithImpl;
@useResult
$Res call({
 String street, String area, String city, String postalCode
});




}
/// @nodoc
class _$StructuredAddressCopyWithImpl<$Res>
    implements $StructuredAddressCopyWith<$Res> {
  _$StructuredAddressCopyWithImpl(this._self, this._then);

  final StructuredAddress _self;
  final $Res Function(StructuredAddress) _then;

/// Create a copy of StructuredAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? area = null,Object? city = null,Object? postalCode = null,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StructuredAddress].
extension StructuredAddressPatterns on StructuredAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StructuredAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StructuredAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StructuredAddress value)  $default,){
final _that = this;
switch (_that) {
case _StructuredAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StructuredAddress value)?  $default,){
final _that = this;
switch (_that) {
case _StructuredAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String area,  String city,  String postalCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StructuredAddress() when $default != null:
return $default(_that.street,_that.area,_that.city,_that.postalCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String area,  String city,  String postalCode)  $default,) {final _that = this;
switch (_that) {
case _StructuredAddress():
return $default(_that.street,_that.area,_that.city,_that.postalCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String area,  String city,  String postalCode)?  $default,) {final _that = this;
switch (_that) {
case _StructuredAddress() when $default != null:
return $default(_that.street,_that.area,_that.city,_that.postalCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StructuredAddress implements StructuredAddress {
  const _StructuredAddress({required this.street, required this.area, required this.city, required this.postalCode});
  factory _StructuredAddress.fromJson(Map<String, dynamic> json) => _$StructuredAddressFromJson(json);

@override final  String street;
@override final  String area;
@override final  String city;
@override final  String postalCode;

/// Create a copy of StructuredAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StructuredAddressCopyWith<_StructuredAddress> get copyWith => __$StructuredAddressCopyWithImpl<_StructuredAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StructuredAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StructuredAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.area, area) || other.area == area)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,area,city,postalCode);

@override
String toString() {
  return 'StructuredAddress(street: $street, area: $area, city: $city, postalCode: $postalCode)';
}


}

/// @nodoc
abstract mixin class _$StructuredAddressCopyWith<$Res> implements $StructuredAddressCopyWith<$Res> {
  factory _$StructuredAddressCopyWith(_StructuredAddress value, $Res Function(_StructuredAddress) _then) = __$StructuredAddressCopyWithImpl;
@override @useResult
$Res call({
 String street, String area, String city, String postalCode
});




}
/// @nodoc
class __$StructuredAddressCopyWithImpl<$Res>
    implements _$StructuredAddressCopyWith<$Res> {
  __$StructuredAddressCopyWithImpl(this._self, this._then);

  final _StructuredAddress _self;
  final $Res Function(_StructuredAddress) _then;

/// Create a copy of StructuredAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? area = null,Object? city = null,Object? postalCode = null,}) {
  return _then(_StructuredAddress(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
