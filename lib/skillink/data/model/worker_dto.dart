import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';

part 'worker_dto.freezed.dart';
part 'worker_dto.g.dart';

@freezed
abstract class WorkerDto with _$WorkerDto {
  const factory WorkerDto({
    required String id,
    required String name,
    required String email,
    String? phone,
    @Default(<String>[]) List<String> skillTypes,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(false) bool verificationStatus,
    double? latitude,
    double? longitude,
    double? hourlyRate,
    String? avatarUrl,
    String? bio,
    double? distanceKm,
    @Default(<String>[]) List<String> portfolioUrls,
    int? experienceYears,
    double? serviceRadiusKm,
  }) = _WorkerDto;

  factory WorkerDto.fromJson(Map<String, dynamic> json) =>
      _$WorkerDtoFromJson(json);
}

extension WorkerDtoMapper on WorkerDto {
  Worker toDomain() {
    return Worker(
      id: id,
      name: name,
      email: email,
      phone: phone ?? '',
      skillTypes: skillTypes,
      rating: rating,
      reviewCount: reviewCount,
      verificationStatus: verificationStatus,
      latitude: latitude,
      longitude: longitude,
      hourlyRate: hourlyRate,
      avatarUrl: avatarUrl,
      bio: bio,
      distanceKm: distanceKm,
      portfolioUrls: portfolioUrls,
      experienceYears: experienceYears,
      serviceRadiusKm: serviceRadiusKm,
    );
  }
}
