import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/in_app_notification.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/notifications/view_models/notifications_view_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsViewModelProvider);
    final vm = ref.read(notificationsViewModelProvider.notifier);
    final unread = vm.unreadCount;

    return AppScaffold(
      title: 'Notifications',
      actions: unread > 0
          ? [
              TextButton(
                onPressed: vm.markAllRead,
                child: const Text('Mark all read'),
              ),
            ]
          : null,
      body: state.items.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: const EmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'No notifications',
                    subtitle: 'Job updates and alerts will appear here.',
                  ),
                ),
              ),
            )
          : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final n = state.items[index];
                  return _NotificationTile(
                    notification: n,
                    onTap: () {
                      vm.markRead(n.id);
                      switch (n.type) {
                        case InAppNotificationType.job:
                          if (n.targetId.isNotEmpty) {
                            context.push(Routes.jobTracking(n.targetId));
                          }
                          break;
                        case InAppNotificationType.anomaly:
                          if (n.targetId.isNotEmpty) {
                            context.push(Routes.alertDetail(n.targetId));
                          }
                          break;
                        case InAppNotificationType.system:
                          break;
                      }
                    },
                  );
                },
              ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final InAppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.read ? AppColors.border : AppColors.primary,
          width: notification.read ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                switch (notification.type) {
                  InAppNotificationType.job => Icons.handyman_outlined,
                  InAppNotificationType.anomaly => Icons.warning_amber_rounded,
                  InAppNotificationType.system => Icons.info_outline,
                },
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
