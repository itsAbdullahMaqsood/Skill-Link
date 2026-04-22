import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/service_request.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/booking/view_models/booking_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_back_scope.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/open_job_post/view_models/open_job_post_view_model.dart';

class OpenJobPostScreen extends ConsumerWidget {
  const OpenJobPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(openJobPostViewModelProvider);
    final vm = ref.read(openJobPostViewModelProvider.notifier);

    ref.listen<OpenJobPostState>(openJobPostViewModelProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg == null || msg == prev?.errorMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return AppBackScope(
      fallbackPath: Routes.homeownerHome,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Post a Job'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (state.currentStep > 0) {
                vm.back();
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.homeownerHome);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _StepperHeader(currentStep: state.currentStep),
              Expanded(
                child: IndexedStack(
                  index: state.currentStep,
                  children: [
                    _StepIssue(state: state, vm: vm),
                    _StepSchedule(state: state, vm: vm),
                    _StepAddress(state: state, vm: vm),
                  ],
                ),
              ),
              _OpenJobPostFooter(
                state: state,
                onBack: vm.back,
                onNext: vm.next,
                onSubmit: () async {
                  final outcome = await vm.submit();
                  if (!context.mounted) return;
                  if (outcome != OpenJobPostOutcome.success) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Your job is now open for bids. Workers will '
                        'start responding shortly.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.homeownerHome);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader({required this.currentStep});
  final int currentStep;

  static const _titles = ['Describe issue', 'Pick time', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Open to bids from qualifying workers nearby',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= currentStep
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Step ${currentStep + 1} of 3 · ${_titles[currentStep]}',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}


class _StepIssue extends StatefulWidget {
  const _StepIssue({required this.state, required this.vm});
  final OpenJobPostState state;
  final OpenJobPostViewModel vm;

  @override
  State<_StepIssue> createState() => _StepIssueState();
}

class _StepIssueState extends State<_StepIssue> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppTextField(
          label: 'What\'s the issue?',
          hint: 'e.g. Bathroom sink is leaking under the cabinet…',
          controller: _controller,
          maxLines: 5,
          onChanged: widget.vm.setDescription,
        ),
        const SizedBox(height: 20),
        Text('Photos (optional)', style: AppTypography.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Helps workers quote accurately. Up to '
          '${OpenJobPostViewModel.maxPhotos} photos.',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final path in widget.state.localPhotoPaths)
              _PhotoTile(
                path: path,
                onRemove: () => widget.vm.removePhoto(path),
              ),
            if (widget.state.localPhotoPaths.length <
                OpenJobPostViewModel.maxPhotos)
              _AddPhotoTile(onTap: widget.vm.addPhoto),
          ],
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(path),
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.border,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.textMuted),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
            SizedBox(height: 4),
            Text('Add', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}


class _StepSchedule extends StatelessWidget {
  const _StepSchedule({required this.state, required this.vm});
  final OpenJobPostState state;
  final OpenJobPostViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isToday = state.scheduledDate != null &&
        _isSameDay(state.scheduledDate!, DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Preferred date', style: AppTypography.titleLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: state.scheduledDate ?? now,
              firstDate: now,
              lastDate: now.add(const Duration(days: 30)),
            );
            if (picked != null) vm.setDate(picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  state.scheduledDate == null
                      ? 'Pick a date'
                      : _formatDate(state.scheduledDate!),
                  style: AppTypography.bodyMedium.copyWith(
                    color: state.scheduledDate == null
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Time slot', style: AppTypography.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in BookingTimeSlot.all)
              Builder(
                builder: (_) {
                  final disabled =
                      isToday && slot.startHour <= DateTime.now().hour;
                  return ChoiceChip(
                    label: Text(slot.label),
                    selected: state.timeSlot == slot.label,
                    onSelected: disabled
                        ? null
                        : (_) => vm.setTimeSlot(slot.label),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}


class _StepAddress extends StatefulWidget {
  const _StepAddress({required this.state, required this.vm});
  final OpenJobPostState state;
  final OpenJobPostViewModel vm;

  @override
  State<_StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<_StepAddress> {
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _addressCtrl = TextEditingController(text: widget.state.serviceAddress);
  }

  @override
  void didUpdateWidget(covariant _StepAddress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.serviceAddress != _addressCtrl.text &&
        !_addressCtrl.selection.isValid) {
      _addressCtrl.text = widget.state.serviceAddress;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Service address', style: AppTypography.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Where should the winning worker show up? Pre-filled from your '
          'profile — edit if needed.',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Address',
          hint: 'e.g. G9, Main Road, Islamabad',
          controller: _addressCtrl,
          maxLines: 3,
          onChanged: widget.vm.setServiceAddress,
        ),
        const SizedBox(height: 24),
        Text('Payment method', style: AppTypography.titleLarge),
        const SizedBox(height: 8),
        _PaymentOption(
          label: 'Cash on Completion',
          subtitle: 'Pay the worker directly after the job is done.',
          icon: Icons.payments_outlined,
          selected:
              widget.state.paymentMethod == ServiceRequestPaymentMethod.cash,
          onTap: () =>
              widget.vm.setPaymentMethod(ServiceRequestPaymentMethod.cash),
        ),
        const SizedBox(height: 8),
        _PaymentOption(
          label: 'Pay in-app',
          subtitle: 'Secure card / wallet payment via SkillLink.',
          icon: Icons.credit_card,
          selected: false,
          disabled: true,
          comingSoon: true,
          onTap: () {},
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.comingSoon = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.border;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label, style: AppTypography.titleLarge),
                        if (comingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Coming soon',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _OpenJobPostFooter extends StatelessWidget {
  const _OpenJobPostFooter({
    required this.state,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final OpenJobPostState state;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  bool get _canProceed => switch (state.currentStep) {
        0 => state.isStep1Valid,
        1 => state.isStep2Valid,
        _ => state.isStep3Valid,
      };

  @override
  Widget build(BuildContext context) {
    final isLast = state.currentStep == 2;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (state.currentStep > 0) ...[
              Expanded(
                child: SecondaryButton(
                  label: 'Back',
                  onPressed: state.isSubmitting ? null : onBack,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: isLast ? 'Post job' : 'Continue',
                isLoading: state.isSubmitting,
                onPressed:
                    !_canProceed ? null : (isLast ? onSubmit : onNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
