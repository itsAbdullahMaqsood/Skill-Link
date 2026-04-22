import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/domain/models/in_app_notification.dart';

class NotificationsState {
  const NotificationsState({this.items = const <InAppNotification>[]});

  final List<InAppNotification> items;

  NotificationsState copyWith({List<InAppNotification>? items}) {
    return NotificationsState(items: items ?? this.items);
  }
}

class NotificationsViewModel extends StateNotifier<NotificationsState> {
  NotificationsViewModel() : super(NotificationsState(items: _seeded()));

  static List<InAppNotification> _seeded() {
    final now = DateTime.now();
    return [
      InAppNotification(
        id: 'seed_job_1',
        title: 'Job update',
        body: 'Your technician is on the way.',
        type: InAppNotificationType.job,
        targetId: 'job_active_1',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      InAppNotification(
        id: 'seed_anom_1',
        title: 'Anomaly detected',
        body: 'Voltage spike on Living Room AC.',
        type: InAppNotificationType.anomaly,
        targetId: 'an_seed_001',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      InAppNotification(
        id: 'seed_sys_1',
        title: 'Welcome to SkillLink',
        body:
            'Browse workers from Marketplace, try the AI assistant, or monitor appliances from IoT.',
        type: InAppNotificationType.system,
        targetId: '',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  void add(InAppNotification notification) {
    final rest =
        state.items.where((i) => i.id != notification.id).toList(growable: false);
    state = state.copyWith(items: [notification, ...rest]);
  }

  void markRead(String id) {
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.id == id) n.copyWith(read: true) else n,
      ],
    );
  }

  void markAllRead() {
    state = state.copyWith(
      items: [
        for (final n in state.items) n.copyWith(read: true),
      ],
    );
  }

  int get unreadCount => state.items.where((n) => !n.read).length;

  void clear() {
    state = NotificationsState(items: _seeded());
  }
}

final notificationsViewModelProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>(
  (ref) => NotificationsViewModel(),
);
