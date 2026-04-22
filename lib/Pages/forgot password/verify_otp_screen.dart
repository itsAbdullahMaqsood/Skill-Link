import 'package:flutter/material.dart';
import 'package:skilllink/services/password_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/Pages/forgot%20password/reset_password_screen.dart';
import 'package:skilllink/Widgets/auth_shell.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordService = PasswordService();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final resetToken = await _passwordService.verifyOtp(
        widget.email,
        _otpController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _passwordService.forgotPassword(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'OTP sent again. Check your email and spam folder.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AuthHero(
              subtitle: 'Verify OTP',
              description: 'Enter the 6-digit code sent to ${widget.email}',
            ),
          ),
          Expanded(
            child: AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text('Enter OTP',
                          style: AppTypography.headlineLarge),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '6-digit code from your email',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('OTP', style: AppTypography.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      style: AppTypography.headlineMedium.copyWith(
                        letterSpacing: 6,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      decoration: authInputDecoration(
                        hint: '••••••',
                        counterText: '',
                      ),
                      validator: (value) {
                        final s = value?.trim() ?? '';
                        if (s.length != 6) return 'Enter 6 digits';
                        if (!RegExp(r'^\d{6}$').hasMatch(s)) {
                          return 'OTP must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(48, 44),
                        ),
                        child: const Text("Didn't receive? Resend OTP"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Verify OTP',
                      icon: Icons.verified_user_rounded,
                      isLoading: _isLoading,
                      onPressed: _verifyOtp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
