import 'package:flutter/material.dart';

import '../../../../../domain/models/drink_stats.dart';
import '../../../../../domain/models/portion_size.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

/// Top floating glass header matching the web layout: brand + Today/Life on
/// row one, size pills + round action buttons on row two.
class GlassHeaderBar extends StatelessWidget {
  const GlassHeaderBar({
    super.key,
    required this.totalToday,
    required this.totalLifetime,
    required this.selectedSize,
    required this.canUndo,
    required this.onSelectSize,
    required this.onUndo,
    required this.onOpenHistory,
    required this.onOpenCalendar,
    required this.onOpenWrapped,
    required this.onOpenReset,
  });

  final DrinkStats totalToday;
  final DrinkStats totalLifetime;
  final PortionSize selectedSize;
  final bool canUndo;
  final ValueChanged<String> onSelectSize;
  final VoidCallback onUndo;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenWrapped;
  final VoidCallback onOpenReset;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "JAMAL'S ADDICTION",
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Metric(
                label: 'TODAY',
                value: '${totalToday.count}',
                sub: '(${DrinkStats.formatVolumeShort(totalToday.ml)})',
                subColor: Colors.white70,
              ),
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white.withValues(alpha: 0.15),
              ),
              _Metric(
                label: 'LIFE',
                value: '${totalLifetime.count}',
                sub: '(${DrinkStats.formatVolumeShort(totalLifetime.ml)})',
                subColor: const Color(0xFF5EEAD4),
              ),
              const SizedBox(width: 8),
              _CircleBtn(icon: Icons.refresh_rounded, onTap: onOpenReset),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: PortionSize.all.map((PortionSize size) {
                      final bool active = size.id == selectedSize.id;
                      return GestureDetector(
                        onTap: () => onSelectSize(size.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            size.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.black : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Opacity(
                opacity: canUndo ? 1 : 0.4,
                child: _CircleBtn(icon: Icons.undo_rounded, onTap: onUndo),
              ),
              const SizedBox(width: 5),
              _CircleBtn(icon: Icons.add_rounded, onTap: onOpenHistory),
              const SizedBox(width: 5),
              _CircleBtn(
                icon: Icons.calendar_today_rounded,
                onTap: onOpenCalendar,
              ),
              const SizedBox(width: 5),
              _CircleBtn(
                icon: Icons.auto_awesome_rounded,
                onTap: onOpenWrapped,
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFEC4899), Color(0xFFF97316)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  final String label;
  final String value;
  final String sub;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' $sub',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.gradient});

  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? Colors.white.withValues(alpha: 0.12) : null,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
