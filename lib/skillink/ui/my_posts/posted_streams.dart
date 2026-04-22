import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

final myPostedJobsStreamProvider = StreamProvider<List<PostedJob>>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.id));
  if (uid == null) {
    return const Stream<List<PostedJob>>.empty();
  }
  return ref.read(postedJobRepositoryProvider).watchMyPostedJobs(uid);
});
