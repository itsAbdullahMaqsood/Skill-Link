// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Job {

 String get jobId; String get userId; String? get workerId; String get serviceType; JobStatus get status; DateTime get scheduledDate; double? get finalPrice; List<Bid> get bidHistory; String get description; List<String> get photoUrls; StructuredAddress get address; PaymentMethod get paymentMethod; bool get paid; DateTime? get paidAt; DateTime get createdAt;
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCopyWith<Job> get copyWith => _$JobCopyWithImpl<Job>(this as Job, _$identity);

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Job&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&const DeepCollectionEquality().equals(other.bidHistory, bidHistory)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.address, address) || other.address == address)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,userId,workerId,serviceType,status,scheduledDate,finalPrice,const DeepCollectionEquality().hash(bidHistory),description,const DeepCollectionEquality().hash(photoUrls),address,paymentMethod,paid,paidAt,createdAt);

@override
String toString() {
  return 'Job(jobId: $jobId, userId: $userId, workerId: $workerId, serviceType: $serviceType, status: $status, scheduledDate: $scheduledDate, finalPrice: $finalPrice, bidHistory: $bidHistory, description: $description, photoUrls: $photoUrls, address: $address, paymentMethod: $paymentMethod, paid: $paid, paidAt: $paidAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $JobCopyWith<$Res>  {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
@useResult
$Res call({
 String jobId, String userId, String? workerId, String serviceType, JobStatus status, DateTime scheduledDate, double? finalPrice, List<Bid> bidHistory, String description, List<String> photoUrls, StructuredAddress address, PaymentMethod paymentMethod, bool paid, DateTime? paidAt, DateTime createdAt
});


$StructuredAddressCopyWith<$Res> get address;

}
/// @nodoc
class _$JobCopyWithImpl<$Res>
    implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? userId = null,Object? workerId = freezed,Object? serviceType = null,Object? status = null,Object? scheduledDate = null,Object? finalPrice = freezed,Object? bidHistory = null,Object? description = null,Object? photoUrls = null,Object? address = null,Object? paymentMethod = null,Object? paid = null,Object? paidAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workerId: freezed == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String?,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,bidHistory: null == bidHistory ? _self.bidHistory : bidHistory // ignore: cast_nullable_to_non_nullable
as List<Bid>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as StructuredAddress,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredAddressCopyWith<$Res> get address {
  
  return $StructuredAddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Job value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Job value)  $default,){
final _that = this;
switch (_that) {
case _Job():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Job value)?  $default,){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  String userId,  String? workerId,  String serviceType,  JobStatus status,  DateTime scheduledDate,  double? finalPrice,  List<Bid> bidHistory,  String description,  List<String> photoUrls,  StructuredAddress address,  PaymentMethod paymentMethod,  bool paid,  DateTime? paidAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.jobId,_that.userId,_that.workerId,_that.serviceType,_that.status,_that.scheduledDate,_that.finalPrice,_that.bidHistory,_that.description,_that.photoUrls,_that.address,_that.paymentMethod,_that.paid,_that.paidAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  String userId,  String? workerId,  String serviceType,  JobStatus status,  DateTime scheduledDate,  double? finalPrice,  List<Bid> bidHistory,  String description,  List<String> photoUrls,  StructuredAddress address,  PaymentMethod paymentMethod,  bool paid,  DateTime? paidAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Job():
return $default(_that.jobId,_that.userId,_that.workerId,_that.serviceType,_that.status,_that.scheduledDate,_that.finalPrice,_that.bidHistory,_that.description,_that.photoUrls,_that.address,_that.paymentMethod,_that.paid,_that.paidAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  String userId,  String? workerId,  String serviceType,  JobStatus status,  DateTime scheduledDate,  double? finalPrice,  List<Bid> bidHistory,  String description,  List<String> photoUrls,  StructuredAddress address,  PaymentMethod paymentMethod,  bool paid,  DateTime? paidAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.jobId,_that.userId,_that.workerId,_that.serviceType,_that.status,_that.scheduledDate,_that.finalPrice,_that.bidHistory,_that.description,_that.photoUrls,_that.address,_that.paymentMethod,_that.paid,_that.paidAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Job implements Job {
  const _Job({required this.jobId, required this.userId, this.workerId, required this.serviceType, required this.status, required this.scheduledDate, this.finalPrice, final  List<Bid> bidHistory = const [], required this.description, final  List<String> photoUrls = const [], required this.address, required this.paymentMethod, this.paid = false, this.paidAt, required this.createdAt}): _bidHistory = bidHistory,_photoUrls = photoUrls;
  factory _Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

@override final  String jobId;
@override final  String userId;
@override final  String? workerId;
@override final  String serviceType;
@override final  JobStatus status;
@override final  DateTime scheduledDate;
@override final  double? finalPrice;
 final  List<Bid> _bidHistory;
@override@JsonKey() List<Bid> get bidHistory {
  if (_bidHistory is EqualUnmodifiableListView) return _bidHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bidHistory);
}

@override final  String description;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

@override final  StructuredAddress address;
@override final  PaymentMethod paymentMethod;
@override@JsonKey() final  bool paid;
@override final  DateTime? paidAt;
@override final  DateTime createdAt;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCopyWith<_Job> get copyWith => __$JobCopyWithImpl<_Job>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Job&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&const DeepCollectionEquality().equals(other._bidHistory, _bidHistory)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.address, address) || other.address == address)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,userId,workerId,serviceType,status,scheduledDate,finalPrice,const DeepCollectionEquality().hash(_bidHistory),description,const DeepCollectionEquality().hash(_photoUrls),address,paymentMethod,paid,paidAt,createdAt);

@override
String toString() {
  return 'Job(jobId: $jobId, userId: $userId, workerId: $workerId, serviceType: $serviceType, status: $status, scheduledDate: $scheduledDate, finalPrice: $finalPrice, bidHistory: $bidHistory, description: $description, photoUrls: $photoUrls, address: $address, paymentMethod: $paymentMethod, paid: $paid, paidAt: $paidAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) = __$JobCopyWithImpl;
@override @useResult
$Res call({
 String jobId, String userId, String? workerId, String serviceType, JobStatus status, DateTime scheduledDate, double? finalPrice, List<Bid> bidHistory, String description, List<String> photoUrls, StructuredAddress address, PaymentMethod paymentMethod, bool paid, DateTime? paidAt, DateTime createdAt
});


@override $StructuredAddressCopyWith<$Res> get address;

}
/// @nodoc
class __$JobCopyWithImpl<$Res>
    implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? userId = null,Object? workerId = freezed,Object? serviceType = null,Object? status = null,Object? scheduledDate = null,Object? finalPrice = freezed,Object? bidHistory = null,Object? description = null,Object? photoUrls = null,Object? address = null,Object? paymentMethod = null,Object? paid = null,Object? paidAt = freezed,Object? createdAt = null,}) {
  return _then(_Job(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workerId: freezed == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String?,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,bidHistory: null == bidHistory ? _self._bidHistory : bidHistory // ignore: cast_nullable_to_non_nullable
as List<Bid>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as StructuredAddress,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredAddressCopyWith<$Res> get address {
  
  return $StructuredAddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}

// dart format on
