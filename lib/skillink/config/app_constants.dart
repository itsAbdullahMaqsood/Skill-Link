import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skilllink/services/api_service.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl =>
      _env('API_BASE_URL', fallback: ApiService.skillinkBaseUrl);

  static String get firebaseRtdbUrl =>
      _env('FIREBASE_RTDB_URL', fallback: 'https://REPLACE_ME.firebaseio.com');

  /// ESP32 posts latest readings here (sibling to `readings` push events).
  static const String firebaseEsp32SensorDataPath = 'sensorData';

  /// Use this as an appliance [Appliance.iotDeviceId] to bind live UI to
  /// [firebaseEsp32SensorDataPath] in [RemoteIotRepository.watchLiveSensorData].
  static const String firebaseEsp32SensorDataDeviceId = 'esp32-sensorData';

  static const String iotReadingsPath = 'readings';
  static const String iotDeviceLivePath = 'devices';
  static const String anomaliesPath = 'users';

  static const String jobStatusPath = 'jobs';
  static const String workerLocationPath =
      'jobs';

  static const String postedJobsRoot = 'posted_jobs';
  static const String postedJobsByTagRoot = 'posted_jobs_by_tag';
  static const String postedBidsRoot = 'bids';
  static const String bidsByWorkerRoot = 'bids_by_worker';

  static const double defaultPostedJobLat = 31.5204;
  static const double defaultPostedJobLng = 74.3587;

  static const int maxPostedJobTitleLength = 80;
  static const int maxPostedJobDescriptionLength = 1000;
  static const int maxPostedBidNoteLength = 200;

  static const int postedJobMediaSoftTotalBytes = 200 * 1024 * 1024;

  static const String postedJobsNotificationChannelId =
      'skillink_posted_jobs';
  static const String postedJobsNotificationChannelName =
      'Posted jobs & bids';
  static const String postedJobsNotificationChannelDescription =
      'Alerts when jobs are posted or bids change.';

  static const Duration cancellationGracePeriod = Duration(minutes: 5);
  static const Duration workerBidTimeout = Duration(seconds: 60);
  static const Duration jobStatusPollInterval = Duration(seconds: 10);
  static const Duration workerLocationPublishInterval = Duration(seconds: 10);

  static const double distanceNearby = 5.0;
  static const double distanceABitFar = 10.0;
  static const double distanceTooFar = 20.0;
  static const double searchResultMaxDistance = 20.0;

  static const double platformFeePercent = 0.10;

  static const double suspensionThreshold = 3.0;
  static const double lowRatingWarningThreshold = 3.5;
  static const int ratingWindowDays = 30;

  static const double homeMarketplacePreviewCardWidth = 300;

  static const double homeMarketplacePreviewStripHeight = 160;

  static const int maxImageSizeBytes = 5 * 1024 * 1024;
  static const int imageMaxDimension = 1920;
  static const int imageCompressQuality = 80;

  static const String supportEmail = 'skillink@lgufyp.app';

  static const Duration postedJobETARefreshInterval = Duration(minutes: 2);
  static const double completionAmountDiscrepancyThreshold = 0.10;

  static const String completionReportsRoot = 'completion_reports';

  static const String completionFlagAmountDiscrepancy = 'amount_discrepancy';

  static const bool seedDemoCompletionReport = false;

  static const Duration maxVideoDuration = Duration(minutes: 2);
  static const int maxVideoSizeBytes = 50 * 1024 * 1024;
  static const int maxVoiceNoteSizeBytes =
      20 * 1024 * 1024;

  static const int chatMessagePageSize = 50;

  static const int maxChatAudioBytes = 20 * 1024 * 1024;

  static const String chatsRoot = 'chats';
  static const String userChatsIndexRoot = 'user_chats_index';

  static const String chatStoragePrefix = 'chats';

  static const String chatNotificationChannelId = 'skillink_chat';
  static const String chatNotificationChannelName = 'Chat messages';
  static const String chatNotificationChannelDescription =
      'Alerts when you receive a new chat message.';

  static const String cnicFormatRegex = r'^\d{5}-\d{7}-\d$';

  static const bool showSimulateAnomalyButton =
      true;
  static const bool inAppPaymentsEnabled = false;

  static String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY');

  static String _env(String key, {String? fallback}) {
    final compileTime = String.fromEnvironment(key);
    if (compileTime.isNotEmpty) return compileTime;

    if (dotenv.isInitialized) {
      final runtime = dotenv.maybeGet(key);
      if (runtime != null && runtime.isNotEmpty) return runtime;
    }

    if (fallback != null) return fallback;
    throw StateError(
      'Missing required env var "$key". '
      'Copy .env.example to .env or pass --dart-define=$key=...',
    );
  }
}
