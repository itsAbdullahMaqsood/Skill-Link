import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/worker_card.dart';
import 'package:skilllink/skillink/ui/marketplace/view_models/marketplace_view_model.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key, this.initialTrade});

  final String? initialTrade;

  static const List<({String id, String label})> _tradeOptions = [
    (id: 'electrician', label: 'Electrician'),
    (id: 'plumber', label: 'Plumber'),
    (id: 'hvac', label: 'AC / HVAC'),
    (id: 'carpenter', label: 'Carpenter'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = marketplaceViewModelProvider(initialTrade);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    final serviceMap =
        ref.watch(labourServiceIdToNameProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Marketplace', style: AppTypography.headlineMedium),
        actions: [
          _SortMenu(
            current: state.filter.sort,
            onChanged: viewModel.setSort,
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            tradeOptions: _tradeOptions,
            state: state,
            onTradeChanged: viewModel.setTrade,
            onMinRatingChanged: viewModel.setMinRating,
            onMaxDistanceChanged: viewModel.setMaxDistance,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: state.workers.when(
                skipLoadingOnReload: true,
                loading: () => const _LoadingList(),
                error: (err, _) => ErrorView(
                  message: err is String ? err : err.toString(),
                  onRetry: viewModel.refresh,
                ),
                data: (workers) {
                  if (workers.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 64),
                      children: [
                        EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No workers match',
                          subtitle:
                              'Try widening the distance or clearing the trade '
                              'filter.',
                          actionLabel: 'Clear filters',
                          onAction: () {
                            viewModel.setTrade(null);
                            viewModel.setMinRating(null);
                            viewModel.setMaxDistance(null);
                          },
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: workers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final w = workers[i];
                      return WorkerCard(
                        name: w.name,
                        services: resolveWorkerServiceLabels(
                          w,
                          idToName: serviceMap,
                        ),
                        rating: w.rating,
                        reviewCount: w.reviewCount,
                        distanceKm: w.distanceKm ?? 0,
                        avatarUrl: w.avatarUrl,
                        isVerified: w.verificationStatus,
                        onTap: () => context.push(Routes.workerProfile(w.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.tradeOptions,
    required this.state,
    required this.onTradeChanged,
    required this.onMinRatingChanged,
    required this.onMaxDistanceChanged,
  });

  final List<({String id, String label})> tradeOptions;
  final MarketplaceState state;
  final ValueChanged<String?> onTradeChanged;
  final ValueChanged<double?> onMinRatingChanged;
  final ValueChanged<double?> onMaxDistanceChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: 'All',
                  selected: state.filter.trade == null,
                  onSelected: () => onTradeChanged(null),
                ),
                const SizedBox(width: 8),
                for (final t in tradeOptions) ...[
                  _Chip(
                    label: t.label,
                    selected: state.filter.trade == t.id,
                    onSelected: () => onTradeChanged(t.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: state.filter.minRating == null
                      ? 'Any rating'
                      : '${state.filter.minRating!.toStringAsFixed(1)}+ ★',
                  selected: state.filter.minRating != null,
                  leading: const Icon(Icons.star_rounded, size: 14),
                  onSelected: () => _openRatingSheet(context),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: state.filter.radiusKm == null
                      ? 'Any distance'
                      : '≤ ${state.filter.radiusKm!.toStringAsFixed(0)} km',
                  selected: state.filter.radiusKm != null,
                  leading: const Icon(Icons.place_outlined, size: 14),
                  onSelected: () => _openDistanceSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRatingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet<double?>(
        title: 'Minimum rating',
        current: state.filter.minRating,
        options: const [
          (value: null, label: 'Any rating'),
          (value: 3.5, label: '3.5 ★ and up'),
          (value: 4.0, label: '4.0 ★ and up'),
          (value: 4.5, label: '4.5 ★ and up'),
        ],
        onSelected: onMinRatingChanged,
      ),
    );
  }

  void _openDistanceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet<double?>(
        title: 'Max distance',
        current: state.filter.radiusKm,
        options: const [
          (value: null, label: 'Any distance'),
          (value: 5.0, label: 'Within 5 km (Nearby)'),
          (value: 10.0, label: 'Within 10 km'),
          (value: 20.0, label: 'Within 20 km'),
        ],
        onSelected: onMaxDistanceChanged,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surface;
    final fg = selected ? Colors.white : AppColors.textPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 14),
                  child: leading!,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onChanged});

  final WorkerSort current;
  final ValueChanged<WorkerSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<WorkerSort>(
      tooltip: 'Sort',
      icon: const Icon(Icons.swap_vert_rounded),
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final option in WorkerSort.values)
          PopupMenuItem<WorkerSort>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 18,
                  color: option == current
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(option.displayName),
              ],
            ),
          ),
      ],
    );
  }
}

class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.current,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final T current;
  final List<({T value, String label})> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title, style: AppTypography.titleLarge),
            ),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                title: Text(option.label),
                trailing: current == option.value
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelected(option.value);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            LoadingShimmer.avatar(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingShimmer(width: 160),
                  SizedBox(height: 8),
                  LoadingShimmer(width: 110),
                  SizedBox(height: 8),
                  LoadingShimmer(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
