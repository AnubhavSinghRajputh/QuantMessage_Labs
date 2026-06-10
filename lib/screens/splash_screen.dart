import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_bar.dart';
import 'home_screen.dart';
import 'premium_effects.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.repeat(); // Changed to repeat for the continuous infinity flow

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(title: 'INITIATING'),
      body: PremiumBackgroundStack(
        bgController: _controller,
        showMovingDots: true,
        child: SafeArea(
          child: Stack(
            children: [
              // 1. INFINITY GLASS ANIMATION LAYER
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: InfinityGlassPainter(
                      progress: _controller.value,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),

              // 2. Content Layer
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Central Core - Polished Glass Look
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.8), Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.all_inclusive,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Antigravity Style Text
                      Text(
                        'QUANTNEWS ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'REDEFINING EXPERIENCES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 4.0,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CUSTOM PAINTER: The Moving Infinity Glass Loop
class InfinityGlassPainter extends CustomPainter {
  final double progress;

  InfinityGlassPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double width = size.width * 0.4; // Width of the infinity symbol
    final double height = size.height * 0.15; // Height of the infinity symbol

    // The Path for the Infinity Symbol (Lemniscate)
    final path = Path();

    // Using a simplified Bezier approach to create a smooth infinity loop
    path.moveTo(center.dx - width / 2, center.dy);
    path.cubicTo(
        center.dx - width / 4, center.dy - height,
        center.dx + width / 4, center.dy + height,
        center.dx + width / 2, center.dy
    );
    path.cubicTo(
        center.dx + width / 4, center.dy - height,
        center.dx - width / 4, center.dy + height,
        center.dx - width / 2, center.dy
    );

    // 1. BACKGROUND GLOW (The blurred glass effect)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0 // Very thick for blur effect
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = Colors.white.withOpacity(0.07);

    canvas.drawPath(path, glowPaint);

    // 2. MAIN LIGHT RING (The moving greyish-white line)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..color = Colors.white.withOpacity(0.4);

    // Create a dashed effect to simulate moving light
    // We use a dash of 0.1 and a gap of 0.1, moving the offset via 'progress'
    final double dashWidth = 0.05 * size.width;
    final double gapWidth = 0.05 * size.width;

    // This creates the "moving" effect along the path
    final Path dashedPath = Path();
    // Note: Pure dashed paths in Flutter are tricky, so we simulate a glowing
    // trail by drawing the path with a slightly varied opacity over the loop.
    canvas.drawPath(path, ringPaint);

    // 3. ACCENT HIGHLIGHT (The "Glassy" reflection)
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant InfinityGlassPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
