// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviews_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewUserSummary {

 String get id; String get fullName; String? get profilePic; double get ratings; int get reviewCount;
/// Create a copy of ReviewUserSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewUserSummaryCopyWith<ReviewUserSummary> get copyWith => _$ReviewUserSummaryCopyWithImpl<ReviewUserSummary>(this as ReviewUserSummary, _$identity);

  /// Serializes this ReviewUserSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewUserSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.profilePic, profilePic) || other.profilePic == profilePic)&&(identical(other.ratings, ratings) || other.ratings == ratings)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,profilePic,ratings,reviewCount);

@override
String toString() {
  return 'ReviewUserSummary(id: $id, fullName: $fullName, profilePic: $profilePic, ratings: $ratings, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class $ReviewUserSummaryCopyWith<$Res>  {
  factory $ReviewUserSummaryCopyWith(ReviewUserSummary value, $Res Function(ReviewUserSummary) _then) = _$ReviewUserSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? profilePic, double ratings, int reviewCount
});




}
/// @nodoc
class _$ReviewUserSummaryCopyWithImpl<$Res>
    implements $ReviewUserSummaryCopyWith<$Res> {
  _$ReviewUserSummaryCopyWithImpl(this._self, this._then);

  final ReviewUserSummary _self;
  final $Res Function(ReviewUserSummary) _then;

/// Create a copy of ReviewUserSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? profilePic = freezed,Object? ratings = null,Object? reviewCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,profilePic: freezed == profilePic ? _self.profilePic : profilePic // ignore: cast_nullable_to_non_nullable
as String?,ratings: null == ratings ? _self.ratings : ratings // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewUserSummary].
extension ReviewUserSummaryPatterns on ReviewUserSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewUserSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewUserSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewUserSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReviewUserSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewUserSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewUserSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? profilePic,  double ratings,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewUserSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.profilePic,_that.ratings,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? profilePic,  double ratings,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _ReviewUserSummary():
return $default(_that.id,_that.fullName,_that.profilePic,_that.ratings,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? profilePic,  double ratings,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _ReviewUserSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.profilePic,_that.ratings,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewUserSummary implements ReviewUserSummary {
  const _ReviewUserSummary({required this.id, required this.fullName, this.profilePic, this.ratings = 0.0, this.reviewCount = 0});
  factory _ReviewUserSummary.fromJson(Map<String, dynamic> json) => _$ReviewUserSummaryFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? profilePic;
@override@JsonKey() final  double ratings;
@override@JsonKey() final  int reviewCount;

/// Create a copy of ReviewUserSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewUserSummaryCopyWith<_ReviewUserSummary> get copyWith => __$ReviewUserSummaryCopyWithImpl<_ReviewUserSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewUserSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewUserSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.profilePic, profilePic) || other.profilePic == profilePic)&&(identical(other.ratings, ratings) || other.ratings == ratings)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,profilePic,ratings,reviewCount);

@override
String toString() {
  return 'ReviewUserSummary(id: $id, fullName: $fullName, profilePic: $profilePic, ratings: $ratings, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$ReviewUserSummaryCopyWith<$Res> implements $ReviewUserSummaryCopyWith<$Res> {
  factory _$ReviewUserSummaryCopyWith(_ReviewUserSummary value, $Res Function(_ReviewUserSummary) _then) = __$ReviewUserSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? profilePic, double ratings, int reviewCount
});




}
/// @nodoc
class __$ReviewUserSummaryCopyWithImpl<$Res>
    implements _$ReviewUserSummaryCopyWith<$Res> {
  __$ReviewUserSummaryCopyWithImpl(this._self, this._then);

  final _ReviewUserSummary _self;
  final $Res Function(_ReviewUserSummary) _then;

/// Create a copy of ReviewUserSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? profilePic = freezed,Object? ratings = null,Object? reviewCount = null,}) {
  return _then(_ReviewUserSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,profilePic: freezed == profilePic ? _self.profilePic : profilePic // ignore: cast_nullable_to_non_nullable
as String?,ratings: null == ratings ? _self.ratings : ratings // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReviewsSummary {

 ReviewUserSummary get user; List<Review> get reviews;
/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewsSummaryCopyWith<ReviewsSummary> get copyWith => _$ReviewsSummaryCopyWithImpl<ReviewsSummary>(this as ReviewsSummary, _$identity);

  /// Serializes this ReviewsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewsSummary&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.reviews, reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(reviews));

@override
String toString() {
  return 'ReviewsSummary(user: $user, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class $ReviewsSummaryCopyWith<$Res>  {
  factory $ReviewsSummaryCopyWith(ReviewsSummary value, $Res Function(ReviewsSummary) _then) = _$ReviewsSummaryCopyWithImpl;
@useResult
$Res call({
 ReviewUserSummary user, List<Review> reviews
});


$ReviewUserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$ReviewsSummaryCopyWithImpl<$Res>
    implements $ReviewsSummaryCopyWith<$Res> {
  _$ReviewsSummaryCopyWithImpl(this._self, this._then);

  final ReviewsSummary _self;
  final $Res Function(ReviewsSummary) _then;

/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? reviews = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ReviewUserSummary,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,
  ));
}
/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewUserSummaryCopyWith<$Res> get user {
  
  return $ReviewUserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReviewsSummary].
extension ReviewsSummaryPatterns on ReviewsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewsSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReviewsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewUserSummary user,  List<Review> reviews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewsSummary() when $default != null:
return $default(_that.user,_that.reviews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewUserSummary user,  List<Review> reviews)  $default,) {final _that = this;
switch (_that) {
case _ReviewsSummary():
return $default(_that.user,_that.reviews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewUserSummary user,  List<Review> reviews)?  $default,) {final _that = this;
switch (_that) {
case _ReviewsSummary() when $default != null:
return $default(_that.user,_that.reviews);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewsSummary implements ReviewsSummary {
  const _ReviewsSummary({required this.user, final  List<Review> reviews = const <Review>[]}): _reviews = reviews;
  factory _ReviewsSummary.fromJson(Map<String, dynamic> json) => _$ReviewsSummaryFromJson(json);

@override final  ReviewUserSummary user;
 final  List<Review> _reviews;
@override@JsonKey() List<Review> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}


/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewsSummaryCopyWith<_ReviewsSummary> get copyWith => __$ReviewsSummaryCopyWithImpl<_ReviewsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewsSummary&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other._reviews, _reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(_reviews));

@override
String toString() {
  return 'ReviewsSummary(user: $user, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class _$ReviewsSummaryCopyWith<$Res> implements $ReviewsSummaryCopyWith<$Res> {
  factory _$ReviewsSummaryCopyWith(_ReviewsSummary value, $Res Function(_ReviewsSummary) _then) = __$ReviewsSummaryCopyWithImpl;
@override @useResult
$Res call({
 ReviewUserSummary user, List<Review> reviews
});


@override $ReviewUserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$ReviewsSummaryCopyWithImpl<$Res>
    implements _$ReviewsSummaryCopyWith<$Res> {
  __$ReviewsSummaryCopyWithImpl(this._self, this._then);

  final _ReviewsSummary _self;
  final $Res Function(_ReviewsSummary) _then;

/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? reviews = null,}) {
  return _then(_ReviewsSummary(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ReviewUserSummary,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,
  ));
}

/// Create a copy of ReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewUserSummaryCopyWith<$Res> get user {
  
  return $ReviewUserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
