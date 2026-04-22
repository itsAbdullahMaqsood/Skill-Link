import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    this.title = 'Skill Link',
    required this.subtitle,
    this.description,
  });

  final String title;

  final String subtitle;

  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              'assets/images/Vector.svg',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: Colors.white.withOpacity(0.9)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
  String? counterText,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
    prefixIcon: prefix,
    suffixIcon: suffix,
    counterText: counterText,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
  );
}
