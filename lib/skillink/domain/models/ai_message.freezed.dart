// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiSource {

 String get title; String get url;
/// Create a copy of AiSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSourceCopyWith<AiSource> get copyWith => _$AiSourceCopyWithImpl<AiSource>(this as AiSource, _$identity);

  /// Serializes this AiSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSource&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,url);

@override
String toString() {
  return 'AiSource(title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class $AiSourceCopyWith<$Res>  {
  factory $AiSourceCopyWith(AiSource value, $Res Function(AiSource) _then) = _$AiSourceCopyWithImpl;
@useResult
$Res call({
 String title, String url
});




}
/// @nodoc
class _$AiSourceCopyWithImpl<$Res>
    implements $AiSourceCopyWith<$Res> {
  _$AiSourceCopyWithImpl(this._self, this._then);

  final AiSource _self;
  final $Res Function(AiSource) _then;

/// Create a copy of AiSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? url = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiSource].
extension AiSourcePatterns on AiSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiSource value)  $default,){
final _that = this;
switch (_that) {
case _AiSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiSource value)?  $default,){
final _that = this;
switch (_that) {
case _AiSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiSource() when $default != null:
return $default(_that.title,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String url)  $default,) {final _that = this;
switch (_that) {
case _AiSource():
return $default(_that.title,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String url)?  $default,) {final _that = this;
switch (_that) {
case _AiSource() when $default != null:
return $default(_that.title,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiSource implements AiSource {
  const _AiSource({required this.title, required this.url});
  factory _AiSource.fromJson(Map<String, dynamic> json) => _$AiSourceFromJson(json);

@override final  String title;
@override final  String url;

/// Create a copy of AiSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiSourceCopyWith<_AiSource> get copyWith => __$AiSourceCopyWithImpl<_AiSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiSource&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,url);

@override
String toString() {
  return 'AiSource(title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class _$AiSourceCopyWith<$Res> implements $AiSourceCopyWith<$Res> {
  factory _$AiSourceCopyWith(_AiSource value, $Res Function(_AiSource) _then) = __$AiSourceCopyWithImpl;
@override @useResult
$Res call({
 String title, String url
});




}
/// @nodoc
class __$AiSourceCopyWithImpl<$Res>
    implements _$AiSourceCopyWith<$Res> {
  __$AiSourceCopyWithImpl(this._self, this._then);

  final _AiSource _self;
  final $Res Function(_AiSource) _then;

/// Create a copy of AiSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? url = null,}) {
  return _then(_AiSource(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AiMessage {

 String get id; AiMessageRole get role; String get content; DateTime get createdAt; List<AiSource> get sources; Worker? get recommendedWorker; String? get suggestedTrade;
/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMessageCopyWith<AiMessage> get copyWith => _$AiMessageCopyWithImpl<AiMessage>(this as AiMessage, _$identity);

  /// Serializes this AiMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.recommendedWorker, recommendedWorker) || other.recommendedWorker == recommendedWorker)&&(identical(other.suggestedTrade, suggestedTrade) || other.suggestedTrade == suggestedTrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,content,createdAt,const DeepCollectionEquality().hash(sources),recommendedWorker,suggestedTrade);

@override
String toString() {
  return 'AiMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, sources: $sources, recommendedWorker: $recommendedWorker, suggestedTrade: $suggestedTrade)';
}


}

/// @nodoc
abstract mixin class $AiMessageCopyWith<$Res>  {
  factory $AiMessageCopyWith(AiMessage value, $Res Function(AiMessage) _then) = _$AiMessageCopyWithImpl;
@useResult
$Res call({
 String id, AiMessageRole role, String content, DateTime createdAt, List<AiSource> sources, Worker? recommendedWorker, String? suggestedTrade
});


$WorkerCopyWith<$Res>? get recommendedWorker;

}
/// @nodoc
class _$AiMessageCopyWithImpl<$Res>
    implements $AiMessageCopyWith<$Res> {
  _$AiMessageCopyWithImpl(this._self, this._then);

  final AiMessage _self;
  final $Res Function(AiMessage) _then;

/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? content = null,Object? createdAt = null,Object? sources = null,Object? recommendedWorker = freezed,Object? suggestedTrade = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AiMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<AiSource>,recommendedWorker: freezed == recommendedWorker ? _self.recommendedWorker : recommendedWorker // ignore: cast_nullable_to_non_nullable
as Worker?,suggestedTrade: freezed == suggestedTrade ? _self.suggestedTrade : suggestedTrade // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkerCopyWith<$Res>? get recommendedWorker {
    if (_self.recommendedWorker == null) {
    return null;
  }

  return $WorkerCopyWith<$Res>(_self.recommendedWorker!, (value) {
    return _then(_self.copyWith(recommendedWorker: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiMessage].
extension AiMessagePatterns on AiMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMessage value)  $default,){
final _that = this;
switch (_that) {
case _AiMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AiMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AiMessageRole role,  String content,  DateTime createdAt,  List<AiSource> sources,  Worker? recommendedWorker,  String? suggestedTrade)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMessage() when $default != null:
return $default(_that.id,_that.role,_that.content,_that.createdAt,_that.sources,_that.recommendedWorker,_that.suggestedTrade);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AiMessageRole role,  String content,  DateTime createdAt,  List<AiSource> sources,  Worker? recommendedWorker,  String? suggestedTrade)  $default,) {final _that = this;
switch (_that) {
case _AiMessage():
return $default(_that.id,_that.role,_that.content,_that.createdAt,_that.sources,_that.recommendedWorker,_that.suggestedTrade);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AiMessageRole role,  String content,  DateTime createdAt,  List<AiSource> sources,  Worker? recommendedWorker,  String? suggestedTrade)?  $default,) {final _that = this;
switch (_that) {
case _AiMessage() when $default != null:
return $default(_that.id,_that.role,_that.content,_that.createdAt,_that.sources,_that.recommendedWorker,_that.suggestedTrade);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiMessage implements AiMessage {
  const _AiMessage({required this.id, required this.role, required this.content, required this.createdAt, final  List<AiSource> sources = const [], this.recommendedWorker, this.suggestedTrade}): _sources = sources;
  factory _AiMessage.fromJson(Map<String, dynamic> json) => _$AiMessageFromJson(json);

@override final  String id;
@override final  AiMessageRole role;
@override final  String content;
@override final  DateTime createdAt;
 final  List<AiSource> _sources;
@override@JsonKey() List<AiSource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override final  Worker? recommendedWorker;
@override final  String? suggestedTrade;

/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMessageCopyWith<_AiMessage> get copyWith => __$AiMessageCopyWithImpl<_AiMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.recommendedWorker, recommendedWorker) || other.recommendedWorker == recommendedWorker)&&(identical(other.suggestedTrade, suggestedTrade) || other.suggestedTrade == suggestedTrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,content,createdAt,const DeepCollectionEquality().hash(_sources),recommendedWorker,suggestedTrade);

@override
String toString() {
  return 'AiMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, sources: $sources, recommendedWorker: $recommendedWorker, suggestedTrade: $suggestedTrade)';
}


}

/// @nodoc
abstract mixin class _$AiMessageCopyWith<$Res> implements $AiMessageCopyWith<$Res> {
  factory _$AiMessageCopyWith(_AiMessage value, $Res Function(_AiMessage) _then) = __$AiMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, AiMessageRole role, String content, DateTime createdAt, List<AiSource> sources, Worker? recommendedWorker, String? suggestedTrade
});


@override $WorkerCopyWith<$Res>? get recommendedWorker;

}
/// @nodoc
class __$AiMessageCopyWithImpl<$Res>
    implements _$AiMessageCopyWith<$Res> {
  __$AiMessageCopyWithImpl(this._self, this._then);

  final _AiMessage _self;
  final $Res Function(_AiMessage) _then;

/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? content = null,Object? createdAt = null,Object? sources = null,Object? recommendedWorker = freezed,Object? suggestedTrade = freezed,}) {
  return _then(_AiMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AiMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<AiSource>,recommendedWorker: freezed == recommendedWorker ? _self.recommendedWorker : recommendedWorker // ignore: cast_nullable_to_non_nullable
as Worker?,suggestedTrade: freezed == suggestedTrade ? _self.suggestedTrade : suggestedTrade // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AiMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkerCopyWith<$Res>? get recommendedWorker {
    if (_self.recommendedWorker == null) {
    return null;
  }

  return $WorkerCopyWith<$Res>(_self.recommendedWorker!, (value) {
    return _then(_self.copyWith(recommendedWorker: value));
  });
}
}

// dart format on
