import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/chat/chat_service.dart';
import 'package:skilllink/services/google_geocoding_service.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/skillink/data/repositories/ai_repository.dart';
import 'package:skilllink/skillink/data/repositories/anomaly_repository.dart';
import 'package:skilllink/skillink/data/repositories/auth_repository.dart';
import 'package:skilllink/skillink/data/repositories/chat_repository.dart';
import 'package:skilllink/skillink/data/repositories/completion_report_repository.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/data/repositories/job_repository.dart';
import 'package:skilllink/skillink/data/repositories/open_job_post_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_bid_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_job_repository.dart';
import 'package:skilllink/skillink/data/repositories/posted_jobs_hub.dart';
import 'package:skilllink/skillink/data/repositories/remote_ai_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_anomaly_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_iot_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_job_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_open_job_post_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_service_request_repository.dart';
import 'package:skilllink/skillink/data/repositories/remote_worker_repository.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/domain/models/open_job_post.dart';
import 'package:skilllink/skillink/domain/models/open_job_post_bid.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart';
import 'package:skilllink/skillink/data/repositories/socketio_chat_repository.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/data/services/api_service.dart';
import 'package:skilllink/skillink/data/services/fcm_service.dart';
import 'package:skilllink/skillink/data/services/local_notifications_service.dart';
import 'package:skilllink/skillink/data/services/maps_distance_service.dart';
import 'package:skilllink/skillink/data/services/media_upload_service.dart';
import 'package:skilllink/skillink/testing/fakes/fake_ai_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_anomaly_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_auth_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_chat_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_completion_report_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_iot_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_job_repository.dart';
import 'package:skilllink/skillink/testing/fakes/fake_posted_jobs_hub.dart';
import 'package:skilllink/skillink/testing/fakes/fake_worker_repository.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

const kUseFakeRepositories = true;

const kUseFakeWorkerRepository = false;
const kUseFakeAuthRepository = false;

const kUseFakeAiRepository = false;

final skillChainAuthServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
    'skillChainAuthServiceProvider must be overridden in main().',
  );
});

final skillChainChatServiceProvider = Provider<ChatService>((ref) {
  throw UnimplementedError(
    'skillChainChatServiceProvider must be overridden in main().',
  );
});

final currentLabourUserProvider = FutureProvider<sc.UserModel?>((ref) async {
  ref.watch(authViewModelProvider);
  final auth = ref.watch(skillChainAuthServiceProvider);
  if (!await auth.isLoggedIn()) return null;
  return auth.getCurrentUser();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    authService: ref.watch(skillChainAuthServiceProvider),
  );
});

final labourServiceIdToNameProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final auth = ref.watch(skillChainAuthServiceProvider);
  final token = await auth.getAccessToken();
  if (token == null || token.isEmpty) return {};
  final items = await SignupApiService().fetchActiveLabourServices(token);
  return {for (final s in items) s.id: s.name};
});

final mediaUploadServiceProvider =
    Provider<MediaUploadService>((ref) => MediaUploadService());

final mapsDistanceServiceProvider =
    Provider<MapsDistanceService>((ref) => MapsDistanceService());

final postedJobsHubProvider = Provider<PostedJobsHub>((ref) {
  final notifications = ref.watch(localNotificationsServiceProvider);
  final jobs = ref.watch(jobRepositoryProvider);
  if (kUseFakeRepositories) {
    final hub = FakePostedJobsHub(
      jobRepository: jobs,
      notifications: notifications,
      currentUserId: () => ref.read(authViewModelProvider).user?.id,
    );
    ref.onDispose(hub.dispose);
    return hub;
  }
  throw UnimplementedError(
    'A real PostedJobsHub is not yet wired to the new SkillLink backend.',
  );
});

final postedJobRepositoryProvider = Provider<PostedJobRepository>((ref) {
  return ref.watch(postedJobsHubProvider);
});

final postedJobBidRepositoryProvider = Provider<PostedJobBidRepository>((ref) {
  return ref.watch(postedJobsHubProvider);
});

final localNotificationsServiceProvider = Provider<LocalNotificationsService>(
    (ref) => LocalNotificationsService());

final fcmServiceProvider = Provider<FcmService>((ref) {
  final svc = FcmService();
  ref.onDispose(svc.dispose);
  return svc;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseFakeAuthRepository) return FakeAuthRepository();
  return SkillChainAuthRepository(
    authService: ref.watch(skillChainAuthServiceProvider),
    api: ref.watch(apiServiceProvider),
  );
});

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final useFakeWorker = kUseFakeRepositories && kUseFakeWorkerRepository;
  if (useFakeWorker) {
    return FakeWorkerRepository(
      authService: ref.watch(skillChainAuthServiceProvider),
    );
  }
  return RemoteWorkerRepository(
    apiService: ref.watch(apiServiceProvider),
    authService: ref.watch(skillChainAuthServiceProvider),
  );
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  if (kUseFakeRepositories) {
    final fake = FakeJobRepository();
    ref.onDispose(fake.dispose);
    return fake;
  }
  return RemoteJobRepository(apiService: ref.watch(apiServiceProvider));
});

final serviceRequestRepositoryProvider =
    Provider<ServiceRequestRepository>((ref) {
  return RemoteServiceRequestRepository(
    apiService: ref.watch(apiServiceProvider),
  );
});

final openJobPostRepositoryProvider = Provider<OpenJobPostRepository>((ref) {
  return RemoteOpenJobPostRepository(
    apiService: ref.watch(apiServiceProvider),
  );
});

final myOpenJobPostsProvider = FutureProvider.autoDispose
    .family<List<OpenJobPost>, ServiceRequestRole>((ref, role) async {
  final repo = ref.watch(openJobPostRepositoryProvider);
  final result = await repo.listMyOpenJobPosts(role: role);
  return result.when(
    success: (list) => list,
    failure: (message, _) => throw Exception(message),
  );
});

final discoverOpenJobPostsProvider =
    FutureProvider.autoDispose<List<OpenJobPost>>((ref) async {
  final repo = ref.watch(openJobPostRepositoryProvider);
  final result = await repo.discoverOpenJobPosts();
  return result.when(
    success: (list) => list,
    failure: (message, _) => throw Exception(message),
  );
});

final openJobPostByIdProvider = FutureProvider.autoDispose
    .family<OpenJobPost, String>((ref, id) async {
  final repo = ref.watch(openJobPostRepositoryProvider);
  final result = await repo.getOpenJobPost(id);
  return result.when(
    success: (post) => post,
    failure: (message, _) => throw Exception(message),
  );
});

final openJobPostBidsProvider = FutureProvider.autoDispose
    .family<List<OpenJobPostBid>, String>((ref, postId) async {
  final repo = ref.watch(openJobPostRepositoryProvider);
  final result = await repo.listBidsForOpenJobPost(postId);
  return result.when(
    success: (bids) => bids,
    failure: (message, _) => throw Exception(message),
  );
});

final myServiceRequestsProvider = FutureProvider.autoDispose
    .family<List<ServiceRequest>, ServiceRequestRole>((ref, role) async {
  final repo = ref.watch(serviceRequestRepositoryProvider);
  final result = await repo.listMyRequests(role: role);
  return result.when(
    success: (list) => list,
    failure: (message, _) => throw Exception(message),
  );
});

final serviceRequestByIdProvider = FutureProvider.autoDispose
    .family<ServiceRequest, String>((ref, id) async {
  final repo = ref.watch(serviceRequestRepositoryProvider);
  final result = await repo.getServiceRequest(id);
  return result.when(
    success: (req) => req,
    failure: (message, _) => throw Exception(message),
  );
});

final googleGeocodingServiceProvider = Provider<GoogleGeocodingService>((ref) {
  return GoogleGeocodingService();
});

final forwardGeocodeProvider =
    FutureProvider.autoDispose.family<({double lat, double lng})?, String>(
  (ref, address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;
    final service = ref.watch(googleGeocodingServiceProvider);
    return service.forwardGeocode(trimmed);
  },
);

final iotRepositoryProvider = Provider<IotRepository>((ref) {
  if (kUseFakeRepositories) {
    final fake = FakeIotRepository(
      notifications: ref.watch(localNotificationsServiceProvider),
    );
    ref.onDispose(fake.dispose);
    return fake;
  }
  return RemoteIotRepository(
    apiService: ref.watch(apiServiceProvider),
    notifications: ref.watch(localNotificationsServiceProvider),
    currentUserId: () => ref.read(authViewModelProvider).user?.id ?? '',
  );
});

final anomalyRepositoryProvider = Provider<AnomalyRepository>((ref) {
  if (kUseFakeRepositories) {
    return FakeAnomalyRepository(iot: ref.watch(iotRepositoryProvider));
  }
  return RemoteAnomalyRepository(apiService: ref.watch(apiServiceProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  if (kUseFakeAiRepository) return FakeAiRepository();
  return RemoteAiRepository(apiService: ref.watch(apiServiceProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (kUseFakeRepositories) {
    final fake = FakeChatRepository();
    ref.onDispose(fake.dispose);
    return fake;
  }
  return SocketIoChatRepository(
    chatService: ref.watch(skillChainChatServiceProvider),
  );
});

final currentChatIdProvider = StateProvider<String?>((ref) => null);

final completionReportRepositoryProvider =
    Provider<CompletionReportRepository>((ref) {
  if (kUseFakeRepositories) {
    final fake = FakeCompletionReportRepository(
      jobRepository: ref.watch(jobRepositoryProvider),
    );
    ref.onDispose(fake.dispose);
    return fake;
  }
  throw UnimplementedError(
    'A real CompletionReportRepository is not yet wired to the new SkillLink '
    'backend.',
  );
});
