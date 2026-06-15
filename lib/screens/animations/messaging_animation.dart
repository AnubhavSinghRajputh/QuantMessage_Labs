// messaging_animation.dart
// Updated: Black & white theme matching premium_effects.dart
// Wide rectangular panel for home_screen.dart integration
//
// Usage in home_screen.dart:
//
//   Row(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Expanded(child: /* your Early Access column */),
//       SizedBox(width: 48),
//       SizedBox(
//         width: 630,
//         height: 480,
//         child: MessagingAnimation(),
//       ),
//     ],
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';

class MessagingAnimation extends StatefulWidget {
  const MessagingAnimation({Key? key}) : super(key: key);

  @override
  State<MessagingAnimation> createState() => _MessagingAnimationState();
}

class _MessagingAnimationState extends State<MessagingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _masterController;

  final List<_BubbleData> _bubbles = [];
  final math.Random _rng = math.Random();

  static const int _poolSize = 12;

  static const String _labelLeft  = 'QM Node A';
  static const String _labelRight = 'QM Node B';

  // ── B&W palette (mirrors premium_effects.dart dark base) ──────────────────
  static const Color _panelBg      = Color(0xFF070709);   // same as baseColor
  static const Color _borderColor  = Color(0x1AFFFFFF);   // white @ 10%
  static const Color _nodeBg       = Color(0xFF12121A);   // same as radial mid
  static const Color _nodeBorder   = Color(0x33FFFFFF);   // white @ 20%
  static const Color _pulseColor   = Color(0x26FFFFFF);   // white @ 15%
  static const Color _dotWhite     = Colors.white;
  static const Color _accentWhite  = Color(0xFFF5F5F5);   // faint white accent

  // Bubble colours: white, grey, faint-white — matching InteractiveFluidPainter cycle
  static const List<Color> _bubbleColors = [
    Color(0xFFFFFFFF), // white
    Color(0xFFBDBDBD), // greyish white
    Color(0xFFF5F5F5), // faint white
  ];

  static const List<String> _snippets = [
    'INIT_HANDSHAKE',
    '0xA3F9…4C2B',
    'PING 0ms',
    'DATA_STREAM',
    'AUTH_TOKEN',
    'ACK #4821',
    'SYNC_BLOCK',
    'ENCRYPT_OK',
    '0xFF01…88DA',
    'ROUTE_OK',
    'QKD_PULSE',
    'LATENCY 0.3ms',
    'PKT #9912',
    'SIGNED_MSG',
    'TX_COMMIT',
    'VERIFY OK',
  ];

  int _snippetIndex = 0;

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(_tick)
      ..repeat();

    for (int i = 0; i < _poolSize; i++) {
      _bubbles.add(_makeBubble(initialProgress: i / _poolSize));
    }
  }

  _BubbleData _makeBubble({double initialProgress = 0.0}) {
    final leftToRight = _rng.nextBool();
    final speed       = 0.004 + _rng.nextDouble() * 0.006;
    final yFraction   = 0.2   + _rng.nextDouble() * 0.6;
    final snippet     = _snippets[_snippetIndex % _snippets.length];
    _snippetIndex++;
    final colorVariant = _rng.nextInt(_bubbleColors.length);

    return _BubbleData(
      progress:      initialProgress,
      speed:         speed,
      leftToRight:   leftToRight,
      yFraction:     yFraction,
      snippet:       snippet,
      colorVariant:  colorVariant,
    );
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _bubbles.length; i++) {
        _bubbles[i].progress += _bubbles[i].speed;
        if (_bubbles[i].progress > 1.0) {
          _bubbles[i] = _makeBubble();
        }
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Fill the entire slot — width and height are independent
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Container(
        width:  w,
        height: h,
        decoration: BoxDecoration(
          // Radial gradient background identical to MovingDotsPainter
          gradient: const RadialGradient(
            center: Alignment(0.0, -0.35),
            radius: 1.2,
            colors: [
              Color(0xFF12121A),
              Color(0xFF070709),
              Color(0xFF030304),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle grid — same low opacity as premium_effects dots
            CustomPaint(
              size: Size(w, h),
              painter: _GridPainter(),
            ),

            // Animated message bubbles
            CustomPaint(
              size: Size(w, h),
              painter: _BubblePainter(
                bubbles:      _bubbles,
                width:        w,
                height:       h,
                bubbleColors: _bubbleColors,
              ),
            ),

            // Left node
            Positioned(
              left: 14,
              top:  h / 2 - 52,
              child: _SystemNode(
                label:            _labelLeft,
                icon:             Icons.developer_board_rounded,
                nodeBg:           _nodeBg,
                nodeBorder:       _nodeBorder,
                pulseColor:       _pulseColor,
                dotColor:         _dotWhite,
                masterController: _masterController,
              ),
            ),

            // Right node
            Positioned(
              right: 14,
              top:   h / 2 - 52,
              child: _SystemNode(
                label:            _labelRight,
                icon:             Icons.hub_rounded,
                nodeBg:           _nodeBg,
                nodeBorder:       _nodeBorder,
                pulseColor:       _pulseColor,
                dotColor:         _dotWhite,
                masterController: _masterController,
                flipPulse:        true,
              ),
            ),

            // Top badge — styled like CirculatingAura label
            Positioned(
              top:   16,
              left:  0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    'LIVE CHANNEL',
                    style: TextStyle(
                      color:       Colors.white.withOpacity(0.55),
                      fontSize:    9,
                      fontWeight:  FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom stats bar
            Positioned(
              bottom: 0,
              left:   0,
              right:  0,
              child: _StatsBar(masterController: _masterController),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble data model
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleData {
  double progress;
  final double speed;
  final bool leftToRight;
  final double yFraction;
  final String snippet;
  final int colorVariant;

  _BubbleData({
    required this.progress,
    required this.speed,
    required this.leftToRight,
    required this.yFraction,
    required this.snippet,
    required this.colorVariant,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble painter — B&W variant
// ─────────────────────────────────────────────────────────────────────────────

class _BubblePainter extends CustomPainter {
  final List<_BubbleData> bubbles;
  final double width;
  final double height;
  final List<Color> bubbleColors;

  static const double _nodeWidth = 80.0;
  static const double _trackPad  = _nodeWidth + 18;

  const _BubblePainter({
    required this.bubbles,
    required this.width,
    required this.height,
    required this.bubbleColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackStart = _trackPad;
    final trackEnd   = width - _trackPad;
    final trackWidth = trackEnd - trackStart;

    for (final b in bubbles) {
      final color = bubbleColors[b.colorVariant % bubbleColors.length];
      final t = b.leftToRight ? b.progress : (1.0 - b.progress);
      final x = trackStart + t * trackWidth;
      final y = height * b.yFraction;

      final edgeFade = (b.progress < 0.08)
          ? b.progress / 0.08
          : (b.progress > 0.92)
          ? (1.0 - b.progress) / 0.08
          : 1.0;

      // Trail
      const trailLength = 32.0;
      final trailDx = b.leftToRight ? -trailLength : trailLength;
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0),
            color.withOpacity(0.25 * edgeFade),
          ],
          begin: b.leftToRight ? Alignment.centerLeft  : Alignment.centerRight,
          end:   b.leftToRight ? Alignment.centerRight : Alignment.centerLeft,
        ).createShader(Rect.fromLTWH(x + trailDx, y - 1, trailLength, 2))
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x + trailDx, y), Offset(x, y), trailPaint);

      // Pill text
      final textPainter = TextPainter(
        text: TextSpan(
          text: b.snippet,
          style: TextStyle(
            color:       color.withOpacity(0.9 * edgeFade),
            fontSize:    9,
            fontWeight:  FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pillW = textPainter.width + 16;
      const pillH = 20.0;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: pillW, height: pillH),
        const Radius.circular(6),
      );

      // Soft glow (very subtle — matches MovingDotsPainter accent glow)
      canvas.drawRRect(
        pillRect.inflate(3),
        Paint()
          ..color = color.withOpacity(0.08 * edgeFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Pill background: very dark with slight white tint
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF0A0A10),
            color,
            0.07,
          )!.withOpacity(edgeFade)
          ..style = PaintingStyle.fill,
      );

      // Pill border — white at low opacity
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color = color.withOpacity(0.28 * edgeFade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid painter — same subtle grid as premium_effects background feel
// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// System node — B&W, matches CirculatingAura glow style
// ─────────────────────────────────────────────────────────────────────────────

class _SystemNode extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color nodeBg;
  final Color nodeBorder;
  final Color pulseColor;
  final Color dotColor;
  final AnimationController masterController;
  final bool flipPulse;

  const _SystemNode({
    required this.label,
    required this.icon,
    required this.nodeBg,
    required this.nodeBorder,
    required this.pulseColor,
    required this.dotColor,
    required this.masterController,
    this.flipPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: masterController,
      builder: (context, _) {
        final pulseT      = (masterController.value + (flipPulse ? 0.5 : 0.0)) % 1.0;
        final glowOpacity = math.sin(pulseT * math.pi * 2) * 0.5 + 0.5;

        return SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circulating-aura-style glow box
              Container(
                width:  54,
                height: 54,
                decoration: BoxDecoration(
                  color:        nodeBg,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: nodeBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color:       Colors.white.withOpacity(0.12 * glowOpacity),
                      blurRadius:  18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.75),
                    size:  22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:         Colors.white.withOpacity(0.45),
                  fontSize:      9,
                  fontWeight:    FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              // Activity dots — white, matching MovingDotsPainter accent dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final dotT = (masterController.value * 3 -
                      i * 0.33 +
                      (flipPulse ? 1.5 : 0)) %
                      1.0;
                  final dotOpacity =
                      math.sin(dotT * math.pi * 2) * 0.5 + 0.5;
                  return Container(
                    margin:     const EdgeInsets.symmetric(horizontal: 1.5),
                    width:  4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2 + 0.6 * dotOpacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom stats bar — B&W
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBar extends StatefulWidget {
  final AnimationController masterController;
  const _StatsBar({required this.masterController});

  @override
  State<_StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<_StatsBar> {
  int    _packetCount = 0;
  double _latency     = 0.3;
  int    _ticker      = 0;

  @override
  void initState() {
    super.initState();
    widget.masterController.addListener(_update);
  }

  void _update() {
    if (!mounted) return;
    _ticker++;
    if (_ticker % 4 == 0) {
      setState(() {
        _packetCount += 1 + math.Random().nextInt(3);
        _latency      = 0.1 + math.Random().nextDouble() * 0.6;
      });
    }
  }

  @override
  void dispose() {
    widget.masterController.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(label: 'PKTS', value: '$_packetCount'),
          _Stat(label: 'LAT',  value: '${_latency.toStringAsFixed(1)}ms'),
          _Stat(label: 'ENC',  value: 'AES-256'),
          Row(
            children: [
              Container(
                width:  6,
                height: 6,
                decoration: BoxDecoration(
                  // White dot for online — matches dotColor in MovingDotsPainter
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'ONLINE',
                style: TextStyle(
                  color:         Colors.white.withOpacity(0.55),
                  fontSize:      9,
                  fontWeight:    FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label ',
          style: TextStyle(
            color:         Colors.white.withOpacity(0.28),
            fontSize:      9,
            fontWeight:    FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:         Colors.white.withOpacity(0.72),
            fontSize:      9,
            fontWeight:    FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}