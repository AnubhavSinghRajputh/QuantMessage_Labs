import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable animated feature map widget.
/// Displays "QuantMessage" at the center with animated branches and labels.
class FeaturesWebAnimation extends StatefulWidget {
  final double size;
  final Duration duration;
  final bool useDarkTheme;

  const FeaturesWebAnimation({
    Key? key,
    this.size = 400,
    this.duration = const Duration(seconds: 10),
    this.useDarkTheme = false,
  }) : super(key: key);

  @override
  State<FeaturesWebAnimation> createState() => _FeaturesWebAnimationState();
}

class _FeaturesWebAnimationState extends State<FeaturesWebAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> categories = [
    'Design',
    'Content creation',
    'Business strategy',
    'Software development',
  ];

  final Map<String, List<String>> subCategories = {
    'Design': ['Responsive', 'Visuals', 'Components', 'Prototypes', 'Flows'],
    'Content creation': [
      'Translation',
      'Documentation',
      'Education',
      'Marketing',
      'Editing',
    ],
    'Business strategy': [
      'Modeling',
      'Growth',
      'Campaigns',
      'Competition',
      'Markets',
    ],
    'Software development': [
      'Debugging',
      'Reviews',
      'Testing',
      'Documentation',
      'Optimization',
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FeaturesPainter(
            progress: _controller.value,
            categories: categories,
            subCategories: subCategories,
            useDarkTheme: widget.useDarkTheme,
          ),
        );
      },
    );
  }
}

class _FeaturesPainter extends CustomPainter {
  final double progress;
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final bool useDarkTheme;

  _FeaturesPainter({
    required this.progress,
    required this.categories,
    required this.subCategories,
    this.useDarkTheme = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    if (useDarkTheme) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black,
      );
    }

    final Paint outlinePaint = Paint()
      ..color = useDarkTheme
          ? Colors.white.withOpacity(0.35)
          : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'QuantMessage',
      style: TextStyle(
        color: Colors.green,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );

    final double radius = size.width * 0.3;
    for (int i = 0; i < categories.length; i++) {
      final double angle =
          (i / categories.length) * 2 * math.pi + progress * 2 * math.pi;
      final Offset catPos = Offset(
        cx + radius * math.cos(angle),
        cy + radius * math.sin(angle),
      );

      canvas.drawLine(center, catPos, outlinePaint);

      textPainter.text = TextSpan(
        text: categories[i],
        style: TextStyle(
          color: useDarkTheme ? Colors.white : Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        catPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      final subs = subCategories[categories[i]]!;
      const double subRadius = 70;
      for (int j = 0; j < subs.length; j++) {
        final double subAngle =
            (j / subs.length) * 2 * math.pi - progress * 2 * math.pi;
        final Offset subPos = Offset(
          catPos.dx + subRadius * math.cos(subAngle),
          catPos.dy + subRadius * math.sin(subAngle),
        );

        canvas.drawLine(catPos, subPos, outlinePaint);

        textPainter.text = TextSpan(
          text: subs[j],
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          subPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FeaturesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
