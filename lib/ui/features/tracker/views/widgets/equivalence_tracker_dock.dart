import 'package:flutter/material.dart';

import '../../../../../domain/models/drink_spec.dart';
import '../../../../../domain/models/drink_stats.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

/// Bottom "Total Cans & Bottles Tracker" dock, matching the web layout.
class EquivalenceTrackerDock extends StatelessWidget {
  const EquivalenceTrackerDock({
    super.key,
    required this.activeDrinkId,
    required this.cokeStats,
    required this.pepsiStats,
    required this.dewStats,
    required this.totalStats,
    required this.onSelectDrink,
    required this.onOpenAllZoom,
  });

  final String activeDrinkId;
  final DrinkStats cokeStats;
  final DrinkStats pepsiStats;
  final DrinkStats dewStats;
  final DrinkStats totalStats;
  final ValueChanged<String> onSelectDrink;
  final VoidCallback onOpenAllZoom;

  @override
  Widget build(BuildContext context) {
    final List<({DrinkSpec spec, DrinkStats stats})> items =
        <({DrinkSpec spec, DrinkStats stats})>[
      (spec: DrinkSpec.coke, stats: cokeStats),
      (spec: DrinkSpec.pepsi, stats: pepsiStats),
      (spec: DrinkSpec.dew, stats: dewStats),
    ];

    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
      backgroundColor: Colors.black.withValues(alpha: 0.38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: onOpenAllZoom,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.bar_chart_rounded,
                      size: 12, color: Color(0xFF5EEAD4)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TOTAL CANS & BOTTLES TRACKER',
                        style: AppTheme.monoStyle(
                          fontSize: 8.5,
                          color: Colors.white70,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'All: ≈ ${DrinkStats.formatEquivalence(totalStats.cans330Equivalent)} Cans • ${DrinkStats.formatEquivalence(totalStats.bottles500Equivalent)} Btls',
                      style: AppTheme.monoStyle(
                        fontSize: 8.5,
                        color: const Color(0xFF5EEAD4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              for (final ({DrinkSpec spec, DrinkStats stats}) item in items)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: _Card(
                      spec: item.spec,
                      stats: item.stats,
                      isActive: activeDrinkId == item.spec.id,
                      onTap: () => onSelectDrink(item.spec.id),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.spec,
    required this.stats,
    required this.isActive,
    required this.onTap,
  });

  final DrinkSpec spec;
  final DrinkStats stats;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isActive ? 0.16 : 0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: spec.secondaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      spec.shortName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  DrinkStats.formatVolumeShort(stats.ml, decimals: 2),
                  style: AppTheme.monoStyle(
                    fontSize: 8.5,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  const Text('🥫', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    '${DrinkStats.formatEquivalence(stats.cans330Equivalent)} can',
                    style: AppTheme.monoStyle(
                      fontSize: 9.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🍾', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    '${DrinkStats.formatEquivalence(stats.bottles500Equivalent)} btl',
                    style: AppTheme.monoStyle(
                      fontSize: 9.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
