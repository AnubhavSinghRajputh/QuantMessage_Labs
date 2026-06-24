// lib/screens/animations/animation_widget/ios_animation.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';


class IOSMessageLine {
  const IOSMessageLine({
    required this.type,
    this.text = '',
    this.delayBefore = const Duration(milliseconds: 300),
    this.animateTyping = true,
    this.typingSpeed = const Duration(milliseconds: 14),
    this.holdAfter = const Duration(milliseconds: 500),
    this.typingIndicatorDuration = const Duration(milliseconds: 1100),
  });

  final IOSLineType type;
  final String text;


  final Duration delayBefore;


  final bool animateTyping;

  final Duration typingSpeed;


  final Duration holdAfter;

  /// Only used by [IOSLineType.received]: how long the "•••" typing-dots
  /// bubble is shown before it's replaced by the real message.
  final Duration typingIndicatorDuration;
}

enum IOSLineType {
  /// Outgoing bubble (right-aligned, accent color). Plays by typing the text
  /// into the bottom input bar, then "sending" it as a bubble.
  sent,

  /// Incoming bubble (left-aligned, grey). Plays by showing an animated
  /// "•••" typing indicator, then revealing the message bubble.
  received,

  /// Centered grey meta text, e.g. "Today 9:41 AM". Appears instantly.
  timestamp,

  /// Small grey text under the most recent outgoing bubble, e.g. "Delivered"
  /// or "Read". Appears instantly.
  readReceipt,
}

/// Internal render kind for entries currently in the chat log (separate from
/// [IOSLineType] because the typing-dots indicator is a transient entry that
/// isn't itself part of the authored script).
enum _BubbleKind { sent, received, typingDots, timestamp, readReceipt }

class _ChatEntry {
  _ChatEntry({required this.kind, this.text = ''});
  final _BubbleKind kind;
  String text;
}

/// A reusable, self-contained iPhone-style mockup that plays out a scripted
/// iMessage-style conversation: typing indicators, composed-then-sent
/// bubbles, timestamps and read receipts, looping by default.
///
/// Drop it into any screen like:
///
/// ```dart
/// const IOSAnimation(
///   contactName: 'TaskFlow Assistant',
///   contactSubtitle: 'AI · Always available',
/// )
/// ```
///
/// Pass a custom [script] (a `List<IOSMessageLine>`) to author your own
/// conversation; otherwise a sensible default plays.
class IOSAnimation extends StatefulWidget {
  const IOSAnimation({
    super.key,
    this.width = 380,
    this.height = 540,
    this.contactName = 'TaskFlow Assistant',
    this.contactSubtitle = 'AI · Always available',
    this.contactInitials = 'TF',
    this.statusBarTime = '9:41',
    this.cardColor = const Color(0xFFC9D9D2),
    this.frameColor = const Color(0xFF111113),
    this.chatBackgroundColor = const Color(0xFFFFFFFF),
    this.sentBubbleColor = const Color(0xFF0A84FF),
    this.receivedBubbleColor = const Color(0xFFE9E9EB),
    this.sentTextColor = Colors.white,
    this.receivedTextColor = const Color(0xFF1C1C1E),
    this.accentColor = const Color(0xFF0A84FF),
    this.script,
    this.loop = true,
    this.loopPause = const Duration(seconds: 2),
    this.borderRadius = 28,
    this.deviceBorderRadius = 46,
    this.autoStart = true,
  });

  final double width;
  final double height;

  final String contactName;
  final String contactSubtitle;
  final String contactInitials;
  final String statusBarTime;

  /// Backdrop behind the phone mockup.
  final Color cardColor;

  /// Bezel color of the phone mockup.
  final Color frameColor;

  final Color chatBackgroundColor;
  final Color sentBubbleColor;
  final Color receivedBubbleColor;
  final Color sentTextColor;
  final Color receivedTextColor;

  /// Used for the back chevron, send button and contact avatar.
  final Color accentColor;

  final List<IOSMessageLine>? script;

  final bool loop;
  final Duration loopPause;

  final double borderRadius;
  final double deviceBorderRadius;

  final bool autoStart;

  @override
  State<IOSAnimation> createState() => _IOSAnimationState();
}

class _IOSAnimationState extends State<IOSAnimation>
    with TickerProviderStateMixin {
  late List<IOSMessageLine> _script;
  final List<_ChatEntry> _entries = [];
  String _composingText = '';

  Timer? _typingTimer;
  Timer? _delayTimer;
  bool _disposed = false;

  late final AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _script = widget.script ?? defaultIOSScript;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playFrom(0));
    }
  }

  @override
  void didUpdateWidget(covariant IOSAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.script != widget.script) {
      _resetAndReplay();
    }
  }

  void _resetAndReplay() {
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    setState(() {
      _script = widget.script ?? defaultIOSScript;
      _entries.clear();
      _composingText = '';
    });
    _playFrom(0);
  }

  // ---- Sequencing ----------------------------------------------------

  void _playFrom(int index) {
    if (_disposed) return;
    if (index >= _script.length) {
      if (widget.loop) {
        _delayTimer = Timer(widget.loopPause, _resetAndReplay);
      }
      return;
    }

    final line = _script[index];
    _delayTimer = Timer(line.delayBefore, () {
      if (_disposed) return;
      switch (line.type) {
        case IOSLineType.sent:
          _playSent(line, index);
          break;
        case IOSLineType.received:
          _playReceived(line, index);
          break;
        case IOSLineType.timestamp:
        case IOSLineType.readReceipt:
          _playMeta(line, index);
          break;
      }
    });
  }

  void _playSent(IOSMessageLine line, int index) {
    if (!line.animateTyping || line.text.isEmpty) {
      setState(() => _composingText = line.text);
      _delayTimer = Timer(
        const Duration(milliseconds: 250),
            () => _sendComposed(line, index),
      );
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
        _composingText = line.text.substring(
          0,
          charIndex.clamp(0, line.text.length),
        );
      });
      if (charIndex >= line.text.length) {
        timer.cancel();
        _delayTimer = Timer(
          const Duration(milliseconds: 350),
              () => _sendComposed(line, index),
        );
      }
    });
  }

  void _sendComposed(IOSMessageLine line, int index) {
    if (_disposed) return;
    setState(() {
      _composingText = '';
      _entries.add(_ChatEntry(kind: _BubbleKind.sent, text: line.text));
    });
    _scrollToBottomSoon();
    _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
  }

  void _playReceived(IOSMessageLine line, int index) {
    final dotsEntry = _ChatEntry(kind: _BubbleKind.typingDots);
    setState(() => _entries.add(dotsEntry));
    _scrollToBottomSoon();

    _delayTimer = Timer(line.typingIndicatorDuration, () {
      if (_disposed) return;
      setState(() => _entries.remove(dotsEntry));

      if (!line.animateTyping || line.text.isEmpty) {
        setState(
              () => _entries.add(
            _ChatEntry(kind: _BubbleKind.received, text: line.text),
          ),
        );
        _scrollToBottomSoon();
        _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
        return;
      }

      final entry = _ChatEntry(kind: _BubbleKind.received, text: '');
      setState(() => _entries.add(entry));

      int charIndex = 0;
      _typingTimer = Timer.periodic(line.typingSpeed, (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        charIndex++;
        setState(() {
          entry.text = line.text.substring(
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

  void _playMeta(IOSMessageLine line, int index) {
    final kind = line.type == IOSLineType.timestamp
        ? _BubbleKind.timestamp
        : _BubbleKind.readReceipt;
    setState(() => _entries.add(_ChatEntry(kind: kind, text: line.text)));
    _scrollToBottomSoon();
    _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---- Build -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                color: widget.cardColor,
                child: CustomPaint(
                  painter: _IOSBackdropPainter(
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.width * 0.09,
                vertical: widget.height * 0.045,
              ),
              child: _buildPhoneFrame(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneFrame() {
    return Container(
      decoration: BoxDecoration(
        color: widget.frameColor,
        borderRadius: BorderRadius.circular(widget.deviceBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.deviceBorderRadius - 12),
        child: Container(
          color: widget.chatBackgroundColor,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildStatusBar(),
                  _buildNavBar(),
                  const Divider(height: 1, thickness: 0.6),
                  Expanded(child: _buildChatBody()),
                  _buildInputBar(),
                ],
              ),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 80,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 4),
      child: Row(
        children: [
          Text(
            widget.statusBarTime,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          const Icon(Icons.wifi, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          const Icon(Icons.battery_full, size: 16, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: widget.accentColor, size: 26),
                Text(
                  '24',
                  style: TextStyle(color: widget.accentColor, fontSize: 15),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            child: Icon(
              Icons.videocam_rounded,
              color: widget.accentColor,
              size: 22,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.accentColor,
                child: Text(
                  widget.contactInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.contactName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.contactSubtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      physics: const ClampingScrollPhysics(),
      itemCount: _entries.length,
      itemBuilder: (context, i) => _buildEntry(_entries[i]),
    );
  }

  Widget _buildEntry(_ChatEntry entry) {
    switch (entry.kind) {
      case _BubbleKind.timestamp:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              entry.text,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );

      case _BubbleKind.readReceipt:
        return Padding(
          padding: const EdgeInsets.only(right: 6, top: 2, bottom: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              entry.text,
              style: TextStyle(
                color: Colors.black.withOpacity(0.38),
                fontSize: 11,
              ),
            ),
          ),
        );

      case _BubbleKind.sent:
        return _Bubble(
          alignment: Alignment.centerRight,
          color: widget.sentBubbleColor,
          textColor: widget.sentTextColor,
          text: entry.text,
          tailOnRight: true,
          maxWidth: widget.width * 0.62,
        );

      case _BubbleKind.received:
        return _Bubble(
          alignment: Alignment.centerLeft,
          color: widget.receivedBubbleColor,
          textColor: widget.receivedTextColor,
          text: entry.text,
          tailOnRight: false,
          maxWidth: widget.width * 0.62,
        );

      case _BubbleKind.typingDots:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.receivedBubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (_pulseController.value * 2 * math.pi) -
                        (i * 0.6);
                    final bounce = (math.sin(phase) + 1) / 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, -bounce * 4),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        );
    }
  }

  Widget _buildInputBar() {
    final hasText = _composingText.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E2E4), width: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.add_circle,
            color: Colors.black.withOpacity(0.28),
            size: 26,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCDCDE), width: 0.8),
              ),
              child: hasText
                  ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _composingText,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          final visible =
                              (_pulseController.value * 2) % 1 < 0.5;
                          return Opacity(
                            opacity: visible ? 1 : 0,
                            child: Container(
                              width: 1.5,
                              height: 14,
                              margin: const EdgeInsets.only(left: 1),
                              color: widget.accentColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
                  : Text(
                'iMessage',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.35),
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: hasText
                  ? widget.accentColor
                  : widget.accentColor.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single chat bubble with an iMessage-style "tail" on the side it points
/// from.
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignment,
    required this.color,
    required this.textColor,
    required this.text,
    required this.tailOnRight,
    required this.maxWidth,
  });

  final Alignment alignment;
  final Color color;
  final Color textColor;
  final String text;
  final bool tailOnRight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(tailOnRight ? 18 : 4),
              bottomRight: Radius.circular(tailOnRight ? 4 : 18),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 14.5, height: 1.32),
          ),
        ),
      ),
    );
  }
}

/// Faint diagonal texture for the backdrop card, matching the visual
/// language of terminal_animation.dart's topo-line background.
class _IOSBackdropPainter extends CustomPainter {
  _IOSBackdropPainter({required this.color});

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
        final wiggle =
            26 * ((i.isEven) ? 1 : -1) * _sinApprox((y / size.height) * 3.0 + i);
        path.lineTo(baseX + wiggle, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  double _sinApprox(double x) {
    const pi = 3.1415926535897932;
    while (x > pi) {
      x -= 2 * pi;
    }
    while (x < -pi) {
      x += 2 * pi;
    }
    final x2 = x * x;
    return x * (1 - x2 / 6 + (x2 * x2) / 120 - (x2 * x2 * x2) / 5040);
  }

  @override
  bool shouldRepaint(covariant _IOSBackdropPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A ready-to-use default conversation, shown when [IOSAnimation.script] is
/// not provided. Swap in your own `List<IOSMessageLine>` to script a
/// different conversation while reusing the same widget.
const List<IOSMessageLine> defaultIOSScript = [
  IOSMessageLine(
    type: IOSLineType.timestamp,
    text: 'Today 9:41 AM',
    animateTyping: false,
    delayBefore: Duration(milliseconds: 300),
    holdAfter: Duration(milliseconds: 300),
  ),
  IOSMessageLine(
    type: IOSLineType.sent,
    text: 'Hey — can you check if the TaskFlow API deploy went out ok?',
    delayBefore: Duration(milliseconds: 400),
    typingSpeed: Duration(milliseconds: 16),
    holdAfter: Duration(milliseconds: 500),
  ),
  IOSMessageLine(
    type: IOSLineType.received,
    text: 'Checking the deploy logs now, one sec.',
    animateTyping: false,
    typingIndicatorDuration: Duration(milliseconds: 1300),
    holdAfter: Duration(milliseconds: 500),
  ),
  IOSMessageLine(
    type: IOSLineType.received,
    text:
    'Deploy finished 4 minutes ago — all green. 12 routes updated, no failed health checks.',
    animateTyping: false,
    typingIndicatorDuration: Duration(milliseconds: 1400),
    holdAfter: Duration(milliseconds: 600),
  ),
  IOSMessageLine(
    type: IOSLineType.sent,
    text: 'Perfect, thank you!',
    delayBefore: Duration(milliseconds: 300),
    typingSpeed: Duration(milliseconds: 18),
    holdAfter: Duration(milliseconds: 400),
  ),
  IOSMessageLine(
    type: IOSLineType.readReceipt,
    text: 'Delivered',
    animateTyping: false,
    delayBefore: Duration(milliseconds: 200),
    holdAfter: Duration(milliseconds: 2200),
  ),
];