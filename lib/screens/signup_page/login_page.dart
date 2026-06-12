import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../app_bar.dart';
import '../home_screen.dart';
import '../premium_effects.dart';
import '../transition_animations.dart';
import 'signup_page.dart';
import 'google_signin_page.dart';
import 'github_regis_page.dart';
import 'congrats_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late final AuthService _authService;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(Supabase.instance.client);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToSignupPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const SignupPage()),
    );
  }

  void _goToGoogleSigninPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const GoogleSigninPage()),
    );
  }

  void _goToGitHubPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const GitHubRegisPage()),
    );
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    // 1. LOCK UI: Prevent multiple clicks and visual state update
    setState(() => _isSubmitting = true);

    try {
      // 2. AWAIT the authentication process
      await _authService.signIn(email: email, password: password);

      // 3. SESSION GUARD: Check if we actually have a session now.
      // This prevents the page from opening if the service returned without an error but failed to log in.
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception("Authentication failed: No session established.");
      }

      if (!mounted) return;

      // 4. SUCCESS: Only navigate if the session check passed.
      Navigator.of(context).pushReplacement(
        PremiumTransitions.zoomFade(
          CongratsPage(
            authMethod: "Email",
            authAction: "logged in",
          ),
        ),
      );
    } on AuthException catch (e) {
      if (mounted) _showSnackBar(e.message);
    } catch (e) {
      if (mounted) _showSnackBar('Sign in failed. Please check your credentials.');
    } finally {
      // 5. UNLOCK UI: Restore button functionality
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Enter your email address first.');
      return;
    }

    try {
      await _authService.resetPassword(email);
      if (!mounted) return;
      _showSnackBar('Password reset email sent.');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not send reset email. Try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        backgroundColor: const Color(0xFF1A1A1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAppBarLeading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white.withOpacity(0.8),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.blur_on,
            color: Colors.black,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'QUANTMESSAGE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.0,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PremiumAppBar(
        leading: _buildAppBarLeading(),
      ),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        showMovingDots: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'AUTHENTICATION',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuraHeadline(
                    controller: _textController,
                    fullText: '< /sign_in > to QUANTMESSAGE',
                    highlightPart: '< /sign_in >',
                  ),
                  const SizedBox(height: 16),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Enter your credentials to access your personalised feed and workspace.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: _buildInputField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: _buildInputField(
                      controller: _passwordController,
                      hintText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withOpacity(0.35),
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      // DISABLE button if submitting to prevent multiple triggers
                      onPressed: _isSubmitting ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'sign in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToGitHubPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.code, size: 18, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            'continue with github',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToGoogleSigninPage,
                      outlined: true,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[300],
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'continue with google',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: TextButton(
                      onPressed: _goToSignupPage,
                      child: Text(
                        "Don't have an account? create",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Container(
      width: 320,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
