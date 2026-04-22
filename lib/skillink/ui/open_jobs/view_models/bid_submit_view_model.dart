import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/posted_job.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/utils/error_mapper.dart';

class BidSubmitState {
  const BidSubmitState({
    this.visitingText = '',
    this.jobEstimateText = '',
    this.note = '',
    this.etaMinutes,
    this.isSubmitting = false,
    this.isEtaLoading = false,
    this.errorMessage,
  });

  final String visitingText;
  final String jobEstimateText;
  final String note;
  final int? etaMinutes;
  final bool isSubmitting;
  final bool isEtaLoading;
  final String? errorMessage;

  BidSubmitState copyWith({
    String? visitingText,
    String? jobEstimateText,
    String? note,
    int? etaMinutes,
    bool clearEta = false,
    bool? isSubmitting,
    bool? isEtaLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BidSubmitState(
      visitingText: visitingText ?? this.visitingText,
      jobEstimateText: jobEstimateText ?? this.jobEstimateText,
      note: note ?? this.note,
      etaMinutes: clearEta ? null : (etaMinutes ?? this.etaMinutes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEtaLoading: isEtaLoading ?? this.isEtaLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BidSubmitViewModel extends StateNotifier<BidSubmitState> {
  BidSubmitViewModel(this._ref, this._job) : super(const BidSubmitState()) {
    refreshEta();
  }

  final Ref _ref;
  final PostedJob _job;

  void setVisiting(String v) => state = state.copyWith(visitingText: v);
  void setJobEstimate(String v) => state = state.copyWith(jobEstimateText: v);
  void setNote(String v) => state = state.copyWith(note: v);

  Future<void> refreshEta() async {
    state = state.copyWith(isEtaLoading: true, clearError: true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      final maps = _ref.read(mapsDistanceServiceProvider);
      final r = await maps.drivingEtaMinutes(
        originLat: pos.latitude,
        originLng: pos.longitude,
        destLat: _job.locationLat,
        destLng: _job.locationLng,
      );
      if (!mounted) return;
      if (r.isFailure) {
        state = state.copyWith(
          isEtaLoading: false,
          errorMessage: r.errorOrNull,
        );
        return;
      }
      state = state.copyWith(
        isEtaLoading: false,
        etaMinutes: r.valueOrNull,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isEtaLoading: false,
        errorMessage: ErrorMapper.fromException(e),
      );
    }
  }

  Future<String?> submit() async {
    final uid = _ref.read(authViewModelProvider).user?.id;
    if (uid == null) return 'Not signed in.';
    final v = double.tryParse(state.visitingText.trim());
    final j = double.tryParse(state.jobEstimateText.trim());
    if (v == null || j == null) return 'Enter valid amounts.';
    final eta = state.etaMinutes ?? 0;
    state = state.copyWith(isSubmitting: true, clearError: true);
    final res = await _ref.read(postedJobBidRepositoryProvider).submitWorkerBid(
          jobId: _job.jobId,
          workerId: uid,
          visitingCharges: v,
          jobChargesEstimate: j,
          etaMinutes: eta,
          note: state.note.trim().isEmpty ? null : state.note.trim(),
        );
    if (!mounted) return null;
    state = state.copyWith(isSubmitting: false);
    return res.isFailure ? (res.errorOrNull ?? 'Failed') : null;
  }
}

final bidSubmitViewModelProvider = StateNotifierProvider.autoDispose
    .family<BidSubmitViewModel, BidSubmitState, PostedJob>((ref, job) {
  return BidSubmitViewModel(ref, job);
});
