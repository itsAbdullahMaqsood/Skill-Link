import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/service_request_repository.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/sent_requests_screen.dart'
    show SentRequestTile;

class ReceivedRequestsScreen extends ConsumerWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awardedSrIds =
        ref.watch(workerAwardedOpenJobServiceRequestIdsProvider);
    final async =
        ref.watch(myServiceRequestsProvider(ServiceRequestRole.worker));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title:
            Text('Direct Bookings', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          myServiceRequestsProvider(ServiceRequestRole.worker).future,
        ),
        child: async.when(
          data: (items) {
            final restFiltered = items
                .where(
                  (r) =>
                      !r.showsAsWorkerOngoingJob &&
                      !awardedSrIds.contains(r.id),
                )
                .toList();
            final ongoing =
                items.where((r) => r.showsAsWorkerOngoingJob).toList();
            if (ongoing.isEmpty && restFiltered.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No direct bookings yet',
                    subtitle:
                        'Requests booked from your marketplace profile '
                        'will appear here.',
                  ),
                ],
              );
            }
            final rest = restFiltered;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (ongoing.isNotEmpty) ...[
                  Text(
                    'In progress',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < ongoing.length; i++) ...[
                    SentRequestTile(
                      request: ongoing[i],
                      onTap: () => context.push(
                        Routes.receivedRequestDetail(ongoing[i].id),
                      ),
                    ),
                    if (i < ongoing.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 20),
                ],
                if (rest.isNotEmpty && ongoing.isNotEmpty)
                  Text(
                    'Other requests',
                    style: AppTypography.titleLarge,
                  ),
                if (rest.isNotEmpty && ongoing.isNotEmpty)
                  const SizedBox(height: 10),
                for (var i = 0; i < rest.length; i++) ...[
                  SentRequestTile(
                    request: rest[i],
                    onTap: () => context
                        .push(Routes.receivedRequestDetail(rest[i].id)),
                  ),
                  if (i < rest.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              LoadingShimmer(height: 96),
              SizedBox(height: 10),
              LoadingShimmer(height: 96),
              SizedBox(height: 10),
              LoadingShimmer(height: 96),
            ],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load your bookings',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
