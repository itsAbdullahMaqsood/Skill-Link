import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/Widgets/auth_back_scope.dart';
import 'package:skilllink/router/app_router.dart' as router;
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, UserRole role) async {
    final auth = ref.read(authViewModelProvider);
    final user = auth.user;

    if (user != null && user.role != role) {
      final container = ProviderScope.containerOf(context, listen: false);
      await ref.read(authViewModelProvider.notifier).signOut();
      await router.reloadSkillPrefs(container);
      if (!context.mounted) return;
      context.go(router.skillTypePath);
      return;
    }

    await router.setLabourRole(ref, role.name);

    if (user != null) {
      ref
          .read(authViewModelProvider.notifier)
          .setUser(user.copyWith(role: role));
    }

    if (!context.mounted) return;
    if (user != null) {
      context.go(Routes.homeFor(role));
    } else {
      context.push(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthBackScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (context.canPop())
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textMuted,
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                  ),
                ),
              SizedBox(height: context.canPop() ? 8 : 40),
              Text('Welcome to Skill Link', style: AppTypography.displayMedium),
              const SizedBox(height: 8),
              Text(
                'How will you use the labour-skills side?',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 48),
              _RoleCard(
                icon: Icons.home_rounded,
                title: 'I need help at home',
                subtitle:
                    'Find trusted workers, get AI diagnostics, and monitor your appliances.',
                onTap: () => _pick(context, ref, UserRole.homeowner),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: Icons.construction_rounded,
                title: "I'm a skilled worker",
                subtitle:
                    'Get hired for jobs, manage bookings, and grow your reputation.',
                onTap: () => _pick(context, ref, UserRole.worker),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/skill-type'),
                  child: Text(
                    'Switch to Digital Skills instead',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
