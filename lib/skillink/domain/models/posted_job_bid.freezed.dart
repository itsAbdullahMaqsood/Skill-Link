// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'posted_job_bid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostedJobBid {

 String get bidId; String get jobId;/// Worker who submitted this bid (null for pure homeowner counter rows if ever needed).
 String? get workerId;@JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson) PostedBidOfferedBy get offeredBy; double get visitingCharges; double get jobChargesEstimate; String? get note; int get etaMinutes; DateTime get submittedAt;@JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson) PostedBidStatus get status;
/// Create a copy of PostedJobBid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostedJobBidCopyWith<PostedJobBid> get copyWith => _$PostedJobBidCopyWithImpl<PostedJobBid>(this as PostedJobBid, _$identity);

  /// Serializes this PostedJobBid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostedJobBid&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.offeredBy, offeredBy) || other.offeredBy == offeredBy)&&(identical(other.visitingCharges, visitingCharges) || other.visitingCharges == visitingCharges)&&(identical(other.jobChargesEstimate, jobChargesEstimate) || other.jobChargesEstimate == jobChargesEstimate)&&(identical(other.note, note) || other.note == note)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,jobId,workerId,offeredBy,visitingCharges,jobChargesEstimate,note,etaMinutes,submittedAt,status);

@override
String toString() {
  return 'PostedJobBid(bidId: $bidId, jobId: $jobId, workerId: $workerId, offeredBy: $offeredBy, visitingCharges: $visitingCharges, jobChargesEstimate: $jobChargesEstimate, note: $note, etaMinutes: $etaMinutes, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $PostedJobBidCopyWith<$Res>  {
  factory $PostedJobBidCopyWith(PostedJobBid value, $Res Function(PostedJobBid) _then) = _$PostedJobBidCopyWithImpl;
@useResult
$Res call({
 String bidId, String jobId, String? workerId,@JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson) PostedBidOfferedBy offeredBy, double visitingCharges, double jobChargesEstimate, String? note, int etaMinutes, DateTime submittedAt,@JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson) PostedBidStatus status
});




}
/// @nodoc
class _$PostedJobBidCopyWithImpl<$Res>
    implements $PostedJobBidCopyWith<$Res> {
  _$PostedJobBidCopyWithImpl(this._self, this._then);

  final PostedJobBid _self;
  final $Res Function(PostedJobBid) _then;

/// Create a copy of PostedJobBid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bidId = null,Object? jobId = null,Object? workerId = freezed,Object? offeredBy = null,Object? visitingCharges = null,Object? jobChargesEstimate = null,Object? note = freezed,Object? etaMinutes = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
bidId: null == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,workerId: freezed == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String?,offeredBy: null == offeredBy ? _self.offeredBy : offeredBy // ignore: cast_nullable_to_non_nullable
as PostedBidOfferedBy,visitingCharges: null == visitingCharges ? _self.visitingCharges : visitingCharges // ignore: cast_nullable_to_non_nullable
as double,jobChargesEstimate: null == jobChargesEstimate ? _self.jobChargesEstimate : jobChargesEstimate // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostedBidStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PostedJobBid].
extension PostedJobBidPatterns on PostedJobBid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostedJobBid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostedJobBid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostedJobBid value)  $default,){
final _that = this;
switch (_that) {
case _PostedJobBid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostedJobBid value)?  $default,){
final _that = this;
switch (_that) {
case _PostedJobBid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bidId,  String jobId,  String? workerId, @JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson)  PostedBidOfferedBy offeredBy,  double visitingCharges,  double jobChargesEstimate,  String? note,  int etaMinutes,  DateTime submittedAt, @JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson)  PostedBidStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostedJobBid() when $default != null:
return $default(_that.bidId,_that.jobId,_that.workerId,_that.offeredBy,_that.visitingCharges,_that.jobChargesEstimate,_that.note,_that.etaMinutes,_that.submittedAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bidId,  String jobId,  String? workerId, @JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson)  PostedBidOfferedBy offeredBy,  double visitingCharges,  double jobChargesEstimate,  String? note,  int etaMinutes,  DateTime submittedAt, @JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson)  PostedBidStatus status)  $default,) {final _that = this;
switch (_that) {
case _PostedJobBid():
return $default(_that.bidId,_that.jobId,_that.workerId,_that.offeredBy,_that.visitingCharges,_that.jobChargesEstimate,_that.note,_that.etaMinutes,_that.submittedAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bidId,  String jobId,  String? workerId, @JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson)  PostedBidOfferedBy offeredBy,  double visitingCharges,  double jobChargesEstimate,  String? note,  int etaMinutes,  DateTime submittedAt, @JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson)  PostedBidStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PostedJobBid() when $default != null:
return $default(_that.bidId,_that.jobId,_that.workerId,_that.offeredBy,_that.visitingCharges,_that.jobChargesEstimate,_that.note,_that.etaMinutes,_that.submittedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostedJobBid implements PostedJobBid {
  const _PostedJobBid({required this.bidId, required this.jobId, this.workerId, @JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson) this.offeredBy = PostedBidOfferedBy.worker, required this.visitingCharges, required this.jobChargesEstimate, this.note, this.etaMinutes = 0, required this.submittedAt, @JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson) this.status = PostedBidStatus.pending});
  factory _PostedJobBid.fromJson(Map<String, dynamic> json) => _$PostedJobBidFromJson(json);

@override final  String bidId;
@override final  String jobId;
/// Worker who submitted this bid (null for pure homeowner counter rows if ever needed).
@override final  String? workerId;
@override@JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson) final  PostedBidOfferedBy offeredBy;
@override final  double visitingCharges;
@override final  double jobChargesEstimate;
@override final  String? note;
@override@JsonKey() final  int etaMinutes;
@override final  DateTime submittedAt;
@override@JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson) final  PostedBidStatus status;

/// Create a copy of PostedJobBid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostedJobBidCopyWith<_PostedJobBid> get copyWith => __$PostedJobBidCopyWithImpl<_PostedJobBid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostedJobBidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostedJobBid&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.offeredBy, offeredBy) || other.offeredBy == offeredBy)&&(identical(other.visitingCharges, visitingCharges) || other.visitingCharges == visitingCharges)&&(identical(other.jobChargesEstimate, jobChargesEstimate) || other.jobChargesEstimate == jobChargesEstimate)&&(identical(other.note, note) || other.note == note)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,jobId,workerId,offeredBy,visitingCharges,jobChargesEstimate,note,etaMinutes,submittedAt,status);

@override
String toString() {
  return 'PostedJobBid(bidId: $bidId, jobId: $jobId, workerId: $workerId, offeredBy: $offeredBy, visitingCharges: $visitingCharges, jobChargesEstimate: $jobChargesEstimate, note: $note, etaMinutes: $etaMinutes, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PostedJobBidCopyWith<$Res> implements $PostedJobBidCopyWith<$Res> {
  factory _$PostedJobBidCopyWith(_PostedJobBid value, $Res Function(_PostedJobBid) _then) = __$PostedJobBidCopyWithImpl;
@override @useResult
$Res call({
 String bidId, String jobId, String? workerId,@JsonKey(fromJson: _postedBidOfferedByFromJson, toJson: _postedBidOfferedByToJson) PostedBidOfferedBy offeredBy, double visitingCharges, double jobChargesEstimate, String? note, int etaMinutes, DateTime submittedAt,@JsonKey(fromJson: _postedBidStatusFromJson, toJson: _postedBidStatusToJson) PostedBidStatus status
});




}
/// @nodoc
class __$PostedJobBidCopyWithImpl<$Res>
    implements _$PostedJobBidCopyWith<$Res> {
  __$PostedJobBidCopyWithImpl(this._self, this._then);

  final _PostedJobBid _self;
  final $Res Function(_PostedJobBid) _then;

/// Create a copy of PostedJobBid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bidId = null,Object? jobId = null,Object? workerId = freezed,Object? offeredBy = null,Object? visitingCharges = null,Object? jobChargesEstimate = null,Object? note = freezed,Object? etaMinutes = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_PostedJobBid(
bidId: null == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,workerId: freezed == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String?,offeredBy: null == offeredBy ? _self.offeredBy : offeredBy // ignore: cast_nullable_to_non_nullable
as PostedBidOfferedBy,visitingCharges: null == visitingCharges ? _self.visitingCharges : visitingCharges // ignore: cast_nullable_to_non_nullable
as double,jobChargesEstimate: null == jobChargesEstimate ? _self.jobChargesEstimate : jobChargesEstimate // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostedBidStatus,
  ));
}


}

// dart format on
