import 'package:skilllink/skillink/domain/models/job_post_tag.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_status.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/utils/result.dart';

class CreatePostedJobPayload {
  const CreatePostedJobPayload({
    required this.homeownerId,
    required this.homeownerDisplayName,
    required this.title,
    required this.tag,
    this.descriptionText,
    this.descriptionVoiceUrl,
    this.media = const <JobMedia>[],
    required this.location,
    required this.locationLat,
    required this.locationLng,
  });

  final String homeownerId;
  final String homeownerDisplayName;
  final String title;
  final JobPostTag tag;
  final String? descriptionText;
  final String? descriptionVoiceUrl;
  final List<JobMedia> media;
  final StructuredAddress location;
  final double locationLat;
  final double locationLng;
}

abstract class PostedJobRepository {
  Future<Result<String>> createPostedJob(CreatePostedJobPayload payload);

  Future<Result<void>> updatePostedJob(PostedJob job);

  Future<Result<void>> softDeletePostedJob({
    required String jobId,
    required String homeownerId,
  });

  Stream<PostedJob?> watchPostedJob(String jobId);

  Stream<List<PostedJob>> watchMyPostedJobs(String homeownerId);

  Stream<List<PostedJob>> watchOpenPostedJobsForTags(List<JobPostTag> tags);
}
