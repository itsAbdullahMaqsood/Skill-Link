import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/posted_job_bid.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

final myPostedJobBidsStreamProvider = StreamProvider<List<PostedJobBid>>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.id));
  if (uid == null) {
    return const Stream<List<PostedJobBid>>.empty();
  }
  return ref.read(postedJobBidRepositoryProvider).watchBidsForWorker(uid);
});
