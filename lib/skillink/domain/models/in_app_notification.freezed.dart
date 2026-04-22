// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InAppNotification {

 String get id; String get title; String get body; InAppNotificationType get type;/// Job id, anomaly id, or empty for system.
 String get targetId; DateTime get createdAt; bool get read;
/// Create a copy of InAppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InAppNotificationCopyWith<InAppNotification> get copyWith => _$InAppNotificationCopyWithImpl<InAppNotification>(this as InAppNotification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InAppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.read, read) || other.read == read));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,targetId,createdAt,read);

@override
String toString() {
  return 'InAppNotification(id: $id, title: $title, body: $body, type: $type, targetId: $targetId, createdAt: $createdAt, read: $read)';
}


}

/// @nodoc
abstract mixin class $InAppNotificationCopyWith<$Res>  {
  factory $InAppNotificationCopyWith(InAppNotification value, $Res Function(InAppNotification) _then) = _$InAppNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, InAppNotificationType type, String targetId, DateTime createdAt, bool read
});




}
/// @nodoc
class _$InAppNotificationCopyWithImpl<$Res>
    implements $InAppNotificationCopyWith<$Res> {
  _$InAppNotificationCopyWithImpl(this._self, this._then);

  final InAppNotification _self;
  final $Res Function(InAppNotification) _then;

/// Create a copy of InAppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? targetId = null,Object? createdAt = null,Object? read = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InAppNotificationType,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InAppNotification].
extension InAppNotificationPatterns on InAppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InAppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InAppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InAppNotification value)  $default,){
final _that = this;
switch (_that) {
case _InAppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InAppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _InAppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  InAppNotificationType type,  String targetId,  DateTime createdAt,  bool read)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InAppNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetId,_that.createdAt,_that.read);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  InAppNotificationType type,  String targetId,  DateTime createdAt,  bool read)  $default,) {final _that = this;
switch (_that) {
case _InAppNotification():
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetId,_that.createdAt,_that.read);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  InAppNotificationType type,  String targetId,  DateTime createdAt,  bool read)?  $default,) {final _that = this;
switch (_that) {
case _InAppNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.targetId,_that.createdAt,_that.read);case _:
  return null;

}
}

}

/// @nodoc


class _InAppNotification implements InAppNotification {
  const _InAppNotification({required this.id, required this.title, required this.body, required this.type, required this.targetId, required this.createdAt, this.read = false});
  

@override final  String id;
@override final  String title;
@override final  String body;
@override final  InAppNotificationType type;
/// Job id, anomaly id, or empty for system.
@override final  String targetId;
@override final  DateTime createdAt;
@override@JsonKey() final  bool read;

/// Create a copy of InAppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InAppNotificationCopyWith<_InAppNotification> get copyWith => __$InAppNotificationCopyWithImpl<_InAppNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InAppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.read, read) || other.read == read));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,targetId,createdAt,read);

@override
String toString() {
  return 'InAppNotification(id: $id, title: $title, body: $body, type: $type, targetId: $targetId, createdAt: $createdAt, read: $read)';
}


}

/// @nodoc
abstract mixin class _$InAppNotificationCopyWith<$Res> implements $InAppNotificationCopyWith<$Res> {
  factory _$InAppNotificationCopyWith(_InAppNotification value, $Res Function(_InAppNotification) _then) = __$InAppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, InAppNotificationType type, String targetId, DateTime createdAt, bool read
});




}
/// @nodoc
class __$InAppNotificationCopyWithImpl<$Res>
    implements _$InAppNotificationCopyWith<$Res> {
  __$InAppNotificationCopyWithImpl(this._self, this._then);

  final _InAppNotification _self;
  final $Res Function(_InAppNotification) _then;

/// Create a copy of InAppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? targetId = null,Object? createdAt = null,Object? read = null,}) {
  return _then(_InAppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InAppNotificationType,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
