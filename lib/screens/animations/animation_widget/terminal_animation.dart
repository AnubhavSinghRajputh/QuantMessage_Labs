

import 'dart:async';
import 'package:flutter/material.dart';

/// A single line/block rendered inside the terminal body.
///
/// The terminal plays through a list of [TerminalLine]s in order, typing
/// each one out character-by-character (when [animateTyping] is true) before
/// moving on to the next, with [delayBefore] as a pause beforehand.
class TerminalLine {
  const TerminalLine({
    required this.type,
    this.text = '',
    this.delayBefore = const Duration(milliseconds: 300),
    this.animateTyping = true,
    this.typingSpeed = const Duration(milliseconds: 14),
    this.holdAfter = const Duration(milliseconds: 400),
  });

  final TerminalLineType type;
  final String text;

  /// Pause before this line starts appearing.
  final Duration delayBefore;

  /// Whether to type this line out character-by-character, or show it
  /// instantly once its turn comes up.
  final bool animateTyping;

  /// Delay between each character when [animateTyping] is true.
  final Duration typingSpeed;

  /// Extra pause once the line has fully appeared, before moving to the
  /// next line.
  final Duration holdAfter;
}

enum TerminalLineType {
  /// The highlighted "> ..." user-typed prompt block.
  userPrompt,

  /// A plain bullet line, e.g. "I'll explore the codebase...".
  bullet,

  /// A tool-call line with a small status dot, e.g. "Explore(...)".
  toolCall,

  /// The indented "Done (...)" status line under a tool call.
  toolResult,

  /// The pulsing "Claud-ing... (esc to interrupt)" busy indicator.
  busyIndicator,

  /// A bold section heading in the response, e.g. "TaskFlow API - ...".
  heading,

  /// A plain paragraph of response text.
  paragraph,

  /// A monospace file-tree row, e.g. "├─ src/".
  fileTreeRow,

  /// Empty vertical spacing.
  spacer,
}

/// A reusable, self-playing terminal/chat animation styled after a coding
/// assistant CLI, wrapped in a soft rounded card background.
class TerminalAnimation extends StatefulWidget {
  const TerminalAnimation({
    super.key,
    this.width = 560,
    this.height = 420,
    this.brandName = 'QuantMessage',
    this.brandVersion = 'v2.1.76',
    this.brandSubtitle = 'Opus 4.6 (1M Context) · Quant Enterprise',
    this.workingDirectory = '/Users/johnnie/taskflow',
    this.cardColor = const Color(0xFFC9D9D2),
    this.windowColor = const Color(0xFF0E0E10),
    this.accentColor = const Color(0xFFFF7A52),
    this.titleBarColor = const Color(0xFF1B1B1D),
    this.dotColors = const [
      Color(0xFF4A4A4D),
      Color(0xFF4A4A4D),
      Color(0xFF4A4A4D),
    ],
    this.script,
    this.loop = true,
    this.loopPause = const Duration(seconds: 2),
    this.borderRadius = 28,
    this.windowBorderRadius = 14,
    this.autoStart = true,
  });

  /// Overall footprint of the widget (the sage card). The terminal window
  /// is inset within it.
  final double width;
  final double height;

  /// Branding shown at the top of the terminal (replaces "Claude").
  final String brandName;
  final String brandVersion;
  final String brandSubtitle;
  final String workingDirectory;

  /// Outer rounded card color (the sage-green background in the reference).
  final Color cardColor;

  /// Terminal window background.
  final Color windowColor;

  /// Accent used for the brand glyph, busy indicator, and highlights.
  final Color accentColor;

  /// Title bar strip color at the top of the terminal window.
  final Color titleBarColor;

  /// Colors of the three macOS-style traffic-light dots, left to right.
  final List<Color> dotColors;

  /// The scripted conversation to play. If null, a sensible default script
  /// is used (mirrors the reference design).
  final List<TerminalLine>? script;

  /// Whether to restart the whole sequence after it finishes.
  final bool loop;

  /// Pause at the end of a full playthrough before looping.
  final Duration loopPause;

  final double borderRadius;
  final double windowBorderRadius;

  /// Whether the animation should begin playing as soon as it mounts.
  final bool autoStart;

  @override
  State<TerminalAnimation> createState() => _TerminalAnimationState();
}

class _TerminalAnimationState extends State<TerminalAnimation>
    with TickerProviderStateMixin {
  late List<TerminalLine> _script;
  final List<String> _revealedText = [];
  final List<bool> _lineVisible = [];

  int _currentLineIndex = -1;
  Timer? _typingTimer;
  Timer? _delayTimer;
  bool _disposed = false;

  late AnimationController _busyController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _script = widget.script ?? _defaultScript(widget.brandName);
    _lineVisible.addAll(List.filled(_script.length, false));
    _revealedText.addAll(List.filled(_script.length, ''));

    _busyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playFrom(0));
    }
  }

  @override
  void didUpdateWidget(covariant TerminalAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.script != widget.script ||
        oldWidget.brandName != widget.brandName) {
      _resetAndReplay();
    }
  }

  void _resetAndReplay() {
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    setState(() {
      _script = widget.script ?? _defaultScript(widget.brandName);
      _lineVisible
        ..clear()
        ..addAll(List.filled(_script.length, false));
      _revealedText
        ..clear()
        ..addAll(List.filled(_script.length, ''));
      _currentLineIndex = -1;
    });
    _playFrom(0);
  }

  void _playFrom(int index) {
    if (_disposed || index >= _script.length) {
      if (widget.loop && !_disposed) {
        _delayTimer = Timer(widget.loopPause, _resetAndReplay);
      }
      return;
    }

    _currentLineIndex = index;
    final line = _script[index];

    _delayTimer = Timer(line.delayBefore, () {
      if (_disposed) return;
      setState(() => _lineVisible[index] = true);

      if (!line.animateTyping || line.text.isEmpty) {
        setState(() => _revealedText[index] = line.text);
        _scrollToBottomSoon();
        _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
        return;
      }

      int charIndex = 0;
      _typingTimer = Timer.periodic(line.typingSpeed, (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        charIndex++;
        setState(() {
          _revealedText[index] = line.text.substring(
            0,
            charIndex.clamp(0, line.text.length),
          );
        });
        _scrollToBottomSoon();
        if (charIndex >= line.text.length) {
          timer.cancel();
          _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
        }
      });
    });
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    _busyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static List<TerminalLine> _defaultScript(String brand) {
    return [
      TerminalLine(
        type: TerminalLineType.userPrompt,
        text:
        "I just joined the team. Can you give me a high-level overview of how this codebase is structured and where the main entry points are?",
        delayBefore: const Duration(milliseconds: 500),
        typingSpeed: const Duration(milliseconds: 10),
      ),
      const TerminalLine(
        type: TerminalLineType.bullet,
        text: "I'll explore the codebase to give you a comprehensive overview.",
        delayBefore: Duration(milliseconds: 400),
      ),
      const TerminalLine(
        type: TerminalLineType.toolCall,
        text: 'Explore(Explore codebase structure)',
        delayBefore: Duration(milliseconds: 500),
        animateTyping: false,
      ),
      const TerminalLine(
        type: TerminalLineType.toolResult,
        text: 'Done (17 tool uses · 38.0k tokens · 28s)',
        delayBefore: Duration(milliseconds: 900),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 600),
      ),
      TerminalLine(
        type: TerminalLineType.busyIndicator,
        text: '${_lowerCamel(brand)}ing… (esc to interrupt)',
        delayBefore: const Duration(milliseconds: 300),
        animateTyping: false,
        holdAfter: const Duration(milliseconds: 1200),
      ),
      const TerminalLine(
        type: TerminalLineType.heading,
        text: 'TaskFlow API - Codebase Overview',
        delayBefore: Duration(milliseconds: 300),
        animateTyping: false,
      ),
      const TerminalLine(
        type: TerminalLineType.paragraph,
        text:
        "Welcome to the team! This is a Node.js/Express REST API for task management with team collaboration features. Here's the project structure:",
        delayBefore: Duration(milliseconds: 300),
        typingSpeed: Duration(milliseconds: 8),
      ),
      const TerminalLine(
        type: TerminalLineType.spacer,
        delayBefore: Duration(milliseconds: 100),
        holdAfter: Duration.zero,
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: 'taskflow/',
        delayBefore: Duration(milliseconds: 150),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 150),
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: '├─ src/',
        delayBefore: Duration(milliseconds: 100),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 150),
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: '│  ├─ index.js        # Main entry point - starts the server',
        delayBefore: Duration(milliseconds: 100),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 150),
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: '│  ├─ routes/         # API route handlers',
        delayBefore: Duration(milliseconds: 100),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 150),
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: '│  ├─ models/         # Database models',
        delayBefore: Duration(milliseconds: 100),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 150),
      ),
      const TerminalLine(
        type: TerminalLineType.fileTreeRow,
        text: '│  └─ middleware/     # Auth & validation',
        delayBefore: Duration(milliseconds: 100),
        animateTyping: false,
        holdAfter: Duration(milliseconds: 2000),
      ),
    ];
  }

  static String _lowerCamel(String brand) {
    if (brand.isEmpty) return 'Process';
    return brand[0].toUpperCase() + brand.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background sage card with faint topographic line texture.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                color: widget.cardColor,
                child: CustomPaint(
                  painter: _TopoLinesPainter(
                    color: Colors.black.withOpacity(0.06),
                  ),
                ),
              ),
            ),
          ),
          // Terminal window, inset and centered.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.width * 0.07,
                vertical: widget.height * 0.07,
              ),
              child: _buildTerminalWindow(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalWindow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.windowColor,
        borderRadius: BorderRadius.circular(widget.windowBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 30,
      color: widget.titleBarColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: widget.dotColors
            .map(
              (c) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildBrandHeader(),
        const SizedBox(height: 14),
        for (int i = 0; i < _script.length; i++)
          if (_lineVisible[i]) _buildLine(i, _script[i]),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandGlyph(color: widget.accentColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.brandName} ',
                      style: _mono(
                        color: Colors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: widget.brandVersion,
                      style: _mono(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(widget.brandSubtitle, style: _mono(color: Colors.white60)),
              const SizedBox(height: 2),
              Text(widget.workingDirectory, style: _mono(color: Colors.white38)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index, TerminalLine line) {
    final text = _revealedText[index];

    switch (line.type) {
      case TerminalLineType.userPrompt:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '> ', style: _mono(color: Colors.white54)),
                  TextSpan(text: text, style: _mono(color: Colors.white)),
                ],
              ),
            ),
          ),
        );

      case TerminalLineType.bullet:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '•  ', style: _mono(color: Colors.white70)),
                TextSpan(text: text, style: _mono(color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        );

      case TerminalLineType.toolCall:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 8),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(text, style: _mono(color: Colors.white.withOpacity(0.85))),
              ),
            ],
          ),
        );

      case TerminalLineType.toolResult:
        return Padding(
          padding: const EdgeInsets.only(left: 14, top: 2, bottom: 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'L  ', style: _mono(color: Colors.white38)),
                TextSpan(text: text, style: _mono(color: Colors.white38)),
              ],
            ),
          ),
        );

      case TerminalLineType.busyIndicator:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AnimatedBuilder(
            animation: _busyController,
            builder: (context, _) {
              final opacity = 0.45 + (_busyController.value * 0.55);
              return Row(
                children: [
                  Icon(Icons.circle, size: 8, color: widget.accentColor.withOpacity(opacity)),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: _mono(
                      color: widget.accentColor.withOpacity(opacity),
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        );

      case TerminalLineType.heading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '•  ', style: _mono(color: Colors.white70)),
                TextSpan(
                  text: text,
                  style: _mono(color: Colors.white, weight: FontWeight.w700, size: 14.5),
                ),
              ],
            ),
          ),
        );

      case TerminalLineType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 18),
          child: Text(
            text,
            style: _mono(color: Colors.white.withOpacity(0.82)),
          ),
        );

      case TerminalLineType.fileTreeRow:
        return Padding(
          padding: const EdgeInsets.only(left: 18, top: 1, bottom: 1),
          child: Text(text, style: _mono(color: Colors.white.withOpacity(0.78))),
        );

      case TerminalLineType.spacer:
        return const SizedBox(height: 8);
    }
  }

  TextStyle _mono({
    required Color color,
    FontWeight weight = FontWeight.w400,
    double size = 13.5,
  }) {
    return TextStyle(
      color: color,
      fontWeight: weight,
      fontSize: size,
      fontFamily: 'monospace',
      height: 1.45,
    );
  }
}

/// Small diamond/star brand glyph, replacing the Claude asterisk mark with
/// a generic shape so any brand name can sit next to it.
class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _SparkPainter()),
    );
  }
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * 3.1415926535 / 180;
      final tip = Offset(
        center.dx + r * 1.6 * _cos(angle),
        center.dy + r * 1.6 * _sin(angle),
      );
      final left = Offset(
        center.dx + r * 0.4 * _cos(angle - 0.6),
        center.dy + r * 0.4 * _sin(angle - 0.6),
      );
      final right = Offset(
        center.dx + r * 0.4 * _cos(angle + 0.6),
        center.dy + r * 0.4 * _sin(angle + 0.6),
      );
      path
        ..moveTo(center.dx, center.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  double _cos(double a) => _approxCos(a);
  double _sin(double a) => _approxCos(a - 1.5707963267948966);

  // Minimal cosine without importing dart:math (kept self-contained); falls
  // back to a Taylor approximation accurate enough for an 8-point glyph.
  double _approxCos(double x) {
    // Normalize to [-pi, pi]
    const pi = 3.1415926535897932;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    final x2 = x * x;
    return 1 - x2 / 2 + (x2 * x2) / 24 - (x2 * x2 * x2) / 720;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Faint, organic topographic-line background painted behind the terminal,
/// matching the subtle contour texture in the reference card.
class _TopoLinesPainter extends CustomPainter {
  _TopoLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final baseX = size.width * (0.05 + i * 0.16);
      path.moveTo(baseX, -20);
      for (double y = -20; y <= size.height + 20; y += 40) {
        final wiggle = 26 * ((i.isEven) ? 1 : -1) *
            _sinApprox((y / size.height) * 3.0 + i);
        path.lineTo(baseX + wiggle, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  double _sinApprox(double x) {
    const pi = 3.1415926535897932;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;
    final x2 = x * x;
    return x * (1 - x2 / 6 + (x2 * x2) / 120 - (x2 * x2 * x2) / 5040);
  }

  @override
  bool shouldRepaint(covariant _TopoLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}

// lib/screens/animation/animation_widget/terminal_animation.dart
//
// A reusable, self-playing "AI coding terminal" demo animation.
//
// Visually mirrors a dark terminal window sitting inside a soft, rounded
// card: a tiny brand glyph + version line, a typed user prompt, a sequence
// of "thinking" / tool-call lines, and a final typed-out response complete
// with a little file tree — all driven by an internal timeline so it can be
// dropped into any screen and just plays on its own.
//
// Usage:
// ```dart
// TerminalAnimation(
///   width: 600,
///   height: 420,
/// )
/// ```
//
// Everything is configurable (brand name, colors, conversation script,
// sizes) so it can be restyled or reused for a different product without
// touching internals.