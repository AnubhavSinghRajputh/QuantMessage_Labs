// documentations/documentation_homescreen/documentation_homescreen.dart
import 'package:flutter/material.dart';
import 'package:newsos_app/screens/transition_animations.dart';

import '../../app_bar.dart';
import '../../animations/pendulum_animation.dart';
import '../../premium_effects.dart';

/// ---------------------------------------------------------------------
/// DATA MODEL
/// A doc section is a node in the sidebar tree. Leaf sections carry
/// [body] content; parent sections are pure grouping (expand/collapse).
/// ---------------------------------------------------------------------
class DocSection {
  final String id;
  final String title;
  final IconData icon;
  final List<DocBlock>? body;
  final List<DocSection>? children;

  const DocSection({
    required this.id,
    required this.title,
    required this.icon,
    this.body,
    this.children,
  });

  bool get isLeaf => body != null;
}

/// A single content block inside a doc page — kept intentionally simple
/// (heading / paragraph / code / note) so real content can be dropped in
/// without rebuilding the renderer.
class DocBlock {
  final DocBlockType type;
  final String text;
  const DocBlock(this.type, this.text);

  const DocBlock.h(this.text) : type = DocBlockType.heading;
  const DocBlock.p(this.text) : type = DocBlockType.paragraph;
  const DocBlock.code(this.text) : type = DocBlockType.code;
  const DocBlock.note(this.text) : type = DocBlockType.note;
}

enum DocBlockType { heading, paragraph, code, note }

/// ---------------------------------------------------------------------
/// SAMPLE CONTENT TREE
/// Replace with real docs — structure is what matters here.
/// ---------------------------------------------------------------------
final List<DocSection> kDocTree = [
  DocSection(
    id: 'getting-started',
    title: 'Getting Started',
    icon: Icons.bolt_outlined,
    children: [
      DocSection(
        id: 'overview',
        title: 'Overview',
        icon: Icons.circle,
        body: [
          DocBlock.h('Overview'),
          DocBlock.p(
            'QUANT-MESSAGE is built around a single idea: messages should '
                'move like signal, not noise. This section walks through the '
                'core concepts before you touch any code.',
          ),
          DocBlock.note(
            'New here? Start with Installation, then Quickstart.',
          ),
        ],
      ),
      DocSection(
        id: 'install',
        title: 'Installation',
        icon: Icons.circle,
        body: [
          DocBlock.h('Installation'),
          DocBlock.p('Add the dependency to your pubspec.yaml:'),
          DocBlock.code('dependencies:\n  quant_message: ^1.0.0'),
          DocBlock.p('Then fetch packages and you are ready to import.'),
        ],
      ),
      DocSection(
        id: 'quickstart',
        title: 'Quickstart',
        icon: Icons.circle,
        body: [
          DocBlock.h('Quickstart'),
          DocBlock.p('Send your first message in three lines:'),
          DocBlock.code(
            "final client = QuantClient.connect();\n"
                "await client.send('hello-channel', 'first signal');",
          ),
        ],
      ),
    ],
  ),
  DocSection(
    id: 'core-concepts',
    title: 'Core Concepts',
    icon: Icons.hub_outlined,
    children: [
      DocSection(
        id: 'channels',
        title: 'Channels',
        icon: Icons.circle,
        body: [
          DocBlock.h('Channels'),
          DocBlock.p(
            'Channels are durable, ordered streams. Every message belongs '
                'to exactly one channel, and channels never reorder delivery.',
          ),
        ],
      ),
      DocSection(
        id: 'sync',
        title: 'QuantSync',
        icon: Icons.circle,
        body: [
          DocBlock.h('QuantSync'),
          DocBlock.p(
            'QuantSync reconciles offline state against the server clock '
                'using a vector-timestamp merge, so reconnect is never a '
                'full resync.',
          ),
        ],
      ),
    ],
  ),
  DocSection(
    id: 'api',
    title: 'API Reference',
    icon: Icons.api_outlined,
    children: [
      DocSection(
        id: 'client',
        title: 'QuantClient',
        icon: Icons.circle,
        body: [
          DocBlock.h('QuantClient'),
          DocBlock.p('The entry point for every connection.'),
          DocBlock.code(
            'QuantClient.connect({\n'
                '  String? token,\n'
                '  Duration timeout = const Duration(seconds: 10),\n'
                '})',
          ),
        ],
      ),
      DocSection(
        id: 'errors',
        title: 'Error Codes',
        icon: Icons.circle,
        body: [
          DocBlock.h('Error Codes'),
          DocBlock.p(
            'Every failure returns a typed QuantError with a stable code, '
                'so you can branch on it without parsing strings.',
          ),
        ],
      ),
    ],
  ),
  DocSection(
    id: 'support',
    title: 'Support',
    icon: Icons.support_agent_outlined,
    body: [
      DocBlock.h('Support'),
      DocBlock.p(
        'Stuck on something the docs do not cover? Reach the team '
            'directly — we read every message.',
      ),
    ],
  ),
];

/// ---------------------------------------------------------------------
/// SCREEN
/// ---------------------------------------------------------------------
class DocumentationHomescreen extends StatefulWidget {
  const DocumentationHomescreen({Key? key}) : super(key: key);

  @override
  State<DocumentationHomescreen> createState() =>
      _DocumentationHomescreenState();
}

class _DocumentationHomescreenState extends State<DocumentationHomescreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentFade;

  DocSection? _activeSection;
  final Set<String> _expanded = {};
  bool _isLoadingSection = false;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

    _contentFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Expand the first group and open the first leaf by default.
    _expanded.add(kDocTree.first.id);
    _activeSection = _firstLeaf(kDocTree.first);
    _contentFade.forward();

    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  DocSection? _firstLeaf(DocSection section) {
    if (section.isLeaf) return section;
    for (final child in section.children ?? const []) {
      final found = _firstLeaf(child);
      if (found != null) return found;
    }
    return null;
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentFade.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectSection(DocSection section) {
    if (!section.isLeaf || section.id == _activeSection?.id) return;

    setState(() => _isLoadingSection = true);
    _contentFade.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _activeSection = section;
        _isLoadingSection = false;
      });
      _contentFade.forward();
    });
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
  }

  bool _matchesQuery(DocSection section) {
    if (_query.isEmpty) return true;
    if (section.title.toLowerCase().contains(_query)) return true;
    for (final child in section.children ?? const []) {
      if (_matchesQuery(child)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(title: 'QUANT-MESSAGE DOCS'),
      drawer: isMobile ? Drawer(child: _buildSidebarContent(context)) : null,
      body: PremiumBackgroundStack(
        bgController: _bgController,
        baseColor: const Color(0xFF070709),
        // Keep the fluid mesh, drop the wandering dot field — copy needs
        // a calm surface to sit on, not a starfield competing for focus.
        showMovingDots: false,
        showFluidMesh: true,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: const PremiumAppBar().preferredSize.height,
            ),
            child: isMobile ? _buildMobileBody(context) : _buildDesktopBody(context),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // LAYOUT: DESKTOP — fixed sidebar + content column
  // -------------------------------------------------------------------
  Widget _buildDesktopBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: _buildSidebarContent(context),
        ),
        Container(width: 1, color: Colors.white.withOpacity(0.06)),
        Expanded(child: _buildContentArea(context)),
      ],
    );
  }

  // -------------------------------------------------------------------
  // LAYOUT: MOBILE — drawer holds the nav, body is content + menu button
  // -------------------------------------------------------------------
  Widget _buildMobileBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _activeSection?.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContentArea(context)),
      ],
    );
  }

  // -------------------------------------------------------------------
  // SIDEBAR
  // -------------------------------------------------------------------
  Widget _buildSidebarContent(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: _buildSearchField(),
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: kDocTree
                  .where(_matchesQuery)
                  .map((section) => _buildNavNode(section, depth: 0))
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search docs',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavNode(DocSection section, {required int depth}) {
    if (!_matchesQuery(section)) return const SizedBox.shrink();

    if (section.isLeaf) {
      final isActive = section.id == _activeSection?.id;
      return InkWell(
        onTap: () => _selectSection(section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.fromLTRB(12, 1, 12, 1),
          padding: EdgeInsets.fromLTRB(12 + depth * 14, 9, 12, 9),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.07) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: isActive ? Colors.greenAccent.withOpacity(0.8) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.greenAccent : Colors.white.withOpacity(0.25),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final expanded = _expanded.contains(section.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleExpand(section.id),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12 + depth * 14, 10, 12, 10),
            child: Row(
              children: [
                Icon(section.icon, size: 15, color: Colors.white.withOpacity(0.55)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right,
                      size: 16, color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: expanded
              ? Column(
            children: (section.children ?? [])
                .map((c) => _buildNavNode(c, depth: depth + 1))
                .toList(),
          )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }

  Widget _buildSidebarFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const PendulumAnimation(size: 22, color: Color(0xFF6E6E78)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'In step with v1.0.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // CONTENT AREA
  // -------------------------------------------------------------------
  Widget _buildContentArea(BuildContext context) {
    if (_isLoadingSection) {
      return const Center(
        child: PendulumAnimation(size: 56, color: Colors.white),
      );
    }

    final section = _activeSection;
    if (section == null) {
      return Center(
        child: Text(
          'Pick a topic from the left to begin.',
          style: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      );
    }

    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _contentFade, curve: Curves.easeOutCubic)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: _breadcrumbFor(section)
                      .map((label) => Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                ...section.body!.map(_buildBlock),
                const SizedBox(height: 48),
                _buildFeedbackRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _breadcrumbFor(DocSection target) {
    for (final top in kDocTree) {
      if (top.id == target.id) return ['DOCS', '/', top.title.toUpperCase()];
      for (final child in top.children ?? const []) {
        if (child.id == target.id) {
          return ['DOCS', '/', top.title.toUpperCase(), '/', child.title.toUpperCase()];
        }
      }
    }
    return ['DOCS'];
  }

  Widget _buildBlock(DocBlock block) {
    switch (block.type) {
      case DocBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            block.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        );
      case DocBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            block.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        );
      case DocBlockType.code:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            block.text,
            style: const TextStyle(
              color: Color(0xFFB7F7C5),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        );
      case DocBlockType.note:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: Colors.greenAccent.withOpacity(0.6), width: 2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.greenAccent.withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.text,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildFeedbackRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Was this page useful?',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.thumb_up_outlined, size: 16, color: Colors.white.withOpacity(0.5)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.thumb_down_outlined, size: 16, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Helper for callers navigating in from elsewhere in the app, using the
/// existing PremiumTransitions so this screen arrives consistently with
/// the rest of QUANT-MESSAGE.
/// ---------------------------------------------------------------------
void openDocumentationHome(BuildContext context) {
  Navigator.of(context).push(
    PremiumTransitions.softFade(const DocumentationHomescreen()),
  );
}