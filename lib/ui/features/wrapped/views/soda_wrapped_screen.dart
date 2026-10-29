import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../../../../domain/models/portion_size.dart';
import '../../../../domain/models/wrapped_summary.dart';
import '../../../core/theme/app_theme.dart';
import '../../tracker/view_models/tracker_view_model.dart';

/// Spotify-Wrapped-inspired 8-slide story experience (`/wrapped`) with
/// Weekly, Monthly, and Yearly tabs, auto-advancing story progress bars,
/// tap left/right navigation, and animated count-up telemetry.
class SodaWrappedScreen extends StatefulWidget {
  const SodaWrappedScreen({
    super.key,
    this.initialPeriod = WrappedPeriod.yearly,
  });

  final WrappedPeriod initialPeriod;

  @override
  State<SodaWrappedScreen> createState() => _SodaWrappedScreenState();
}

class _SodaWrappedScreenState extends State<SodaWrappedScreen>
    with SingleTickerProviderStateMixin {
  static const int _slideCount = 8;
  static const Duration _slideDuration = Duration(milliseconds: 6500);

  late WrappedPeriod _period;
  int _offset = 0;
  int _currentSlide = 0;
  late final PageController _pageController;
  late final AnimationController _storyTimerController;

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
    _pageController = PageController();
    _storyTimerController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _nextSlide();
        }
      });
    _storyTimerController.forward();
  }

  @override
  void dispose() {
    _storyTimerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    final int clamped = index.clamp(0, _slideCount - 1);
    setState(() => _currentSlide = clamped);
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
    _storyTimerController
      ..reset()
      ..forward();
  }

  void _nextSlide() {
    if (_currentSlide < _slideCount - 1) {
      _goToSlide(_currentSlide + 1);
    } else {
      _storyTimerController.stop();
    }
  }

  void _prevSlide() {
    if (_currentSlide > 0) {
      _goToSlide(_currentSlide - 1);
    } else {
      _storyTimerController
        ..reset()
        ..forward();
    }
  }

  void _changePeriod(WrappedPeriod nextPeriod) {
    setState(() {
      _period = nextPeriod;
      _offset = 0;
    });
    _goToSlide(0);
  }

  void _stepOffset(int delta) {
    setState(() {
      _offset = (_offset + delta).clamp(-52, 0);
    });
    _goToSlide(0);
  }

  List<Color> _slideGradient(int slideIndex, DrinkSpec topDrink) {
    switch (slideIndex) {
      case 0:
        return const <Color>[
          Color(0xFF1A0526),
          Color(0xFF0A1931),
          Color(0xFF052E16),
        ];
      case 1:
        return const <Color>[
          Color(0xFF3B0764),
          Color(0xFF1E1B4B),
          Color(0xFF090D16),
        ];
      case 2:
        return topDrink.expandedGradientColors;
      case 3:
        return const <Color>[
          Color(0xFF0F172A),
          Color(0xFF1E293B),
          Color(0xFF090D16),
        ];
      case 4:
        return const <Color>[
          Color(0xFF042F2E),
          Color(0xFF064E3B),
          Color(0xFF04070D),
        ];
      case 5:
        return const <Color>[
          Color(0xFF450A0A),
          Color(0xFF1E1B4B),
          Color(0xFF050811),
        ];
      case 6:
        return const <Color>[
          Color(0xFF31102F),
          Color(0xFF0F172A),
          Color(0xFF052E16),
        ];
      default:
        return <Color>[
          topDrink.expandedGradientColors.first,
          const Color(0xFF0B132B),
          const Color(0xFF05070C),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.watch<TrackerViewModel>();
    final WrappedSummary summary = viewModel.computeWrapped(
      period: _period,
      offset: _offset,
    );
    final List<Color> bgColors =
        _slideGradient(_currentSlide, summary.topDrink);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 860),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgColors,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: <Widget>[
                    // 1. Segmented Story Progress Bars
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: AnimatedBuilder(
                        animation: _storyTimerController,
                        builder: (BuildContext context, _) {
                          return Row(
                            children: List<Widget>.generate(_slideCount,
                                (int i) {
                              double fill = 0.0;
                              if (i < _currentSlide) {
                                fill = 1.0;
                              } else if (i == _currentSlide) {
                                fill = _storyTimerController.value;
                              }
                              return Expanded(
                                child: Container(
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.24),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: fill,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                    // 2. Period Selector Tabs (Weekly | Monthly | Yearly) + Offset Nav
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: <Widget>[
                          for (final WrappedPeriod p in WrappedPeriod.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                onTap: () => _changePeriod(p),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _period == p
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    p.label,
                                    style: AppTheme.monoStyle(
                                      fontSize: 10,
                                      color: _period == p
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _stepOffset(-1),
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed:
                                _offset < 0 ? () => _stepOffset(1) : null,
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: _offset < 0
                                  ? Colors.white
                                  : Colors.white24,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Story Slide Deck with Left/Right Tap Zones
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPressStart: (_) => _storyTimerController.stop(),
                        onLongPressEnd: (_) => _storyTimerController.forward(),
                        onTapUp: (TapUpDetails details) {
                          final double width = context.size?.width ?? 400;
                          if (details.localPosition.dx < width * 0.33) {
                            _prevSlide();
                          } else {
                            _nextSlide();
                          }
                        },
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (int index) {
                            setState(() => _currentSlide = index);
                            _storyTimerController
                              ..reset()
                              ..forward();
                          },
                          children: <Widget>[
                            _Slide0Intro(summary: summary),
                            _Slide1TotalDamage(summary: summary),
                            _Slide2TopObsession(summary: summary),
                            _Slide3BrandBreakdown(summary: summary),
                            _Slide4Timeline(summary: summary),
                            _Slide5Streaks(summary: summary),
                            _Slide6SugarAndVessel(summary: summary),
                            _Slide7PersonaCard(
                              summary: summary,
                              onReplay: () => _goToSlide(0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Footer Prev / Next controls
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: _currentSlide > 0 ? _prevSlide : null,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13,
                            ),
                            label: const Text('Prev'),
                          ),
                          Text(
                            '${_currentSlide + 1} / $_slideCount · ${summary.periodTitle}',
                            style: AppTheme.monoStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _currentSlide < _slideCount - 1
                                ? _nextSlide
                                : () => _goToSlide(0),
                            icon: Icon(
                              _currentSlide < _slideCount - 1
                                  ? Icons.arrow_forward_ios_rounded
                                  : Icons.replay_rounded,
                              size: 13,
                            ),
                            label: Text(
                              _currentSlide < _slideCount - 1
                                  ? 'Next'
                                  : 'Replay',
                            ),
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
      ),
    );
  }
}

class _Slide0Intro extends StatelessWidget {
  const _Slide0Intro({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "JAMAL'S ADDICTION PRESENTS",
              style: AppTheme.monoStyle(fontSize: 10, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: DrinkSpec.all.map((DrinkSpec d) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Image.asset(d.assetPath, height: 95),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text(
            'SODA\nWRAPPED',
            textAlign: TextAlign.center,
            style: AppTheme.syneStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 0.98,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary.periodTitle.toUpperCase(),
            style: AppTheme.monoStyle(
              fontSize: 14,
              color: const Color(0xFFB8FF01),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.periodSub,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Slide1TotalDamage extends StatelessWidget {
  const _Slide1TotalDamage({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'TOTAL FIZZ CONSUMED',
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: const Color(0xFF38BDF8),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: summary.totalCount.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double val, _) {
              return Text(
                '${val.round()}',
                style: AppTheme.syneStyle(
                  fontSize: 74,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
          Text(
            'Drinks Logged · ${DrinkStats.formatVolume(summary.totalMl)}',
            style: AppTheme.monoStyle(fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _WrappedStatPill(
                label: '330ml Cans',
                value: '🥫 ${DrinkStats.formatEquivalence(summary.equivCans)}',
              ),
              _WrappedStatPill(
                label: '500ml Bottles',
                value: '🍾 ${DrinkStats.formatEquivalence(summary.equiv500)}',
              ),
              _WrappedStatPill(
                label: '1L Bottles',
                value: '🍶 ${DrinkStats.formatEquivalence(summary.equiv1L)}',
              ),
              _WrappedStatPill(
                label: '2L Bottles',
                value: '🫗 ${DrinkStats.formatEquivalence(summary.equiv2L)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slide2TopObsession extends StatelessWidget {
  const _Slide2TopObsession({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    final DrinkSpec top = summary.topDrink;
    final int topCount = summary.byDrinkCount[top.id] ?? 0;
    final int topMl = summary.byDrinkMl[top.id] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'YOUR #1 OBSESSION',
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Image.asset(top.assetPath, height: 170),
          const SizedBox(height: 16),
          Text(
            top.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTheme.syneStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${summary.topDrinkShare}% of your total volume · $topCount drinks (${DrinkStats.formatVolume(topMl)})',
            textAlign: TextAlign.center,
            style: AppTheme.monoStyle(fontSize: 11.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Slide3BrandBreakdown extends StatelessWidget {
  const _Slide3BrandBreakdown({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'THE COLA WARS BREAKDOWN',
            textAlign: TextAlign.center,
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: const Color(0xFFB8FF01),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          for (final DrinkSpec spec in DrinkSpec.all) ...<Widget>[
            Builder(
              builder: (BuildContext context) {
                final int count = summary.byDrinkCount[spec.id] ?? 0;
                final int ml = summary.byDrinkMl[spec.id] ?? 0;
                final double ratio = summary.totalMl > 0
                    ? (ml / summary.totalMl).clamp(0.0, 1.0)
                    : 0.0;
                final int pct = (ratio * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            spec.name,
                            style: AppTheme.syneStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '$count · ${DrinkStats.formatVolume(ml)} ($pct%)',
                            style: AppTheme.monoStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            spec.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Slide4Timeline extends StatelessWidget {
  const _Slide4Timeline({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    int maxCount = 1;
    for (final WrappedBucket b in summary.buckets) {
      if (b.count > maxCount) {
        maxCount = b.count;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'SIP-BY-SIP RHYTHM',
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: const Color(0xFF38BDF8),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.periodTitle,
            style: AppTheme.syneStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: summary.buckets.map((WrappedBucket b) {
                final double factor =
                    (b.count / maxCount).clamp(0.06, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${b.count}',
                          style: AppTheme.monoStyle(
                            fontSize: 9.5,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: factor,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      summary.topDrink.secondaryAccent,
                                      summary.topDrink.accentColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.label,
                          style: AppTheme.monoStyle(
                            fontSize: 9.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide5Streaks extends StatelessWidget {
  const _Slide5Streaks({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'CONSISTENCY & STREAKS',
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: const Color(0xFFB8FF01),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _WrappedStatPill(
            label: 'Soda Days Logged',
            value:
                '${summary.activeDaysCount} / ${summary.totalDaysInPeriod} days',
          ),
          const SizedBox(height: 12),
          _WrappedStatPill(
            label: 'Longest Fizz Streak',
            value: '🔥 ${summary.longestStreak} consecutive days',
          ),
          const SizedBox(height: 12),
          _WrappedStatPill(
            label: 'Peak Soda Day',
            value: summary.busiestDayKey != null
                ? '${summary.busiestDayKey} (${summary.busiestDayCount} drinks)'
                : 'No peak day yet',
          ),
        ],
      ),
    );
  }
}

class _Slide6SugarAndVessel extends StatelessWidget {
  const _Slide6SugarAndVessel({required this.summary});

  final WrappedSummary summary;

  @override
  Widget build(BuildContext context) {
    final PortionSize favSize = summary.topSize;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'VESSEL & SUGAR TELEMETRY',
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: const Color(0xFF38BDF8),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            favSize.emoji,
            style: const TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 6),
          Text(
            'Go-To Size: ${favSize.name} (${favSize.label})',
            textAlign: TextAlign.center,
            style: AppTheme.syneStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _WrappedStatPill(
            label: 'Estimated Sugar Rush',
            value:
                '🍬 ${summary.sugarGrams}g (≈ ${summary.sugarTeaspoons} tsp)',
          ),
          const SizedBox(height: 10),
          _WrappedStatPill(
            label: 'Estimated Energy',
            value: '⚡ ${summary.calories} kcal',
          ),
        ],
      ),
    );
  }
}

class _Slide7PersonaCard extends StatelessWidget {
  const _Slide7PersonaCard({
    required this.summary,
    required this.onReplay,
  });

  final WrappedSummary summary;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  summary.personaBadge,
                  style: AppTheme.monoStyle(
                    fontSize: 10,
                    color: const Color(0xFFB8FF01),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.personaTitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.syneStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.personaSub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const Divider(height: 24, color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _MiniKpi(
                      label: 'DRINKS',
                      value: '${summary.totalCount}',
                    ),
                    _MiniKpi(
                      label: 'VOLUME',
                      value: DrinkStats.formatVolume(summary.totalMl),
                    ),
                    _MiniKpi(
                      label: '330ML CANS',
                      value: DrinkStats.formatEquivalence(summary.equivCans),
                    ),
                    _MiniKpi(
                      label: 'TOP SODA',
                      value: summary.topDrink.shortName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onReplay,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text(
              'Replay Soda Wrapped',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _WrappedStatPill extends StatelessWidget {
  const _WrappedStatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          Text(
            value,
            style: AppTheme.monoStyle(fontSize: 12.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: AppTheme.monoStyle(fontSize: 8.5, color: Colors.white54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.syneStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
