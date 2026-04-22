import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';

class Routes {
  Routes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const roleSelect = '/role-select';
  static const completeProfile = '/complete-profile';

  static const homeowner = '/homeowner';
  static const worker = '/worker';

  static const homeownerHome = '/homeowner/home';
  static const homeownerMarketplace = '/homeowner/marketplace';
  static const homeownerAi = '/homeowner/ai';
  static const homeownerIot = '/homeowner/iot';

  static const workerJobs = '/worker/jobs';
  static const workerEarnings = '/worker/earnings';
  static const workerMyProfile = '/worker/profile';

  static String workerJobDetail(String jobId) => '/worker/jobs/$jobId';
  static const workerJobDetailPath = '/worker/jobs/:jobId';

  static const storybook = '/dev/storybook';

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const helpSupport = '/profile/help';
  static const notifications = '/notifications';

  static const about = '/about';
  static const myPosts = '/my-posts';
  static const myBids = '/my-bids';

  static const sentRequests = '/sent-requests';

  static String sentRequestDetail(String id) => '/sent-requests/$id';
  static const sentRequestDetailPath = '/sent-requests/:id';

  static const receivedRequests = '/received-requests';
  static String receivedRequestDetail(String id) => '/received-requests/$id';
  static const receivedRequestDetailPath = '/received-requests/:id';

  static String postedJobDetail(String jobId) => '/posted-jobs/$jobId';
  static const postedJobDetailPath = '/posted-jobs/:jobId';
  static const chatList = '/chat';

  static String chatThread(String chatId) => '/chat/$chatId';
  static const chatThreadPath = '/chat/:chatId';

  static const iotDevices = '/iot/devices';

  static const homeownerProfile = '/homeowner/profile';

  static const workerMarketplace = '/worker/marketplace';
  static const workerAi = '/worker/ai';

  static const workerChat = '/worker/chat';

  static const workerIncoming = '/worker/incoming';

  static const workerOngoing = '/worker/ongoing';


  static const jobHistory = '/jobs/history';

  static String booking(String workerId) => '/book/$workerId';
  static const bookingPath = '/book/:workerId';

  static const newOpenJobPost = '/open-job-post/new';

  static String openJobPostDetail(String id) => '/open-job-post/$id';
  static const openJobPostDetailPath = '/open-job-post/:id';

  static const discoverOpenJobs = '/open-job-posts/discover';

  static String bookingSuccess(String jobId) => '/booking/success/$jobId';
  static const bookingSuccessPath = '/booking/success/:jobId';

  static String jobTracking(String jobId) => '/jobs/$jobId';
  static const jobTrackingPath = '/jobs/:jobId';

  static String rateJob(String jobId) => '/jobs/$jobId/rate';
  static const rateJobPath = '/jobs/:jobId/rate';

  static String completionPrompt(String jobId) => '/completion-prompt/$jobId';
  static const completionPromptPath = '/completion-prompt/:jobId';


  static const alerts = '/iot/alerts';

  static String alertDetail(String id) => '/iot/alerts/$id';
  static const alertDetailPath = '/iot/alerts/:id';

  static String applianceDetail(String id) => '/iot/appliances/$id';
  static const applianceDetailPath = '/iot/appliances/:id';


  static String signup(UserRole role) => '/signup/${role.name}';

  static String workerProfile(String id, {bool hideBook = false}) =>
      hideBook ? '/workers/$id?hideBook=1' : '/workers/$id';
  static const workerProfilePath = '/workers/:id';

  static String marketplace({String? trade}) =>
      trade == null ? homeownerMarketplace : '$homeownerMarketplace?trade=$trade';


  static String homeFor(UserRole role) =>
      role == UserRole.worker ? workerJobs : homeownerHome;
}

extension RouteNav on BuildContext {
  void goHomeFor(UserRole role) => go(Routes.homeFor(role));
}
