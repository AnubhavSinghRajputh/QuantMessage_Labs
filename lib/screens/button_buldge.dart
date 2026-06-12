import 'package:flutter/material.dart';

class ButtonBulge extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final double pressedScale;
  final Duration duration;

  const ButtonBulge({
    super.key,
    required this.child,
    this.hoverScale = 1.05, // Slightly bigger on hover
    this.pressedScale = 0.95, // Slightly smaller when clicked
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<ButtonBulge> createState() => _ButtonBulgeState();
}

class _ButtonBulgeState extends State<ButtonBulge> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine the current scale based on state
    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = widget.pressedScale;
    } else if (_isHovered) {
      currentScale = widget.hoverScale;
    }

    return MouseRegion(
      // Detects when the cursor enters the button area
      onEnter: (_) => setState(() => _isHovered = true),
      // Detects when the cursor leaves the button area
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        // Detects the exact moment the user touches the screen/clicks
        onTapDown: (_) => setState(() => _isPressed = true),
        // Detects when the user releases the touch/click
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: currentScale,
          duration: widget.duration,
          // Curves.easeOutBack creates a subtle "bounce" effect
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}
