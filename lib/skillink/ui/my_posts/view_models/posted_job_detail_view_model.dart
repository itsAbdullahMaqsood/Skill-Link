import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_bid_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_repository.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/domain/models/posted_job_bid.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

class PostedJobDetailState {
  const PostedJobDetailState({
    this.job,
    this.bids = const <PostedJobBid>[],
    this.isLoading = true,
    this.errorMessage,
  });

  final PostedJob? job;
  final List<PostedJobBid> bids;
  final bool isLoading;
  final String? errorMessage;
}

class PostedJobDetailViewModel extends StateNotifier<PostedJobDetailState> {
  PostedJobDetailViewModel(this._ref, this._jobId)
      : super(const PostedJobDetailState()) {
    _jobSub = _ref.read(postedJobRepositoryProvider).watchPostedJob(_jobId).listen((
      job,
    ) {
      if (!mounted) return;
      state = PostedJobDetailState(
        job: job,
        bids: state.bids,
        isLoading: false,
        errorMessage: job == null ? 'Job not found.' : null,
      );
    });
    _bidsSub =
        _ref.read(postedJobBidRepositoryProvider).watchBidsForJob(_jobId).listen((
      bids,
    ) {
      if (!mounted) return;
      state = PostedJobDetailState(
        job: state.job,
        bids: bids,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      );
    });
  }

  final Ref _ref;
  final String _jobId;
  StreamSubscription<PostedJob?>? _jobSub;
  StreamSubscription<List<PostedJobBid>>? _bidsSub;

  PostedJobBidRepository get _bidsRepo => _ref.read(postedJobBidRepositoryProvider);
  PostedJobRepository get _postedRepo => _ref.read(postedJobRepositoryProvider);

  Future<({String? error, String? trackingJobId})> acceptBid(String bidId) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) {
      return (error: 'Not signed in.', trackingJobId: null);
    }
    final res = await _bidsRepo.homeownerAcceptBid(
      jobId: _jobId,
      bidId: bidId,
      homeownerId: uid,
    );
    if (res.isFailure) {
      return (error: res.errorOrNull ?? 'Failed', trackingJobId: null);
    }
    return (error: null, trackingJobId: res.valueOrNull?.trackingJobId);
  }

  Future<String?> rejectBid(String bidId) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final res = await _bidsRepo.homeownerRejectBid(
      jobId: _jobId,
      bidId: bidId,
      homeownerId: uid,
    );
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }

  Future<String?> counterOffer({
    required double visiting,
    required double jobEstimate,
    String? note,
  }) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final res = await _bidsRepo.homeownerCounterOffer(
      jobId: _jobId,
      homeownerId: uid,
      visitingCharges: visiting,
      jobChargesEstimate: jobEstimate,
      note: note,
    );
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }

  Future<({String? error, String? trackingJobId})> acceptCounterOffer(
    String counterBidId,
  ) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) {
      return (error: 'Not signed in.', trackingJobId: null);
    }
    final res = await _bidsRepo.workerAcceptCounterOffer(
      jobId: _jobId,
      counterBidId: counterBidId,
      workerId: uid,
    );
    if (res.isFailure) {
      return (error: res.errorOrNull ?? 'Failed', trackingJobId: null);
    }
    return (error: null, trackingJobId: res.valueOrNull?.trackingJobId);
  }

  Future<String?> rejectCounterOffer(String counterBidId) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final res = await _bidsRepo.workerRejectCounterOffer(
      jobId: _jobId,
      counterBidId: counterBidId,
      workerId: uid,
    );
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }

  Future<String?> withdrawOwnCounterOffer(String bidId) async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final res = await _bidsRepo.homeownerWithdrawCounterOffer(
      jobId: _jobId,
      bidId: bidId,
      homeownerId: uid,
    );
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }

  Future<String?> deletePost() async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final res = await _postedRepo.softDeletePostedJob(jobId: _jobId, homeownerId: uid);
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }

  @override
  void dispose() {
    _jobSub?.cancel();
    _bidsSub?.cancel();
    super.dispose();
  }
}

final postedJobDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<PostedJobDetailViewModel, PostedJobDetailState, String>((ref, jobId) {
  return PostedJobDetailViewModel(ref, jobId);
});
