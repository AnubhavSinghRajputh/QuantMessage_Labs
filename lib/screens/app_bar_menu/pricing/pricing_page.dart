// screens/app_bar_menu/pricing/pricing_page.dart

import 'package:flutter/material.dart';
import '../../premium_effects.dart';
import '../../transition_animations.dart';
import '../../button_buldge.dart';

enum BillingCycle { monthly, yearly }

class PricingPlan {
  final String       name;
  final String       tagline;
  final double       monthlyPrice;
  final double       yearlyDiscountPct;
  final List<String> features;
  final bool         highlighted;
  final bool         isAddOn;
  final IconData     icon;

  const PricingPlan({
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.features,
    required this.icon,
    this.yearlyDiscountPct = 0.20,
    this.highlighted = false,
    this.isAddOn = false,
  });

  /// Effective price per month for the given billing cycle.
  /// Yearly price is calculated automatically — no need to hardcode it.
  double priceFor(BillingCycle cycle) {
    if (monthlyPrice == 0) return 0;
    if (cycle == BillingCycle.monthly) return monthlyPrice;
    return monthlyPrice * (1 - yearlyDiscountPct);
  }

  /// Total billed amount for the cycle (yearly is charged upfront as
  /// 12x the discounted monthly rate).
  double totalFor(BillingCycle cycle) {
    final perMonth = priceFor(cycle);
    return cycle == BillingCycle.yearly ? perMonth * 12 : perMonth;
  }
}

const _plans = <PricingPlan>[
  PricingPlan(
    name:         'Free',
    tagline:      'Get started with QuantMessage',
    monthlyPrice: 0,
    icon:         Icons.bolt_outlined,
    features: [
      'Access to QuantMessage free tier',
      'Limited messages / month',
      'Community support',
      'Web + Mobile access',
      'Ads supported',
    ],
  ),
  PricingPlan(
    name:         'Pro',
    tagline:      'For individuals who want more',
    monthlyPrice: 150,
    icon:         Icons.workspace_premium_outlined,
    features: [
      'Full access to QuantMessage',
      'Higher message limits',
      'Priority response speed',
      'Email support',
      'Reduced ads',
    ],
  ),
  PricingPlan(
    name:         'Prime',
    tagline:      'For power users who need it all',
    monthlyPrice: 250,
    icon:         Icons.auto_awesome_outlined,
    highlighted:  true,
    features: [
      'Everything in Pro',
      'Unlimited QuantMessage access',
      'Advanced features & tools',
      'Faster priority support',
      'No ads included',
    ],
  ),
  PricingPlan(
    name:         'Enterprise',
    tagline:      'For teams and organizations',
    monthlyPrice: 1000,
    icon:         Icons.groups_2_outlined,
    features: [
      'Everything in Prime',
      'Team / multi-seat access',
      'Dedicated account manager',
      'Custom integrations',
      'SLA-backed support',
      'No ads included',
    ],
  ),
];

const _addOnPlan = PricingPlan(
  name:         'No Ads',
  tagline:      'Remove ads from any plan',
  monthlyPrice: 50,
  icon:         Icons.block_outlined,
  isAddOn:      true,
  features: [
    'Removes all ads',
    'Stacks with Free or Pro plan',
    'Cancel anytime',
  ],
);

class PricingPage extends StatefulWidget {
  const PricingPage({Key? key}) : super(key: key);

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage>
    with TickerProviderStateMixin {

  late final AnimationController _heroCtrl;

  BillingCycle _cycle    = BillingCycle.monthly;
  PricingPlan  _selected = _plans[2];
  bool         _addOnSelected = false;

  Key _swapKey = const ValueKey('plans_grid_v1');


  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _selectPlan(PricingPlan plan) {
    if (_selected.name == plan.name) return;
    setState(() {
      _selected = plan;
      _swapKey  = ValueKey('plans_grid_${plan.name}_${DateTime.now().microsecondsSinceEpoch}');
    });
  }

  void _toggleAddOn() {
    setState(() => _addOnSelected = !_addOnSelected);
  }

  double get _totalDue {
    final base = _selected.totalFor(_cycle);
    final addOn = _addOnSelected ? _addOnPlan.totalFor(_cycle) : 0.0;
    return base + addOn;
  }

  void _onContinue() {
    final cycleLabel = _cycle == BillingCycle.monthly ? 'monthly' : 'yearly';
    final addOnLabel = _addOnSelected ? ' + No Ads' : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Continuing with ${_selected.name}$addOnLabel plan ($cycleLabel) '
              '— ₹${_totalDue.toStringAsFixed(0)} ${_cycle == BillingCycle.yearly ? "/ year" : "/ month"}.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF15151B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final isMobile = screenW < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        baseColor: const Color(0xFF070709),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 40),
                _buildBillingToggle(),
                const SizedBox(height: 40),
                _buildPlansGrid(isMobile),
                const SizedBox(height: 28),
                _buildAddOnCard(isMobile),
                const SizedBox(height: 40),
                _buildContinueBar(isMobile),
                const SizedBox(height: 40),
                _buildFooterNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // header

  Widget _buildHeader(bool isMobile) {
    return FadeInOnTextAnimation(
      controller: _heroCtrl,
      child: Column(
        children: [
          AuraHeadline(
            controller: _heroCtrl,
            auraController: _bgController,
            fullText: 'Pricing',
            highlightPart: 'Pricing',
            borderRadius: 24,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              'Simple, transparent pricing for QuantMessage. Start free, upgrade anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    isMobile ? 15 : 18,
                fontWeight:  FontWeight.w400,
                color:       Colors.white.withOpacity(0.55),
                height:      1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleChip(BillingCycle.monthly, 'Monthly'),
          _buildToggleChip(BillingCycle.yearly,  'Yearly  • save 20%'),
        ],
      ),
    );
  }

  Widget _buildToggleChip(BillingCycle cycle, String label) {
    final selected = _cycle == cycle;
    return ButtonBulge(
      hoverScale: 1.03,
      pressedScale: 0.96,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _cycle = cycle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    13,
                fontWeight:  FontWeight.w600,
                color:       selected ? Colors.black : Colors.white.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansGrid(bool isMobile) {
    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (isMobile) {
          return Column(
            children: _plans
                .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _PlanCard(
                plan:        p,
                cycle:       _cycle,
                isSelected:  _selected.name == p.name,
                onSelect:    () => _selectPlan(p),
                bgController: _bgController,
                fullWidth:   width,
              ),
            ))
                .toList(),
          );
        }
// 2 cross 2 mobile ki grid
         final useTwoColumns = width < 1100;
        if (useTwoColumns) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: _PlanCard(
                      plan: _plans[0], cycle: _cycle,
                      isSelected: _selected.name == _plans[0].name,
                      onSelect: () => _selectPlan(_plans[0]),
                      bgController: _bgController,
                    ),
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: _PlanCard(
                      plan: _plans[1], cycle: _cycle,
                      isSelected: _selected.name == _plans[1].name,
                      onSelect: () => _selectPlan(_plans[1]),
                      bgController: _bgController,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: _PlanCard(
                      plan: _plans[2], cycle: _cycle,
                      isSelected: _selected.name == _plans[2].name,
                      onSelect: () => _selectPlan(_plans[2]),
                      bgController: _bgController,
                    ),
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: _PlanCard(
                      plan: _plans[3], cycle: _cycle,
                      isSelected: _selected.name == _plans[3].name,
                      onSelect: () => _selectPlan(_plans[3]),
                      bgController: _bgController,
                    ),
                  )),
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _plans.map((p) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: _PlanCard(
                  plan:        p,
                  cycle:       _cycle,
                  isSelected:  _selected.name == p.name,
                  onSelect:    () => _selectPlan(p),
                  bgController: _bgController,
                ),
              ),
            );
          }).toList(),
        );
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve:  Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: _swapKey, child: grid),
    );
  }

  Widget _buildAddOnCard(bool isMobile) {
    final price = _addOnPlan.priceFor(_cycle);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ButtonBulge(
        hoverScale: 1.02,
        pressedScale: 0.98,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _toggleAddOn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _addOnSelected
                      ? Colors.greenAccent.withOpacity(0.7)
                      : Colors.white.withOpacity(0.08),
                  width: _addOnSelected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block_outlined, size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Ads add-on',
                          style: TextStyle(
                            fontFamily:  'Inter',
                            fontSize:    14.5,
                            fontWeight:  FontWeight.w700,
                            color:       Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Remove ads from your plan',
                          style: TextStyle(
                            fontFamily:  'Inter',
                            fontSize:    12.5,
                            fontWeight:  FontWeight.w400,
                            color:       Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price == 0 ? 'Free' : '₹${price.toStringAsFixed(0)} / mo',
                    style: const TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    14,
                      fontWeight:  FontWeight.w700,
                      color:       Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _addOnSelected ? Colors.greenAccent : Colors.transparent,
                      border: Border.all(
                        color: _addOnSelected
                            ? Colors.greenAccent
                            : Colors.white.withOpacity(0.25),
                        width: 1.4,
                      ),
                    ),
                    child: _addOnSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueBar(bool isMobile) {
    final cycleSuffix = _cycle == BillingCycle.monthly ? '/ mo' : '/ yr';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        ButtonBulge(
          child: AuraButton(
            onPressed: _onContinue,
            auraController: _bgController,
            width: isMobile ? 220 : 200,
            height: 46,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize:      14,
                      fontWeight:    FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Text(
                'Selected: ${_selected.name}'
                    '${_addOnSelected ? ' + No Ads' : ''}'
                    '  •  ₹${_totalDue.toStringAsFixed(0)} $cycleSuffix',
                style: const TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    13,
                  fontWeight:  FontWeight.w600,
                  color:       Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Text(
        'Prices shown in INR (₹). Yearly billing is charged upfront at a 20% '
            'discount versus the monthly rate. Cancel any time from your account settings.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily:  'Inter',
          fontSize:    12.5,
          fontWeight:  FontWeight.w400,
          color:       Colors.white.withOpacity(0.45),
          height:      1.5,
        ),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final PricingPlan         plan;
  final BillingCycle        cycle;
  final bool                isSelected;
  final VoidCallback        onSelect;
  final AnimationController bgController;
  final double?             fullWidth;

  const _PlanCard({
    required this.plan,
    required this.cycle,
    required this.isSelected,
    required this.onSelect,
    required this.bgController,
    this.fullWidth,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.plan.highlighted;

    final cardBody = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isSelected
              ? Colors.greenAccent.withOpacity(0.7)
              : Colors.white.withOpacity(_hovered ? 0.18 : 0.08),
          width: widget.isSelected ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildPrice(),
          const SizedBox(height: 22),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 18),
          _buildFeatures(),
          const SizedBox(height: 26),
          _buildCTA(highlighted),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: highlighted
            ? CirculatingAura(
          controller: widget.bgController,
          borderRadius: 20,
          padding: const EdgeInsets.all(3),
          glowColor: Colors.white,
          accentColor: Colors.greenAccent,
          child: cardBody,
        )
            : cardBody,
      ),
    );
  }

  Widget _buildHeader() {
    const fg = Colors.white;
    final sub = Colors.white.withOpacity(0.6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.plan.icon, color: fg, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.name,
                style: const TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      20,
                  fontWeight:    FontWeight.w700,
                  color:         fg,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.plan.tagline,
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    12,
                  fontWeight:  FontWeight.w400,
                  color:       sub,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        if (widget.plan.highlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.85),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'POPULAR',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    9,
                fontWeight:  FontWeight.w700,
                color:       Colors.black,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrice() {
    final price  = widget.plan.priceFor(widget.cycle);
    const fg     = Colors.white;
    final sub    = Colors.white.withOpacity(0.55);
    final isFree = price == 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isFree ? 'Free' : '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontFamily:    'Inter',
            fontSize:      38,
            fontWeight:    FontWeight.w800,
            color:         fg,
            height:        1.0,
            letterSpacing: -1.0,
          ),
        ),
        if (!isFree) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              ' / mo',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    13,
                fontWeight:  FontWeight.w500,
                color:       sub,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (!isFree && widget.cycle == BillingCycle.yearly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              '−20%',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    10,
                fontWeight:  FontWeight.w700,
                color:       Colors.greenAccent,
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatures() {
    const fg = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.plan.features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check, size: 16, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    13.5,
                    fontWeight:  FontWeight.w400,
                    color:       fg.withOpacity(0.85),
                    height:      1.45,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTA(bool highlighted) {
    if (highlighted) {
      return Center(
        child: ButtonBulge(
          child: AuraButton(
            onPressed: widget.onSelect,
            auraController: widget.bgController,
            width: 180,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.isSelected ? 'Selected' : 'Choose ${widget.plan.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(widget.isSelected ? Icons.check : Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ButtonBulge(
        hoverScale: 1.02,
        pressedScale: 0.97,
        child: AuraButton(
          onPressed: widget.onSelect,
          auraController: widget.bgController,
          outlined: true,
          height: 44,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(_hovered ? 0.6 : 0.28)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            widget.isSelected ? 'Selected' : 'Choose ${widget.plan.name}',
            style: const TextStyle(
              fontFamily:  'Inter',
              fontSize:    13,
              fontWeight:  FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}