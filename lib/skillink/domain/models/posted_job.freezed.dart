// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'posted_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobMedia {

 String get url;@JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson) JobMediaType get type; String? get thumbnailUrl;
/// Create a copy of JobMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobMediaCopyWith<JobMedia> get copyWith => _$JobMediaCopyWithImpl<JobMedia>(this as JobMedia, _$identity);

  /// Serializes this JobMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobMedia&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,type,thumbnailUrl);

@override
String toString() {
  return 'JobMedia(url: $url, type: $type, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $JobMediaCopyWith<$Res>  {
  factory $JobMediaCopyWith(JobMedia value, $Res Function(JobMedia) _then) = _$JobMediaCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson) JobMediaType type, String? thumbnailUrl
});




}
/// @nodoc
class _$JobMediaCopyWithImpl<$Res>
    implements $JobMediaCopyWith<$Res> {
  _$JobMediaCopyWithImpl(this._self, this._then);

  final JobMedia _self;
  final $Res Function(JobMedia) _then;

/// Create a copy of JobMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? type = null,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as JobMediaType,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobMedia].
extension JobMediaPatterns on JobMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobMedia value)  $default,){
final _that = this;
switch (_that) {
case _JobMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobMedia value)?  $default,){
final _that = this;
switch (_that) {
case _JobMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson)  JobMediaType type,  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobMedia() when $default != null:
return $default(_that.url,_that.type,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson)  JobMediaType type,  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _JobMedia():
return $default(_that.url,_that.type,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson)  JobMediaType type,  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _JobMedia() when $default != null:
return $default(_that.url,_that.type,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobMedia implements JobMedia {
  const _JobMedia({required this.url, @JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson) this.type = JobMediaType.photo, this.thumbnailUrl});
  factory _JobMedia.fromJson(Map<String, dynamic> json) => _$JobMediaFromJson(json);

@override final  String url;
@override@JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson) final  JobMediaType type;
@override final  String? thumbnailUrl;

/// Create a copy of JobMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobMediaCopyWith<_JobMedia> get copyWith => __$JobMediaCopyWithImpl<_JobMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobMedia&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,type,thumbnailUrl);

@override
String toString() {
  return 'JobMedia(url: $url, type: $type, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$JobMediaCopyWith<$Res> implements $JobMediaCopyWith<$Res> {
  factory _$JobMediaCopyWith(_JobMedia value, $Res Function(_JobMedia) _then) = __$JobMediaCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(fromJson: _jobMediaTypeFromJson, toJson: _jobMediaTypeToJson) JobMediaType type, String? thumbnailUrl
});




}
/// @nodoc
class __$JobMediaCopyWithImpl<$Res>
    implements _$JobMediaCopyWith<$Res> {
  __$JobMediaCopyWithImpl(this._self, this._then);

  final _JobMedia _self;
  final $Res Function(_JobMedia) _then;

/// Create a copy of JobMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? type = null,Object? thumbnailUrl = freezed,}) {
  return _then(_JobMedia(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as JobMediaType,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PostedJob {

 String get jobId; String get homeownerId; String get title;@JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson) JobPostTag get tag; String? get descriptionText; String? get descriptionVoiceUrl; List<JobMedia> get media; StructuredAddress get location; double get locationLat; double get locationLng;@JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson) PostedJobStatus get status; String? get acceptedBidId; String? get acceptedWorkerId; String? get trackingJobId; DateTime get createdAt; DateTime? get acceptedAt; String? get homeownerDisplayName;
/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostedJobCopyWith<PostedJob> get copyWith => _$PostedJobCopyWithImpl<PostedJob>(this as PostedJob, _$identity);

  /// Serializes this PostedJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostedJob&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.homeownerId, homeownerId) || other.homeownerId == homeownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.descriptionText, descriptionText) || other.descriptionText == descriptionText)&&(identical(other.descriptionVoiceUrl, descriptionVoiceUrl) || other.descriptionVoiceUrl == descriptionVoiceUrl)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.status, status) || other.status == status)&&(identical(other.acceptedBidId, acceptedBidId) || other.acceptedBidId == acceptedBidId)&&(identical(other.acceptedWorkerId, acceptedWorkerId) || other.acceptedWorkerId == acceptedWorkerId)&&(identical(other.trackingJobId, trackingJobId) || other.trackingJobId == trackingJobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.homeownerDisplayName, homeownerDisplayName) || other.homeownerDisplayName == homeownerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,homeownerId,title,tag,descriptionText,descriptionVoiceUrl,const DeepCollectionEquality().hash(media),location,locationLat,locationLng,status,acceptedBidId,acceptedWorkerId,trackingJobId,createdAt,acceptedAt,homeownerDisplayName);

@override
String toString() {
  return 'PostedJob(jobId: $jobId, homeownerId: $homeownerId, title: $title, tag: $tag, descriptionText: $descriptionText, descriptionVoiceUrl: $descriptionVoiceUrl, media: $media, location: $location, locationLat: $locationLat, locationLng: $locationLng, status: $status, acceptedBidId: $acceptedBidId, acceptedWorkerId: $acceptedWorkerId, trackingJobId: $trackingJobId, createdAt: $createdAt, acceptedAt: $acceptedAt, homeownerDisplayName: $homeownerDisplayName)';
}


}

/// @nodoc
abstract mixin class $PostedJobCopyWith<$Res>  {
  factory $PostedJobCopyWith(PostedJob value, $Res Function(PostedJob) _then) = _$PostedJobCopyWithImpl;
@useResult
$Res call({
 String jobId, String homeownerId, String title,@JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson) JobPostTag tag, String? descriptionText, String? descriptionVoiceUrl, List<JobMedia> media, StructuredAddress location, double locationLat, double locationLng,@JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson) PostedJobStatus status, String? acceptedBidId, String? acceptedWorkerId, String? trackingJobId, DateTime createdAt, DateTime? acceptedAt, String? homeownerDisplayName
});


$StructuredAddressCopyWith<$Res> get location;

}
/// @nodoc
class _$PostedJobCopyWithImpl<$Res>
    implements $PostedJobCopyWith<$Res> {
  _$PostedJobCopyWithImpl(this._self, this._then);

  final PostedJob _self;
  final $Res Function(PostedJob) _then;

/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? homeownerId = null,Object? title = null,Object? tag = null,Object? descriptionText = freezed,Object? descriptionVoiceUrl = freezed,Object? media = null,Object? location = null,Object? locationLat = null,Object? locationLng = null,Object? status = null,Object? acceptedBidId = freezed,Object? acceptedWorkerId = freezed,Object? trackingJobId = freezed,Object? createdAt = null,Object? acceptedAt = freezed,Object? homeownerDisplayName = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,homeownerId: null == homeownerId ? _self.homeownerId : homeownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as JobPostTag,descriptionText: freezed == descriptionText ? _self.descriptionText : descriptionText // ignore: cast_nullable_to_non_nullable
as String?,descriptionVoiceUrl: freezed == descriptionVoiceUrl ? _self.descriptionVoiceUrl : descriptionVoiceUrl // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<JobMedia>,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as StructuredAddress,locationLat: null == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double,locationLng: null == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostedJobStatus,acceptedBidId: freezed == acceptedBidId ? _self.acceptedBidId : acceptedBidId // ignore: cast_nullable_to_non_nullable
as String?,acceptedWorkerId: freezed == acceptedWorkerId ? _self.acceptedWorkerId : acceptedWorkerId // ignore: cast_nullable_to_non_nullable
as String?,trackingJobId: freezed == trackingJobId ? _self.trackingJobId : trackingJobId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,homeownerDisplayName: freezed == homeownerDisplayName ? _self.homeownerDisplayName : homeownerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredAddressCopyWith<$Res> get location {
  
  return $StructuredAddressCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostedJob].
extension PostedJobPatterns on PostedJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostedJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostedJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostedJob value)  $default,){
final _that = this;
switch (_that) {
case _PostedJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostedJob value)?  $default,){
final _that = this;
switch (_that) {
case _PostedJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  String homeownerId,  String title, @JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson)  JobPostTag tag,  String? descriptionText,  String? descriptionVoiceUrl,  List<JobMedia> media,  StructuredAddress location,  double locationLat,  double locationLng, @JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson)  PostedJobStatus status,  String? acceptedBidId,  String? acceptedWorkerId,  String? trackingJobId,  DateTime createdAt,  DateTime? acceptedAt,  String? homeownerDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostedJob() when $default != null:
return $default(_that.jobId,_that.homeownerId,_that.title,_that.tag,_that.descriptionText,_that.descriptionVoiceUrl,_that.media,_that.location,_that.locationLat,_that.locationLng,_that.status,_that.acceptedBidId,_that.acceptedWorkerId,_that.trackingJobId,_that.createdAt,_that.acceptedAt,_that.homeownerDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  String homeownerId,  String title, @JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson)  JobPostTag tag,  String? descriptionText,  String? descriptionVoiceUrl,  List<JobMedia> media,  StructuredAddress location,  double locationLat,  double locationLng, @JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson)  PostedJobStatus status,  String? acceptedBidId,  String? acceptedWorkerId,  String? trackingJobId,  DateTime createdAt,  DateTime? acceptedAt,  String? homeownerDisplayName)  $default,) {final _that = this;
switch (_that) {
case _PostedJob():
return $default(_that.jobId,_that.homeownerId,_that.title,_that.tag,_that.descriptionText,_that.descriptionVoiceUrl,_that.media,_that.location,_that.locationLat,_that.locationLng,_that.status,_that.acceptedBidId,_that.acceptedWorkerId,_that.trackingJobId,_that.createdAt,_that.acceptedAt,_that.homeownerDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  String homeownerId,  String title, @JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson)  JobPostTag tag,  String? descriptionText,  String? descriptionVoiceUrl,  List<JobMedia> media,  StructuredAddress location,  double locationLat,  double locationLng, @JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson)  PostedJobStatus status,  String? acceptedBidId,  String? acceptedWorkerId,  String? trackingJobId,  DateTime createdAt,  DateTime? acceptedAt,  String? homeownerDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _PostedJob() when $default != null:
return $default(_that.jobId,_that.homeownerId,_that.title,_that.tag,_that.descriptionText,_that.descriptionVoiceUrl,_that.media,_that.location,_that.locationLat,_that.locationLng,_that.status,_that.acceptedBidId,_that.acceptedWorkerId,_that.trackingJobId,_that.createdAt,_that.acceptedAt,_that.homeownerDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostedJob implements PostedJob {
  const _PostedJob({required this.jobId, required this.homeownerId, required this.title, @JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson) required this.tag, this.descriptionText, this.descriptionVoiceUrl, final  List<JobMedia> media = const <JobMedia>[], required this.location, required this.locationLat, required this.locationLng, @JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson) this.status = PostedJobStatus.open, this.acceptedBidId, this.acceptedWorkerId, this.trackingJobId, required this.createdAt, this.acceptedAt, this.homeownerDisplayName}): _media = media;
  factory _PostedJob.fromJson(Map<String, dynamic> json) => _$PostedJobFromJson(json);

@override final  String jobId;
@override final  String homeownerId;
@override final  String title;
@override@JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson) final  JobPostTag tag;
@override final  String? descriptionText;
@override final  String? descriptionVoiceUrl;
 final  List<JobMedia> _media;
@override@JsonKey() List<JobMedia> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override final  StructuredAddress location;
@override final  double locationLat;
@override final  double locationLng;
@override@JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson) final  PostedJobStatus status;
@override final  String? acceptedBidId;
@override final  String? acceptedWorkerId;
@override final  String? trackingJobId;
@override final  DateTime createdAt;
@override final  DateTime? acceptedAt;
@override final  String? homeownerDisplayName;

/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostedJobCopyWith<_PostedJob> get copyWith => __$PostedJobCopyWithImpl<_PostedJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostedJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostedJob&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.homeownerId, homeownerId) || other.homeownerId == homeownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.descriptionText, descriptionText) || other.descriptionText == descriptionText)&&(identical(other.descriptionVoiceUrl, descriptionVoiceUrl) || other.descriptionVoiceUrl == descriptionVoiceUrl)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.status, status) || other.status == status)&&(identical(other.acceptedBidId, acceptedBidId) || other.acceptedBidId == acceptedBidId)&&(identical(other.acceptedWorkerId, acceptedWorkerId) || other.acceptedWorkerId == acceptedWorkerId)&&(identical(other.trackingJobId, trackingJobId) || other.trackingJobId == trackingJobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.homeownerDisplayName, homeownerDisplayName) || other.homeownerDisplayName == homeownerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,homeownerId,title,tag,descriptionText,descriptionVoiceUrl,const DeepCollectionEquality().hash(_media),location,locationLat,locationLng,status,acceptedBidId,acceptedWorkerId,trackingJobId,createdAt,acceptedAt,homeownerDisplayName);

@override
String toString() {
  return 'PostedJob(jobId: $jobId, homeownerId: $homeownerId, title: $title, tag: $tag, descriptionText: $descriptionText, descriptionVoiceUrl: $descriptionVoiceUrl, media: $media, location: $location, locationLat: $locationLat, locationLng: $locationLng, status: $status, acceptedBidId: $acceptedBidId, acceptedWorkerId: $acceptedWorkerId, trackingJobId: $trackingJobId, createdAt: $createdAt, acceptedAt: $acceptedAt, homeownerDisplayName: $homeownerDisplayName)';
}


}

/// @nodoc
abstract mixin class _$PostedJobCopyWith<$Res> implements $PostedJobCopyWith<$Res> {
  factory _$PostedJobCopyWith(_PostedJob value, $Res Function(_PostedJob) _then) = __$PostedJobCopyWithImpl;
@override @useResult
$Res call({
 String jobId, String homeownerId, String title,@JsonKey(fromJson: _postedJobTagFromJson, toJson: _postedJobTagToJson) JobPostTag tag, String? descriptionText, String? descriptionVoiceUrl, List<JobMedia> media, StructuredAddress location, double locationLat, double locationLng,@JsonKey(fromJson: _postedJobStatusFromJson, toJson: _postedJobStatusToJson) PostedJobStatus status, String? acceptedBidId, String? acceptedWorkerId, String? trackingJobId, DateTime createdAt, DateTime? acceptedAt, String? homeownerDisplayName
});


@override $StructuredAddressCopyWith<$Res> get location;

}
/// @nodoc
class __$PostedJobCopyWithImpl<$Res>
    implements _$PostedJobCopyWith<$Res> {
  __$PostedJobCopyWithImpl(this._self, this._then);

  final _PostedJob _self;
  final $Res Function(_PostedJob) _then;

/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? homeownerId = null,Object? title = null,Object? tag = null,Object? descriptionText = freezed,Object? descriptionVoiceUrl = freezed,Object? media = null,Object? location = null,Object? locationLat = null,Object? locationLng = null,Object? status = null,Object? acceptedBidId = freezed,Object? acceptedWorkerId = freezed,Object? trackingJobId = freezed,Object? createdAt = null,Object? acceptedAt = freezed,Object? homeownerDisplayName = freezed,}) {
  return _then(_PostedJob(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,homeownerId: null == homeownerId ? _self.homeownerId : homeownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as JobPostTag,descriptionText: freezed == descriptionText ? _self.descriptionText : descriptionText // ignore: cast_nullable_to_non_nullable
as String?,descriptionVoiceUrl: freezed == descriptionVoiceUrl ? _self.descriptionVoiceUrl : descriptionVoiceUrl // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<JobMedia>,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as StructuredAddress,locationLat: null == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double,locationLng: null == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostedJobStatus,acceptedBidId: freezed == acceptedBidId ? _self.acceptedBidId : acceptedBidId // ignore: cast_nullable_to_non_nullable
as String?,acceptedWorkerId: freezed == acceptedWorkerId ? _self.acceptedWorkerId : acceptedWorkerId // ignore: cast_nullable_to_non_nullable
as String?,trackingJobId: freezed == trackingJobId ? _self.trackingJobId : trackingJobId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,homeownerDisplayName: freezed == homeownerDisplayName ? _self.homeownerDisplayName : homeownerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostedJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredAddressCopyWith<$Res> get location {
  
  return $StructuredAddressCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
