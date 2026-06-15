import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'premium_effects.dart';
import 'signup_page/login_page.dart';
import 'signup_page/signup_page.dart';
import 'signup_page/google_login_page.dart';
import 'signup_page/github_regis_page.dart';
import 'transition_animations.dart';
import 'button_buldge.dart';
import 'home_animation.dart';
import 'frequently_asked/frequently_asked.dart';
import 'buttons/google_button.dart';
import 'buttons/github_button.dart';
import 'bottom_info/bottom_info.dart';
import 'animations/messaging_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late Animation<double> _fadeInAnimation;

  late AnimationController _earlyAccessController;
  late Animation<double> _earlyAccessFadeInAnimation;

  // Shimmer + fade-in for the "Register to receive Beta…" text
  late AnimationController _betaTextController;
  late Animation<double> _betaFadeAnimation;
  late Animation<double> _betaShimmerAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _earlyAccessAnimated = false;

  final TextEditingController _accessCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat();

    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _fadeInAnimation = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
    );

    _earlyAccessController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _earlyAccessFadeInAnimation = CurvedAnimation(
      parent: _earlyAccessController,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
    );

    // Shimmer controller: slow repeating loop for the green text
    _betaTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _betaFadeAnimation = CurvedAnimation(
      parent: _betaTextController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _betaShimmerAnimation = CurvedAnimation(
      parent: _betaTextController,
      curve: Curves.easeInOut,
    );
    _betaTextController.repeat(reverse: true);

    _scrollController.addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _checkScrollPosition();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 150 && !_earlyAccessAnimated) {
        setState(() => _earlyAccessAnimated = true);
        _earlyAccessController.forward();
      }
    }
  }

  void _checkScrollPosition() {
    if (!mounted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final earlyAccessTop = screenHeight * 0.8;
    if (_scrollController.offset > 150 ||
        screenHeight > earlyAccessTop + 100) {
      if (!_earlyAccessAnimated) {
        setState(() => _earlyAccessAnimated = true);
        _earlyAccessController.forward();
      }
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    _earlyAccessController.dispose();
    _betaTextController.dispose();
    _scrollController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  void _goToLoginPage() =>
      Navigator.of(context).push(PremiumTransitions.slideRight(const LoginPage()));
  void _goToSignupPage() =>
      Navigator.of(context).push(PremiumTransitions.slideRight(const SignupPage()));
  void _goToGoogleLoginPage() =>
      Navigator.of(context).push(PremiumTransitions.slideRight(const GoogleLoginPage()));
  void _goToGitHubPage() =>
      Navigator.of(context).push(PremiumTransitions.slideRight(const GitHubRegisPage()));
  void _goToFAQPage() =>
      Navigator.of(context).push(PremiumTransitions.slideRight(const FrequentlyAskedScreen()));

  void _handleAccessCode() {
    if (_accessCodeController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an access code');
    } else {
      _goToLoginPage();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;
    final double headlineSize = isMobile ? 40 : 72;
    final double subHeadlineSize = isMobile ? 14 : 18;
    final double sectionTitleSize = isMobile ? 40 : 72;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(),
      body: Stack(
        children: [
          const HomeAnimation(),
          PremiumBackgroundStack(
            bgController: _bgController,
            showMovingDots: true,
            baseColor: Colors.transparent,
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── HERO SECTION ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: const Text(
                                  'SYSTEM ONLINE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TypingTextAnimation(
                              controller: _textController,
                              fullText:
                              '< Coming very soon >\n< stay tuned >',
                              highlightPart: '< Coming very soon >',
                              style: TextStyle(
                                fontFamily: '__copernicus_669e4a',
                                color: Colors.white,
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 40),
                                child: Text(
                                  'We are crafting something extraordinary. Join the next-gen agent platform built by Anubhav Singh Rajput.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: subHeadlineSize,
                                    fontWeight: FontWeight.w300,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.center,
                                children: [
                                  ButtonBulge(
                                    child: AuraButton(
                                      onPressed: _goToLoginPage,
                                      auraController: _bgController,
                                      width: 150,
                                      height: 40,
                                      child: _buildButtonContent(
                                          'sign in', Icons.arrow_forward),
                                    ),
                                  ),
                                  ButtonBulge(
                                    child: AuraButton(
                                      onPressed: _goToSignupPage,
                                      outlined: true,
                                      auraController: _bgController,
                                      width: 150,
                                      height: 40,
                                      child: _buildButtonContent(
                                          'create', Icons.person_add_outlined),
                                    ),
                                  ),
                                  ButtonBulge(
                                    child: AuraButton(
                                      onPressed: _goToFAQPage,
                                      outlined: true,
                                      auraController: _bgController,
                                      width: 150,
                                      height: 40,
                                      child: _buildButtonContent(
                                          'F.A.Q.s',
                                          Icons.help_outline_rounded),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── EARLY ACCESS SECTION ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 80, horizontal: 24),
                      child: Column(
                        children: [
                          TypingTextAnimation(
                            controller: _earlyAccessController,
                            fullText: '< Early Access >',
                            highlightPart: '< Early Access >',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sectionTitleSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: '__copernicus_669e4a',
                            ),
                          ),
                          const SizedBox(height: 48),
                          FadeTransition(
                            opacity: _earlyAccessFadeInAnimation,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final bool mobile = constraints.maxWidth < 1000;

                                if (mobile) {
                                  // ── MOBILE: stack vertically, animation full width ──
                                  return Column(
                                    children: [
                                      // 630×480 animation, capped to available width
                                      SizedBox(
                                        width: constraints.maxWidth,
                                        height: 480,
                                        child: const MessagingAnimation(),
                                      ),

                                      const SizedBox(height: 40),

                                      _buildEarlyAccessPanel(
                                        screenWidth,
                                        isMobile,
                                      ),
                                    ],
                                  );
                                }

                                // ── DESKTOP: side-by-side ──────────────────
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1200,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        // Animation takes ~57% of the row (630 of 1100)
                                        Expanded(
                                          flex: 57,
                                          child: SizedBox(
                                            // Fixed 480 height; width fills flex share
                                            height: 480,
                                            child: const MessagingAnimation(),
                                          ),
                                        ),

                                        const SizedBox(width: 72),

                                        // Early access panel takes remaining ~43%
                                        Expanded(
                                          flex: 43,
                                          child: _buildEarlyAccessPanel(
                                            screenWidth,
                                            isMobile,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // ── FOOTER (full-width, no horizontal padding) ─────────────
                  BottomInfoPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarlyAccessPanel(
      double screenWidth,
      bool isMobile,
      ) {
    return Column(
      children: [
        // ── Shimmer italic green beta text ──────────────────────────────
        AnimatedBuilder(
          animation: _betaTextController,
          builder: (context, child) {
            // Shimmer sweeps a brighter green across the base colour
            final shimmer = _betaShimmerAnimation.value;
            final baseGreen  = const Color(0xFF4ADE80);
            final glowGreen  = const Color(0xFFBBF7D0);
            final textColor  = Color.lerp(
              baseGreen.withOpacity(0.75),
              glowGreen,
              shimmer,
            )!;

            return FadeTransition(
              opacity: _betaFadeAnimation,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-1.0 + shimmer * 2.5, 0),
                  end:   Alignment( 0.4 + shimmer * 2.5, 0),
                  colors: [
                    baseGreen.withOpacity(0.7),
                    glowGreen,
                    baseGreen.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  "Register to receive Beta version updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                    height: 1.5,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF4ADE80).withOpacity(0.45 * shimmer),
                        blurRadius: 14,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        Container(
          width: isMobile ? screenWidth * 0.8 : 320,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _accessCodeController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter access code...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ButtonBulge(
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 18,
                    ),
                    onPressed: _handleAccessCode,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            ButtonBulge(
              child: GitHubButton(
                onPressed: _goToGitHubPage,
                width: 150,
                height: 40,
              ),
            ),
            ButtonBulge(
              child: GoogleButton(
                onPressed: _goToGoogleLoginPage,
                width: 150,
                height: 40,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        GestureDetector(
          onTap: _goToFAQPage,
          child: Text(
            "Frequently Asked Questions",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent(String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16),
      ],
    );
  }
}