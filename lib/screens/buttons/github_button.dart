import 'dart:math' as math;
import 'package:flutter/material.dart';

class GitHubButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double width;
  final double height;

  const GitHubButton({
    Key? key,
    required this.onPressed,
    this.width = 150,
    this.height = 40,
  }) : super(key: key);

  @override
  State<GitHubButton> createState() => _GitHubButtonState();
}

class _GitHubButtonState extends State<GitHubButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Dynamic hover controller for animations (e.g. tail wagging)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
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
        _controller.repeat(reverse: true);
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
                  color: Colors.grey.withOpacity(0.2),
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
                    AnimatedBuilder(
                      animation: _hoverAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomPaint(
                            painter: GitHubLogoPainter(
                              hoverValue: _hoverAnimation.value,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GitHub',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.3,
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

class GitHubLogoPainter extends CustomPainter {
  final double hoverValue;

  GitHubLogoPainter({required this.hoverValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 30;
    final double scaleY = size.height / 30;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Draw outer black circle
    final Paint circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(15, 15), 15, circlePaint);

    final Paint silhouettePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 2. Draw head & body silhouette
    final Path faceAndBody = Path();
    faceAndBody.moveTo(15, 9.5); // Center dip between ears
    faceAndBody.quadraticBezierTo(12, 9, 9, 6.5); // To left ear tip
    faceAndBody.quadraticBezierTo(8, 10, 9.5, 13.5); // Left ear outer to cheek
    faceAndBody.quadraticBezierTo(7, 17.5, 11, 20.5); // Cheek to left neck
    faceAndBody.lineTo(12, 23);
    faceAndBody.lineTo(12, 27);
    faceAndBody.quadraticBezierTo(15, 28, 18, 27); // Body bottom
    faceAndBody.lineTo(18, 23);
    faceAndBody.lineTo(19, 20.5);
    faceAndBody.quadraticBezierTo(23, 17.5, 20.5, 13.5); // Cheek to right ear base
    faceAndBody.quadraticBezierTo(22, 10, 21, 6.5); // Right ear outer to tip
    faceAndBody.quadraticBezierTo(18, 9, 15, 9.5); // Tip to center dip
    faceAndBody.close();

    canvas.drawPath(faceAndBody, silhouettePaint);

    // 3. Draw tail with rotation based on hoverValue
    final double tailBaseX = 12.0;
    final double tailBaseY = 25.5;

    // Calculate dynamic rotation angle for tail wagging (cycles back and forth)
    final double wagAngle = math.sin(hoverValue * 2 * math.pi) * 16 * math.pi / 180;

    canvas.save();
    canvas.translate(tailBaseX, tailBaseY);
    canvas.rotate(wagAngle);
    canvas.translate(-tailBaseX, -tailBaseY);

    final Path tail = Path();
    tail.moveTo(12, 25.5);
    tail.cubicTo(7.5, 26.5, 5, 24, 4.5, 22.5); // Outer tip curve
    tail.quadraticBezierTo(5.5, 23.5, 7.5, 24.5); // Inside curve back
    tail.quadraticBezierTo(9.5, 25, 12, 25.5);
    tail.close();

    canvas.drawPath(tail, silhouettePaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GitHubLogoPainter oldDelegate) {
    return oldDelegate.hoverValue != hoverValue;
  }
}
