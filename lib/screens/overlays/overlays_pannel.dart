// lib/screens/overlays/overlays_panel.dart
//
// A white-background feature-showcase panel designed to be superimposed
// on home_screen.dart as a scrollable overlay sheet.
//
// Integration in home_screen.dart — add this anywhere inside your Stack or
// as a DraggableScrollableSheet anchored at the bottom:
//
//   // Inside home_screen.dart build(), add to your Stack children:
//   OverlaysPanel(),
//
// Or trigger it via a button:
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => const OverlaysPanel(),
//   );

import 'package:flutter/material.dart';

// ─── Data model ──────────────────────────────────────────────────────────────

class _Feature {
  final String title;
  final String description;
  const _Feature({required this.title, required this.description});
}

// ─── Panel widget ─────────────────────────────────────────────────────────────

class OverlaysPanel extends StatefulWidget {
  const OverlaysPanel({Key? key}) : super(key: key);

  @override
  State<OverlaysPanel> createState() => _OverlaysPanelState();
}

class _OverlaysPanelState extends State<OverlaysPanel>
    with SingleTickerProviderStateMixin {
  // Scroll-triggered reveal controller
  late final AnimationController _revealController;
  final ScrollController _scrollController = ScrollController();

  // Track which grid rows have revealed
  final Set<int> _revealedRows = {};

  static const _features = <_Feature>[
    _Feature(
      title: 'QuantMessage Managed Agents',
      description:
      'A suite of composable APIs for building and deploying agents at scale.',
    ),
    _Feature(
      title: 'Prompt caching',
      description:
      'Give QuantMessage more background knowledge and example outputs to reduce costs and latency.',
    ),
    _Feature(
      title: 'Web search and fetch',
      description:
      'Augment QuantMessage\'s knowledge with current, real-world data from across the web.',
    ),
    _Feature(
      title: 'Advanced tool use',
      description:
      'Allow QuantMessage to interact with hundreds of external tools and APIs so it can perform a wider range of tasks.',
    ),
    _Feature(
      title: 'Batch processing',
      description:
      'Process large volumes of requests asynchronously and save 50% on costs.',
    ),
    _Feature(
      title: 'Memory',
      description:
      'Let QuantMessage store and consult information from a dedicated memory file.',
    ),
    _Feature(
      title: 'Context editing',
      description:
      'Automatically clear less relevant tool calls and results from the context window when approaching token limits.',
    ),
    _Feature(
      title: 'MCP connector',
      description:
      'Connect QuantMessage to any remote MCP server without writing client code.',
    ),
    _Feature(
      title: 'Code execution',
      description:
      'Run Python code, create visualizations, and analyze data directly within API calls.',
    ),
    _Feature(
      title: 'Citations',
      description:
      'Get detailed references to the exact sentences and passages QuantMessage uses to generate responses, leading to more verifiable, trustworthy outputs.',
    ),
    _Feature(
      title: 'Files API',
      description:
      'Upload documents once and reference them repeatedly across conversations.',
    ),
    _Feature(
      title: 'Skills',
      description:
      'Teach QuantMessage your expertise, procedures, and best practices so it delivers consistent, expert-level results.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Reveal rows progressively as the user scrolls
    final offset = _scrollController.offset;
    // Each row is roughly 160 px tall; hero is ~340 px
    final rowsVisible = ((offset - 200) / 160).floor();
    for (int i = 0; i <= rowsVisible; i++) {
      if (!_revealedRows.contains(i)) {
        setState(() => _revealedRows.add(i));
      }
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 700;

    return Container(
      // White panel with top rounded corners — sits above the dark home screen
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Drag handle
              _buildHandle(),

              // Hero block
              _buildHero(isMobile),

              // Features grid
              _buildFeaturesGrid(isMobile),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ── Drag handle ────────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────

  Widget _buildHero(bool isMobile) {
    return FadeTransition(
      opacity: _revealController,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 28 : 80,
          vertical: 56,
        ),
        child: Column(
          children: [
            // Clock-pin icon — matches screenshot exactly
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1A1A1A),
                  width: 1.4,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _ClockPinPainter(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Do more with built-in tools',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '__copernicus_669e4a',
                fontSize: isMobile ? 32 : 52,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D0D0D),
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 32),

            // "See developer docs" button
            _DocsButton(),
          ],
        ),
      ),
    );
  }

  // ── Features grid ──────────────────────────────────────────────────────────

  Widget _buildFeaturesGrid(bool isMobile) {
    // Pair features into rows of 2
    final rows = <List<_Feature>>[];
    for (int i = 0; i < _features.length; i += 2) {
      rows.add([
        _features[i],
        if (i + 1 < _features.length) _features[i + 1],
      ]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64),
      child: Column(
        children: List.generate(rows.length, (rowIdx) {
          final revealed = _revealedRows.contains(rowIdx) ||
              rowIdx == 0; // first row always visible
          return _AnimatedRow(
            revealed: revealed,
            delay: Duration(milliseconds: rowIdx * 60),
            child: Column(
              children: [
                // Horizontal divider above every row
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: isMobile
                      ? Column(
                    children: rows[rowIdx]
                        .map((f) => _FeatureCard(feature: f))
                        .toList(),
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FeatureCard(feature: rows[rowIdx][0]),
                      ),
                      if (rows[rowIdx].length > 1) ...[
                        // Vertical divider between columns
                        Container(
                          width: 1,
                          height: 140,
                          margin: const EdgeInsets.only(top: 28),
                          color: const Color(0xFF1A1A1A).withOpacity(0.10),
                        ),
                        Expanded(
                          child: _FeatureCard(feature: rows[rowIdx][1]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFF1A1A1A).withOpacity(0.10),
    );
  }
}

// ─── Animated row wrapper ────────────────────────────────────────────────────

class _AnimatedRow extends StatefulWidget {
  final bool revealed;
  final Duration delay;
  final Widget child;

  const _AnimatedRow({
    required this.revealed,
    required this.delay,
    required this.child,
  });

  @override
  State<_AnimatedRow> createState() => _AnimatedRowState();
}

class _AnimatedRowState extends State<_AnimatedRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.revealed) {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed && !oldWidget.revealed) {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Individual feature card ─────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filled checkmark circle — identical to screenshots
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 2, right: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D0D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),

          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily: '__copernicus_669e4a',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D0D0D),
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0D0D0D).withOpacity(0.52),
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "See developer docs" button ─────────────────────────────────────────────

class _DocsButton extends StatefulWidget {
  const _DocsButton();

  @override
  State<_DocsButton> createState() => _DocsButtonState();
}

class _DocsButtonState extends State<_DocsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFF0D0D0D)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFF0D0D0D).withOpacity(0.30),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              // Navigate to developer docs
            },
            splashColor: Colors.black.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? Colors.white : const Color(0xFF0D0D0D),
                  letterSpacing: 0.1,
                ),
                child: const Text('See developer docs'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Clock-pin icon painter ───────────────────────────────────────────────────

class _ClockPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D0D0D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Vertical line (pin stem)
    canvas.drawLine(
      Offset(cx, cy - size.height * 0.42),
      Offset(cx, cy + size.height * 0.42),
      paint,
    );

    // Small filled circle at centre
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.12,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;

    // Horizontal tick (crosshair feel — matches screenshot icon)
    canvas.drawLine(
      Offset(cx - size.width * 0.22, cy),
      Offset(cx + size.width * 0.22, cy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


// ─────────────────────────────────────────────────────────────────────────────
// HOW TO INTEGRATE INTO home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Add the import at the top of home_screen.dart:
//      import 'overlays/overlays_panel.dart';
//
// 2. Add a trigger button (e.g. in your hero Wrap of AuraButtons):
//
//      ButtonBulge(
//        child: AuraButton(
//          onPressed: _showOverlayPanel,
//          outlined: true,
//          auraController: _bgController,
//          width: 180,
//          height: 40,
//          child: _buildButtonContent('built-in tools', Icons.layers_outlined),
//        ),
//      ),
//
// 3. Add this method to _HomeScreenState:
//
//      void _showOverlayPanel() {
//        showModalBottomSheet(
//          context: context,
//          isScrollControlled: true,        // fills up to full screen height
//          backgroundColor: Colors.transparent,
//          barrierColor: Colors.black.withOpacity(0.55),
//          builder: (_) => DraggableScrollableSheet(
//            initialChildSize: 0.88,        // opens at 88% of screen height
//            minChildSize: 0.50,
//            maxChildSize: 1.0,
//            expand: false,
//            builder: (_, scrollController) => const OverlaysPanel(),
//          ),
//        );
//      }