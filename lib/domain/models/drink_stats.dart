import 'portion_size.dart';

/// Aggregated statistics and container equivalences for a drink or total volume.
class DrinkStats {
  const DrinkStats({
    required this.count,
    required this.ml,
    required this.bySize,
  });

  factory DrinkStats.empty() {
    return const DrinkStats(
      count: 0,
      ml: 0,
      bySize: <String, int>{
        'can_330': 0,
        'bottle_500': 0,
        'bottle_1000': 0,
        'bottle_2000': 0,
      },
    );
  }

  factory DrinkStats.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rawBySize =
        json['bySize'] as Map<String, dynamic>?;
    return DrinkStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      ml: (json['ml'] as num?)?.toInt() ?? 0,
      bySize: <String, int>{
        'can_330': (rawBySize?['can_330'] as num?)?.toInt() ?? 0,
        'bottle_500': (rawBySize?['bottle_500'] as num?)?.toInt() ?? 0,
        'bottle_1000': (rawBySize?['bottle_1000'] as num?)?.toInt() ?? 0,
        'bottle_2000': (rawBySize?['bottle_2000'] as num?)?.toInt() ?? 0,
      },
    );
  }

  final int count;
  final int ml;
  final Map<String, int> bySize;

  /// Equivalence in 330ml standard cans.
  double get cans330Equivalent => ml / 330.0;

  /// Equivalence in 500ml bottles.
  double get bottles500Equivalent => ml / 500.0;

  /// Equivalence in 1L bottles.
  double get bottles1LEquivalent => ml / 1000.0;

  /// Equivalence in 2L bottles.
  double get bottles2LEquivalent => ml / 2000.0;

  DrinkStats increment(PortionSize size) {
    final Map<String, int> updated = Map<String, int>.from(bySize);
    updated[size.id] = (updated[size.id] ?? 0) + 1;
    return DrinkStats(
      count: count + 1,
      ml: ml + size.ml,
      bySize: updated,
    );
  }

  DrinkStats decrement(PortionSize size) {
    final Map<String, int> updated = Map<String, int>.from(bySize);
    final int currentSizeCount = updated[size.id] ?? 0;
    if (currentSizeCount > 0) {
      updated[size.id] = currentSizeCount - 1;
    }
    return DrinkStats(
      count: (count - 1).clamp(0, 1 << 30),
      ml: (ml - size.ml).clamp(0, 1 << 30),
      bySize: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'count': count,
      'ml': ml,
      'bySize': bySize,
    };
  }

  /// Formats a numeric equivalence cleanly (`0`, `1.5`, `12`).
  static String formatEquivalence(double value) {
    if (value <= 0) {
      return '0';
    }
    if (value >= 100) {
      return value.round().toString();
    }
    final double rounded = (value * 10).round() / 10.0;
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(1);
  }

  /// Web-style volume: `0ml`, `660ml`, `4.6L` (fixed [decimals] for liters).
  static String formatVolumeShort(int ml, {int decimals = 1}) {
    if (ml < 1000) {
      return '${ml}ml';
    }
    return '${(ml / 1000.0).toStringAsFixed(decimals)}L';
  }

  /// Formats milliliters into compact human-readable strings (`0ml`, `660ml`, `2.5L`).
  static String formatVolume(int ml) {
    if (ml <= 0) {
      return '0ml';
    }
    if (ml >= 1000) {
      final double liters = ml / 1000.0;
      if (liters == liters.truncateToDouble()) {
        return '${liters.toInt()}L';
      }
      return '${liters.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}L';
    }
    return '${ml}ml';
  }
}
