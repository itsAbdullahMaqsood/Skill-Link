import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

enum BookingOutcome { success, failure }

class BookingTimeSlot {
  const BookingTimeSlot._(this.label, this.start, this.end, this.startHour);
  final String label;
  final String start;
  final String end;
  final int startHour;

  static const morning =
      BookingTimeSlot._('9:00–11:00 AM', '09:00', '11:00', 9);
  static const lateMorning =
      BookingTimeSlot._('11:00 AM–1:00 PM', '11:00', '13:00', 11);
  static const earlyAfternoon =
      BookingTimeSlot._('1:00–3:00 PM', '13:00', '15:00', 13);
  static const afternoon =
      BookingTimeSlot._('3:00–5:00 PM', '15:00', '17:00', 15);
  static const evening =
      BookingTimeSlot._('5:00–7:00 PM', '17:00', '19:00', 17);

  static const all = <BookingTimeSlot>[
    morning,
    lateMorning,
    earlyAfternoon,
    afternoon,
    evening,
  ];

  static BookingTimeSlot? fromLabel(String label) {
    for (final s in all) {
      if (s.label == label) return s;
    }
    return null;
  }
}

class BookingState {
  const BookingState({
    this.currentStep = 0,
    this.description = '',
    this.localPhotoPaths = const <String>[],
    this.scheduledDate,
    this.timeSlot,
    this.serviceAddress = '',
    this.paymentMethod = ServiceRequestPaymentMethod.cash,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdRequest,
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
  final ServiceRequest? createdRequest;

  bool get isStep1Valid => description.trim().length >= 10;
  bool get isStep2Valid => scheduledDate != null && timeSlot != null;
  bool get isStep3Valid => serviceAddress.trim().length >= 4;

  BookingState copyWith({
    int? currentStep,
    String? description,
    List<String>? localPhotoPaths,
    DateTime? scheduledDate,
    String? timeSlot,
    String? serviceAddress,
    ServiceRequestPaymentMethod? paymentMethod,
    bool? isSubmitting,
    String? errorMessage,
    ServiceRequest? createdRequest,
    bool clearError = false,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      description: description ?? this.description,
      localPhotoPaths: localPhotoPaths ?? this.localPhotoPaths,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      serviceAddress: serviceAddress ?? this.serviceAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdRequest: createdRequest ?? this.createdRequest,
    );
  }
}

class BookingViewModel extends StateNotifier<BookingState> {
  BookingViewModel({
    required Ref ref,
    required this.workerId,
    ImagePicker? picker,
  })  : _ref = ref,
        _picker = picker ?? ImagePicker(),
        super(const BookingState()) {
    _prefillFromProfile();
  }

  final Ref _ref;
  final String workerId;
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


  Future<BookingOutcome> submit() async {
    if (!state.isStep1Valid || !state.isStep2Valid || !state.isStep3Valid) {
      state = state.copyWith(errorMessage: 'Please complete every step.');
      return BookingOutcome.failure;
    }

    final slot = BookingTimeSlot.fromLabel(state.timeSlot!);
    if (slot == null) {
      state = state.copyWith(errorMessage: 'Please pick a time slot.');
      return BookingOutcome.failure;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final repo = _ref.read(serviceRequestRepositoryProvider);

    final result = await repo.createServiceRequest(
      CreateServiceRequestInput(
        requestedWorkerId: workerId,
        description: state.description.trim(),
        scheduledServiceDate: state.scheduledDate!,
        timeSlotStart: slot.start,
        timeSlotEnd: slot.end,
        serviceAddress: state.serviceAddress.trim(),
        paymentMethod: state.paymentMethod,
        localPhotoPaths: state.localPhotoPaths,
      ),
    );
    if (!mounted) return BookingOutcome.failure;

    return result.when(
      success: (req) {
        state = state.copyWith(isSubmitting: false, createdRequest: req);
        return BookingOutcome.success;
      },
      failure: (message, _) {
        state = state.copyWith(isSubmitting: false, errorMessage: message);
        return BookingOutcome.failure;
      },
    );
  }
}

class BookingArgs {
  const BookingArgs({required this.workerId});
  final String workerId;

  @override
  bool operator ==(Object other) =>
      other is BookingArgs && other.workerId == workerId;

  @override
  int get hashCode => workerId.hashCode;
}

final bookingViewModelProvider = StateNotifierProvider.autoDispose
    .family<BookingViewModel, BookingState, BookingArgs>((ref, args) {
  return BookingViewModel(ref: ref, workerId: args.workerId);
});
