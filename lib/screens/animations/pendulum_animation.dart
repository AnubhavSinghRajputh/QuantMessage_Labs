//  pendulum_animation.dart 
import 'dart:math';
import 'package:flutter/material.dart';

/// A reusable cyclic pendulum animation widget.
/// Place this file in: library/screens/animations/cyclic_pendulum_animation.dart
class CyclicPendulumAnimation extends StatefulWidget {
  final double size;
  final Color nodeColor;
  final Color lineColor;
  final int nodeCount;
  final Duration duration;

  const CyclicPendulumAnimation({
    Key? key,
    this.size = 200,
    this.nodeColor = Colors.white,
    this.lineColor = Colors.white,
    this.nodeCount = 6,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<CyclicPendulumAnimation> createState() => _CyclicPendulumAnimationState();
}

class _CyclicPendulumAnimationState extends State<CyclicPendulumAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _swing = Tween<double>(begin: -pi / 6, end: pi / 6).animate(
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
      animation: _swing,
      builder: (context, child) {
        return Transform.rotate(
          angle: _swing.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PendulumPainter(
              nodeCount: widget.nodeCount,
              nodeColor: widget.nodeColor,
              lineColor: widget.lineColor,
            ),
          ),
        );
      },
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final int nodeCount;
  final Color nodeColor;
  final Color lineColor;

  _PendulumPainter({
    required this.nodeCount,
    required this.nodeColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2;

    final Paint nodePaint = Paint()..color = nodeColor;

    final double radius = size.width / 2.5;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw nodes in circular arrangement
    List<Offset> nodes = [];
    for (int i = 0; i < nodeCount; i++) {
      double angle = (2 * pi / nodeCount) * i;
      Offset node = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      nodes.add(node);
    }

    // Draw connecting lines
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        canvas.drawLine(nodes[i], nodes[j], linePaint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      canvas.drawCircle(node, 6, nodePaint);
    }

    // Draw center node
    canvas.drawCircle(center, 8, nodePaint);
    for (final node in nodes) {
      canvas.drawLine(center, node, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
