import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/router/app_router.dart' show kSkillTypePrefKey;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _navigateAfterSplash();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authService = AuthService();
    await authService.initializeAuth();

    if (!mounted) return;
    final isLoggedIn = await authService.isLoggedIn();

    final prefs = await SharedPreferences.getInstance();
    final skillType = prefs.getString(kSkillTypePrefKey);
    final labourRole = prefs.getString(kLabourRolePrefKey);

    if (!mounted) return;

    if (!isLoggedIn) {
      context.go('/skill-type');
      return;
    }

    if (skillType == null || skillType.isEmpty) {
      context.go('/skill-type');
    } else if (skillType == 'digital') {
      context.go('/digital');
    } else if (labourRole == null || labourRole.isEmpty) {
      context.go(Routes.roleSelect);
    } else if (labourRole == 'worker') {
      context.go(Routes.workerJobs);
    } else {
      context.go(Routes.homeownerHome);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/Vector.svg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Skill Link',
                style: AppTypography.displayLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Seamless Skill Exchange',
                style:
                    AppTypography.titleLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
