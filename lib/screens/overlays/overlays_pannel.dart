// lib/screens/overlays/overlays_panel.dart
//
// WHITE-background overlay panel.
// Superimposed on home_screen via a SliverPersistentHeader so it scrolls
// in naturally as a "second section" with a visible lined partition between
// the dark home content and this white panel.

import 'package:flutter/material.dart';
import '../animations/pendulum_animation.dart';

// ─── Feature model ────────────────────────────────────────────────────────────

class _Feature {
  final String title;
  final String description;
  const _Feature({required this.title, required this.description});
}

const _features = <_Feature>[
  _Feature(title: 'QuantMessage Managed Agents',  description: 'A suite of composable APIs for building and deploying agents at scale.'),
  _Feature(title: 'Prompt caching',               description: 'Give QuantMessage more background knowledge and example outputs to reduce costs and latency.'),
  _Feature(title: 'Web search and fetch',          description: "Augment QuantMessage's knowledge with current, real-world data from across the web."),
  _Feature(title: 'Advanced tool use',             description: 'Allow QuantMessage to interact with hundreds of external tools and APIs so it can perform a wider range of tasks.'),
  _Feature(title: 'Batch processing',              description: 'Process large volumes of requests asynchronously and save 50% on costs.'),
  _Feature(title: 'Memory',                        description: 'Let QuantMessage store and consult information from a dedicated memory file.'),
  _Feature(title: 'Context editing',               description: 'Automatically clear less relevant tool calls and results from the context window when approaching token limits.'),
  _Feature(title: 'MCP connector',                 description: 'Connect QuantMessage to any remote MCP server without writing client code.'),
  _Feature(title: 'Code execution',                description: 'Run Python code, create visualizations, and analyze data directly within API calls.'),
  _Feature(title: 'Citations',                     description: 'Get detailed references to the exact sentences and passages QuantMessage uses to generate responses, leading to more verifiable, trustworthy outputs.'),
  _Feature(title: 'Files API',                     description: 'Upload documents once and reference them repeatedly across conversations.'),
  _Feature(title: 'Skills',                        description: 'Teach QuantMessage your expertise, procedures, and best practices so it delivers consistent, expert-level results.'),
];

// ─── Main widget ──────────────────────────────────────────────────────────────
//
// Drop this directly inside home_screen's Column (after all dark content)
// so it scrolls in as a natural continuation.  The top lined partition and
// white background create the visual "attachment" effect.

class OverlaysPanel extends StatefulWidget {
  const OverlaysPanel({Key? key}) : super(key: key);

  @override
  State<OverlaysPanel> createState() => _OverlaysPanelState();
}

class _OverlaysPanelState extends State<OverlaysPanel>
    with SingleTickerProviderStateMixin {
  // All rows revealed with staggered delays as soon as panel mounts

  // Hero entry animation
  late final AnimationController _heroCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Start hero animation as soon as the panel appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  // Called by home_screen when the outer scroll position passes the panel
  void onBecameVisible() {
    if (!_heroCtrl.isCompleted) _heroCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final isMobile = screenW < 700;

    return Container(
      // White background — contrasts with the dark home screen above it
      color: const Color(0xFFF7F7F5),
      child: Column(
        children: [
          // ── Lined partition (dark → white transition bar) ────────────────
          _buildPartition(),

          // ── Hero ─────────────────────────────────────────────────────────
          FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: _buildHero(isMobile),
            ),
          ),

          // ── Feature grid ─────────────────────────────────────────────────
          _buildFeaturesGrid(isMobile),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Partition ─────────────────────────────────────────────────────────────
  // Three lines: a bold dark line flanked by two hairlines — gives a clean
  // "superimposed panel" look matching the screenshot transition zone.

  Widget _buildPartition() {
    return Column(
      children: [
        // Hairline top
        Container(height: 1, color: const Color(0xFF1A1A1A).withOpacity(0.08)),
        const SizedBox(height: 2),
        // Bold centre line
        Container(height: 2, color: const Color(0xFF1A1A1A).withOpacity(0.18)),
        const SizedBox(height: 2),
        // Hairline bottom
        Container(height: 1, color: const Color(0xFF1A1A1A).withOpacity(0.08)),
      ],
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 28 : 80,
        vertical:   60,
      ),
      child: Column(
        children: [
          // Pendulum icon — dark coloured for white background
          const PendulumAnimation(size: 80, color: Color(0xFF1A1A1A)),

          const SizedBox(height: 36),

          Text(
            ' < One Phlatform For Everything >',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily:    '__copernicus_669e4a',
              fontSize:      isMobile ? 30 : 52,
              fontWeight:    FontWeight.w800,
              color:         const Color(0xFF0D0D0D),
              height:        1.1,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 32),

          _DocsButton(),
        ],
      ),
    );
  }

  // ── Feature grid ──────────────────────────────────────────────────────────

  Widget _buildFeaturesGrid(bool isMobile) {
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
          return _AnimatedRow(
            // All rows reveal with staggered delays once panel mounts
            revealed: true,
            delay:    Duration(milliseconds: 120 + rowIdx * 80),
            child: Column(
              children: [
                _buildRowDivider(),
                isMobile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows[rowIdx]
                      .map((f) => _FeatureCard(feature: f))
                      .toList(),
                )
                    : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _FeatureCard(feature: rows[rowIdx][0])),
                      if (rows[rowIdx].length > 1) ...[
                        // Vertical column divider
                        Container(
                          width: 1,
                          color: const Color(0xFF1A1A1A).withOpacity(0.08),
                        ),
                        Expanded(child: _FeatureCard(feature: rows[rowIdx][1])),
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

  Widget _buildRowDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF1A1A1A).withOpacity(0.12),
            const Color(0xFF1A1A1A).withOpacity(0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.12, 0.88, 1.0],
        ),
      ),
    );
  }
}

// ─── Animated row reveal ──────────────────────────────────────────────────────

class _AnimatedRow extends StatefulWidget {
  final bool     revealed;
  final Duration delay;
  final Widget   child;
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
      duration: const Duration(milliseconds: 480),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide   = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.revealed) _scheduleForward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedRow old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !old.revealed) _scheduleForward();
  }

  void _scheduleForward() {
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─── Feature card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark filled circle with white checkmark
          Container(
            width:  26,
            height: 26,
            margin: const EdgeInsets.only(top: 1, right: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D0D),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily:    '__copernicus_669e4a',
                    fontSize:      17,
                    fontWeight:    FontWeight.w600,
                    color:         Color(0xFF0D0D0D),
                    height:        1.3,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    14,
                    fontWeight:  FontWeight.w400,
                    color:       const Color(0xFF0D0D0D).withOpacity(0.52),
                    height:      1.65,
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF0D0D0D) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFF0D0D0D).withOpacity(_hovered ? 1.0 : 0.28),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {},
            splashColor: Colors.black.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    14,
                  fontWeight:  FontWeight.w500,
                  color: _hovered ? Colors.white : const Color(0xFF0D0D0D),
                  letterSpacing: 0.2,
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