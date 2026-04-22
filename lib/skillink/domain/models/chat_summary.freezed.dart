// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatSummary {

 String get chatId; String get peerId; String get peerName; String? get peerAvatar; UserRole get peerRole;/// Last message preview text (or "[Image]" / "[Voice note]") shown in the
/// inbox row. Nullable until the first message is sent.
 String? get lastMessagePreview; ChatMessageType? get lastMessageType; DateTime? get lastMessageAt; int get unreadCount;
/// Create a copy of ChatSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSummaryCopyWith<ChatSummary> get copyWith => _$ChatSummaryCopyWithImpl<ChatSummary>(this as ChatSummary, _$identity);

  /// Serializes this ChatSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSummary&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.peerId, peerId) || other.peerId == peerId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.peerAvatar, peerAvatar) || other.peerAvatar == peerAvatar)&&(identical(other.peerRole, peerRole) || other.peerRole == peerRole)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chatId,peerId,peerName,peerAvatar,peerRole,lastMessagePreview,lastMessageType,lastMessageAt,unreadCount);

@override
String toString() {
  return 'ChatSummary(chatId: $chatId, peerId: $peerId, peerName: $peerName, peerAvatar: $peerAvatar, peerRole: $peerRole, lastMessagePreview: $lastMessagePreview, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ChatSummaryCopyWith<$Res>  {
  factory $ChatSummaryCopyWith(ChatSummary value, $Res Function(ChatSummary) _then) = _$ChatSummaryCopyWithImpl;
@useResult
$Res call({
 String chatId, String peerId, String peerName, String? peerAvatar, UserRole peerRole, String? lastMessagePreview, ChatMessageType? lastMessageType, DateTime? lastMessageAt, int unreadCount
});




}
/// @nodoc
class _$ChatSummaryCopyWithImpl<$Res>
    implements $ChatSummaryCopyWith<$Res> {
  _$ChatSummaryCopyWithImpl(this._self, this._then);

  final ChatSummary _self;
  final $Res Function(ChatSummary) _then;

/// Create a copy of ChatSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatId = null,Object? peerId = null,Object? peerName = null,Object? peerAvatar = freezed,Object? peerRole = null,Object? lastMessagePreview = freezed,Object? lastMessageType = freezed,Object? lastMessageAt = freezed,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,peerId: null == peerId ? _self.peerId : peerId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,peerAvatar: freezed == peerAvatar ? _self.peerAvatar : peerAvatar // ignore: cast_nullable_to_non_nullable
as String?,peerRole: null == peerRole ? _self.peerRole : peerRole // ignore: cast_nullable_to_non_nullable
as UserRole,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: freezed == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSummary].
extension ChatSummaryPatterns on ChatSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSummary value)  $default,){
final _that = this;
switch (_that) {
case _ChatSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chatId,  String peerId,  String peerName,  String? peerAvatar,  UserRole peerRole,  String? lastMessagePreview,  ChatMessageType? lastMessageType,  DateTime? lastMessageAt,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSummary() when $default != null:
return $default(_that.chatId,_that.peerId,_that.peerName,_that.peerAvatar,_that.peerRole,_that.lastMessagePreview,_that.lastMessageType,_that.lastMessageAt,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chatId,  String peerId,  String peerName,  String? peerAvatar,  UserRole peerRole,  String? lastMessagePreview,  ChatMessageType? lastMessageType,  DateTime? lastMessageAt,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _ChatSummary():
return $default(_that.chatId,_that.peerId,_that.peerName,_that.peerAvatar,_that.peerRole,_that.lastMessagePreview,_that.lastMessageType,_that.lastMessageAt,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chatId,  String peerId,  String peerName,  String? peerAvatar,  UserRole peerRole,  String? lastMessagePreview,  ChatMessageType? lastMessageType,  DateTime? lastMessageAt,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatSummary() when $default != null:
return $default(_that.chatId,_that.peerId,_that.peerName,_that.peerAvatar,_that.peerRole,_that.lastMessagePreview,_that.lastMessageType,_that.lastMessageAt,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatSummary implements ChatSummary {
  const _ChatSummary({required this.chatId, required this.peerId, required this.peerName, this.peerAvatar, required this.peerRole, this.lastMessagePreview, this.lastMessageType, this.lastMessageAt, this.unreadCount = 0});
  factory _ChatSummary.fromJson(Map<String, dynamic> json) => _$ChatSummaryFromJson(json);

@override final  String chatId;
@override final  String peerId;
@override final  String peerName;
@override final  String? peerAvatar;
@override final  UserRole peerRole;
/// Last message preview text (or "[Image]" / "[Voice note]") shown in the
/// inbox row. Nullable until the first message is sent.
@override final  String? lastMessagePreview;
@override final  ChatMessageType? lastMessageType;
@override final  DateTime? lastMessageAt;
@override@JsonKey() final  int unreadCount;

/// Create a copy of ChatSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSummaryCopyWith<_ChatSummary> get copyWith => __$ChatSummaryCopyWithImpl<_ChatSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSummary&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.peerId, peerId) || other.peerId == peerId)&&(identical(other.peerName, peerName) || other.peerName == peerName)&&(identical(other.peerAvatar, peerAvatar) || other.peerAvatar == peerAvatar)&&(identical(other.peerRole, peerRole) || other.peerRole == peerRole)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chatId,peerId,peerName,peerAvatar,peerRole,lastMessagePreview,lastMessageType,lastMessageAt,unreadCount);

@override
String toString() {
  return 'ChatSummary(chatId: $chatId, peerId: $peerId, peerName: $peerName, peerAvatar: $peerAvatar, peerRole: $peerRole, lastMessagePreview: $lastMessagePreview, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ChatSummaryCopyWith<$Res> implements $ChatSummaryCopyWith<$Res> {
  factory _$ChatSummaryCopyWith(_ChatSummary value, $Res Function(_ChatSummary) _then) = __$ChatSummaryCopyWithImpl;
@override @useResult
$Res call({
 String chatId, String peerId, String peerName, String? peerAvatar, UserRole peerRole, String? lastMessagePreview, ChatMessageType? lastMessageType, DateTime? lastMessageAt, int unreadCount
});




}
/// @nodoc
class __$ChatSummaryCopyWithImpl<$Res>
    implements _$ChatSummaryCopyWith<$Res> {
  __$ChatSummaryCopyWithImpl(this._self, this._then);

  final _ChatSummary _self;
  final $Res Function(_ChatSummary) _then;

/// Create a copy of ChatSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatId = null,Object? peerId = null,Object? peerName = null,Object? peerAvatar = freezed,Object? peerRole = null,Object? lastMessagePreview = freezed,Object? lastMessageType = freezed,Object? lastMessageAt = freezed,Object? unreadCount = null,}) {
  return _then(_ChatSummary(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,peerId: null == peerId ? _self.peerId : peerId // ignore: cast_nullable_to_non_nullable
as String,peerName: null == peerName ? _self.peerName : peerName // ignore: cast_nullable_to_non_nullable
as String,peerAvatar: freezed == peerAvatar ? _self.peerAvatar : peerAvatar // ignore: cast_nullable_to_non_nullable
as String?,peerRole: null == peerRole ? _self.peerRole : peerRole // ignore: cast_nullable_to_non_nullable
as UserRole,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: freezed == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
