// lib/animations/pendulum_animation.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class PendulumAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const PendulumAnimation({
    Key? key,
    this.size  = 80,
    this.color = const Color(0xFF1A1A1A),
  }) : super(key: key);

  @override
  State<PendulumAnimation> createState() => _PendulumAnimationState();
}

class _PendulumAnimationState extends State<PendulumAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      // Faster speed: 1500ms instead of 2000ms
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Linear curve for smooth continuous rotation
    _rotation = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _PendulumPainter(
          rotationFraction: _rotation.value,
          color: widget.color,
        ),
      ),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _PendulumPainter extends CustomPainter {
  final double rotationFraction; // 0.0 → 1.0 maps to 0 → 360°
  final Color color;

  const _PendulumPainter({
    required this.rotationFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 2.5;

    final basePaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap   = StrokeCap.round;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, basePaint);

    // Vertical stem
    canvas.drawLine(
      Offset(cx, cy - r * 0.88),
      Offset(cx, cy + r * 0.88),
      basePaint,
    );

    // Horizontal crosshair
    canvas.drawLine(
      Offset(cx - r * 0.30, cy),
      Offset(cx + r * 0.30, cy),
      basePaint,
    );

    // Centre dot
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.10,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // ── Pendulum arm rotating 360° ──────────────────────────────────────────
    final angle = rotationFraction * 2 * math.pi; // full circle
    final armLen = r * 0.72;
    final armEnd = Offset(
      cx + armLen * math.cos(angle),
      cy + armLen * math.sin(angle),
    );

    // Glowing arm
    canvas.drawLine(
      Offset(cx, cy),
      armEnd,
      Paint()
        ..color       = color.withOpacity(0.18)
        ..strokeWidth = 5.0
        ..strokeCap   = StrokeCap.round
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Arm itself
    canvas.drawLine(
      Offset(cx, cy),
      armEnd,
      basePaint..strokeWidth = 1.8,
    );

    // Bob at the end
    canvas.drawCircle(
      armEnd,
      r * 0.09,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    // Bob ring
    canvas.drawCircle(
      armEnd,
      r * 0.09,
      Paint()
        ..color       = color.withOpacity(0.30)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter old) =>
      old.rotationFraction != rotationFraction || old.color != color;
}
