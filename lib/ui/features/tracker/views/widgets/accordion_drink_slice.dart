import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../domain/models/drink_spec.dart';
import '../../../../../domain/models/drink_stats.dart';
import '../../../../../domain/models/portion_size.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/rotated_vertical_text.dart';
import 'drink_control_hud.dart';

/// Individual slice in the 3-panel horizontal accordion showcase.
class AccordionDrinkSlice extends StatefulWidget {
  const AccordionDrinkSlice({
    super.key,
    required this.spec,
    required this.isExpanded,
    required this.selectedSize,
    required this.todayStats,
    required this.lifetimeStats,
    required this.pulseTick,
    required this.topInset,
    required this.bottomInset,
    required this.onTapCollapsed,
    required this.onIncrement,
    required this.onDecrement,
    required this.onOpenZoom,
  });

  final DrinkSpec spec;
  final bool isExpanded;
  final PortionSize selectedSize;
  final DrinkStats todayStats;
  final DrinkStats lifetimeStats;
  final int pulseTick;
  final double topInset;
  final double bottomInset;
  final VoidCallback onTapCollapsed;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onOpenZoom;

  @override
  State<AccordionDrinkSlice> createState() => _AccordionDrinkSliceState();
}

class _AccordionDrinkSliceState extends State<AccordionDrinkSlice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  int _handledPulseTick = 0;
  double _popBoost = 1.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AccordionDrinkSlice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseTick != _handledPulseTick && widget.pulseTick > 0) {
      _handledPulseTick = widget.pulseTick;
      setState(() => _popBoost = 1.08);
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (mounted) {
          setState(() => _popBoost = 1.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DrinkSpec spec = widget.spec;
    final bool isExpanded = widget.isExpanded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isExpanded ? null : widget.onTapCollapsed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isExpanded
                ? spec.expandedGradientColors
                : spec.collapsedGradientColors,
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final double h = box.maxHeight;
            final double canH = h * 0.30;
            final double miniH = h * 0.085;

            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                // Expanded: centered title + can + soft floor shadow
                IgnorePointer(
                  ignoring: !isExpanded,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 320),
                    opacity: isExpanded ? 1.0 : 0.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned(
                          top: widget.topInset + 2,
                          left: 6,
                          right: 6,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              spec.name,
                              maxLines: 1,
                              style: AppTheme.syneStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.02),
                          child: GestureDetector(
                            onTap: widget.onOpenZoom,
                            child: AnimatedBuilder(
                              animation: _floatController,
                              builder: (BuildContext context, Widget? child) {
                                final double wave =
                                    math.sin(_floatController.value * math.pi);
                                return Transform.translate(
                                  offset: Offset(0, -6.0 * wave),
                                  child: child,
                                );
                              },
                              child: AnimatedScale(
                                scale: _popBoost,
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Hero(
                                      tag: 'can_hero_${spec.id}',
                                      child: Image.asset(
                                        spec.assetPath,
                                        height: canH,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                    Container(
                                      width: canH * 0.55,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.35),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: widget.bottomInset + 4,
                          child: DrinkControlHud(
                            spec: spec,
                            selectedSize: widget.selectedSize,
                            todayStats: widget.todayStats,
                            lifetimeStats: widget.lifetimeStats,
                            onIncrement: widget.onIncrement,
                            onDecrement: widget.onDecrement,
                            onOpenZoom: widget.onOpenZoom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsed: top rotated label + count pill, small can lower
                IgnorePointer(
                  ignoring: isExpanded,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    opacity: isExpanded ? 0.0 : 1.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned(
                          top: widget.topInset + 6,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: <Widget>[
                              RotatedVerticalText(
                                text: spec.name,
                                style: AppTheme.syneStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '${widget.todayStats.count}',
                                  style: AppTheme.monoStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.30),
                          child: Image.asset(
                            spec.assetPath,
                            height: miniH,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
