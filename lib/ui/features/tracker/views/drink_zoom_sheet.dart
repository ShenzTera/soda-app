import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../../../../domain/models/portion_size.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../view_models/tracker_view_model.dart';

/// Close-Up Interactive Zoom Sheet (`/zoom/:drinkId`) showing studio can hero,
/// Today vs. Lifetime stats, 4-size equivalence grid, and portion breakdown.
class DrinkZoomSheet extends StatelessWidget {
  const DrinkZoomSheet({
    super.key,
    required this.drinkId,
  });

  final String drinkId;

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.watch<TrackerViewModel>();
    final DrinkSpec spec = DrinkSpec.byId(drinkId);
    final DrinkStats todayStats = viewModel.todayStatsFor(spec.id);
    final DrinkStats lifeStats = viewModel.lifetimeStatsFor(spec.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xEB080B12),
                borderColor: spec.accentColor.withValues(alpha: 0.45),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header bar
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: spec.accentColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: spec.accentColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              '${spec.indexLabel} · ${spec.badge}',
                              style: AppTheme.monoStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // Hero Can + Brand Info
                      SizedBox(
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    spec.accentColor.withValues(alpha: 0.45),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Hero(
                              tag: 'can_hero_${spec.id}',
                              child: Image.asset(
                                spec.assetPath,
                                height: 195,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spec.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTheme.syneStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Today vs Lifetime cards
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _MetricCard(
                              title: 'TODAY',
                              value: '${todayStats.count}',
                              sub: DrinkStats.formatVolume(todayStats.ml),
                              accent: spec.accentColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              title: 'LIFETIME',
                              value: '${lifeStats.count}',
                              sub: DrinkStats.formatVolume(lifeStats.ml),
                              accent: spec.secondaryAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Total Volume Equivalence Grid (How many cans or bottles it equals)
                      Text(
                        'TOTAL VOLUME EQUIVALENCE (${DrinkStats.formatVolume(lifeStats.ml)})',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _EquivTile(
                              emoji: '🥫',
                              value: DrinkStats.formatEquivalence(
                                lifeStats.cans330Equivalent,
                              ),
                              label: '330ml Cans',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _EquivTile(
                              emoji: '🍾',
                              value: DrinkStats.formatEquivalence(
                                lifeStats.bottles500Equivalent,
                              ),
                              label: '500ml Btls',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _EquivTile(
                              emoji: '🍶',
                              value: DrinkStats.formatEquivalence(
                                lifeStats.bottles1LEquivalent,
                              ),
                              label: '1L Bottles',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _EquivTile(
                              emoji: '🫗',
                              value: DrinkStats.formatEquivalence(
                                lifeStats.bottles2LEquivalent,
                              ),
                              label: '2L Bottles',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Portion Size Selector inside Zoom Sheet
                      Text(
                        'ACTIVE PORTION SIZE & LOGGED BREAKDOWN',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PortionSize.all.map((PortionSize size) {
                          final bool selected =
                              viewModel.selectedSizeId == size.id;
                          final int loggedCount =
                              lifeStats.bySize[size.id] ?? 0;
                          return GestureDetector(
                            onTap: () => viewModel.selectSize(size.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? spec.accentColor.withValues(alpha: 0.28)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? spec.accentColor
                                      : Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(size.emoji),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${size.label} · ×$loggedCount',
                                    style: AppTheme.monoStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Log / Remove action row
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  viewModel.removeDrinkToday(spec.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.24),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              label: const Text('Remove Today'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => viewModel.logDrink(spec.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: spec.accentColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(
                                'Log +1 (${viewModel.selectedSize.label})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.accent,
  });

  final String title;
  final String value;
  final String sub;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTheme.monoStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.syneStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sub,
            style: AppTheme.monoStyle(
              fontSize: 11,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquivTile extends StatelessWidget {
  const _EquivTile({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTheme.syneStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.monoStyle(
              fontSize: 8.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
