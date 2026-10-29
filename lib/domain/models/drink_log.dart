/// Single logged soda consumption entry.
class DrinkLog {
  const DrinkLog({
    required this.id,
    required this.drinkId,
    required this.sizeId,
    required this.ml,
    required this.timestamp,
    required this.dateKey,
    this.backfilled = false,
  });

  final String id;
  final String drinkId;
  final String sizeId;
  final int ml;
  final int timestamp;
  final String dateKey;
  final bool backfilled;

  factory DrinkLog.fromJson(Map<String, dynamic> json) {
    final int ts = (json['timestamp'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    final String rawDateKey = json['dateKey'] as String? ?? '';
    return DrinkLog(
      id: json['id'] as String? ?? 'log_$ts',
      drinkId: json['drinkId'] as String? ?? 'coke',
      sizeId: json['sizeId'] as String? ?? 'can_330',
      ml: (json['ml'] as num?)?.toInt() ?? 330,
      timestamp: ts,
      dateKey: rawDateKey.isNotEmpty
          ? rawDateKey
          : formatDateKey(DateTime.fromMillisecondsSinceEpoch(ts)),
      backfilled: json['backfilled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'drinkId': drinkId,
      'sizeId': sizeId,
      'ml': ml,
      'timestamp': timestamp,
      'dateKey': dateKey,
      'backfilled': backfilled,
    };
  }

  /// Formats a [DateTime] into local `YYYY-MM-DD`.
  static String formatDateKey(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a `YYYY-MM-DD` string into a local [DateTime] at 12:00 noon.
  static DateTime parseDateKey(String key) {
    final List<String> parts = key.split('-');
    if (parts.length != 3) {
      final DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 12);
    }
    final int y = int.tryParse(parts[0]) ?? DateTime.now().year;
    final int m = int.tryParse(parts[1]) ?? 1;
    final int d = int.tryParse(parts[2]) ?? 1;
    return DateTime(y, m, d, 12);
  }
}
