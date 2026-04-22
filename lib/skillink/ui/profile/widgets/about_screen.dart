import 'package:flutter/material.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('About', style: AppTypography.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.handyman_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text('SkillLink', style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'AI & IoT Powered Smart Home Maintenance',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            _InfoCard(
              title: 'Team',
              children: const [
                _InfoRow(label: 'Flutter Developer', value: 'Abdullah Latif'),
                _InfoRow(label: 'Backend Developer', value: 'Abdullah Maqsood'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Supervisor',
              children: const [
                _InfoRow(label: '', value: 'Ms. Zainab Zafar'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'University',
              children: const [
                _InfoRow(label: '', value: 'Lahore Garrison University'),
                _InfoRow(label: 'Program', value: 'BSCS — Final Year Project'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '\u00a9 2024-2025 SkillLink. All rights reserved.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (label.isNotEmpty) ...[
            Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: label.isEmpty ? TextAlign.start : TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
