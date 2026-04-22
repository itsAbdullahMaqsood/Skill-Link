// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkerDto {

 String get id; String get name; String get email; String? get phone; List<String> get skillTypes; double get rating; int get reviewCount; bool get verificationStatus; double? get latitude; double? get longitude; double? get hourlyRate; String? get avatarUrl; String? get bio; double? get distanceKm; List<String> get portfolioUrls; int? get experienceYears; double? get serviceRadiusKm;
/// Create a copy of WorkerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerDtoCopyWith<WorkerDto> get copyWith => _$WorkerDtoCopyWithImpl<WorkerDto>(this as WorkerDto, _$identity);

  /// Serializes this WorkerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.skillTypes, skillTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other.portfolioUrls, portfolioUrls)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.serviceRadiusKm, serviceRadiusKm) || other.serviceRadiusKm == serviceRadiusKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,const DeepCollectionEquality().hash(skillTypes),rating,reviewCount,verificationStatus,latitude,longitude,hourlyRate,avatarUrl,bio,distanceKm,const DeepCollectionEquality().hash(portfolioUrls),experienceYears,serviceRadiusKm);

@override
String toString() {
  return 'WorkerDto(id: $id, name: $name, email: $email, phone: $phone, skillTypes: $skillTypes, rating: $rating, reviewCount: $reviewCount, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, hourlyRate: $hourlyRate, avatarUrl: $avatarUrl, bio: $bio, distanceKm: $distanceKm, portfolioUrls: $portfolioUrls, experienceYears: $experienceYears, serviceRadiusKm: $serviceRadiusKm)';
}


}

/// @nodoc
abstract mixin class $WorkerDtoCopyWith<$Res>  {
  factory $WorkerDtoCopyWith(WorkerDto value, $Res Function(WorkerDto) _then) = _$WorkerDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? phone, List<String> skillTypes, double rating, int reviewCount, bool verificationStatus, double? latitude, double? longitude, double? hourlyRate, String? avatarUrl, String? bio, double? distanceKm, List<String> portfolioUrls, int? experienceYears, double? serviceRadiusKm
});




}
/// @nodoc
class _$WorkerDtoCopyWithImpl<$Res>
    implements $WorkerDtoCopyWith<$Res> {
  _$WorkerDtoCopyWithImpl(this._self, this._then);

  final WorkerDto _self;
  final $Res Function(WorkerDto) _then;

/// Create a copy of WorkerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? skillTypes = null,Object? rating = null,Object? reviewCount = null,Object? verificationStatus = null,Object? latitude = freezed,Object? longitude = freezed,Object? hourlyRate = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? distanceKm = freezed,Object? portfolioUrls = null,Object? experienceYears = freezed,Object? serviceRadiusKm = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,skillTypes: null == skillTypes ? _self.skillTypes : skillTypes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,hourlyRate: freezed == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,portfolioUrls: null == portfolioUrls ? _self.portfolioUrls : portfolioUrls // ignore: cast_nullable_to_non_nullable
as List<String>,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,serviceRadiusKm: freezed == serviceRadiusKm ? _self.serviceRadiusKm : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerDto].
extension WorkerDtoPatterns on WorkerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerDto value)  $default,){
final _that = this;
switch (_that) {
case _WorkerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerDto value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerDto() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm)  $default,) {final _that = this;
switch (_that) {
case _WorkerDto():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm)?  $default,) {final _that = this;
switch (_that) {
case _WorkerDto() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkerDto implements WorkerDto {
  const _WorkerDto({required this.id, required this.name, required this.email, this.phone, final  List<String> skillTypes = const <String>[], this.rating = 0.0, this.reviewCount = 0, this.verificationStatus = false, this.latitude, this.longitude, this.hourlyRate, this.avatarUrl, this.bio, this.distanceKm, final  List<String> portfolioUrls = const <String>[], this.experienceYears, this.serviceRadiusKm}): _skillTypes = skillTypes,_portfolioUrls = portfolioUrls;
  factory _WorkerDto.fromJson(Map<String, dynamic> json) => _$WorkerDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String? phone;
 final  List<String> _skillTypes;
@override@JsonKey() List<String> get skillTypes {
  if (_skillTypes is EqualUnmodifiableListView) return _skillTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillTypes);
}

@override@JsonKey() final  double rating;
@override@JsonKey() final  int reviewCount;
@override@JsonKey() final  bool verificationStatus;
@override final  double? latitude;
@override final  double? longitude;
@override final  double? hourlyRate;
@override final  String? avatarUrl;
@override final  String? bio;
@override final  double? distanceKm;
 final  List<String> _portfolioUrls;
@override@JsonKey() List<String> get portfolioUrls {
  if (_portfolioUrls is EqualUnmodifiableListView) return _portfolioUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_portfolioUrls);
}

@override final  int? experienceYears;
@override final  double? serviceRadiusKm;

/// Create a copy of WorkerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerDtoCopyWith<_WorkerDto> get copyWith => __$WorkerDtoCopyWithImpl<_WorkerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other._skillTypes, _skillTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other._portfolioUrls, _portfolioUrls)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.serviceRadiusKm, serviceRadiusKm) || other.serviceRadiusKm == serviceRadiusKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,const DeepCollectionEquality().hash(_skillTypes),rating,reviewCount,verificationStatus,latitude,longitude,hourlyRate,avatarUrl,bio,distanceKm,const DeepCollectionEquality().hash(_portfolioUrls),experienceYears,serviceRadiusKm);

@override
String toString() {
  return 'WorkerDto(id: $id, name: $name, email: $email, phone: $phone, skillTypes: $skillTypes, rating: $rating, reviewCount: $reviewCount, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, hourlyRate: $hourlyRate, avatarUrl: $avatarUrl, bio: $bio, distanceKm: $distanceKm, portfolioUrls: $portfolioUrls, experienceYears: $experienceYears, serviceRadiusKm: $serviceRadiusKm)';
}


}

/// @nodoc
abstract mixin class _$WorkerDtoCopyWith<$Res> implements $WorkerDtoCopyWith<$Res> {
  factory _$WorkerDtoCopyWith(_WorkerDto value, $Res Function(_WorkerDto) _then) = __$WorkerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? phone, List<String> skillTypes, double rating, int reviewCount, bool verificationStatus, double? latitude, double? longitude, double? hourlyRate, String? avatarUrl, String? bio, double? distanceKm, List<String> portfolioUrls, int? experienceYears, double? serviceRadiusKm
});




}
/// @nodoc
class __$WorkerDtoCopyWithImpl<$Res>
    implements _$WorkerDtoCopyWith<$Res> {
  __$WorkerDtoCopyWithImpl(this._self, this._then);

  final _WorkerDto _self;
  final $Res Function(_WorkerDto) _then;

/// Create a copy of WorkerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? skillTypes = null,Object? rating = null,Object? reviewCount = null,Object? verificationStatus = null,Object? latitude = freezed,Object? longitude = freezed,Object? hourlyRate = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? distanceKm = freezed,Object? portfolioUrls = null,Object? experienceYears = freezed,Object? serviceRadiusKm = freezed,}) {
  return _then(_WorkerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,skillTypes: null == skillTypes ? _self._skillTypes : skillTypes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,hourlyRate: freezed == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,portfolioUrls: null == portfolioUrls ? _self._portfolioUrls : portfolioUrls // ignore: cast_nullable_to_non_nullable
as List<String>,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,serviceRadiusKm: freezed == serviceRadiusKm ? _self.serviceRadiusKm : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
