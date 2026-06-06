import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
void main() {
  runApp(const ComingSoonApp());
}
class ComingSoonApp extends StatelessWidget {
  const ComingSoonApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coming Soon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        primaryColor: Colors.white,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  const PremiumAppBar({
    Key? key,
    this.title = 'NEWSOS',
    this.actions,
    this.leading,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: preferredSize.height,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  leading ?? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        title,
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
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions ?? [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.03),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

// 2. SPLASH SCREEN WIDGET

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 0.05);
            var end = Offset.zero;
            var curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF16161A),
                  Color(0xFF0A0A0C),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.02),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.04),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
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
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.grey.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.all_inclusive,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'NEWSOS LABS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
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
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.5),
                      ),
                      minHeight: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. HOME SCREEN WIDGET

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(title: 'NEWSOS'),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: FluidBackgroundPainter(animationValue: _bgController.value),
                child: Container(),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
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
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    TypingTextAnimation(
                      controller: _textController,
                      fullText: "coming soon stay tuned",
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: Curves.easeIn.transform(_textController.value),
                          child: child,
                        );
                      },
                      child: Text(
                        'We are crafting something extraordinary. Enter your key to pre-register.',
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
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: Curves.easeIn.transform(_textController.value),
                          child: child,
                        );
                      },
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
                                icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                                onPressed: () {},
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
          ),
        ],
      ),
    );
  }
}
// ==========================================
// 4. ANIMATED FLUID MESH GRADIENT PAINTER
// ==========================================
class FluidBackgroundPainter extends CustomPainter {
  final double animationValue;
  FluidBackgroundPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlob1 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    final paintBlob2 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140);
    final paintBlob3 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final basePaint = Paint()..color = const Color(0xFF070709);
    canvas.drawRect(Offset.zero & size, basePaint);
    final angle = animationValue * 2 * math.pi;
    final b1x = cx + math.cos(angle) * (size.width * 0.25) + 60;
    final b1y = cy + math.sin(angle) * (size.height * 0.15) - 100;
    final radius1 = size.width * 0.45;
    paintBlob1.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.06),
        Colors.white.withOpacity(0.005),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(b1x, b1y), radius: radius1));
    canvas.drawCircle(Offset(b1x, b1y), radius1, paintBlob1);
    final b2x = cx - math.sin(angle + math.pi / 3) * (size.width * 0.3) - 40;
    final b2y = cy - math.cos(angle + math.pi / 3) * (size.height * 0.2) + 120;
    final radius2 = size.width * 0.5;
    paintBlob2.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.04),
        Colors.white.withOpacity(0.002),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(b2x, b2y), radius: radius2));
    canvas.drawCircle(Offset(b2x, b2y), radius2, paintBlob2);
    final breathScale = 1.0 + 0.1 * math.sin(angle * 2);
    final radius3 = size.width * 0.35 * breathScale;
    paintBlob3.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.03),
        Colors.white.withOpacity(0.001),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius3));
    canvas.drawCircle(Offset(cx, cy), radius3, paintBlob3);
  }
  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
// ==========================================
// 5. TYPING TEXT ANIMATION
// ==========================================
class TypingTextAnimation extends StatefulWidget {
  final AnimationController controller;
  final String fullText;
  const TypingTextAnimation({
    Key? key,
    required this.controller,
    required this.fullText,
  }) : super(key: key);
  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}
class _TypingTextAnimationState extends State<TypingTextAnimation> with SingleTickerProviderStateMixin {
  late Animation<int> _characterCount;
  late AnimationController _cursorController;
  bool _showCursor = true;
  @override
  void initState() {
    super.initState();
    _characterCount = StepTween(
      begin: 0,
      end: widget.fullText.length,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.9, curve: Curves.linear),
      ),
    );
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showCursor = !_showCursor;
        });
        _cursorController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showCursor = !_showCursor;
        });
        _cursorController.forward();
      }
    });
    _cursorController.forward();
  }
  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final count = _characterCount.value;
        final visibleText = widget.fullText.substring(0, count);
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 38,
              height: 1.3,
              letterSpacing: -0.5,
            ),
            children: [
              ..._buildStyledSpans(visibleText),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Opacity(
                  opacity: _showCursor ? 1.0 : 0.0,
                  child: Container(
                    width: 2.5,
                    height: 36,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  List<TextSpan> _buildStyledSpans(String typedText) {
    const part1 = "coming soon";

    List<TextSpan> spans = [];
    if (typedText.length <= part1.length) {
      spans.add(
        TextSpan(
          text: typedText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.white30,
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      );
    } else {
      spans.add(
        const TextSpan(
          text: part1,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.white30,
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      );

      final part2Typed = typedText.substring(part1.length);
      spans.add(
        TextSpan(
          text: part2Typed,
          style: const TextStyle(
            color: Color(0xFF7E7E86),
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }
    return spans;
  }
}
