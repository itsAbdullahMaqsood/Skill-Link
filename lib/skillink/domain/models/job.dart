import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skilllink/skillink/domain/models/bid.dart';
import 'package:skilllink/skillink/domain/models/job_status.dart';
import 'package:skilllink/skillink/domain/models/payment_method.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';

part 'job.freezed.dart';
part 'job.g.dart';

@freezed
abstract class Job with _$Job {
  const factory Job({
    required String jobId,
    required String userId,
    String? workerId,
    required String serviceType,
    required JobStatus status,
    required DateTime scheduledDate,
    double? finalPrice,
    @Default([]) List<Bid> bidHistory,
    required String description,
    @Default([]) List<String> photoUrls,
    required StructuredAddress address,
    required PaymentMethod paymentMethod,
    @Default(false) bool paid,
    DateTime? paidAt,
    required DateTime createdAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
