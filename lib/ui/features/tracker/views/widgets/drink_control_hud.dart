import 'package:flutter/material.dart';

import '../../../../../domain/models/drink_spec.dart';
import '../../../../../domain/models/drink_stats.dart';
import '../../../../../domain/models/portion_size.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

/// Compact glass HUD bar inside the expanded drink slice. Scales down to
/// fit its panel so it can never overflow.
class DrinkControlHud extends StatelessWidget {
  const DrinkControlHud({
    super.key,
    required this.spec,
    required this.selectedSize,
    required this.todayStats,
    required this.lifetimeStats,
    required this.onIncrement,
    required this.onDecrement,
    required this.onOpenZoom,
  });

  final DrinkSpec spec;
  final PortionSize selectedSize;
  final DrinkStats todayStats;
  final DrinkStats lifetimeStats;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onOpenZoom;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      backgroundColor: Colors.black.withValues(alpha: 0.38),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Stat(
              label: 'TODAY',
              count: todayStats.count,
              sub: DrinkStats.formatVolumeShort(todayStats.ml),
              subColor: Colors.white70,
            ),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            _Stat(
              label: 'LIFE',
              count: lifetimeStats.count,
              sub: DrinkStats.formatVolumeShort(lifetimeStats.ml),
              subColor: const Color(0xFF5EEAD4),
            ),
            const SizedBox(width: 10),
            _RoundIcon(icon: Icons.remove_rounded, onTap: onDecrement),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.add_rounded, size: 15, color: Colors.black),
                    const SizedBox(width: 3),
                    Text(
                      'Log ${selectedSize.label}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            _RoundIcon(icon: Icons.open_in_full_rounded, onTap: onOpenZoom),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.count,
    required this.sub,
    required this.subColor,
  });

  final String label;
  final int count;
  final String sub;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTheme.monoStyle(
            fontSize: 8,
            color: Colors.white54,
            letterSpacing: 0.8,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              sub,
              style: AppTheme.monoStyle(
                fontSize: 9.5,
                color: subColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
