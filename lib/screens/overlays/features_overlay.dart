// lib/screens/overlays/features_overlay.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../animations/features_web_animations.dart';
import '../animations/briefcase_animation.dart';

/// Descriptive left panel + [FeaturesWebAnimation] on the right.
/// Black background, white typography — scrolls as part of [HomeScreen].
class FeaturesOverlay extends StatelessWidget {
  const FeaturesOverlay({Key? key}) : super(key: key);

  // ── Helper: bottom border under each info block (left-side accent line) ──
  Widget _buildInfoBlock({
    required String title,
    required String description,
    bool showBorder = true,
  }) {
    return Container(
      // Outer border on the left side of the block
      decoration: showBorder
          ? BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.18),
            width: 1.0,
          ),
          // Left accent line — gives the "border after every description"
          // look from the screenshot
          left: BorderSide(
            color: Colors.white.withOpacity(0.35),
            width: 2.0,
          ),
        ),
      )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero block: briefcase + heading + subtitle + download buttons ──────
  Widget _buildHeroBlock(double maxWidth, bool isMobile) {
    // Responsive briefcase size: scales down on small screens
    final double briefcaseSize = isMobile
        ? math.min(maxWidth * 0.5, 180.0)
        : math.min(maxWidth * 0.35, 220.0);

    // Responsive title size
    final double titleSize   = isMobile ? 36 : 60;
    final double subtitleSize = isMobile ? 15 : 18;
    final double buttonFontSize = isMobile ? 13 : 15;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 0,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Briefcase animation
          BriefcaseAnimation(
            size: briefcaseSize,
            duration: const Duration(seconds: 3),
          ),
          const SizedBox(height: 24),

          // Main heading — "The AI for problem solvers"
          Text(
            '< The Messaging App Of AI Era >',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily:    '__copernicus_669e4a',
              color:         Colors.white,
              fontSize:      titleSize,
              fontWeight:    FontWeight.w800,
              height:        1.1,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle — "Use Cowork in the desktop app to hand off tasks."
          // with "Cowork" underlined.
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                color:      Colors.white.withOpacity(0.85),
                fontSize:   subtitleSize,
                fontWeight: FontWeight.w400,
                height:     1.5,
              ),
              children: const [
                TextSpan(text: 'Use '),
                TextSpan(
                  text: 'QuantMessage',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                    decorationColor: Colors.white,
                  ),
                ),
                TextSpan(text: '  to hand off tasks.'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Download row — matches the image
          _buildDownloadRow(isMobile, buttonFontSize),
        ],
      ),
    );
  }

  // ── Download buttons row (macOS / Windows / Windows arm64) ────────────
  Widget _buildDownloadRow(bool isMobile, double fontSize) {
    final buttons = <Widget>[
      _buildDownloadButton('macOS',            fontSize),
      _buildDownloadButton('Windows',          fontSize),
      _buildDownloadButton('Windows (arm64)',  fontSize),
    ];

    if (isMobile) {
      // Stack vertically on very small screens to avoid overflow
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            buttons[i],
          ],
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download the desktop app:',
              style: TextStyle(
                color:      Colors.white.withOpacity(0.7),
                fontSize:   fontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 14),
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              buttons[i],
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton(String label, double fontSize) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Hook up actual download URLs here
          debugPrint('Download tapped: $label');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:      Colors.white,
              fontSize:   fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Animation box (right side on desktop, bottom on mobile) ───────────
  Widget _buildAnimationBox({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Center(
        child: FeaturesWebAnimation(
          size: 380,
          useDarkTheme: true,
        ),
      ),
    );
  }

  // ── Layout helpers ─────────────────────────────────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBlock(
          title: 'Break down problems together',
          description: 'QuantMessage builds on your ideas, expands on your logic, '
              'and simplifies complexity one step at a time.',
        ),
        _buildInfoBlock(
          title: 'Tackle your toughest work',
          description: 'QuantMessage provides expert-level collaboration on the things '
              'you need to get done—from coding a product to critical data analysis.',
        ),
        _buildInfoBlock(
          title: 'Explore what\'s next',
          description: 'Like an expert in your pocket, collaborating with QuantMessage expands '
              'what you can build on your own or with teams.',
          showBorder: false, // last block — no bottom border
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile    = screenWidth < 900;
    final maxWidth    = screenWidth < 1400 ? screenWidth - 48 : 1352.0;

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── HERO BLOCK (briefcase + title + subtitle + downloads) ─
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _buildHeroBlock(maxWidth, isMobile),
              ),

              const SizedBox(height: 60),

              // ── INFO + ANIMATION ROW (responsive) ─────────────────────
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: isMobile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftColumn(),
                    const SizedBox(height: 32),
                    _buildAnimationBox(height: 400),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 45, child: _buildLeftColumn()),
                    const SizedBox(width: 40),
                    Expanded(flex: 55, child: _buildAnimationBox(height: 500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
