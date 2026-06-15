import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable briefcase opening animation widget.
class BriefcaseAnimation extends StatefulWidget {
  final double size;
  final Duration duration;

  const BriefcaseAnimation({
    Key? key,
    this.size = 200,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<BriefcaseAnimation> createState() => _BriefcaseAnimationState();
}

class _BriefcaseAnimationState extends State<BriefcaseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lidAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _lidAnimation = Tween<double>(begin: 0.0, end: -math.pi / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lidAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.7),
          painter: _BriefcasePainter(lidAngle: _lidAnimation.value),
        );
      },
    );
  }
}

class _BriefcasePainter extends CustomPainter {
  final double lidAngle;

  _BriefcasePainter({required this.lidAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double width = size.width;
    final double height = size.height;

    final Rect bodyRect = Rect.fromLTWH(0, height * 0.3, width, height * 0.7);
    canvas.drawRect(bodyRect, outlinePaint);

    final double lidHeight = height * 0.3;
    final Offset pivot = Offset(0, height * 0.3);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(lidAngle);
    canvas.drawRect(Rect.fromLTWH(0, -lidHeight, width, lidHeight), outlinePaint);
    canvas.restore();

    final Rect handleRect = Rect.fromLTWH(
      width * 0.4,
      height * 0.15,
      width * 0.2,
      height * 0.1,
    );
    canvas.drawRect(handleRect, outlinePaint);

    final Paint toolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(width * 0.2, height * 0.5),
      Offset(width * 0.2, height * 0.7),
      toolPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width * 0.2, height * 0.45),
        width: 20,
        height: 10,
      ),
      toolPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width * 0.5, height * 0.55), radius: 15),
      math.pi / 4,
      math.pi / 2,
      false,
      toolPaint,
    );
    canvas.drawLine(
      Offset(width * 0.5, height * 0.55),
      Offset(width * 0.5, height * 0.7),
      toolPaint,
    );

    canvas.drawLine(
      Offset(width * 0.75, height * 0.45),
      Offset(width * 0.75, height * 0.7),
      toolPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width * 0.75, height * 0.42),
        width: 8,
        height: 12,
      ),
      toolPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BriefcasePainter oldDelegate) =>
      oldDelegate.lidAngle != lidAngle;
}
