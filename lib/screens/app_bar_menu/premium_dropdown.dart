import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

// import 'package:newsos_app/screens/app_bar_menu/about/windcrest_page.dart';

class PremiumDropdown extends StatefulWidget {
  final String label;
  final List<DropdownColumn> columns;

  const PremiumDropdown({super.key, required this.label, required this.columns});

  @override
  State<PremiumDropdown> createState() => _PremiumDropdownState();
}

class _PremiumDropdownState extends State<PremiumDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  final ValueNotifier<bool> _closeNotifier = ValueNotifier(false);

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _closeNotifier.value = false;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    _closeNotifier.value = true;
  }

  void _onAnimationFinished() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 45),
            child: _DropdownContent(
              columns: widget.columns,
              closeNotifier: _closeNotifier,
              onAnimationComplete: _onAnimationFinished,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownColumn {
  final String title;
  final List<DropdownItem> items;
  DropdownColumn({required this.title, required this.items});
}

class DropdownItem {
  final String title;
  final VoidCallback onTap;
  final bool hasExternalLink;
  DropdownItem({required this.title, required this.onTap, this.hasExternalLink = false});
}

class _DropdownContent extends StatefulWidget {
  final List<DropdownColumn> columns;
  final ValueNotifier<bool> closeNotifier;
  final VoidCallback onAnimationComplete;

  const _DropdownContent({
    required this.columns,
    required this.closeNotifier,
    required this.onAnimationComplete,
  });

  @override
  State<_DropdownContent> createState() => _DropdownContentState();
}

class _DropdownContentState extends State<_DropdownContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = _scaleAnimation;

    _controller.forward();

    widget.closeNotifier.addListener(_handleCloseSignal);
  }

  void _handleCloseSignal() {
    if (widget.closeNotifier.value == true) {
      _controller.reverse().then((_) {
        widget.onAnimationComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicWidth(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1F).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.columns.map((col) {
                      return SizedBox(
                        width: 180,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                col.title,
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 12),
                              ...col.items.map((item) => _buildItem(item)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(DropdownItem item) {
    final VoidCallback effectiveOnTap = item.title == 'Windcrest'
        ? () async {
      final Uri url = Uri(scheme: 'https', host: 'windcrest-gilt.vercel.app');
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    }
        : item.onTap;

    return InkWell(
      onTap: effectiveOnTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
            if (item.hasExternalLink) Icon(Icons.open_in_new, size: 14, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
