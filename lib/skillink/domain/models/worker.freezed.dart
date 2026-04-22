// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Worker {

 String get id; String get name; String get email; String get phone; List<String> get skillTypes; double get rating; int get reviewCount; bool get verificationStatus; double? get latitude; double? get longitude; double? get hourlyRate; String? get avatarUrl; String? get bio; double? get distanceKm; List<String> get portfolioUrls; int? get experienceYears; double? get serviceRadiusKm;/// Labour API `role` (e.g. worker).
 String? get role;/// Labour API `status` (e.g. approved).
 String? get accountStatus;/// Non-numeric `pastExperience` text from the API.
 String? get experienceNote;
/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerCopyWith<Worker> get copyWith => _$WorkerCopyWithImpl<Worker>(this as Worker, _$identity);

  /// Serializes this Worker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.skillTypes, skillTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other.portfolioUrls, portfolioUrls)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.serviceRadiusKm, serviceRadiusKm) || other.serviceRadiusKm == serviceRadiusKm)&&(identical(other.role, role) || other.role == role)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.experienceNote, experienceNote) || other.experienceNote == experienceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,email,phone,const DeepCollectionEquality().hash(skillTypes),rating,reviewCount,verificationStatus,latitude,longitude,hourlyRate,avatarUrl,bio,distanceKm,const DeepCollectionEquality().hash(portfolioUrls),experienceYears,serviceRadiusKm,role,accountStatus,experienceNote]);

@override
String toString() {
  return 'Worker(id: $id, name: $name, email: $email, phone: $phone, skillTypes: $skillTypes, rating: $rating, reviewCount: $reviewCount, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, hourlyRate: $hourlyRate, avatarUrl: $avatarUrl, bio: $bio, distanceKm: $distanceKm, portfolioUrls: $portfolioUrls, experienceYears: $experienceYears, serviceRadiusKm: $serviceRadiusKm, role: $role, accountStatus: $accountStatus, experienceNote: $experienceNote)';
}


}

/// @nodoc
abstract mixin class $WorkerCopyWith<$Res>  {
  factory $WorkerCopyWith(Worker value, $Res Function(Worker) _then) = _$WorkerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String phone, List<String> skillTypes, double rating, int reviewCount, bool verificationStatus, double? latitude, double? longitude, double? hourlyRate, String? avatarUrl, String? bio, double? distanceKm, List<String> portfolioUrls, int? experienceYears, double? serviceRadiusKm, String? role, String? accountStatus, String? experienceNote
});




}
/// @nodoc
class _$WorkerCopyWithImpl<$Res>
    implements $WorkerCopyWith<$Res> {
  _$WorkerCopyWithImpl(this._self, this._then);

  final Worker _self;
  final $Res Function(Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? skillTypes = null,Object? rating = null,Object? reviewCount = null,Object? verificationStatus = null,Object? latitude = freezed,Object? longitude = freezed,Object? hourlyRate = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? distanceKm = freezed,Object? portfolioUrls = null,Object? experienceYears = freezed,Object? serviceRadiusKm = freezed,Object? role = freezed,Object? accountStatus = freezed,Object? experienceNote = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,skillTypes: null == skillTypes ? _self.skillTypes : skillTypes // ignore: cast_nullable_to_non_nullable
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
as double?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,accountStatus: freezed == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String?,experienceNote: freezed == experienceNote ? _self.experienceNote : experienceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Worker].
extension WorkerPatterns on Worker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Worker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Worker value)  $default,){
final _that = this;
switch (_that) {
case _Worker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Worker value)?  $default,){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm,  String? role,  String? accountStatus,  String? experienceNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm,_that.role,_that.accountStatus,_that.experienceNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm,  String? role,  String? accountStatus,  String? experienceNote)  $default,) {final _that = this;
switch (_that) {
case _Worker():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm,_that.role,_that.accountStatus,_that.experienceNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String phone,  List<String> skillTypes,  double rating,  int reviewCount,  bool verificationStatus,  double? latitude,  double? longitude,  double? hourlyRate,  String? avatarUrl,  String? bio,  double? distanceKm,  List<String> portfolioUrls,  int? experienceYears,  double? serviceRadiusKm,  String? role,  String? accountStatus,  String? experienceNote)?  $default,) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.skillTypes,_that.rating,_that.reviewCount,_that.verificationStatus,_that.latitude,_that.longitude,_that.hourlyRate,_that.avatarUrl,_that.bio,_that.distanceKm,_that.portfolioUrls,_that.experienceYears,_that.serviceRadiusKm,_that.role,_that.accountStatus,_that.experienceNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Worker implements Worker {
  const _Worker({required this.id, required this.name, required this.email, required this.phone, required final  List<String> skillTypes, required this.rating, required this.reviewCount, required this.verificationStatus, this.latitude, this.longitude, this.hourlyRate, this.avatarUrl, this.bio, this.distanceKm, final  List<String> portfolioUrls = const <String>[], this.experienceYears, this.serviceRadiusKm, this.role, this.accountStatus, this.experienceNote}): _skillTypes = skillTypes,_portfolioUrls = portfolioUrls;
  factory _Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String phone;
 final  List<String> _skillTypes;
@override List<String> get skillTypes {
  if (_skillTypes is EqualUnmodifiableListView) return _skillTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillTypes);
}

@override final  double rating;
@override final  int reviewCount;
@override final  bool verificationStatus;
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
/// Labour API `role` (e.g. worker).
@override final  String? role;
/// Labour API `status` (e.g. approved).
@override final  String? accountStatus;
/// Non-numeric `pastExperience` text from the API.
@override final  String? experienceNote;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerCopyWith<_Worker> get copyWith => __$WorkerCopyWithImpl<_Worker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other._skillTypes, _skillTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other._portfolioUrls, _portfolioUrls)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.serviceRadiusKm, serviceRadiusKm) || other.serviceRadiusKm == serviceRadiusKm)&&(identical(other.role, role) || other.role == role)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.experienceNote, experienceNote) || other.experienceNote == experienceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,email,phone,const DeepCollectionEquality().hash(_skillTypes),rating,reviewCount,verificationStatus,latitude,longitude,hourlyRate,avatarUrl,bio,distanceKm,const DeepCollectionEquality().hash(_portfolioUrls),experienceYears,serviceRadiusKm,role,accountStatus,experienceNote]);

@override
String toString() {
  return 'Worker(id: $id, name: $name, email: $email, phone: $phone, skillTypes: $skillTypes, rating: $rating, reviewCount: $reviewCount, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, hourlyRate: $hourlyRate, avatarUrl: $avatarUrl, bio: $bio, distanceKm: $distanceKm, portfolioUrls: $portfolioUrls, experienceYears: $experienceYears, serviceRadiusKm: $serviceRadiusKm, role: $role, accountStatus: $accountStatus, experienceNote: $experienceNote)';
}


}

/// @nodoc
abstract mixin class _$WorkerCopyWith<$Res> implements $WorkerCopyWith<$Res> {
  factory _$WorkerCopyWith(_Worker value, $Res Function(_Worker) _then) = __$WorkerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String phone, List<String> skillTypes, double rating, int reviewCount, bool verificationStatus, double? latitude, double? longitude, double? hourlyRate, String? avatarUrl, String? bio, double? distanceKm, List<String> portfolioUrls, int? experienceYears, double? serviceRadiusKm, String? role, String? accountStatus, String? experienceNote
});




}
/// @nodoc
class __$WorkerCopyWithImpl<$Res>
    implements _$WorkerCopyWith<$Res> {
  __$WorkerCopyWithImpl(this._self, this._then);

  final _Worker _self;
  final $Res Function(_Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? skillTypes = null,Object? rating = null,Object? reviewCount = null,Object? verificationStatus = null,Object? latitude = freezed,Object? longitude = freezed,Object? hourlyRate = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? distanceKm = freezed,Object? portfolioUrls = null,Object? experienceYears = freezed,Object? serviceRadiusKm = freezed,Object? role = freezed,Object? accountStatus = freezed,Object? experienceNote = freezed,}) {
  return _then(_Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,skillTypes: null == skillTypes ? _self._skillTypes : skillTypes // ignore: cast_nullable_to_non_nullable
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
as double?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,accountStatus: freezed == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String?,experienceNote: freezed == experienceNote ? _self.experienceNote : experienceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
