import 'drink_spec.dart';
import 'portion_size.dart';

/// Time period selector for Soda Wrapped.
enum WrappedPeriod {
  weekly,
  monthly,
  yearly;

  String get label {
    switch (this) {
      case WrappedPeriod.weekly:
        return 'Weekly';
      case WrappedPeriod.monthly:
        return 'Monthly';
      case WrappedPeriod.yearly:
        return 'Yearly';
    }
  }
}

/// Single bar in the Soda Wrapped timeline slide.
class WrappedBucket {
  const WrappedBucket({
    required this.label,
    required this.count,
    required this.ml,
  });

  final String label;
  final int count;
  final int ml;
}

/// Complete computed analytics for the 8-slide Soda Wrapped story deck.
class WrappedSummary {
  const WrappedSummary({
    required this.period,
    required this.offset,
    required this.periodTitle,
    required this.periodSub,
    required this.totalCount,
    required this.totalMl,
    required this.equivCans,
    required this.equiv500,
    required this.equiv1L,
    required this.equiv2L,
    required this.byDrinkCount,
    required this.byDrinkMl,
    required this.bySizeCount,
    required this.topDrink,
    required this.topDrinkShare,
    required this.topSize,
    required this.activeDaysCount,
    required this.totalDaysInPeriod,
    required this.longestStreak,
    required this.busiestDayKey,
    required this.busiestDayCount,
    required this.sugarGrams,
    required this.sugarTeaspoons,
    required this.calories,
    required this.personaTitle,
    required this.personaBadge,
    required this.personaSub,
    required this.buckets,
  });

  final WrappedPeriod period;
  final int offset;
  final String periodTitle;
  final String periodSub;
  final int totalCount;
  final int totalMl;
  final double equivCans;
  final double equiv500;
  final double equiv1L;
  final double equiv2L;
  final Map<String, int> byDrinkCount;
  final Map<String, int> byDrinkMl;
  final Map<String, int> bySizeCount;
  final DrinkSpec topDrink;
  final int topDrinkShare;
  final PortionSize topSize;
  final int activeDaysCount;
  final int totalDaysInPeriod;
  final int longestStreak;
  final String? busiestDayKey;
  final int busiestDayCount;
  final int sugarGrams;
  final int sugarTeaspoons;
  final int calories;
  final String personaTitle;
  final String personaBadge;
  final String personaSub;
  final List<WrappedBucket> buckets;
}
