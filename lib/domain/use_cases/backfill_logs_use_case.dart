import '../models/drink_log.dart';
import '../models/portion_size.dart';

/// Pure domain use case that generates `DrinkLog` entries for single-day or
/// date-range backfill operations, matching the web application's distribution logic.
class BackfillLogsUseCase {
  const BackfillLogsUseCase();

  /// Generates [count] logs on a single [date].
  List<DrinkLog> generateSingleDay({
    required String drinkId,
    required PortionSize size,
    required int count,
    required DateTime date,
  }) {
    final int safeCount = count.clamp(1, 5000);
    final DateTime noon = DateTime(date.year, date.month, date.day, 12);
    final String dateKey = DrinkLog.formatDateKey(noon);
    final int baseTs = noon.millisecondsSinceEpoch;

    return List<DrinkLog>.generate(safeCount, (int i) {
      return DrinkLog(
        id: 'bf_${baseTs}_${i}_${drinkId}_${size.id}',
        drinkId: drinkId,
        sizeId: size.id,
        ml: size.ml,
        timestamp: baseTs + i * 1000,
        dateKey: dateKey,
        backfilled: true,
      );
    });
  }

  /// Distributes [count] logs evenly across inclusive dates `[startDate, endDate]`.
  List<DrinkLog> generateDateRange({
    required String drinkId,
    required PortionSize size,
    required int count,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final int safeCount = count.clamp(1, 5000);
    DateTime start = DateTime(startDate.year, startDate.month, startDate.day, 12);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day, 12);
    if (end.isBefore(start)) {
      final DateTime tmp = start;
      start = end;
      end = tmp;
    }

    final List<DateTime> days = <DateTime>[];
    DateTime cursor = start;
    while (!cursor.isAfter(end) && days.length <= 3660) {
      days.add(cursor);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1, 12);
    }
    if (days.isEmpty) {
      days.add(start);
    }

    final int totalDays = days.length;
    final List<DrinkLog> generated = <DrinkLog>[];
    for (int i = 0; i < safeCount; i++) {
      final int dayIdx =
          ((i / safeCount) * totalDays).floor().clamp(0, totalDays - 1);
      final DateTime d = days[dayIdx];
      final String dk = DrinkLog.formatDateKey(d);
      final int baseTs = d.millisecondsSinceEpoch;
      generated.add(
        DrinkLog(
          id: 'bfr_${baseTs}_${i}_${drinkId}_${size.id}',
          drinkId: drinkId,
          sizeId: size.id,
          ml: size.ml,
          timestamp: baseTs + i * 500,
          dateKey: dk,
          backfilled: true,
        ),
      );
    }
    return generated;
  }
}
