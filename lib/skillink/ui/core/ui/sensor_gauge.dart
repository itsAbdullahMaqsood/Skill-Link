import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class SensorGauge extends StatelessWidget {
  const SensorGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.minValue = 0,
    this.maxValue = 300,
    this.isAnomalous = false,
  });

  final String label;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;
  final bool isAnomalous;

  @override
  Widget build(BuildContext context) {
    final ratio = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final color = isAnomalous ? AppColors.danger : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isAnomalous
            ? Border.all(color: AppColors.danger.withValues(alpha: 0.4))
            : null,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: AppTypography.mono.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(unit, style: AppTypography.monoSmall),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.shimmerBase,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
