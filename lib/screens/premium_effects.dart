import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class MovingDot {
  final double normalizedX;
  final double normalizedY;
  final double radius;
  final double driftRadius;
  final double speed;
  final double phase;
  final double opacity;
  final bool isAccent;

  const MovingDot({
    required this.normalizedX,
    required this.normalizedY,
    required this.radius,
    required this.driftRadius,
    required this.speed,
    required this.phase,
    required this.opacity,
    this.isAccent = false,
  });
}

class MovingDotsPainter extends CustomPainter {
  final double animationValue;
  final List<MovingDot> dots;
  final Color baseColor;
  final Color dotColor;
  final Color accentDotColor;

  MovingDotsPainter({
    required this.animationValue,
    required this.dots,
    this.baseColor = const Color(0xFF070709),
    this.dotColor = Colors.white,
    this.accentDotColor = Colors.greenAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.2,
          colors: [
            const Color(0xFF12121A),
            baseColor,
            const Color(0xFF030304),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.transparent,
            Colors.black.withOpacity(0.45),
          ],
        ).createShader(rect),
    );

    final angle = animationValue * 2 * math.pi;

    for (final dot in dots) {
      final drift = dot.driftRadius * size.shortestSide;
      final x = dot.normalizedX * size.width +
          math.cos(angle * dot.speed + dot.phase) * drift;
      final y = dot.normalizedY * size.height +
          math.sin(angle * dot.speed + dot.phase * 1.37) * drift;

      final pulse = 0.75 + 0.25 * math.sin(angle * 2.4 + dot.phase);
      final radius = dot.radius * (0.85 + size.shortestSide / 900);
      final opacity = (dot.opacity * pulse).clamp(0.04, 0.35);

      final color = dot.isAccent ? accentDotColor : dotColor;

      if (dot.isAccent) {
        final glowPaint = Paint()
          ..color = color.withOpacity(opacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(x, y), radius * 2.8, glowPaint);
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MovingDotsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dots != dots ||
        oldDelegate.baseColor != baseColor;
  }
}

List<MovingDot> generateMovingDots(Size size) {
  final area = size.width * size.height;
  final count = (area / 8500).clamp(48.0, 220.0).toInt();
  final random = math.Random(size.width.round() ^ size.height.round());

  return List.generate(count, (index) {
    final isAccent = index % 11 == 0;
    return MovingDot(
      normalizedX: random.nextDouble(),
      normalizedY: random.nextDouble(),
      radius: lerpDouble(0.8, isAccent ? 2.4 : 1.8, random.nextDouble())!,
      driftRadius: lerpDouble(0.012, 0.045, random.nextDouble())!,
      speed: lerpDouble(0.35, 1.25, random.nextDouble())!,
      phase: random.nextDouble() * math.pi * 2,
      opacity: lerpDouble(0.08, isAccent ? 0.28 : 0.22, random.nextDouble())!,
      isAccent: isAccent,
    );
  });
}

class MovingDotsBackground extends StatefulWidget {
  final Animation<double> animation;
  final Color baseColor;
  final Color dotColor;
  final Color accentDotColor;

  const MovingDotsBackground({
    Key? key,
    required this.animation,
    this.baseColor = const Color(0xFF070709),
    this.dotColor = Colors.white,
    this.accentDotColor = Colors.greenAccent,
  }) : super(key: key);

  @override
  State<MovingDotsBackground> createState() => _MovingDotsBackgroundState();
}

class _MovingDotsBackgroundState extends State<MovingDotsBackground> {
  List<MovingDot> _dots = const [];
  Size _cachedSize = Size.zero;

  void _ensureDots(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;
    _dots = generateMovingDots(size);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureDots(size);

        return AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            return CustomPaint(
              painter: MovingDotsPainter(
                animationValue: widget.animation.value,
                dots: _dots,
                baseColor: widget.baseColor,
                dotColor: widget.dotColor,
                accentDotColor: widget.accentDotColor,
              ),
              child: const SizedBox.expand(),
            );
          },
        );
      },
    );
  }
}

class FluidBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool drawBase;

  FluidBackgroundPainter({
    required this.animationValue,
    this.drawBase = true,
  });

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

    if (drawBase) {
      final basePaint = Paint()..color = const Color(0xFF070709);
      canvas.drawRect(Offset.zero & size, basePaint);
    }

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
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.drawBase != drawBase;
  }
}

class TypingTextAnimation extends StatefulWidget {
  final AnimationController controller;
  final String fullText;
  final String highlightPart;

  const TypingTextAnimation({
    Key? key,
    required this.controller,
    required this.fullText,
    required this.highlightPart,
  }) : super(key: key);

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with SingleTickerProviderStateMixin {
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
        setState(() => _showCursor = !_showCursor);
        _cursorController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _showCursor = !_showCursor);
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
    final part1 = widget.highlightPart;
    final List<TextSpan> spans = [];

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
        TextSpan(
          text: part1,
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

class PremiumBackgroundStack extends StatelessWidget {
  final AnimationController bgController;
  final Widget child;
  final bool showMovingDots;
  final bool showFluidMesh;
  final Color baseColor;
  final Color dotColor;
  final Color accentDotColor;

  const PremiumBackgroundStack({
    Key? key,
    required this.bgController,
    required this.child,
    this.showMovingDots = true,
    this.showFluidMesh = true,
    this.baseColor = const Color(0xFF070709),
    this.dotColor = Colors.white,
    this.accentDotColor = Colors.greenAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showMovingDots)
          MovingDotsBackground(
            animation: bgController,
            baseColor: baseColor,
            dotColor: dotColor,
            accentDotColor: accentDotColor,
          )
        else
          ColoredBox(color: baseColor),
        if (showFluidMesh)
          AnimatedBuilder(
            animation: bgController,
            builder: (context, _) {
              return CustomPaint(
                painter: FluidBackgroundPainter(
                  animationValue: bgController.value,
                  drawBase: !showMovingDots,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.transparent,
                Colors.black.withOpacity(0.55),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class FadeInOnTextAnimation extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const FadeInOnTextAnimation({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: Curves.easeIn.transform(controller.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

class CirculatingAuraPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final Color glowColor;
  final Color accentColor;
  final double strokeWidth;
  final double blurSigma;

  CirculatingAuraPainter({
    required this.progress,
    required this.borderRadius,
    this.glowColor = Colors.white,
    this.accentColor = Colors.greenAccent,
    this.strokeWidth = 2.0,
    this.blurSigma = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final angle = progress * 2 * math.pi;
    final orbitScale = size.shortestSide * 0.5;

    for (var i = 0; i < 3; i++) {
      final orbitAngle = angle + (i * 2 * math.pi / 3);
      final orbX = center.dx + math.cos(orbitAngle) * orbitScale;
      final orbY = center.dy + math.sin(orbitAngle) * orbitScale * 0.65;
      final orbRadius = size.shortestSide * 0.24;

      final orbPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            accentColor.withOpacity(0.42),
            glowColor.withOpacity(0.16),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(orbX, orbY), radius: orbRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

      canvas.drawCircle(Offset(orbX, orbY), orbRadius, orbPaint);
    }

    final borderRect = rect.deflate(4);
    final rrect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular(borderRadius),
    );

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: angle,
        endAngle: angle + math.pi * 2,
        colors: [
          Colors.transparent,
          glowColor.withOpacity(0.18),
          accentColor.withOpacity(0.82),
          glowColor.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
        transform: GradientRotation(angle),
      ).createShader(rect.inflate(24))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(rrect, sweepPaint);

    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.screen;

    canvas.drawRRect(rrect.deflate(2), innerGlow);
  }

  @override
  bool shouldRepaint(covariant CirculatingAuraPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.accentColor != accentColor;
  }
}

class CirculatingAura extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color glowColor;
  final Color accentColor;
  final double strokeWidth;
  final double blurSigma;
  final Duration duration;
  final AnimationController? controller;

  const CirculatingAura({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(6),
    this.glowColor = Colors.white,
    this.accentColor = Colors.greenAccent,
    this.strokeWidth = 2.0,
    this.blurSigma = 12.0,
    this.duration = const Duration(seconds: 3),
    this.controller,
  }) : super(key: key);

  @override
  State<CirculatingAura> createState() => _CirculatingAuraState();
}

class _CirculatingAuraState extends State<CirculatingAura>
    with SingleTickerProviderStateMixin {
  AnimationController? _ownedController;
  Animation<double>? _animation;

  Animation<double> get _effectiveAnimation {
    if (widget.controller != null) {
      return widget.controller!;
    }
    return _animation!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = AnimationController(
        vsync: this,
        duration: widget.duration,
      )..repeat();
      _animation = _ownedController;
    }
  }

  @override
  void didUpdateWidget(covariant CirculatingAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration && _ownedController != null) {
      _ownedController!
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _effectiveAnimation,
      builder: (context, child) {
        return Padding(
          padding: widget.padding,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: CirculatingAuraPainter(
                    progress: _effectiveAnimation.value,
                    borderRadius: widget.borderRadius,
                    glowColor: widget.glowColor,
                    accentColor: widget.accentColor,
                    strokeWidth: widget.strokeWidth,
                    blurSigma: widget.blurSigma,
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class AuraHeadline extends StatelessWidget {
  final AnimationController controller;
  final String fullText;
  final String highlightPart;
  final AnimationController? auraController;
  final double borderRadius;

  const AuraHeadline({
    Key? key,
    required this.controller,
    required this.fullText,
    required this.highlightPart,
    this.auraController,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CirculatingAura(
      controller: auraController,
      borderRadius: borderRadius,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: TypingTextAnimation(
        controller: controller,
        fullText: fullText,
        highlightPart: highlightPart,
      ),
    );
  }
}

class AuraButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final ButtonStyle? style;
  final bool outlined;
  final AnimationController? auraController;

  const AuraButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = 320,
    this.height = 52,
    this.borderRadius = 16,
    this.style,
    this.outlined = false,
    this.auraController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = outlined
        ? OutlinedButton(
      onPressed: onPressed,
      style: style ??
          OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
      child: child,
    )
        : ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
      child: child,
    );

    return CirculatingAura(
      controller: auraController,
      borderRadius: borderRadius,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: width,
        height: height,
        child: button,
      ),
    );
  }
}
