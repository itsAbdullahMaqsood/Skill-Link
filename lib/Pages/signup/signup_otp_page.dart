import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skilllink/Widgets/auth_back_scope.dart';
import 'package:skilllink/Widgets/auth_shell.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/core/storage/token_storage.dart';
import 'package:skilllink/Pages/signup/signup_profile_page.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

class SignupOtpPage extends StatefulWidget {
  const SignupOtpPage({super.key, required this.email});

  final String email;

  @override
  State<SignupOtpPage> createState() => _SignupOtpPageState();
}

class _SignupOtpPageState extends State<SignupOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  final _api = SignupApiService();
  final _tokenStorage = TokenStorage();
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    final otp = _otpController.text.trim();
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await _api.verifyOtpSignup(
        email: widget.email,
        otp: otp,
      );
      await _tokenStorage.saveTempSignupToken(res.token);
      _expiryTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupProfilePage(
            email: widget.email,
            tempToken: res.token,
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
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  AuthHero(
                    subtitle: 'Check your email',
                    description: 'We sent a 6-digit code to ${widget.email}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Enter verification code',
                          style: AppTypography.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a 6-digit code to ${widget.email}',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _otpController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          letterSpacing: 6,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: authInputDecoration(
                          hint: '••••••',
                          counterText: '',
                        ),
                        validator: (v) {
                          final s = v?.trim().replaceAll(' ', '') ?? '';
                          if (s.length != 6) return 'Enter 6 digits';
                          if (!RegExp(r'^\d{6}$').hasMatch(s)) {
                            return 'Only numbers allowed';
                          }
                          return null;
                        },
                        onChanged: (v) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length <= 6 && digits != v) {
                            _otpController.text = digits;
                            _otpController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: digits.length),
                            );
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
                        label: 'Verify',
                        icon: Icons.verified_user_rounded,
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
