// lib/screens/buttons/windcrest_logo.dart
import 'package:flutter/material.dart';

class WindcrestLogo extends StatelessWidget {
  final double height;

  final Color markColor;

  final Color textColor;

  final bool showWordmark;

  final double? strokeWidth;

  const WindcrestLogo({
    Key? key,
    this.height = 32,
    this.markColor = const Color(0xFFF15A29),
    this.textColor = const Color(0xFF161616),
    this.showWordmark = true,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double markSize = height * 1.05;
    final double gap = height * 0.32;
    final double fontSize = height * 0.62;

    final mark = SizedBox(
      width: markSize,
      height: markSize,
      child: CustomPaint(
        painter: _MountainMarkPainter(
          color: markColor,
          strokeWidth: strokeWidth ?? height * 0.115,
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        SizedBox(width: gap),
        Text(
          'Windcrest',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _MountainMarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _MountainMarkPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final double padX = strokeWidth * 0.55;
    final double topY = h * 0.18 + strokeWidth * 0.4;
    final double bottomY = h * 0.86 - strokeWidth * 0.2;
    final double midY = h * 0.52;

    final path = Path()
      ..moveTo(padX, bottomY)
      ..lineTo(w * 0.27, topY)
      ..lineTo(w * 0.5, midY)
      ..lineTo(w * 0.73, topY)
      ..lineTo(w - padX, bottomY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MountainMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}