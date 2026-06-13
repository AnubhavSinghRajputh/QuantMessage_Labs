import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoogleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double width;
  final double height;

  const GoogleButton({
    Key? key,
    required this.onPressed,
    this.width = 150,
    this.height = 40,
  }) : super(key: key);

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: _isHovered ? Colors.white : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedBuilder(
                      animation: _hoverAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 38,
                          height: 32,
                          child: CustomPaint(
                            painter: GoogleRingsPainter(
                              animationValue: _hoverAnimation.value,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'gle',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleRingsPainter extends CustomPainter {
  final double animationValue;

  GoogleRingsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final center = Offset(centerX, centerY);

    // Subtle scale and rotation on hover
    final double scale = 1.0 + (animationValue * 0.05);
    final double rotationAngle = animationValue * 6 * math.pi / 180; // 6 degrees rotate on hover

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scale);
    canvas.rotate(rotationAngle);

    final localCenter = Offset.zero;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Define center offsets matching the image layout
    // Red bottom-left, Yellow middle-left, Blue middle-right, Green top-right
    final redCenter = localCenter + const Offset(-8, 5);
    final yellowCenter = localCenter + const Offset(-3, -3);
    final blueCenter = localCenter + const Offset(3, 3);
    final greenCenter = localCenter + const Offset(8, -5);

    const double ringRadius = 6.0;

    // Draw overlap rings
    // 1. Red
    ringPaint.color = const Color(0xFFEA4335);
    canvas.drawCircle(redCenter, ringRadius, ringPaint);

    // 2. Yellow
    ringPaint.color = const Color(0xFFFBBC05);
    canvas.drawCircle(yellowCenter, ringRadius, ringPaint);

    // 3. Blue
    ringPaint.color = const Color(0xFF4285F4);
    canvas.drawCircle(blueCenter, ringRadius, ringPaint);

    // 4. Green
    ringPaint.color = const Color(0xFF34A853);
    canvas.drawCircle(greenCenter, ringRadius, ringPaint);

    // Draw crosshair lines
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Horizontal line
    canvas.drawLine(
      localCenter + const Offset(-18, 0),
      localCenter + const Offset(18, 0),
      linePaint,
    );

    // Tilted vertical line (initially tilted ~12 degrees)
    const double tiltAngle = 12 * math.pi / 180;
    final double lineLength = 22.0;

    final dx = math.sin(tiltAngle) * (lineLength / 2);
    final dy = math.cos(tiltAngle) * (lineLength / 2);

    canvas.drawLine(
      localCenter + Offset(-dx, dy),
      localCenter + Offset(dx, -dy),
      linePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GoogleRingsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
