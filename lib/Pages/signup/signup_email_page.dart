import 'package:flutter/material.dart';
import 'package:skilllink/Widgets/auth_back_scope.dart';
import 'package:skilllink/Widgets/auth_shell.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/Pages/signup/signup_otp_page.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

class SignupEmailPage extends StatefulWidget {
  const SignupEmailPage({super.key});

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _api = SignupApiService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _api.verifyEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupOtpPage(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackScope(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Column(
          children: [
            const SafeArea(
              bottom: false,
              child: AuthHero(subtitle: 'Sign up'),
            ),
            Expanded(
              child: AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Verify your email',
                          style: AppTypography.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        "We'll send a one-time code to this email.",
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        decoration: authInputDecoration(
                          hint: 'you@example.com',
                          prefix: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(s)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Send code',
                        icon: Icons.send_rounded,
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
