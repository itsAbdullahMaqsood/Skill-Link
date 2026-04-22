import 'dart:convert' show base64, json, utf8;
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/Pages/forgot%20password/forgot_password_screen.dart';
import 'package:skilllink/Pages/signup/signup_email_page.dart';
import 'package:skilllink/Widgets/auth_back_scope.dart';
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/google_sign_in_service.dart';
import 'package:skilllink/services/login_api_service.dart';
import 'package:skilllink/services/skillink_login_api_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

void _logGoogleIdTokenForDebug(String idToken) {
  developer.log(
    '[GoogleAuth] id_token (${idToken.length} chars)\n$idToken',
    name: 'GoogleAuth',
  );
  try {
    final parts = idToken.split('.');
    if (parts.length < 2) return;
    var seg = parts[1];
    switch (seg.length % 4) {
      case 0:
        break;
      case 2:
        seg += '==';
        break;
      case 3:
        seg += '=';
        break;
      default:
        return;
    }
    final normalized = seg.replaceAll('-', '+').replaceAll('_', '/');
    final map = json.decode(utf8.decode(base64.decode(normalized)));
    if (map is Map) {
      developer.log(
        '[GoogleAuth] JWT aud=${map['aud']} azp=${map['azp']} email=${map['email']}',
        name: 'GoogleAuth',
      );
      developer.log(
        '[GoogleAuth] If the API says invalid token: set the server\'s Google '
        'OAuth client ID to the same **Web application** client as '
        '[AuthConfig.webClientId] (token audience must match).',
        name: 'GoogleAuth',
      );
    }
  } catch (e, st) {
    developer.log('[GoogleAuth] JWT decode failed: $e', stackTrace: st, name: 'GoogleAuth');
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _loginApi = LoginApiService();
  final _skillinkLoginApi = SkillinkLoginApiService();
  final _googleSignIn = GoogleSignInService();

  bool get _isLabourSide => app_router.currentSkillType() == 'labour';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  static String? _platformErrorToMessage(String code) {
    switch (code) {
      case 'sign_in_failed':
        return 'Google sign-in failed. Check that SHA-1 is added to your Android OAuth client in Google Cloud.';
      case '10':
        return 'Configuration error: Add SHA-1 to Google Cloud Console for this app.';
      case '12501':
        return 'Sign-in was cancelled.';
      case '7':
        return 'No network connection.';
      case 'missing_id_token':
        return 'Google sign-in could not produce an ID token. On Android, add '
            'this app\'s SHA-1 fingerprint in Google Cloud Console (OAuth) and '
            'ensure AuthConfig uses your Web client ID.';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = _isLabourSide
          ? await _skillinkLoginApi.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await _loginApi.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      await _authService.persistAuthFromLogin(
        response,
        labourBackend: _isLabourSide,
      );
      await app_router.reloadSkillPrefs(container);
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(app_router.postLoginLanding(
        app_router.currentSkillType(),
        app_router.currentLabourRole(),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  // ignore: unused_element
  Future<void> _handleGoogleSignIn() async {
    _errorMessage = null;
    setState(() => _isLoading = true);

    try {
      final idToken = await _googleSignIn.signInAndGetIdToken();
      if (!mounted) return;
      if (idToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      _logGoogleIdTokenForDebug(idToken);

      final response = _isLabourSide
          ? await _skillinkLoginApi.loginWithGoogle(idToken: idToken)
          : await _loginApi.loginWithGoogle(idToken: idToken);
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      await _authService.persistAuthFromLogin(
        response,
        labourBackend: _isLabourSide,
      );
      await app_router.reloadSkillPrefs(container);
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(app_router.postLoginLanding(
        app_router.currentSkillType(),
        app_router.currentLabourRole(),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } on PlatformException catch (e) {
      developer.log(
        'Google sign-in PlatformException: ${e.code} - ${e.message}',
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            _platformErrorToMessage(e.code) ?? e.message ?? 'Sign-in failed.';
      });
    } catch (e, st) {
      developer.log('Google sign-in error: $e', stackTrace: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Google sign-in failed. Please try again. (Check console for details)';
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
              child: _buildHero(context),
            ),
            Expanded(child: _buildCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
      child: Column(
        children: [
          if (context.canPop())
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back',
                onPressed: () => context.pop(),
              ),
            )
          else
            const SizedBox(height: 16),
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
            'Skill Link',
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Seamless Skill Exchange',
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Manage the global network of skill sharing.\n'
              'Connect, monitor, and grow the Skill Link ecosystem from one central hub.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Login to get started',
                    style: AppTypography.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),

                Text('Email Address', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: _inputDecoration(
                    hint: 'you@example.com',
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
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: 16),

                Text('Password', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: _inputDecoration(
                    hint: '••••••••',
                    suffix: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(
                          () => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
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

                Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(-8, 0),
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (v) =>
                            setState(() => rememberMe = v ?? false),
                      ),
                    ),
                    Text('Remember me', style: AppTypography.labelLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(48, 44),
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Sign In',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),


                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: AppTypography.bodyMedium),
                      InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupEmailPage(),
                                  ),
                                );
                              },
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Text(
                            'Sign up',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '© 2024 Skill Link. All rights reserved.',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.background,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
}
