import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_bar.dart';
import '../premium_effects.dart';
import '../transition_animations.dart'; // <--- ADDED IMPORT
import '../../services/google_auth_service.dart';
import 'congrats_page.dart'; // <--- ADDED IMPORT

class GoogleSigninPage extends StatefulWidget {
  const GoogleSigninPage({Key? key}) : super(key: key);

  @override
  State<GoogleSigninPage> createState() => _GoogleSigninPageState();
}

class _GoogleSigninPageState extends State<GoogleSigninPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late final GoogleAuthService _googleAuthService;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _googleAuthService = GoogleAuthService(Supabase.instance.client);

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
    super.dispose();
  }

  /// Triggers the Web OAuth Redirect flow
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSubmitting = true);
    try {
      // This method triggers the Google OAuth flow
      await _googleAuthService.signInWithGoogle();

      if (!mounted) return;

      // SUCCESS: Redirect to Congrats Page
      // We use "signed in" as a generic term for OAuth (which handles both login and signup)
      Navigator.of(context).pushReplacement(
        PremiumTransitions.zoomFade(
          CongratsPage(
            authMethod: "Google",
            authAction: "signed in",
          ),
        ),
      );
    } on AuthException catch (e) {
      if (mounted) _showErrorSnackBar(e.message);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Authentication failed. Please check your network.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PremiumAppBar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.8), size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            const Text(
              'AUTH PORTAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
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
                  // Top Status Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'AUTHORIZATION PROTOCOL',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Aura Headline
                  AuraHeadline(
                    controller: _textController,
                    fullText: '< /authorize > google_id',
                    highlightPart: '< /authorize >',
                  ),
                  const SizedBox(height: 16),

                  // Descriptive Text
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Securely link your Google identity to QuantMessage. You will be redirected to the official Google authorization server.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Central Visual Element: Glowing Glassy Google Icon
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.08),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // The Final Action Button
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _isSubmitting ? null : _handleGoogleSignIn,
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
                            'Initiate Handshake',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.lock_open, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Small subtle hint
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Secure End-to-End Encryption',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w300,
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
}
