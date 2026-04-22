import 'package:flutter/material.dart';
import 'package:skilllink/services/password_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/Pages/forgot%20password/verify_otp_screen.dart';
import 'package:skilllink/Widgets/auth_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordService = PasswordService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _passwordService.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);
      final email = _emailController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP sent to $email. Check your inbox and spam folder.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtpScreen(email: email),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: AuthHero(
              subtitle: 'Reset Your Password',
              description:
                  "Enter your email and we'll send you a one-time code.",
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
                      child: Text('Forgot Password?',
                          style: AppTypography.headlineLarge),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "We'll send an OTP to your email",
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Email Address', style: AppTypography.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: authInputDecoration(
                        hint: 'user@example.com',
                        suffix: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final s = value?.trim() ?? '';
                        if (s.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(s)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Send OTP',
                      icon: Icons.send_rounded,
                      isLoading: _isLoading,
                      onPressed: _sendOtp,
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
