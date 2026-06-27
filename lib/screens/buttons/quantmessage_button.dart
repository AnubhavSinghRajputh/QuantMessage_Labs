// lib/screens/buttons/quantmessage_button.dart
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║  QuantMessageButton — fully self-contained, zero extra imports  ║
// ║  Drop onto ANY screen with one import line.                     ║
// ╚══════════════════════════════════════════════════════════════════╝
//
// ── Quick integration ────────────────────────────────────────────────────────
//
//   import 'path/to/quantmessage_button.dart';
//
//   // Minimal:
//   QuantMessageButton(onTap: () { /* your route */ })
//
//   // Full options:
//   QuantMessageButton(
//     label:       'Open QuantMessage',
//     subLabel:    '5 new signals',
//     accentColor: QuantMessageButton.cyan,   // or .green / .violet
//     showBadge:   true,
//     onTap:       () => Navigator.pushNamed(context, '/quant'),
//   )
//
// ── No extra imports needed — painter, badge and press micro-interaction
//    are all defined below. ──────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Public widget
// ─────────────────────────────────────────────────────────────────────────────

class QuantMessageButton extends StatefulWidget {
  // ── Preset accent colours ──────────────────────────────────────────────────
  static const Color cyan   = Color(0xFF22D3EE);
  static const Color green  = Color(0xFF4ADE80);
  static const Color violet = Color(0xFFA78BFA);

  final String         label;
  final String?        subLabel;
  final VoidCallback?  onTap;
  final Color          accentColor;
  final bool           showBadge;

  const QuantMessageButton({
    Key? key,
    this.label       = 'QuantMessage',
    this.subLabel,
    this.onTap,
    this.accentColor = cyan,
    this.showBadge   = false,
  }) : super(key: key);

  @override
  State<QuantMessageButton> createState() => _QuantMessageButtonState();
}

class _QuantMessageButtonState extends State<QuantMessageButton>
    with TickerProviderStateMixin {

  // ── Loop animation (drives the Lissajous painter) ─────────────────────────
  late final AnimationController _loopCtrl;

  // ── Ambient border shimmer ─────────────────────────────────────────────────
  late final AnimationController _shimmerCtrl;

  // ── Press-scale micro-interaction ─────────────────────────────────────────
  late final AnimationController _pressCtrl;
  late final Animation<double>   _scaleAnim;

  // ── Badge pulse ────────────────────────────────────────────────────────────
  late final AnimationController _badgeCtrl;
  late final Animation<double>   _badgePulse;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _badgePulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _loopCtrl.dispose();
    _shimmerCtrl.dispose();
    _pressCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  // ── gestures ───────────────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _)  => _pressCtrl.forward();

  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _pressCtrl.reverse();

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;

    return GestureDetector(
      onTapDown:   enabled ? _onTapDown   : null,
      onTapUp:     enabled ? _onTapUp     : null,
      onTapCancel: enabled ? _onTapCancel : null,
      child: MouseRegion(
        cursor:  enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit:  (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              // ── Pill ──────────────────────────────────────────────────
              _Pill(
                label:       widget.label,
                subLabel:    widget.subLabel,
                accentColor: widget.accentColor,
                loopCtrl:    _loopCtrl,
                shimmerCtrl: _shimmerCtrl,
                isEnabled:   enabled,
                isHovered:   _isHovered,
              ),

              // ── Badge ─────────────────────────────────────────────────
              if (widget.showBadge && enabled)
                Positioned(
                  top:   -5,
                  right: -5,
                  child: _PulseBadge(
                    color: widget.accentColor,
                    pulse: _badgePulse,
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pill (button shell + layout)
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String              label;
  final String?             subLabel;
  final Color               accentColor;
  final AnimationController loopCtrl;
  final AnimationController shimmerCtrl;
  final bool                isEnabled;
  final bool                isHovered;

  const _Pill({
    required this.label,
    required this.accentColor,
    required this.loopCtrl,
    required this.shimmerCtrl,
    required this.isEnabled,
    required this.isHovered,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerCtrl,
      builder: (context, _) {
        final double glow =
            math.sin(shimmerCtrl.value * math.pi * 2) * 0.5 + 0.5;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(
                isEnabled
                    ? (isHovered ? 0.65 : (0.20 + glow * 0.18))
                    : 0.10,
              ),
              width: 1.0,
            ),
            boxShadow: isEnabled
                ? [
              // Colour glow — breathes with the shimmer
              BoxShadow(
                color:        accentColor.withOpacity(
                    0.08 + glow * 0.10),
                blurRadius:   26,
                spreadRadius: -3,
                offset:       const Offset(0, 5),
              ),
              // Depth shadow
              const BoxShadow(
                color:      Color(0x66000000),
                blurRadius: 16,
                offset:     Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ── Lissajous loop icon ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: SizedBox(
                  width:  60,
                  height: 34,
                  child: AnimatedBuilder(
                    animation: loopCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _LissajousPainter(
                        progress:    loopCtrl.value,
                        accentColor: isEnabled
                            ? accentColor
                            : accentColor.withOpacity(0.25),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Hairline divider ──────────────────────────────────────
              Container(
                width:  0.5,
                height: 28,
                color:  accentColor.withOpacity(0.20),
              ),

              // ── Label + sub-label ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color:         Colors.white.withOpacity(
                            isEnabled ? 1.0 : 0.30),
                        fontSize:      14.5,
                        fontWeight:    FontWeight.w600,
                        letterSpacing: 0.25,
                        height:        1.0,
                      ),
                    ),
                    if (subLabel != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subLabel!,
                        style: TextStyle(
                          color:         accentColor.withOpacity(
                              isEnabled ? 0.68 : 0.22),
                          fontSize:      11,
                          fontWeight:    FontWeight.w400,
                          letterSpacing: 0.1,
                          height:        1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Chevron ───────────────────────────────────────────────
              AnimatedSlide(
                offset:   isHovered ? const Offset(0.25, 0) : Offset.zero,
                duration: const Duration(milliseconds: 140),
                curve:    Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size:  12,
                    color: accentColor.withOpacity(
                        isEnabled ? (isHovered ? 0.80 : 0.45) : 0.15),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Lissajous (figure-8) painter — inspired by InfinityAnimation,
//  fully self-contained, no external import.
// ─────────────────────────────────────────────────────────────────────────────

class _LissajousPainter extends CustomPainter {
  final double progress;
  final Color  accentColor;

  _LissajousPainter({
    required this.progress,
    required this.accentColor,
  });

  // ── Lissajous point for a figure-8 (a=1, b=2) ────────────────────────────
  Offset _pt(double t, double cx, double cy, double A, double B,
      double yShift) {
    return Offset(
      cx + A * math.sin(t),
      cy + B * math.sin(2 * t + yShift),
    );
  }

  // ── Build a closed figure-8 path ──────────────────────────────────────────
  Path _buildPath(double cx, double cy, double A, double B, double yShift,
      {int steps = 160}) {
    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final double t = (i / steps) * math.pi * 2;
      final Offset p = _pt(t, cx, cy, A, B, yShift);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  // ── Slight hue-shift for rainbow-ribbon effect ────────────────────────────
  Color _shiftedColor(Color base, double hueDelta, double lightnessAdd,
      double opacity) {
    final HSLColor hsl = HSLColor.fromColor(base);
    return hsl
        .withHue((hsl.hue + hueDelta) % 360.0)
        .withLightness((hsl.lightness + lightnessAdd).clamp(0.0, 1.0))
        .toColor()
        .withOpacity(opacity.clamp(0.0, 1.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width  / 2;
    final double cy = size.height / 2;
    final double A  = size.width  / 2.15;
    final double B  = size.height / 2.15;

    final double phase     = progress * math.pi * 2;
    final double baseYShift = math.sin(phase) * math.pi / 1.5;

    canvas.save();
    // Slight wobble rotation — same as the original
    canvas.translate(cx, cy);
    canvas.rotate(math.sin(phase) * 0.10);
    canvas.translate(-cx, -cy);

    // ── Layer 1: wide outer glow ───────────────────────────────────────────
    _paintTrail(canvas, cx, cy, A * 1.05, B * 1.05, baseYShift, phase,
      trailCount:  5,
      baseOpacity: 0.07,
      strokeWidth: 11.0,
      blurSigma:   18.0,
      hueSpread:   0.0,
      alphaDecay:  0.55,
    );

    // ── Layer 2: mid glow band ─────────────────────────────────────────────
    _paintTrail(canvas, cx, cy, A, B, baseYShift, phase,
      trailCount:  9,
      baseOpacity: 0.16,
      strokeWidth: 5.5,
      blurSigma:   8.0,
      hueSpread:   0.3,
      alphaDecay:  0.74,
    );

    // ── Layer 3: crisp coloured ribbon ────────────────────────────────────
    _paintTrail(canvas, cx, cy, A, B, baseYShift, phase,
      trailCount:  11,
      baseOpacity: 0.70,
      strokeWidth: 2.8,
      blurSigma:   2.0,
      hueSpread:   0.7,
      alphaDecay:  0.80,
    );

    // ── Layer 4: bright white spine ───────────────────────────────────────
    _paintSpine(canvas, cx, cy, A * 0.97, B * 0.97, baseYShift);

    // ── Layer 5: crossing-point depth shadow ──────────────────────────────
    _paintDepthRing(canvas, cx, cy, A, phase);

    // ── Layer 6: primary comet (5 particles) ──────────────────────────────
    _paintComets(canvas, cx, cy, A, B, baseYShift,
      count:       5,
      speedMult:   1.0,
      headColor:   Colors.white,
      tailColor:   accentColor,
    );

    // ── Layer 7: counter comet (3 particles, opposite phase) ──────────────
    _paintComets(canvas, cx, cy, A * 0.95, B * 0.95,
      baseYShift + math.pi,
      count:       3,
      speedMult:   1.38,
      headColor:   accentColor.withOpacity(0.85),
      tailColor:   accentColor.withOpacity(0.50),
    );

    canvas.restore();
  }

  // ── Trail helper ──────────────────────────────────────────────────────────
  void _paintTrail(
      Canvas canvas,
      double cx, double cy, double A, double B,
      double baseYShift, double phase, {
        required int    trailCount,
        required double baseOpacity,
        required double strokeWidth,
        required double blurSigma,
        required double hueSpread,
        required double alphaDecay,
      }) {
    for (int i = 0; i < trailCount; i++) {
      final double ratio      = i / trailCount;
      final double trailShift = ratio * 0.16 * math.sin(phase);
      final double yShift     = baseYShift + trailShift;
      final double opacity    =
          baseOpacity * math.pow(alphaDecay, i).toDouble();

      final Color c = _shiftedColor(
        accentColor,
        hueSpread * ratio * 55.0,
        ratio * 0.18,
        opacity,
      );

      final Paint paint = Paint()
        ..color      = c
        ..style      = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * (1.0 - ratio * 0.45)
        ..strokeCap  = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, blurSigma * (1.0 - ratio * 0.38));

      canvas.drawPath(_buildPath(cx, cy, A, B, yShift), paint);
    }
  }

  // ── Bright spine ──────────────────────────────────────────────────────────
  void _paintSpine(Canvas canvas, double cx, double cy, double A, double B,
      double yShift) {
    final Path path = _buildPath(cx, cy, A, B, yShift, steps: 200);

    // Outer white halo
    canvas.drawPath(
      path,
      Paint()
        ..color      = Colors.white.withOpacity(0.16)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // Inner crisp line
    canvas.drawPath(
      path,
      Paint()
        ..color      = Colors.white.withOpacity(0.52)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap  = StrokeCap.round,
    );
  }

  // ── Depth ring at crossing point ──────────────────────────────────────────
  void _paintDepthRing(Canvas canvas, double cx, double cy, double A,
      double phase) {
    final double pulse  = math.sin(phase * 2) * 0.5 + 0.5;
    final double radius = A * 0.20;

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withOpacity(0.42 * pulse),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        )
        ..style = PaintingStyle.fill,
    );
  }

  // ── Comet particles ───────────────────────────────────────────────────────
  void _paintComets(
      Canvas canvas,
      double cx, double cy, double A, double B, double yShift, {
        required int   count,
        required double speedMult,
        required Color headColor,
        required Color tailColor,
      }) {
    for (int p = 0; p < count; p++) {
      final double t =
          ((progress * math.pi * 4 * speedMult) - (p * 0.18)) %
              (math.pi * 2);
      final Offset pos = _pt(t, cx, cy, A, B, yShift);

      final bool   isHead = p == 0;
      final double alpha  = (1.0 - p / count).clamp(0.0, 1.0);
      final Color  c      = isHead ? headColor : tailColor;

      // Outer glow
      canvas.drawCircle(
        pos,
        isHead ? 6.5 : math.max(0.1, 3.2 - p * 0.45),
        Paint()
          ..color = c.withOpacity(alpha * 0.32)
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, isHead ? 8.0 : 4.5)
          ..style = PaintingStyle.fill,
      );

      // Core dot
      canvas.drawCircle(
        pos,
        isHead ? 2.8 : math.max(0.1, 1.6 - p * 0.28),
        Paint()
          ..color = c.withOpacity(alpha * 0.90)
          ..style = PaintingStyle.fill,
      );

      // Specular highlight on head only
      if (isHead) {
        canvas.drawCircle(
          pos.translate(-1.1, -1.1),
          0.8,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LissajousPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pulse badge
// ─────────────────────────────────────────────────────────────────────────────

class _PulseBadge extends StatelessWidget {
  final Color             color;
  final Animation<double> pulse;

  const _PulseBadge({required this.color, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width:  11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.50 + pulse.value * 0.50),
          boxShadow: [
            BoxShadow(
              color:        color.withOpacity(pulse.value * 0.55),
              blurRadius:   8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}