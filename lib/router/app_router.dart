import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/Pages/forgot%20password/forgot_password_screen.dart';
import 'package:skilllink/Pages/home/home_shell.dart';
import 'package:skilllink/Pages/login/login_page.dart';
import 'package:skilllink/Pages/signup/signup_email_page.dart';
import 'package:skilllink/Pages/splash_screen.dart';
import 'package:skilllink/splash_screen.dart';
import 'package:skilllink/core/auth/auth_change_notifier.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/auth/widgets/role_select_screen.dart';
import 'package:skilllink/skillink/ui/booking/widgets/booking_screen.dart';
import 'package:skilllink/skillink/ui/booking/widgets/booking_success_screen.dart';
import 'package:skilllink/skillink/ui/chat/widgets/chat_list_screen.dart';
import 'package:skilllink/skillink/ui/chat/widgets/chat_thread_screen.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/pending_completion_reports_view_model.dart';
import 'package:skilllink/skillink/ui/completion_report/widgets/completion_prompt_screen.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/ai_chat/widgets/ai_chat_screen.dart';
import 'package:skilllink/skillink/ui/core/ui/storybook_screen.dart';
import 'package:skilllink/skillink/ui/homeowner_home/widgets/homeowner_dashboard_screen.dart';
import 'package:skilllink/skillink/ui/homeowner_home/widgets/homeowner_shell_screen.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/alert_detail_screen.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/alerts_screen.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/appliance_detail_screen.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/appliances_list_screen.dart';
import 'package:skilllink/skillink/ui/job_tracking/widgets/job_history_screen.dart';
import 'package:skilllink/skillink/ui/job_tracking/widgets/job_tracking_screen.dart';
import 'package:skilllink/skillink/ui/job_tracking/widgets/rate_worker_screen.dart';
import 'package:skilllink/skillink/ui/marketplace/widgets/marketplace_screen.dart';
import 'package:skilllink/skillink/ui/marketplace/widgets/worker_profile_screen.dart';
import 'package:skilllink/skillink/ui/my_posts/widgets/my_posts_screen.dart';
import 'package:skilllink/skillink/ui/my_posts/widgets/posted_job_detail_screen.dart';
import 'package:skilllink/skillink/ui/notifications/widgets/notifications_screen.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/discover_open_jobs_screen.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_detail_screen.dart';
import 'package:skilllink/skillink/ui/open_job_post/widgets/open_job_post_screen.dart';
import 'package:skilllink/skillink/ui/profile/widgets/about_screen.dart';
import 'package:skilllink/skillink/ui/profile/widgets/edit_profile_screen.dart';
import 'package:skilllink/skillink/ui/profile/widgets/help_support_screen.dart';
import 'package:skilllink/skillink/ui/profile/widgets/profile_screen.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/received_requests_screen.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/sent_request_detail_screen.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/sent_requests_screen.dart';
import 'package:skilllink/skillink/ui/worker_bids/widgets/my_bids_screen.dart';
import 'package:skilllink/Pages/chat/chat_inbox.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_earnings_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_incoming_requests_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_job_detail_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_jobs_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_marketplace_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_ongoing_jobs_screen.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_profile_screen_edit.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_shell_screen.dart';

const splashPath = '/';
const loginPath = '/login';
const signupPath = '/signup';
const forgotPasswordPath = '/forgot-password';
const skillTypePath = '/skill-type';
const digitalHomePath = '/digital';

const kSkillTypePrefKey = 'skill_type';

bool _isLabourPath(String path) {
  if (path == Routes.roleSelect) return true;
  if (path.startsWith(Routes.homeowner)) return true;
  if (path.startsWith(Routes.worker)) return true;
  if (path.startsWith('/posted-jobs')) return true;
  if (path.startsWith('/iot')) return true;
  if (path.startsWith('/jobs')) return true;
  if (path.startsWith('/book')) return true;
  if (path.startsWith('/booking')) return true;
  if (path.startsWith('/open-job-post')) return true;
  if (path.startsWith('/completion-prompt')) return true;
  if (path.startsWith('/workers')) return true;
  if (path.startsWith('/chat')) return true;
  if (path == Routes.profile ||
      path == Routes.profileEdit ||
      path == Routes.helpSupport ||
      path == Routes.notifications ||
      path == Routes.about ||
      path == Routes.myPosts ||
      path == Routes.myBids ||
      path == Routes.sentRequests ||
      path.startsWith('/sent-requests/') ||
      path == Routes.receivedRequests ||
      path.startsWith('/received-requests/')) {
    return true;
  }
  return false;
}

bool _isAuthRoute(String path) =>
    path == loginPath ||
    path == splashPath ||
    path == skillTypePath ||
    path == Routes.roleSelect ||
    path.startsWith(signupPath) ||
    path.startsWith(forgotPasswordPath);

bool _isDevPath(String path) => path.startsWith('/dev');

class _SkillPrefs {
  String? skillType;
  String? labourRole;
}

final _skillPrefsHolder = _SkillPrefs();

Future<void> _hydrateSkillPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  _skillPrefsHolder.skillType = prefs.getString(kSkillTypePrefKey);
  _skillPrefsHolder.labourRole = prefs.getString(kLabourRolePrefKey);
}

Future<void> reloadSkillPrefs(ProviderContainer container) async {
  await _hydrateSkillPrefs();
  // ignore: invalid_use_of_internal_member, invalid_use_of_protected_member
  container.read(_skillPrefsRefreshProvider).bump();
}

class _SkillPrefsRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}

final _skillPrefsRefreshProvider =
    Provider<_SkillPrefsRefresh>((_) => _SkillPrefsRefresh());

final appRouterProvider = Provider<GoRouter>((ref) {
  unawaited(_hydrateSkillPrefs());

  final notifications = ref.read(localNotificationsServiceProvider);
  final routerHolder = _AnomalyRouterHolder();
  notifications.onTap = (payload) {
    final go = routerHolder.value;
    if (go == null) return;
    final sep = payload.indexOf(':');
    if (sep > 0) {
      final prefix = payload.substring(0, sep);
      final id = payload.substring(sep + 1);
      if (id.isEmpty) return;
      switch (prefix) {
        case 'posted_job':
        case 'posted_bid':
        case 'posted_accept':
        case 'posted_counter':
          go.push(Routes.postedJobDetail(id));
          return;
        case 'chat':
          go.push(Routes.chatThread(id));
          return;
      }
    }
    go.push(Routes.alertDetail(payload));
  };
  unawaited(notifications.init());

  final go = GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final path = state.matchedLocation;

      if (_isDevPath(path)) return null;

      if (path == splashPath) return null;

      await _hydrateSkillPrefs();

      final authService = ref.read(skillChainAuthServiceProvider);
      final isAuthed = await authService.isLoggedIn();

      if (!isAuthed) {
        if (_isAuthRoute(path)) return null;
        return skillTypePath;
      }

      final skillType = _skillPrefsHolder.skillType;
      final labourRole = _skillPrefsHolder.labourRole;

      if (path == loginPath ||
          path.startsWith(signupPath) ||
          path.startsWith(forgotPasswordPath)) {
        return _postLoginLanding(skillType, labourRole);
      }

      if (skillType == null || skillType.isEmpty) {
        return path == skillTypePath ? null : skillTypePath;
      }

      if (skillType == 'digital') {
        if (path == skillTypePath) return null;
        if (path == digitalHomePath || path.startsWith('$digitalHomePath/')) {
          return null;
        }
        if (_isLabourPath(path)) return digitalHomePath;
        return null;
      }

      if (labourRole == null || labourRole.isEmpty) {
        return path == Routes.roleSelect ? null : Routes.roleSelect;
      }

      final role = labourRole == 'worker' ? UserRole.worker : UserRole.homeowner;

      if (path == digitalHomePath || path.startsWith('$digitalHomePath/')) {
        return Routes.homeFor(role);
      }

      final pending = ref.read(oldestPendingCompletionReportProvider);
      if (pending != null) {
        final isOnPrompt = path.startsWith('/completion-prompt/');
        final isOnRate = path.startsWith('/jobs/') && path.endsWith('/rate');
        if (!isOnPrompt && !isOnRate) {
          return Routes.completionPrompt(pending.jobId);
        }
      }

      if (path == Routes.homeowner) return Routes.homeownerHome;
      if (path == Routes.worker) return Routes.workerJobs;

      final isWorkerShell =
          path == Routes.worker || path.startsWith('${Routes.worker}/');
      if (role == UserRole.homeowner && isWorkerShell) {
        return Routes.homeownerHome;
      }
      if (role == UserRole.worker && path.startsWith(Routes.homeowner)) {
        return Routes.workerJobs;
      }

      return null;
    },
    refreshListenable: _AuthRefresh(ref),
    routes: [
      GoRoute(
        path: splashPath,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: signupPath,
        name: 'signup',
        builder: (_, __) => const SignupEmailPage(),
      ),
      GoRoute(
        path: forgotPasswordPath,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: skillTypePath,
        name: 'skillType',
        builder: (_, __) => const TheMostedSplashScreen(),
      ),
      GoRoute(
        path: digitalHomePath,
        name: 'digitalHome',
        builder: (_, __) => const HomeShell(),
      ),

      GoRoute(
        path: Routes.storybook,
        name: 'storybook',
        builder: (_, __) => const StorybookScreen(),
      ),
      GoRoute(
        path: Routes.roleSelect,
        name: 'roleSelect',
        builder: (_, __) => const RoleSelectScreen(),
      ),

      GoRoute(
        path: Routes.profile,
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.profileEdit,
        name: 'profileEdit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.helpSupport,
        name: 'helpSupport',
        builder: (_, __) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.about,
        name: 'about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.myPosts,
        name: 'myPosts',
        builder: (_, __) => const MyPostsScreen(),
      ),
      GoRoute(
        path: Routes.myBids,
        name: 'myBids',
        builder: (_, __) => const MyBidsScreen(),
      ),
      GoRoute(
        path: Routes.sentRequests,
        name: 'sentRequests',
        builder: (_, __) => const SentRequestsScreen(),
      ),
      GoRoute(
        path: Routes.sentRequestDetailPath,
        name: 'sentRequestDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return SentRequestDetailScreen(requestId: id);
        },
      ),
      GoRoute(
        path: Routes.receivedRequests,
        name: 'receivedRequests',
        builder: (_, __) => const ReceivedRequestsScreen(),
      ),
      GoRoute(
        path: Routes.receivedRequestDetailPath,
        name: 'receivedRequestDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return SentRequestDetailScreen(requestId: id);
        },
      ),
      GoRoute(
        path: Routes.postedJobDetailPath,
        name: 'postedJobDetail',
        builder: (_, state) {
          final id = state.pathParameters['jobId'] ?? '';
          return PostedJobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: Routes.chatList,
        name: 'chatList',
        builder: (_, __) => const ChatListScreen(),
      ),
      GoRoute(
        path: Routes.chatThreadPath,
        name: 'chatThread',
        builder: (_, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          return ChatThreadScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: Routes.iotDevices,
        name: 'iotDevices',
        builder: (_, __) => const AppliancesListScreen(),
      ),
      GoRoute(
        path: Routes.workerProfilePath,
        name: 'workerProfile',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          final hideBookRaw = state.uri.queryParameters['hideBook'];
          final hideBook = hideBookRaw == '1' || hideBookRaw == 'true';
          return WorkerProfileScreen(workerId: id, hideBookButton: hideBook);
        },
      ),
      GoRoute(
        path: Routes.bookingPath,
        name: 'booking',
        builder: (_, state) {
          final workerId = state.pathParameters['workerId'] ?? '';
          return BookingScreen(workerId: workerId);
        },
      ),
      GoRoute(
        path: Routes.newOpenJobPost,
        name: 'newOpenJobPost',
        builder: (_, __) => const OpenJobPostScreen(),
      ),
      GoRoute(
        path: Routes.openJobPostDetailPath,
        name: 'openJobPostDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return OpenJobPostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: Routes.discoverOpenJobs,
        name: 'discoverOpenJobs',
        builder: (_, __) => const DiscoverOpenJobsScreen(),
      ),
      GoRoute(
        path: Routes.bookingSuccessPath,
        name: 'bookingSuccess',
        builder: (_, state) {
          final id = state.pathParameters['jobId'] ?? '';
          return BookingSuccessScreen(requestId: id);
        },
      ),
      GoRoute(
        path: Routes.jobHistory,
        name: 'jobHistory',
        builder: (_, __) => const JobHistoryScreen(),
      ),
      GoRoute(
        path: Routes.jobTrackingPath,
        name: 'jobTracking',
        builder: (_, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return JobTrackingScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: Routes.rateJobPath,
        name: 'rateJob',
        builder: (_, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return RateWorkerScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: Routes.completionPromptPath,
        name: 'completionPrompt',
        builder: (_, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return CompletionPromptScreen(jobId: jobId);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            HomeownerShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeownerHome,
                name: 'homeownerHome',
                builder: (_, __) => const HomeownerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeownerMarketplace,
                name: 'homeownerMarketplace',
                builder: (_, state) {
                  final trade = state.uri.queryParameters['trade'];
                  return MarketplaceScreen(initialTrade: trade);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/homeowner/post-stub',
                name: 'homeownerPostStub',
                builder: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeownerAi,
                name: 'homeownerAi',
                builder: (_, __) => const AiChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeownerProfile,
                name: 'homeownerProfile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.applianceDetailPath,
        name: 'applianceDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return ApplianceDetailScreen(applianceId: id);
        },
      ),
      GoRoute(
        path: Routes.alerts,
        name: 'alerts',
        builder: (_, __) => const AlertsScreen(),
      ),
      GoRoute(
        path: Routes.alertDetailPath,
        name: 'alertDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return AlertDetailScreen(anomalyId: id);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            WorkerShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.workerJobs,
                name: 'workerJobs',
                builder: (_, __) => const WorkerJobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.workerMarketplace,
                name: 'workerMarketplace',
                builder: (_, __) => const WorkerMarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.workerChat,
                name: 'workerChat',
                builder: (_, __) => const ChatInboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.workerIncoming,
                name: 'workerIncoming',
                builder: (_, __) => const WorkerIncomingRequestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.workerMyProfile,
                name: 'workerProfileEdit',
                builder: (_, __) => const WorkerProfileEditScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.workerEarnings,
        name: 'workerEarnings',
        builder: (_, __) => const WorkerEarningsScreen(),
      ),
      GoRoute(
        path: Routes.workerOngoing,
        name: 'workerOngoing',
        builder: (_, __) => const WorkerOngoingJobsScreen(),
      ),
      GoRoute(
        path: Routes.workerJobDetailPath,
        name: 'workerJobDetail',
        builder: (_, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return WorkerJobDetailScreen(jobId: jobId);
        },
      ),
    ],
    errorBuilder: (_, state) => _NotFoundScreen(uri: state.uri.toString()),
  );
  routerHolder.value = go;
  return go;
});

String _postLoginLanding(String? skillType, String? labourRole) =>
    postLoginLanding(skillType, labourRole);

String postLoginLanding(String? skillType, String? labourRole) {
  if (skillType == null || skillType.isEmpty) return skillTypePath;
  if (skillType == 'digital') return digitalHomePath;
  if (labourRole == null || labourRole.isEmpty) return Routes.roleSelect;
  return labourRole == 'worker' ? Routes.workerJobs : Routes.homeownerHome;
}

String? currentSkillType() => _skillPrefsHolder.skillType;

String? currentLabourRole() => _skillPrefsHolder.labourRole;

class _AnomalyRouterHolder {
  GoRouter? value;
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen<AuthState>(
      authViewModelProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
    ref.listen(
      oldestPendingCompletionReportProvider,
      (prev, next) {
        if (prev?.jobId != next?.jobId) notifyListeners();
      },
      fireImmediately: false,
    );
    final skillRefresh = ref.read(_skillPrefsRefreshProvider);
    skillRefresh.addListener(notifyListeners);
    void onAuthEpochChanged() {
      unawaited(ref.read(authViewModelProvider.notifier).reloadSession());
      notifyListeners();
    }
    authChangeNotifier.addListener(onAuthEpochChanged);
    ref.onDispose(() {
      skillRefresh.removeListener(notifyListeners);
      authChangeNotifier.removeListener(onAuthEpochChanged);
    });
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.uri});

  final String uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                uri,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const skillTypePrefKey = kSkillTypePrefKey;

Future<void> setSkillType(WidgetRef ref, String? type) async {
  final container = ProviderScope.containerOf(ref.context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  if (type == null) {
    await prefs.remove(kSkillTypePrefKey);
    await prefs.remove(kLabourRolePrefKey);
  } else {
    await prefs.setString(kSkillTypePrefKey, type);
    if (type == 'labour' || type == 'digital') {
      await prefs.remove(kLabourRolePrefKey);
    }
  }
  await reloadSkillPrefs(container);
}

Future<void> setLabourRole(WidgetRef ref, String? role) async {
  final container = ProviderScope.containerOf(ref.context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  if (role == null) {
    await prefs.remove(kLabourRolePrefKey);
  } else {
    await prefs.setString(kLabourRolePrefKey, role);
  }
  await reloadSkillPrefs(container);
}

typedef SkillChainAuthService = AuthService;
