// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

/// Populated by the backend after the bid is persisted — the homeowner
/// then references this id when calling the accept endpoint. Null for
/// in-flight bids the client just built locally.
 String? get bidId; String get bidderId; double get amount; DateTime get submittedAt; bool get accepted;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.accepted, accepted) || other.accepted == accepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,bidderId,amount,submittedAt,accepted);

@override
String toString() {
  return 'Bid(bidId: $bidId, bidderId: $bidderId, amount: $amount, submittedAt: $submittedAt, accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 String? bidId, String bidderId, double amount, DateTime submittedAt, bool accepted
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bidId = freezed,Object? bidderId = null,Object? amount = null,Object? submittedAt = null,Object? accepted = null,}) {
  return _then(_self.copyWith(
bidId: freezed == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String?,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? bidId,  String bidderId,  double amount,  DateTime submittedAt,  bool accepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.bidId,_that.bidderId,_that.amount,_that.submittedAt,_that.accepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? bidId,  String bidderId,  double amount,  DateTime submittedAt,  bool accepted)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.bidId,_that.bidderId,_that.amount,_that.submittedAt,_that.accepted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? bidId,  String bidderId,  double amount,  DateTime submittedAt,  bool accepted)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.bidId,_that.bidderId,_that.amount,_that.submittedAt,_that.accepted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid implements Bid {
  const _Bid({this.bidId, required this.bidderId, required this.amount, required this.submittedAt, this.accepted = false});
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

/// Populated by the backend after the bid is persisted — the homeowner
/// then references this id when calling the accept endpoint. Null for
/// in-flight bids the client just built locally.
@override final  String? bidId;
@override final  String bidderId;
@override final  double amount;
@override final  DateTime submittedAt;
@override@JsonKey() final  bool accepted;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.accepted, accepted) || other.accepted == accepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,bidderId,amount,submittedAt,accepted);

@override
String toString() {
  return 'Bid(bidId: $bidId, bidderId: $bidderId, amount: $amount, submittedAt: $submittedAt, accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 String? bidId, String bidderId, double amount, DateTime submittedAt, bool accepted
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bidId = freezed,Object? bidderId = null,Object? amount = null,Object? submittedAt = null,Object? accepted = null,}) {
  return _then(_Bid(
bidId: freezed == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String?,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
