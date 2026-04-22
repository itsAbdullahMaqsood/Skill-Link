import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/open_job_post_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/booking/view_models/booking_view_model.dart';

enum OpenJobPostOutcome { success, failure }

class OpenJobPostState {
  const OpenJobPostState({
    this.currentStep = 0,
    this.description = '',
    this.localPhotoPaths = const <String>[],
    this.scheduledDate,
    this.timeSlot,
    this.serviceAddress = '',
    this.paymentMethod = ServiceRequestPaymentMethod.cash,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdPost,
  });

  final int currentStep;
  final String description;
  final List<String> localPhotoPaths;
  final DateTime? scheduledDate;

  final String? timeSlot;
  final String serviceAddress;
  final ServiceRequestPaymentMethod paymentMethod;
  final bool isSubmitting;
  final String? errorMessage;
  final OpenJobPost? createdPost;

  bool get isStep1Valid => description.trim().length >= 10;
  bool get isStep2Valid => scheduledDate != null && timeSlot != null;
  bool get isStep3Valid => serviceAddress.trim().length >= 4;

  OpenJobPostState copyWith({
    int? currentStep,
    String? description,
    List<String>? localPhotoPaths,
    DateTime? scheduledDate,
    String? timeSlot,
    String? serviceAddress,
    ServiceRequestPaymentMethod? paymentMethod,
    bool? isSubmitting,
    String? errorMessage,
    OpenJobPost? createdPost,
    bool clearError = false,
  }) {
    return OpenJobPostState(
      currentStep: currentStep ?? this.currentStep,
      description: description ?? this.description,
      localPhotoPaths: localPhotoPaths ?? this.localPhotoPaths,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      serviceAddress: serviceAddress ?? this.serviceAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdPost: createdPost ?? this.createdPost,
    );
  }
}

class OpenJobPostViewModel extends StateNotifier<OpenJobPostState> {
  OpenJobPostViewModel({
    required Ref ref,
    ImagePicker? picker,
  })  : _ref = ref,
        _picker = picker ?? ImagePicker(),
        super(const OpenJobPostState()) {
    _prefillFromProfile();
  }

  final Ref _ref;
  final ImagePicker _picker;

  void _prefillFromProfile() {
    final user = _ref.read(authViewModelProvider).user;
    if (user == null) return;
    final a = user.address;
    final parts = <String>[
      if (a.street.trim().isNotEmpty) a.street.trim(),
      if (a.area.trim().isNotEmpty) a.area.trim(),
      if (a.city.trim().isNotEmpty) a.city.trim(),
      if (a.postalCode.trim().isNotEmpty) a.postalCode.trim(),
    ];
    if (parts.isEmpty) return;
    state = state.copyWith(serviceAddress: parts.join(', '));
  }


  void next() {
    if (state.currentStep >= 2) return;
    state = state.copyWith(currentStep: state.currentStep + 1, clearError: true);
  }

  void back() {
    if (state.currentStep == 0) return;
    state = state.copyWith(currentStep: state.currentStep - 1, clearError: true);
  }


  void setDescription(String value) =>
      state = state.copyWith(description: value, clearError: true);

  static const maxPhotos = 4;

  Future<void> addPhoto() async {
    if (state.localPhotoPaths.length >= maxPhotos) {
      state = state.copyWith(
        errorMessage: 'You can attach up to $maxPhotos photos.',
      );
      return;
    }
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (file == null) return;
      state = state.copyWith(
        localPhotoPaths: [...state.localPhotoPaths, file.path],
        clearError: true,
      );
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: 'Could not attach photo: $e');
    }
  }

  void removePhoto(String path) {
    state = state.copyWith(
      localPhotoPaths:
          state.localPhotoPaths.where((p) => p != path).toList(),
    );
  }


  void setDate(DateTime d) =>
      state = state.copyWith(scheduledDate: d, clearError: true);

  void setTimeSlot(String slot) =>
      state = state.copyWith(timeSlot: slot, clearError: true);


  void setServiceAddress(String v) =>
      state = state.copyWith(serviceAddress: v, clearError: true);

  void setPaymentMethod(ServiceRequestPaymentMethod m) =>
      state = state.copyWith(paymentMethod: m, clearError: true);


  Future<OpenJobPostOutcome> submit() async {
    if (!state.isStep1Valid || !state.isStep2Valid || !state.isStep3Valid) {
      state = state.copyWith(errorMessage: 'Please complete every step.');
      return OpenJobPostOutcome.failure;
    }

    final slot = BookingTimeSlot.fromLabel(state.timeSlot!);
    if (slot == null) {
      state = state.copyWith(errorMessage: 'Please pick a time slot.');
      return OpenJobPostOutcome.failure;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final repo = _ref.read(openJobPostRepositoryProvider);

    final result = await repo.createOpenJobPost(
      CreateOpenJobPostInput(
        description: state.description.trim(),
        scheduledServiceDate: state.scheduledDate!,
        timeSlotStart: slot.start,
        timeSlotEnd: slot.end,
        serviceAddress: state.serviceAddress.trim(),
        paymentMethod: state.paymentMethod,
        localPhotoPaths: state.localPhotoPaths,
      ),
    );
    if (!mounted) return OpenJobPostOutcome.failure;

    return result.when(
      success: (post) {
        state = state.copyWith(isSubmitting: false, createdPost: post);
        _ref.invalidate(
          myOpenJobPostsProvider(ServiceRequestRole.customer),
        );
        return OpenJobPostOutcome.success;
      },
      failure: (message, _) {
        state = state.copyWith(isSubmitting: false, errorMessage: message);
        return OpenJobPostOutcome.failure;
      },
    );
  }
}

final openJobPostViewModelProvider = StateNotifierProvider.autoDispose<
    OpenJobPostViewModel, OpenJobPostState>((ref) {
  return OpenJobPostViewModel(ref: ref);
});
