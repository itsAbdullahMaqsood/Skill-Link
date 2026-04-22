// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anomaly.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Anomaly {

 String get id; String get applianceId; String get type; String get severity; DateTime get detectedAt; bool get read; String? get message; String? get applianceName; String? get suggestedTrade;
/// Create a copy of Anomaly
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnomalyCopyWith<Anomaly> get copyWith => _$AnomalyCopyWithImpl<Anomaly>(this as Anomaly, _$identity);

  /// Serializes this Anomaly to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Anomaly&&(identical(other.id, id) || other.id == id)&&(identical(other.applianceId, applianceId) || other.applianceId == applianceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.read, read) || other.read == read)&&(identical(other.message, message) || other.message == message)&&(identical(other.applianceName, applianceName) || other.applianceName == applianceName)&&(identical(other.suggestedTrade, suggestedTrade) || other.suggestedTrade == suggestedTrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applianceId,type,severity,detectedAt,read,message,applianceName,suggestedTrade);

@override
String toString() {
  return 'Anomaly(id: $id, applianceId: $applianceId, type: $type, severity: $severity, detectedAt: $detectedAt, read: $read, message: $message, applianceName: $applianceName, suggestedTrade: $suggestedTrade)';
}


}

/// @nodoc
abstract mixin class $AnomalyCopyWith<$Res>  {
  factory $AnomalyCopyWith(Anomaly value, $Res Function(Anomaly) _then) = _$AnomalyCopyWithImpl;
@useResult
$Res call({
 String id, String applianceId, String type, String severity, DateTime detectedAt, bool read, String? message, String? applianceName, String? suggestedTrade
});




}
/// @nodoc
class _$AnomalyCopyWithImpl<$Res>
    implements $AnomalyCopyWith<$Res> {
  _$AnomalyCopyWithImpl(this._self, this._then);

  final Anomaly _self;
  final $Res Function(Anomaly) _then;

/// Create a copy of Anomaly
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applianceId = null,Object? type = null,Object? severity = null,Object? detectedAt = null,Object? read = null,Object? message = freezed,Object? applianceName = freezed,Object? suggestedTrade = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applianceId: null == applianceId ? _self.applianceId : applianceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,applianceName: freezed == applianceName ? _self.applianceName : applianceName // ignore: cast_nullable_to_non_nullable
as String?,suggestedTrade: freezed == suggestedTrade ? _self.suggestedTrade : suggestedTrade // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Anomaly].
extension AnomalyPatterns on Anomaly {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Anomaly value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Anomaly() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Anomaly value)  $default,){
final _that = this;
switch (_that) {
case _Anomaly():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Anomaly value)?  $default,){
final _that = this;
switch (_that) {
case _Anomaly() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applianceId,  String type,  String severity,  DateTime detectedAt,  bool read,  String? message,  String? applianceName,  String? suggestedTrade)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Anomaly() when $default != null:
return $default(_that.id,_that.applianceId,_that.type,_that.severity,_that.detectedAt,_that.read,_that.message,_that.applianceName,_that.suggestedTrade);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applianceId,  String type,  String severity,  DateTime detectedAt,  bool read,  String? message,  String? applianceName,  String? suggestedTrade)  $default,) {final _that = this;
switch (_that) {
case _Anomaly():
return $default(_that.id,_that.applianceId,_that.type,_that.severity,_that.detectedAt,_that.read,_that.message,_that.applianceName,_that.suggestedTrade);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applianceId,  String type,  String severity,  DateTime detectedAt,  bool read,  String? message,  String? applianceName,  String? suggestedTrade)?  $default,) {final _that = this;
switch (_that) {
case _Anomaly() when $default != null:
return $default(_that.id,_that.applianceId,_that.type,_that.severity,_that.detectedAt,_that.read,_that.message,_that.applianceName,_that.suggestedTrade);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Anomaly implements Anomaly {
  const _Anomaly({required this.id, required this.applianceId, required this.type, required this.severity, required this.detectedAt, this.read = false, this.message, this.applianceName, this.suggestedTrade});
  factory _Anomaly.fromJson(Map<String, dynamic> json) => _$AnomalyFromJson(json);

@override final  String id;
@override final  String applianceId;
@override final  String type;
@override final  String severity;
@override final  DateTime detectedAt;
@override@JsonKey() final  bool read;
@override final  String? message;
@override final  String? applianceName;
@override final  String? suggestedTrade;

/// Create a copy of Anomaly
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnomalyCopyWith<_Anomaly> get copyWith => __$AnomalyCopyWithImpl<_Anomaly>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnomalyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Anomaly&&(identical(other.id, id) || other.id == id)&&(identical(other.applianceId, applianceId) || other.applianceId == applianceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.read, read) || other.read == read)&&(identical(other.message, message) || other.message == message)&&(identical(other.applianceName, applianceName) || other.applianceName == applianceName)&&(identical(other.suggestedTrade, suggestedTrade) || other.suggestedTrade == suggestedTrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applianceId,type,severity,detectedAt,read,message,applianceName,suggestedTrade);

@override
String toString() {
  return 'Anomaly(id: $id, applianceId: $applianceId, type: $type, severity: $severity, detectedAt: $detectedAt, read: $read, message: $message, applianceName: $applianceName, suggestedTrade: $suggestedTrade)';
}


}

/// @nodoc
abstract mixin class _$AnomalyCopyWith<$Res> implements $AnomalyCopyWith<$Res> {
  factory _$AnomalyCopyWith(_Anomaly value, $Res Function(_Anomaly) _then) = __$AnomalyCopyWithImpl;
@override @useResult
$Res call({
 String id, String applianceId, String type, String severity, DateTime detectedAt, bool read, String? message, String? applianceName, String? suggestedTrade
});




}
/// @nodoc
class __$AnomalyCopyWithImpl<$Res>
    implements _$AnomalyCopyWith<$Res> {
  __$AnomalyCopyWithImpl(this._self, this._then);

  final _Anomaly _self;
  final $Res Function(_Anomaly) _then;

/// Create a copy of Anomaly
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applianceId = null,Object? type = null,Object? severity = null,Object? detectedAt = null,Object? read = null,Object? message = freezed,Object? applianceName = freezed,Object? suggestedTrade = freezed,}) {
  return _then(_Anomaly(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applianceId: null == applianceId ? _self.applianceId : applianceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,applianceName: freezed == applianceName ? _self.applianceName : applianceName // ignore: cast_nullable_to_non_nullable
as String?,suggestedTrade: freezed == suggestedTrade ? _self.suggestedTrade : suggestedTrade // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
