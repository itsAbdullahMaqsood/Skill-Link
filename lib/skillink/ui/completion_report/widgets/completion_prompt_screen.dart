import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/completion_report.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/completion_prompt_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

class CompletionPromptScreen extends ConsumerStatefulWidget {
  const CompletionPromptScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<CompletionPromptScreen> createState() =>
      _CompletionPromptScreenState();
}

class _CompletionPromptScreenState
    extends ConsumerState<CompletionPromptScreen> {
  late final TextEditingController _amount;
  final _formKey = GlobalKey<FormState>();

  bool _didPrefill = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = double.tryParse(_amount.text.trim());
    if (value == null) return;
    await ref
        .read(completionPromptViewModelProvider(widget.jobId).notifier)
        .submit(amount: value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completionPromptViewModelProvider(widget.jobId));

    final prefillJob = state.job;
    if (!_didPrefill && prefillJob != null) {
      _didPrefill = true;
      final price = prefillJob.finalPrice;
      if (price != null && _amount.text.isEmpty) {
        _amount.text = price.toStringAsFixed(0);
      }
    }

    ref.listen(
      completionPromptViewModelProvider(widget.jobId)
          .select((s) => s.submittedReport),
      (prev, next) {
        if (next == null) return;
        final isHomeowner = state.isHomeowner;
        final job = state.job;
        final user = ref.read(authViewModelProvider).user;
        String? destination;
        if (isHomeowner && job != null) {
          destination = Routes.rateJob(job.jobId);
        } else if (user != null) {
          destination = Routes.homeFor(user.role);
        }
        if (destination == null) return;
        context.go(destination);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(completionPromptViewModelProvider(widget.jobId).notifier)
              .acknowledgeSubmission();
        });
      },
    );

    if (state.bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isHomeowner = state.isHomeowner;
    final title = isHomeowner
        ? 'How much did you pay for this job?'
        : 'What amount did you earn from this job?';
    final subtitle = isHomeowner
        ? 'Please answer honestly. This amount is eligible for a full '
            'refund within 3 months if the same issue recurs.'
        : 'Please answer honestly. This will be verified later — '
            'misreporting can result in account suspension.';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32 - 24,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(isHomeowner: isHomeowner),
                          const SizedBox(height: 24),
                          Text(title, style: AppTypography.headlineMedium),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.job != null) _JobSummary(state: state),
                          if (state.report != null) ...[
                            const SizedBox(height: 12),
                            _OtherPartyStatus(
                              report: state.report!,
                              isHomeowner: isHomeowner,
                            ),
                          ],
                          const SizedBox(height: 24),
                          _AmountField(controller: _amount),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.errorMessage!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                          const Expanded(child: SizedBox.shrink()),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: isHomeowner
                                ? 'Report amount paid'
                                : 'Report amount earned',
                            onPressed: state.isSubmitting ? null : _submit,
                            isLoading: state.isSubmitting,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You can't use other parts of the app until "
                            'this is submitted.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isHomeowner});
  final bool isHomeowner;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isHomeowner ? 'Job complete — confirm what you paid'
                : 'Job complete — confirm what you earned',
            style: AppTypography.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _JobSummary extends StatelessWidget {
  const _JobSummary({required this.state});
  final CompletionPromptState state;
  @override
  Widget build(BuildContext context) {
    final job = state.job!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titleCase(job.serviceType), style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${job.address.street}, ${job.address.area}, ${job.address.city}',
            style: AppTypography.bodySmall,
          ),
          if (job.finalPrice != null) ...[
            const SizedBox(height: 8),
            Text(
              'Agreed price: Rs ${job.finalPrice!.toStringAsFixed(0)}',
              style: AppTypography.labelMedium,
            ),
          ],
        ],
      ),
    );
  }

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    if (s.toLowerCase() == 'hvac') return 'HVAC';
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _OtherPartyStatus extends StatelessWidget {
  const _OtherPartyStatus({
    required this.report,
    required this.isHomeowner,
  });

  final CompletionReport report;
  final bool isHomeowner;

  @override
  Widget build(BuildContext context) {
    final otherSubmitted =
        isHomeowner ? report.workerSubmitted : report.homeownerSubmitted;
    final otherSubmittedAt = isHomeowner
        ? report.workerSubmittedAt
        : report.homeownerSubmittedAt;
    final otherLabel = isHomeowner ? 'worker' : 'homeowner';

    final IconData icon;
    final Color color;
    final String text;
    if (otherSubmitted) {
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
      final ago = otherSubmittedAt == null
          ? ''
          : ' · ${_timeAgo(otherSubmittedAt)}';
      text = 'The $otherLabel has reported their amount$ago.';
    } else {
      icon = Icons.hourglass_top_rounded;
      color = AppColors.textMuted;
      text = 'Waiting on the $otherLabel to confirm.';
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  static String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      autofocus: true,
      style: AppTypography.headlineLarge,
      decoration: InputDecoration(
        prefixText: 'Rs ',
        prefixStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.textMuted,
        ),
        hintText: '0',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (value) {
        final v = (value ?? '').trim();
        if (v.isEmpty) return 'Enter the amount.';
        final n = double.tryParse(v);
        if (n == null || n.isNaN || n.isInfinite) return 'Enter a valid number.';
        if (n < 0) return 'Amount cannot be negative.';
        return null;
      },
    );
  }
}
