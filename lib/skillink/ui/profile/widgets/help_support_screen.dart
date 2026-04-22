import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = <({String q, String a})>[
    (
      q: 'How do I book a worker?',
      a:
          'Open Marketplace, pick a trade, choose a worker, then tap Book Now to describe the job and schedule a time.',
    ),
    (
      q: 'How does bidding work?',
      a:
          'After you post a job, the worker sends a price. You can accept or send a counter-offer until both sides agree.',
    ),
    (
      q: 'What is the AI assistant?',
      a:
          'The AI tab helps troubleshoot common home issues and can recommend a nearby technician when you need a pro.',
    ),
    (
      q: 'What do IoT alerts mean?',
      a:
          'When an appliance looks unusual (for example a voltage spike), you get an alert. Open the alert to see details and book help if needed.',
    ),
    (
      q: 'How do I pay?',
      a:
          'MVP supports cash on completion. In-app card payments are planned for a later release.',
    ),
    (
      q: 'How do I contact SkillLink?',
      a: 'Use the button below to email our support team. We respond within one business day.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authViewModelProvider).user?.id ?? 'unknown';

    return AppScaffold(
      title: 'Help & Support',
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Common questions', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          for (final item in _faqs) ...[
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(item.q, style: AppTypography.titleLarge),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      item.a,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Contact support',
            onPressed: () async {
              final subject =
                  Uri.encodeComponent('SkillLink support (user $uid)');
              final uri = Uri.parse(
                'mailto:${AppConstants.supportEmail}?subject=$subject',
              );
              final ok = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!context.mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open email app.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
