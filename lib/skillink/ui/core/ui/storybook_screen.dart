import 'package:flutter/material.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/anomaly_banner.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/bottom_nav_shell.dart';
import 'package:skilllink/skillink/ui/core/ui/chat_bubble.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/error_view.dart';
import 'package:skilllink/skillink/ui/core/ui/job_status_chip.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/secondary_button.dart';
import 'package:skilllink/skillink/ui/core/ui/sensor_gauge.dart';
import 'package:skilllink/skillink/ui/core/ui/worker_card.dart';

class StorybookScreen extends StatefulWidget {
  const StorybookScreen({super.key});

  @override
  State<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends State<StorybookScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Widget Storybook',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('PrimaryButton'),
          PrimaryButton(label: 'Book Now', onPressed: () {}),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Loading…',
            onPressed: () {},
            isLoading: true,
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.add,
          ),

          _section('SecondaryButton'),
          SecondaryButton(label: 'Cancel', onPressed: () {}),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Loading…',
            onPressed: () {},
            isLoading: true,
          ),

          _section('AppTextField'),
          AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Password',
            hint: '••••••••',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: const Icon(Icons.visibility_off_outlined),
          ),

          _section('WorkerCard'),
          WorkerCard(
            name: 'Ali Raza',
            services: const ['Electrician', 'HVAC'],
            rating: 4.8,
            reviewCount: 127,
            distanceKm: 2.3,
            isVerified: true,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          WorkerCard(
            name: 'Usman Khan',
            services: const ['Plumber', 'Carpenter', 'Painter'],
            rating: 4.2,
            reviewCount: 45,
            distanceKm: 8.5,
            onTap: () {},
          ),

          _section('JobStatusChip'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              JobStatusChip(status: 'posted'),
              JobStatusChip(status: 'workerAccepted'),
              JobStatusChip(status: 'bidReceived'),
              JobStatusChip(status: 'bidAccepted'),
              JobStatusChip(status: 'onTheWay'),
              JobStatusChip(status: 'arrived'),
              JobStatusChip(status: 'inProgress'),
              JobStatusChip(status: 'completed'),
              JobStatusChip(status: 'cancelledNoPenalty'),
              JobStatusChip(status: 'cancelledWithPenalty'),
            ],
          ),

          _section('SensorGauge'),
          Row(
            children: [
              Expanded(
                child: SensorGauge(
                  label: 'Voltage',
                  value: 223.5,
                  unit: 'V',
                  maxValue: 300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SensorGauge(
                  label: 'Current',
                  value: 4.2,
                  unit: 'A',
                  maxValue: 15,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SensorGauge(
                  label: 'Wattage',
                  value: 287.0,
                  unit: 'W',
                  maxValue: 500,
                  isAnomalous: true,
                ),
              ),
            ],
          ),

          _section('AnomalyBanner'),
          AnomalyBanner(
            title: 'Voltage Spike Detected',
            subtitle: 'Living Room AC — 287V (normal: 210-240V)',
            onTap: () {},
          ),

          _section('ChatBubble'),
          const ChatBubble(
            text: 'My fridge isn\'t cooling properly. What should I check?',
            isUser: true,
            timestamp: '2:34 PM',
          ),
          const ChatBubble(
            text:
                'Check the condenser coils for dust buildup and ensure the thermostat is set correctly. If the compressor is clicking but not running, you may need a technician.',
            isUser: false,
            timestamp: '2:34 PM',
          ),

          _section('EmptyState'),
          const SizedBox(
            height: 250,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No Workers Found',
              subtitle: 'Try adjusting your filters or search area.',
              actionLabel: 'Clear Filters',
            ),
          ),

          _section('ErrorView'),
          SizedBox(
            height: 250,
            child: ErrorView(
              message: 'Could not load workers. Check your connection.',
              onRetry: () {},
            ),
          ),

          _section('LoadingShimmer'),
          const LoadingShimmer(),
          const SizedBox(height: 8),
          const LoadingShimmer(width: 200, height: 12),
          const SizedBox(height: 8),
          const LoadingShimmer.avatar(),
          const SizedBox(height: 8),
          const LoadingShimmer.card(),

          _section('BottomNavShell (inline demo)'),
          SizedBox(
            height: 120,
            child: BottomNavShell(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store_outlined),
                  activeIcon: Icon(Icons.store),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy_outlined),
                  activeIcon: Icon(Icons.smart_toy),
                  label: 'AI Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sensors_outlined),
                  activeIcon: Icon(Icons.sensors),
                  label: 'IoT',
                ),
              ],
              body: Center(
                child: Text(
                  'Tab $_navIndex selected',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(title, style: AppTypography.headlineSmall),
    );
  }
}
