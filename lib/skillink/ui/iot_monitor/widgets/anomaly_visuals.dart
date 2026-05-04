import 'package:flutter/material.dart';
import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';

class AnomalyVisuals {
  AnomalyVisuals._();

  static String title(Anomaly a) => titleForType(a.type);

  static String titleForType(String type) => switch (type) {
        'voltage_spike' => 'Voltage Spike',
        'voltage_sag' => 'Voltage Drop',
        'voltage_flicker' => 'Voltage Flicker',
        'voltage_instability' => 'Voltage Instability',
        'current_surge' => 'Current Surge',
        'current_drop' => 'Load Drop',
        'abnormal_load_pattern' => 'Abnormal Load Pattern',
        'over_temperature' => 'Overheating',
        _ => 'Anomaly',
      };

  static IconData iconForType(String type) => switch (type) {
        'voltage_spike' => Icons.electrical_services_rounded,
        'voltage_sag' => Icons.trending_down_rounded,
        'voltage_flicker' => Icons.bolt_rounded,
        'voltage_instability' => Icons.show_chart_rounded,
        'current_surge' => Icons.flash_on_rounded,
        'current_drop' => Icons.trending_down_rounded,
        'abnormal_load_pattern' => Icons.scatter_plot_rounded,
        'over_temperature' => Icons.local_fire_department_rounded,
        _ => Icons.warning_amber_rounded,
      };

  static Color colorForSeverity(String severity) => switch (severity) {
        'high' => AppColors.danger,
        'medium' => AppColors.warning,
        'low' => AppColors.accent,
        _ => AppColors.textMuted,
      };

  static String severityLabel(String severity) => switch (severity) {
        'high' => 'High',
        'medium' => 'Medium',
        'low' => 'Low',
        _ => severity,
      };

  static String timeAgo(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 30) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static IconData iconForApplianceType(String type) =>
      switch (type.toLowerCase()) {
        'ac' || 'hvac' => Icons.ac_unit_rounded,
        'fridge' => Icons.kitchen_rounded,
        'heater' => Icons.whatshot_rounded,
        'washer' => Icons.local_laundry_service_rounded,
        'oven' => Icons.microwave_rounded,
        'tv' => Icons.tv_rounded,
        _ => Icons.electrical_services_rounded,
      };

  static Color statusDotFor({
    required bool hasLive,
    required bool hasOpenAnomaly,
  }) {
    if (hasOpenAnomaly) return AppColors.danger;
    if (!hasLive) return AppColors.textMuted;
    return AppColors.success;
  }
}
