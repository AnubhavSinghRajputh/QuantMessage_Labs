import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'premium_effects.dart';
import 'signup_page/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

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

  void _goToLoginPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        child: SafeArea(
          child: Center(
            child: Padding(
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
                      'SYSTEM ONLINE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TypingTextAnimation(
                    controller: _textController,
                    fullText: '< coming soon > stay tuned',
                    highlightPart: '< coming soon >',
                  ),
                  const SizedBox(height: 16),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'We are crafting something extraordinary. Enter your key to pre-register. build by Anubhav Singh Rajput ',
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
                    child: Container(
                      width: 320,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                letterSpacing: 1.0,
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
                          Container(
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
                              onPressed: _goToLoginPage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _goToLoginPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '< Log in >',
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
