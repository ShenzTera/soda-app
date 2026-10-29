import 'package:intl/intl.dart';

import '../models/drink_log.dart';
import '../models/drink_spec.dart';
import '../models/portion_size.dart';
import '../models/wrapped_summary.dart';

/// Pure domain use case that computes the 8-slide Soda Wrapped analytics
/// for Weekly, Monthly, and Yearly windows.
class ComputeWrappedUseCase {
  const ComputeWrappedUseCase();

  WrappedSummary execute({
    required List<DrinkLog> allLogs,
    required WrappedPeriod period,
    required int offset,
    DateTime? referenceNow,
  }) {
    final DateTime now = referenceNow ?? DateTime.now();
    late DateTime startDate;
    late DateTime endDate;
    late String periodTitle;
    late String periodSub;

    if (period == WrappedPeriod.weekly) {
      // Monday-start week
      final int diffToMon = now.weekday - DateTime.monday;
      final DateTime monday = DateTime(
        now.year,
        now.month,
        now.day - diffToMon + (offset * 7),
      );
      final DateTime sunday = DateTime(
        monday.year,
        monday.month,
        monday.day + 6,
        23,
        59,
        59,
      );
      startDate = monday;
      endDate = sunday;
      final DateFormat fmt = DateFormat('MMM d');
      periodTitle = offset == 0
          ? 'This Week'
          : offset == -1
              ? 'Last Week'
              : '${fmt.format(monday)} – ${fmt.format(sunday)}';
      periodSub =
          '${fmt.format(monday)} – ${fmt.format(sunday)}, ${sunday.year}';
    } else if (period == WrappedPeriod.monthly) {
      final DateTime mStart = DateTime(now.year, now.month + offset, 1);
      final DateTime mEnd =
          DateTime(mStart.year, mStart.month + 1, 0, 23, 59, 59);
      startDate = mStart;
      endDate = mEnd;
      periodTitle = DateFormat('MMMM yyyy').format(mStart);
      periodSub = offset == 0 ? 'Current Month Recap' : 'Monthly Soda Recap';
    } else {
      final int yr = now.year + offset;
      startDate = DateTime(yr, 1, 1);
      endDate = DateTime(yr, 12, 31, 23, 59, 59);
      periodTitle = '$yr Year Wrapped';
      periodSub = 'Jan 1 – Dec 31, $yr';
    }

    final String startKey = DrinkLog.formatDateKey(startDate);
    final String endKey = DrinkLog.formatDateKey(endDate);

    final List<DrinkLog> logs = allLogs.where((DrinkLog l) {
      return l.dateKey.compareTo(startKey) >= 0 &&
          l.dateKey.compareTo(endKey) <= 0;
    }).toList();

    int totalCount = 0;
    int totalMl = 0;
    final Map<String, int> byDrinkCount = <String, int>{
      'coke': 0,
      'pepsi': 0,
      'dew': 0,
    };
    final Map<String, int> byDrinkMl = <String, int>{
      'coke': 0,
      'pepsi': 0,
      'dew': 0,
    };
    final Map<String, int> bySizeCount = <String, int>{
      'can_330': 0,
      'bottle_500': 0,
      'bottle_1000': 0,
      'bottle_2000': 0,
    };
    final Map<String, int> dayCounts = <String, int>{};

    for (final DrinkLog l in logs) {
      totalCount++;
      totalMl += l.ml;
      byDrinkCount[l.drinkId] = (byDrinkCount[l.drinkId] ?? 0) + 1;
      byDrinkMl[l.drinkId] = (byDrinkMl[l.drinkId] ?? 0) + l.ml;
      bySizeCount[l.sizeId] = (bySizeCount[l.sizeId] ?? 0) + 1;
      dayCounts[l.dateKey] = (dayCounts[l.dateKey] ?? 0) + 1;
    }

    // Top drink by ml (fallback to count)
    String topDrinkId = 'coke';
    int topDrinkMl = -1;
    for (final DrinkSpec spec in DrinkSpec.all) {
      final int ml = byDrinkMl[spec.id] ?? 0;
      if (ml > topDrinkMl) {
        topDrinkMl = ml;
        topDrinkId = spec.id;
      }
    }
    final DrinkSpec topDrink = DrinkSpec.byId(topDrinkId);
    final int topDrinkShare =
        totalMl > 0 ? ((topDrinkMl / totalMl) * 100).round() : 0;

    // Top container size
    String topSizeId = 'can_330';
    int topSizeCount = -1;
    for (final PortionSize sz in PortionSize.all) {
      final int c = bySizeCount[sz.id] ?? 0;
      if (c > topSizeCount) {
        topSizeCount = c;
        topSizeId = sz.id;
      }
    }
    final PortionSize topSize = PortionSize.byId(topSizeId);

    // Active days, busiest day, and longest streak
    final int activeDaysCount = dayCounts.keys.length;
    String? busiestDayKey;
    int busiestDayCount = 0;
    dayCounts.forEach((String k, int c) {
      if (c > busiestDayCount) {
        busiestDayCount = c;
        busiestDayKey = k;
      }
    });

    int longestStreak = 0;
    int currentStreak = 0;
    int totalDaysInPeriod = 0;
    DateTime cursor =
        DateTime(startDate.year, startDate.month, startDate.day, 12);
    final DateTime endNoon =
        DateTime(endDate.year, endDate.month, endDate.day, 12);
    while (!cursor.isAfter(endNoon) && totalDaysInPeriod <= 370) {
      totalDaysInPeriod++;
      final String dk = DrinkLog.formatDateKey(cursor);
      if ((dayCounts[dk] ?? 0) > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1, 12);
    }

    // Sugar & calorie telemetry estimates (~10.6g sugar & ~42 kcal per 100ml)
    final int sugarGrams = ((totalMl / 100.0) * 10.6).round();
    final int sugarTeaspoons = (sugarGrams / 4.2).round();
    final int calories = ((totalMl / 100.0) * 42.0).round();

    // Equivalences
    final double equivCans = totalMl / 330.0;
    final double equiv500 = totalMl / 500.0;
    final double equiv1L = totalMl / 1000.0;
    final double equiv2L = totalMl / 2000.0;

    // Persona assignment
    String personaTitle = 'The Casual Sipper';
    String personaBadge = 'ICE COLD NOVICE';
    String personaSub =
        'You enjoy a crisp carbonation hit without letting the fizz take over.';
    if (equivCans >= 100) {
      personaTitle = 'Supreme Fizz Overlord';
      personaBadge = 'CARBONATION ROYALTY';
      personaSub =
          'Your bloodstream is practically carbonated. Aluminum recycling plants know you by name.';
    } else if (equivCans >= 30) {
      personaTitle = 'Hardcore Fizz Connoisseur';
      personaBadge = 'CERTIFIED ADDICT';
      personaSub = 'Unstoppable pop-tab reflexes. ${topDrink.name} runs the show.';
    } else if (equivCans >= 10) {
      personaTitle = 'Rhythm Carbonator';
      personaBadge = 'STEADY SIPPER';
      personaSub =
          'Balanced, deliberate, and loyal to ${topDrink.name} whenever cravings hit.';
    } else if (totalCount == 0) {
      personaTitle = 'Zero-Fizz Monk';
      personaBadge = 'PURE HYDRATION';
      personaSub =
          'Not a single drop logged in this window. Log or backfill cans to unlock your full Wrapped!';
    }

    // Timeline buckets
    final List<WrappedBucket> buckets = _buildBuckets(
      period: period,
      startDate: startDate,
      endDate: endDate,
      logs: logs,
      dayCounts: dayCounts,
    );

    return WrappedSummary(
      period: period,
      offset: offset,
      periodTitle: periodTitle,
      periodSub: periodSub,
      totalCount: totalCount,
      totalMl: totalMl,
      equivCans: equivCans,
      equiv500: equiv500,
      equiv1L: equiv1L,
      equiv2L: equiv2L,
      byDrinkCount: byDrinkCount,
      byDrinkMl: byDrinkMl,
      bySizeCount: bySizeCount,
      topDrink: topDrink,
      topDrinkShare: topDrinkShare,
      topSize: topSize,
      activeDaysCount: activeDaysCount,
      totalDaysInPeriod: totalDaysInPeriod,
      longestStreak: longestStreak,
      busiestDayKey: busiestDayKey,
      busiestDayCount: busiestDayCount,
      sugarGrams: sugarGrams,
      sugarTeaspoons: sugarTeaspoons,
      calories: calories,
      personaTitle: personaTitle,
      personaBadge: personaBadge,
      personaSub: personaSub,
      buckets: buckets,
    );
  }

  List<WrappedBucket> _buildBuckets({
    required WrappedPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required List<DrinkLog> logs,
    required Map<String, int> dayCounts,
  }) {
    final List<WrappedBucket> buckets = <WrappedBucket>[];
    if (period == WrappedPeriod.weekly) {
      const List<String> names = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      for (int i = 0; i < 7; i++) {
        final DateTime d = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + i,
          12,
        );
        final String dk = DrinkLog.formatDateKey(d);
        final int dayMl = logs
            .where((DrinkLog l) => l.dateKey == dk)
            .fold<int>(0, (int sum, DrinkLog l) => sum + l.ml);
        buckets.add(
          WrappedBucket(
            label: names[i],
            count: dayCounts[dk] ?? 0,
            ml: dayMl,
          ),
        );
      }
    } else if (period == WrappedPeriod.monthly) {
      final List<WrappedBucket> weeks = List<WrappedBucket>.generate(
        5,
        (int i) => WrappedBucket(label: 'W${i + 1}', count: 0, ml: 0),
      );
      for (final DrinkLog l in logs) {
        final DateTime dt = DrinkLog.parseDateKey(l.dateKey);
        final int idx = ((dt.day - 1) ~/ 7).clamp(0, 4);
        final WrappedBucket current = weeks[idx];
        weeks[idx] = WrappedBucket(
          label: current.label,
          count: current.count + 1,
          ml: current.ml + l.ml,
        );
      }
      buckets.addAll(weeks);
    } else {
      const List<String> mNames = <String>[
        'J',
        'F',
        'M',
        'A',
        'M',
        'J',
        'J',
        'A',
        'S',
        'O',
        'N',
        'D',
      ];
      final List<WrappedBucket> months = List<WrappedBucket>.generate(
        12,
        (int i) => WrappedBucket(label: mNames[i], count: 0, ml: 0),
      );
      for (final DrinkLog l in logs) {
        final DateTime dt = DrinkLog.parseDateKey(l.dateKey);
        final int mIdx = (dt.month - 1).clamp(0, 11);
        final WrappedBucket current = months[mIdx];
        months[mIdx] = WrappedBucket(
          label: current.label,
          count: current.count + 1,
          ml: current.ml + l.ml,
        );
      }
      buckets.addAll(months);
    }
    return buckets;
  }
}
