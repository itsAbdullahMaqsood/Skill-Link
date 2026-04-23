import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/logic/service_request_actions.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/pending_completion_reports_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/service_requests/view_models/service_request_actions_controller.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/bid_amount_sheet.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/negotiation_offer_card.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/party_card.dart';
import 'package:skilllink/skillink/ui/service_requests/widgets/request_location_map.dart';

const Duration _kDetailPollInterval = Duration(seconds: 10);

class SentRequestDetailScreen extends ConsumerStatefulWidget {
  const SentRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<SentRequestDetailScreen> createState() =>
      _SentRequestDetailScreenState();
}

class _SentRequestDetailScreenState
    extends ConsumerState<SentRequestDetailScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      ref.invalidate(serviceRequestByIdProvider(widget.requestId));
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kDetailPollInterval, (_) {
      if (!mounted) return;
      final submitting = ref
          .read(serviceRequestActionsControllerProvider(widget.requestId))
          .isSubmitting;
      if (submitting) return;
      ref.invalidate(serviceRequestByIdProvider(widget.requestId));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(serviceRequestByIdProvider(widget.requestId));
    final viewerId = ref.watch(authViewModelProvider).user?.id;
    final actionsState = ref.watch(
      serviceRequestActionsControllerProvider(widget.requestId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Request Details', style: AppTypography.headlineMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(serviceRequestByIdProvider(widget.requestId).future),
        child: async.when(
          data: (req) {
            final viewer = resolveViewer(
              request: req,
              signedInUserId: viewerId,
            );
            return _DetailBody(request: req, viewer: viewer);
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingShimmer(height: 90),
              SizedBox(height: 16),
              LoadingShimmer(height: 160),
              SizedBox(height: 16),
              LoadingShimmer(height: 240),
            ],
          ),
          error: (e, _) => _ErrorView(message: '$e'),
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (req) {
          final viewer = resolveViewer(request: req, signedInUserId: viewerId);
          var actions = availableActions(request: req, viewer: viewer);

          final offers = req.negotiationOffers;
          final inlineActionsVisible =
              viewer == ServiceRequestViewer.customer &&
                  offers.isNotEmpty &&
                  offers.last.actorRole == NegotiationActor.worker &&
                  req.status == ServiceRequestStatus.bidReceived;
          if (inlineActionsVisible) {
            actions = {
              for (final a in actions)
                if (a != ServiceRequestAction.customerAcceptBid &&
                    a != ServiceRequestAction.customerCounterOffer &&
                    a != ServiceRequestAction.cancel)
                  a,
            };
          }

          if (actions.isEmpty) return null;
          return _ActionBar(
            request: req,
            viewer: viewer,
            actions: actions,
            isSubmitting: actionsState.isSubmitting,
          );
        },
        orElse: () => null,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(
          'Could not load this request',
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

bool _showCustomerCompletionNudge(
  WidgetRef ref,
  ServiceRequest request,
  ServiceRequestViewer viewer,
) {
  if (viewer != ServiceRequestViewer.customer) return false;
  if (request.status != ServiceRequestStatus.completed) return false;
  return !ref.watch(acknowledgedCompletionReportsProvider).contains(request.id);
}

class _CustomerCompletionNudgeCard extends ConsumerWidget {
  const _CustomerCompletionNudgeCard({required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job completed', style: AppTypography.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Optionally report how much you paid. This helps if there is a '
                'payment dispute later.',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref
                          .read(acknowledgedCompletionReportsProvider.notifier)
                          .acknowledge(requestId);
                    },
                    child: const Text('Dismiss'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        context.push(Routes.completionPrompt(requestId)),
                    child: const Text('Report amount'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.request, required this.viewer});
  final ServiceRequest request;
  final ServiceRequestViewer viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNegotiation =
        request.negotiationOffers.isNotEmpty || request.acceptedBid != null;

    final counterparty = viewer == ServiceRequestViewer.customer
        ? (request.assignedWorker, PartyCardVariant.worker)
        : viewer == ServiceRequestViewer.worker
            ? (request.requestingCustomer, PartyCardVariant.customer)
            : (null, PartyCardVariant.worker);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _HeaderCard(request: request),
        if (_showCustomerCompletionNudge(ref, request, viewer)) ...[
          _CustomerCompletionNudgeCard(requestId: request.id),
        ],
        if (request.cancelled) ...[
          const SizedBox(height: 12),
          _CancelledBanner(cancelledAt: request.updatedAt),
        ],
        if (counterparty.$1 != null) ...[
          const SizedBox(height: 16),
          _SectionLabel(
            counterparty.$2 == PartyCardVariant.worker
                ? 'Worker'
                : 'Customer',
          ),
          const SizedBox(height: 8),
          PartyCard(party: counterparty.$1!, variant: counterparty.$2),
        ],
        if (request.serviceAddress.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel('Location'),
          const SizedBox(height: 8),
          RequestLocationMap(
            address: request.serviceAddress,
            viewer: viewer,
          ),
        ],
        const SizedBox(height: 16),
        _SectionLabel('Description'),
        const SizedBox(height: 6),
        Text(
          request.description.trim().isEmpty
              ? 'No description provided.'
              : request.description,
          style: AppTypography.bodyMedium,
        ),
        if (request.photos.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel('Photos'),
          const SizedBox(height: 8),
          _PhotosStrip(paths: request.photos),
        ],
        const SizedBox(height: 20),
        _SectionLabel('Details'),
        const SizedBox(height: 8),
        _InfoCard(request: request),
        if (hasNegotiation) ...[
          const SizedBox(height: 20),
          _SectionLabel('Bids'),
          const SizedBox(height: 8),
          _NegotiationSection(request: request, viewer: viewer),
        ],
        const SizedBox(height: 20),
        _SectionLabel('Progress'),
        const SizedBox(height: 8),
        _Timeline(request: request),
      ],
    );
  }
}


class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.cancelledAt});
  final DateTime? cancelledAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, size: 20, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This request was cancelled',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.danger,
                    fontSize: 14,
                  ),
                ),
                if (cancelledAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'on ${_formatDateTime(cancelledAt!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = request.cancelled
        ? ServiceRequestStatus.cancelled
        : request.status;
    final (label, color) = _statusVisuals(effectiveStatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon(effectiveStatus), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.titleLarge.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  'Booked ${_formatDateTime(request.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final slot = request.timeSlot;
    final slotLabel = (slot.startTime.isEmpty && slot.endTime.isEmpty)
        ? '—'
        : '${slot.startTime}–${slot.endTime}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Date',
            value: _prettyDate(request.scheduledServiceDate),
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Time slot',
            value: slotLabel,
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Address',
            value: request.serviceAddress.isEmpty
                ? '—'
                : request.serviceAddress,
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value: _paymentLabel(request.paymentMethod),
          ),
        ],
      ),
    );
  }

  static String _prettyDate(String ymd) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12) return ymd;
    return '$d ${months[m - 1]} $y';
  }

  static String _paymentLabel(ServiceRequestPaymentMethod pm) => switch (pm) {
    ServiceRequestPaymentMethod.cash => 'Cash',
    ServiceRequestPaymentMethod.card => 'Card',
    ServiceRequestPaymentMethod.bankTransfer => 'Bank transfer',
    ServiceRequestPaymentMethod.digitalWallet => 'Digital wallet',
    ServiceRequestPaymentMethod.online => 'Online',
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}


class _PhotosStrip extends StatelessWidget {
  const _PhotosStrip({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final url = _resolve(paths[i]);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(width: 96, height: 96, color: AppColors.border),
              errorWidget: (_, _, _) => Container(
                width: 96,
                height: 96,
                color: AppColors.border,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = AppConstants.apiBaseUrl;
    final trimmedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$trimmedBase$suffix';
  }
}


class _NegotiationSection extends ConsumerWidget {
  const _NegotiationSection({required this.request, required this.viewer});
  final ServiceRequest request;
  final ServiceRequestViewer viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = request.negotiationOffers;
    final accepted = request.acceptedBid;
    final actions = availableActions(request: request, viewer: viewer);
    final submitting = ref
        .watch(serviceRequestActionsControllerProvider(request.id))
        .isSubmitting;

    final showActionsOnLatest = viewer == ServiceRequestViewer.customer &&
        offers.isNotEmpty &&
        offers.last.actorRole == NegotiationActor.worker &&
        request.status == ServiceRequestStatus.bidReceived &&
        (actions.contains(ServiceRequestAction.customerAcceptBid) ||
            actions.contains(ServiceRequestAction.customerCounterOffer) ||
            actions.contains(ServiceRequestAction.cancel));

    final showAcceptHintOnLatest =
        viewer == ServiceRequestViewer.customer && isWorkerAcceptanceEcho(request);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < offers.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == offers.length - 1 ? 0 : 10),
            child: _buildOfferCard(
              context: context,
              ref: ref,
              offer: offers[i],
              isLatest: i == offers.length - 1,
              showActionsHere:
                  showActionsOnLatest && i == offers.length - 1,
              showAcceptHint:
                  showAcceptHintOnLatest && i == offers.length - 1,
              submitting: submitting,
            ),
          ),
        if (accepted != null) ...[
          const SizedBox(height: 10),
          _AcceptedBidBanner(accepted: accepted),
        ],
      ],
    );
  }

  Widget _buildOfferCard({
    required BuildContext context,
    required WidgetRef ref,
    required NegotiationOffer offer,
    required bool isLatest,
    required bool showActionsHere,
    required bool showAcceptHint,
    required bool submitting,
  }) {
    VoidCallback? accept;
    VoidCallback? counter;
    VoidCallback? reject;

    if (showActionsHere) {
      accept = () => _onAccept(context, ref);
      counter = () => _onCounter(context, ref);
      reject = () => _onReject(context, ref);
    }

    return NegotiationOfferCard(
      offer: offer,
      viewer: viewer,
      isLatest: isLatest,
      showAcceptHint: showAcceptHint,
      onAccept: accept,
      onCounter: counter,
      onReject: reject,
      submitting: submitting,
    );
  }

  Future<void> _onAccept(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(
      serviceRequestActionsControllerProvider(request.id).notifier,
    );
    final result = await controller.acceptBid();
    if (!context.mounted) return;
    _showResult(context, result, successMessage: 'Bid accepted!');
  }

  Future<void> _onCounter(BuildContext context, WidgetRef ref) async {
    final seed = request.latestOffer?.amount;
    final seedCurrency = request.latestOffer?.currency ?? 'PKR';
    final bid = await showBidAmountSheet(
      context,
      title: 'Counter offer',
      ctaLabel: 'Send counter',
      suggestedAmount: seed,
      defaultCurrency: seedCurrency,
      helperText:
          'Propose a new amount. The worker will see this in the negotiation thread.',
    );
    if (bid == null) return;
    if (!context.mounted) return;
    final controller = ref.read(
      serviceRequestActionsControllerProvider(request.id).notifier,
    );
    final result = await controller.counterOffer(
      amount: bid.amount,
      currency: bid.currency,
    );
    if (!context.mounted) return;
    _showResult(context, result, successMessage: 'Counter sent.');
  }

  Future<void> _onReject(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject this bid?'),
        content: const Text(
          'Rejecting will cancel this request — the worker will be notified. You can always book them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject & cancel'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    final controller = ref.read(
      serviceRequestActionsControllerProvider(request.id).notifier,
    );
    final result = await controller.cancel();
    if (!context.mounted) return;
    _showResult(context, result, successMessage: 'Bid rejected.');
  }

  void _showResult(
    BuildContext context,
    ServiceRequestActionResult result, {
    required String successMessage,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    if (result.success) {
      final copy = (result.message != null && result.message!.isNotEmpty)
          ? result.message!
          : successMessage;
      messenger.showSnackBar(
        SnackBar(
          content: Text(copy),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Something went wrong.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AcceptedBidBanner extends StatelessWidget {
  const _AcceptedBidBanner({required this.accepted});
  final AcceptedBid accepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_outlined,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deal accepted at ${accepted.currency} ${_formatAmount(accepted.amount)}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.success,
                    fontSize: 14,
                  ),
                ),
                if (accepted.acceptedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(accepted.acceptedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Timeline extends StatelessWidget {
  const _Timeline({required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final entries = request.timeline;
    if (entries.isEmpty) {
      return Text(
        'No timeline available.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            _TimelineStep(
              entry: entries[i],
              isLast: i == entries.length - 1,
              forceCompleted:
                  i == entries.length - 1 &&
                  request.isTerminal &&
                  !request.cancelled,
              forceMuted: request.cancelled,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.entry,
    required this.isLast,
    this.forceCompleted = false,
    this.forceMuted = false,
  });
  final ServiceRequestTimelineEntry entry;
  final bool isLast;
  final bool forceCompleted;
  final bool forceMuted;

  @override
  Widget build(BuildContext context) {
    final completed = forceCompleted || entry.isCompleted;
    final current = !forceCompleted && entry.isCurrent;
    final pending = !completed && !current;

    final dotColor = forceMuted
        ? AppColors.border
        : completed
        ? AppColors.success
        : current
        ? AppColors.primary
        : AppColors.border;
    final labelColor = forceMuted || pending
        ? AppColors.textMuted
        : AppColors.textPrimary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: Border.all(
                    color: current && !forceMuted
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: completed
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 14,
                      color: labelColor,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(entry, forceCompleted, forceMuted),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitle(
    ServiceRequestTimelineEntry e,
    bool forceCompleted,
    bool forceMuted,
  ) {
    if (e.reachedAt != null) return _formatDateTime(e.reachedAt);
    if (forceMuted) return '—';
    if (forceCompleted) return 'Done';
    if (e.isCurrent) return 'In progress';
    if (e.isPending) return 'Pending';
    return '—';
  }
}


class _ActionBar extends ConsumerWidget {
  const _ActionBar({
    required this.request,
    required this.viewer,
    required this.actions,
    required this.isSubmitting,
  });

  final ServiceRequest request;
  final ServiceRequestViewer viewer;
  final Set<ServiceRequestAction> actions;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCancel = actions.contains(ServiceRequestAction.cancel);
    final positive = _positiveActions(actions);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (positive.isNotEmpty)
              Row(
                children: [
                  for (var i = 0; i < positive.length; i++) ...[
                    Expanded(child: _positiveButton(context, ref, positive[i])),
                    if (i < positive.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            if (hasCancel) ...[
              if (positive.isNotEmpty) const SizedBox(height: 6),
              TextButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () => _confirmCancel(context, ref),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel request'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<ServiceRequestAction> _positiveActions(Set<ServiceRequestAction> set) {
    const priority = <ServiceRequestAction>[
      ServiceRequestAction.customerCounterOffer,
      ServiceRequestAction.workerBid,
      ServiceRequestAction.workerAcceptCounter,
      ServiceRequestAction.customerAcceptBid,
      ServiceRequestAction.workerAccept,
      ServiceRequestAction.workerOnTheWay,
      ServiceRequestAction.workerArrived,
      ServiceRequestAction.workerStart,
      ServiceRequestAction.workerComplete,
    ];
    return priority.where(set.contains).toList();
  }

  Widget _positiveButton(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestAction action,
  ) {
    final (label, icon) = _positiveVisuals(action);
    return FilledButton.icon(
      onPressed: isSubmitting ? null : () => _runPositive(context, ref, action),
      icon: isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  (String, IconData) _positiveVisuals(ServiceRequestAction a) {
    switch (a) {
      case ServiceRequestAction.customerCounterOffer:
        return ('Counter', Icons.swap_horiz);
      case ServiceRequestAction.customerAcceptBid:
        return ('Accept bid', Icons.check_rounded);
      case ServiceRequestAction.workerBid:
        return ('Place bid', Icons.gavel_rounded);
      case ServiceRequestAction.workerAcceptCounter:
        return ('Accept', Icons.check_rounded);
      case ServiceRequestAction.workerAccept:
        return ('Interested in job', Icons.task_alt_outlined);
      case ServiceRequestAction.workerOnTheWay:
        return ('On the way', Icons.directions_car_outlined);
      case ServiceRequestAction.workerArrived:
        return ('Arrived', Icons.location_on_outlined);
      case ServiceRequestAction.workerStart:
        return ('Start', Icons.play_arrow_rounded);
      case ServiceRequestAction.workerComplete:
        return ('Complete', Icons.done_all_rounded);
      case ServiceRequestAction.cancel:
        return ('Cancel', Icons.cancel_outlined);
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text(
          'The worker will be notified. You can always book them again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;

    final controller = ref.read(
      serviceRequestActionsControllerProvider(request.id).notifier,
    );
    final result = await controller.cancel();
    if (!context.mounted) return;
    _showResult(context, result, successMessage: 'Request cancelled.');
  }

  Future<void> _runPositive(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestAction action,
  ) async {
    final controller = ref.read(
      serviceRequestActionsControllerProvider(request.id).notifier,
    );

    switch (action) {
      case ServiceRequestAction.customerCounterOffer:
        final seed = request.latestOffer?.amount;
        final seedCurrency = request.latestOffer?.currency ?? 'PKR';
        final bid = await showBidAmountSheet(
          context,
          title: 'Counter offer',
          ctaLabel: 'Send counter',
          suggestedAmount: seed,
          defaultCurrency: seedCurrency,
          helperText:
              'Propose a new amount. The worker will see this in the negotiation thread.',
        );
        if (bid == null) return;
        if (!context.mounted) return;
        final result = await controller.counterOffer(
          amount: bid.amount,
          currency: bid.currency,
        );
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Counter sent.');
        break;

      case ServiceRequestAction.customerAcceptBid:
        final result = await controller.acceptBid();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Bid accepted!');
        break;

      case ServiceRequestAction.workerAccept:
        final result = await controller.workerAccept();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Job accepted.');
        break;

      case ServiceRequestAction.workerBid:
        final seed = request.latestOffer?.amount;
        final seedCurrency = request.latestOffer?.currency ?? 'PKR';
        final bid = await showBidAmountSheet(
          context,
          title: 'Place bid',
          ctaLabel: 'Send bid',
          suggestedAmount: seed,
          defaultCurrency: seedCurrency,
          helperText:
              'Propose your rate. The customer will see this in the negotiation thread.',
        );
        if (bid == null) return;
        if (!context.mounted) return;
        final result = await controller.workerBid(
          amount: bid.amount,
          currency: bid.currency,
        );
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Bid sent.');
        break;

      case ServiceRequestAction.workerAcceptCounter:
        final last = request.latestOffer;
        if (last == null) {
          _showResult(
            context,
            const ServiceRequestActionResult.err(
              'No customer offer to accept.',
            ),
            successMessage: '',
          );
          return;
        }
        final result = await controller.workerAcceptCustomerCounter(
          amount: last.amount,
          currency: last.currency,
        );
        if (!context.mounted) return;
        _showResult(
          context,
          result,
          successMessage: 'Accepted. Waiting for customer to finalise.',
        );
        break;

      case ServiceRequestAction.workerOnTheWay:
        final result = await controller.workerOnTheWay();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Marked on the way.');
        break;

      case ServiceRequestAction.workerArrived:
        final result = await controller.workerArrived();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Marked arrived.');
        break;

      case ServiceRequestAction.workerStart:
        final result = await controller.workerStart();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Job started.');
        break;

      case ServiceRequestAction.workerComplete:
        final ok = await _confirmComplete(context);
        if (!ok) return;
        if (!context.mounted) return;
        final result = await controller.workerComplete();
        if (!context.mounted) return;
        _showResult(context, result, successMessage: 'Job completed!');
        if (result.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.push(Routes.completionPrompt(request.id));
            }
          });
        }
        break;

      case ServiceRequestAction.cancel:
        await _confirmCancel(context, ref);
        break;
    }
  }

  Future<bool> _confirmComplete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark job as complete?'),
        content: const Text(
          "You can't undo this. The customer will be asked to confirm payment.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _showResult(
    BuildContext context,
    ServiceRequestActionResult result, {
    required String successMessage,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    if (result.success) {
      final copy = (result.message != null && result.message!.isNotEmpty)
          ? result.message!
          : successMessage;
      messenger.showSnackBar(
        SnackBar(
          content: Text(copy),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Something went wrong.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}


class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
  }
}

String _formatDateTime(DateTime? d) {
  if (d == null) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} ${d.year} · $hh:$mm';
}

String _formatAmount(num n) {
  if (n == n.truncate()) return n.toInt().toString();
  return n.toString();
}

(String, Color) _statusVisuals(ServiceRequestStatus status) {
  switch (status) {
    case ServiceRequestStatus.posted:
      return ('Posted', AppColors.primary);
    case ServiceRequestStatus.workerAccepted:
      return ('Worker Interested', AppColors.primary);
    case ServiceRequestStatus.bidReceived:
      return ('Bid Received', AppColors.accent);
    case ServiceRequestStatus.bidAccepted:
      return ('Bid Accepted', AppColors.accent);
    case ServiceRequestStatus.onTheWay:
      return ('On The Way', AppColors.accent);
    case ServiceRequestStatus.arrived:
      return ('Arrived', AppColors.accent);
    case ServiceRequestStatus.inProgress:
      return ('In Progress', AppColors.accent);
    case ServiceRequestStatus.completed:
      return ('Completed', AppColors.success);
    case ServiceRequestStatus.cancelled:
      return ('Cancelled', AppColors.danger);
    case ServiceRequestStatus.unknown:
      return ('Unknown', AppColors.textMuted);
  }
}

IconData _statusIcon(ServiceRequestStatus status) {
  switch (status) {
    case ServiceRequestStatus.posted:
      return Icons.outbox_outlined;
    case ServiceRequestStatus.workerAccepted:
      return Icons.task_alt_outlined;
    case ServiceRequestStatus.bidReceived:
    case ServiceRequestStatus.bidAccepted:
      return Icons.gavel_rounded;
    case ServiceRequestStatus.onTheWay:
      return Icons.directions_car_outlined;
    case ServiceRequestStatus.arrived:
      return Icons.location_on_outlined;
    case ServiceRequestStatus.inProgress:
      return Icons.build_outlined;
    case ServiceRequestStatus.completed:
      return Icons.check_circle_outline;
    case ServiceRequestStatus.cancelled:
      return Icons.cancel_outlined;
    case ServiceRequestStatus.unknown:
      return Icons.help_outline;
  }
}
