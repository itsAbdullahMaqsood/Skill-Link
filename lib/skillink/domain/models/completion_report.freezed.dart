// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completion_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompletionReport {

 String get jobId; DateTime get createdAt; double? get homeownerAmount; DateTime? get homeownerSubmittedAt; double? get workerAmount; DateTime? get workerSubmittedAt; bool get flagged; String? get flaggedReason;
/// Create a copy of CompletionReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletionReportCopyWith<CompletionReport> get copyWith => _$CompletionReportCopyWithImpl<CompletionReport>(this as CompletionReport, _$identity);

  /// Serializes this CompletionReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletionReport&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.homeownerAmount, homeownerAmount) || other.homeownerAmount == homeownerAmount)&&(identical(other.homeownerSubmittedAt, homeownerSubmittedAt) || other.homeownerSubmittedAt == homeownerSubmittedAt)&&(identical(other.workerAmount, workerAmount) || other.workerAmount == workerAmount)&&(identical(other.workerSubmittedAt, workerSubmittedAt) || other.workerSubmittedAt == workerSubmittedAt)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.flaggedReason, flaggedReason) || other.flaggedReason == flaggedReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,createdAt,homeownerAmount,homeownerSubmittedAt,workerAmount,workerSubmittedAt,flagged,flaggedReason);

@override
String toString() {
  return 'CompletionReport(jobId: $jobId, createdAt: $createdAt, homeownerAmount: $homeownerAmount, homeownerSubmittedAt: $homeownerSubmittedAt, workerAmount: $workerAmount, workerSubmittedAt: $workerSubmittedAt, flagged: $flagged, flaggedReason: $flaggedReason)';
}


}

/// @nodoc
abstract mixin class $CompletionReportCopyWith<$Res>  {
  factory $CompletionReportCopyWith(CompletionReport value, $Res Function(CompletionReport) _then) = _$CompletionReportCopyWithImpl;
@useResult
$Res call({
 String jobId, DateTime createdAt, double? homeownerAmount, DateTime? homeownerSubmittedAt, double? workerAmount, DateTime? workerSubmittedAt, bool flagged, String? flaggedReason
});




}
/// @nodoc
class _$CompletionReportCopyWithImpl<$Res>
    implements $CompletionReportCopyWith<$Res> {
  _$CompletionReportCopyWithImpl(this._self, this._then);

  final CompletionReport _self;
  final $Res Function(CompletionReport) _then;

/// Create a copy of CompletionReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? createdAt = null,Object? homeownerAmount = freezed,Object? homeownerSubmittedAt = freezed,Object? workerAmount = freezed,Object? workerSubmittedAt = freezed,Object? flagged = null,Object? flaggedReason = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,homeownerAmount: freezed == homeownerAmount ? _self.homeownerAmount : homeownerAmount // ignore: cast_nullable_to_non_nullable
as double?,homeownerSubmittedAt: freezed == homeownerSubmittedAt ? _self.homeownerSubmittedAt : homeownerSubmittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,workerAmount: freezed == workerAmount ? _self.workerAmount : workerAmount // ignore: cast_nullable_to_non_nullable
as double?,workerSubmittedAt: freezed == workerSubmittedAt ? _self.workerSubmittedAt : workerSubmittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as bool,flaggedReason: freezed == flaggedReason ? _self.flaggedReason : flaggedReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletionReport].
extension CompletionReportPatterns on CompletionReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletionReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletionReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletionReport value)  $default,){
final _that = this;
switch (_that) {
case _CompletionReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletionReport value)?  $default,){
final _that = this;
switch (_that) {
case _CompletionReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  DateTime createdAt,  double? homeownerAmount,  DateTime? homeownerSubmittedAt,  double? workerAmount,  DateTime? workerSubmittedAt,  bool flagged,  String? flaggedReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletionReport() when $default != null:
return $default(_that.jobId,_that.createdAt,_that.homeownerAmount,_that.homeownerSubmittedAt,_that.workerAmount,_that.workerSubmittedAt,_that.flagged,_that.flaggedReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  DateTime createdAt,  double? homeownerAmount,  DateTime? homeownerSubmittedAt,  double? workerAmount,  DateTime? workerSubmittedAt,  bool flagged,  String? flaggedReason)  $default,) {final _that = this;
switch (_that) {
case _CompletionReport():
return $default(_that.jobId,_that.createdAt,_that.homeownerAmount,_that.homeownerSubmittedAt,_that.workerAmount,_that.workerSubmittedAt,_that.flagged,_that.flaggedReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  DateTime createdAt,  double? homeownerAmount,  DateTime? homeownerSubmittedAt,  double? workerAmount,  DateTime? workerSubmittedAt,  bool flagged,  String? flaggedReason)?  $default,) {final _that = this;
switch (_that) {
case _CompletionReport() when $default != null:
return $default(_that.jobId,_that.createdAt,_that.homeownerAmount,_that.homeownerSubmittedAt,_that.workerAmount,_that.workerSubmittedAt,_that.flagged,_that.flaggedReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompletionReport implements CompletionReport {
  const _CompletionReport({required this.jobId, required this.createdAt, this.homeownerAmount, this.homeownerSubmittedAt, this.workerAmount, this.workerSubmittedAt, this.flagged = false, this.flaggedReason});
  factory _CompletionReport.fromJson(Map<String, dynamic> json) => _$CompletionReportFromJson(json);

@override final  String jobId;
@override final  DateTime createdAt;
@override final  double? homeownerAmount;
@override final  DateTime? homeownerSubmittedAt;
@override final  double? workerAmount;
@override final  DateTime? workerSubmittedAt;
@override@JsonKey() final  bool flagged;
@override final  String? flaggedReason;

/// Create a copy of CompletionReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletionReportCopyWith<_CompletionReport> get copyWith => __$CompletionReportCopyWithImpl<_CompletionReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletionReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletionReport&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.homeownerAmount, homeownerAmount) || other.homeownerAmount == homeownerAmount)&&(identical(other.homeownerSubmittedAt, homeownerSubmittedAt) || other.homeownerSubmittedAt == homeownerSubmittedAt)&&(identical(other.workerAmount, workerAmount) || other.workerAmount == workerAmount)&&(identical(other.workerSubmittedAt, workerSubmittedAt) || other.workerSubmittedAt == workerSubmittedAt)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.flaggedReason, flaggedReason) || other.flaggedReason == flaggedReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,createdAt,homeownerAmount,homeownerSubmittedAt,workerAmount,workerSubmittedAt,flagged,flaggedReason);

@override
String toString() {
  return 'CompletionReport(jobId: $jobId, createdAt: $createdAt, homeownerAmount: $homeownerAmount, homeownerSubmittedAt: $homeownerSubmittedAt, workerAmount: $workerAmount, workerSubmittedAt: $workerSubmittedAt, flagged: $flagged, flaggedReason: $flaggedReason)';
}


}

/// @nodoc
abstract mixin class _$CompletionReportCopyWith<$Res> implements $CompletionReportCopyWith<$Res> {
  factory _$CompletionReportCopyWith(_CompletionReport value, $Res Function(_CompletionReport) _then) = __$CompletionReportCopyWithImpl;
@override @useResult
$Res call({
 String jobId, DateTime createdAt, double? homeownerAmount, DateTime? homeownerSubmittedAt, double? workerAmount, DateTime? workerSubmittedAt, bool flagged, String? flaggedReason
});




}
/// @nodoc
class __$CompletionReportCopyWithImpl<$Res>
    implements _$CompletionReportCopyWith<$Res> {
  __$CompletionReportCopyWithImpl(this._self, this._then);

  final _CompletionReport _self;
  final $Res Function(_CompletionReport) _then;

/// Create a copy of CompletionReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? createdAt = null,Object? homeownerAmount = freezed,Object? homeownerSubmittedAt = freezed,Object? workerAmount = freezed,Object? workerSubmittedAt = freezed,Object? flagged = null,Object? flaggedReason = freezed,}) {
  return _then(_CompletionReport(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,homeownerAmount: freezed == homeownerAmount ? _self.homeownerAmount : homeownerAmount // ignore: cast_nullable_to_non_nullable
as double?,homeownerSubmittedAt: freezed == homeownerSubmittedAt ? _self.homeownerSubmittedAt : homeownerSubmittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,workerAmount: freezed == workerAmount ? _self.workerAmount : workerAmount // ignore: cast_nullable_to_non_nullable
as double?,workerSubmittedAt: freezed == workerSubmittedAt ? _self.workerSubmittedAt : workerSubmittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as bool,flaggedReason: freezed == flaggedReason ? _self.flaggedReason : flaggedReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
