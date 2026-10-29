import 'dart:convert';

import '../../domain/models/drink_log.dart';
import '../../domain/models/drink_spec.dart';
import '../../domain/models/drink_stats.dart';

/// Serializable root document matching the web application's
/// `fizz_luxury_soda_telemetry_v1` JSON schema.
class TelemetryStorageModel {
  const TelemetryStorageModel({
    required this.activeDrinkId,
    required this.selectedSizeId,
    required this.logs,
    required this.lifetime,
  });

  factory TelemetryStorageModel.initial() {
    return TelemetryStorageModel(
      activeDrinkId: 'coke',
      selectedSizeId: 'can_330',
      logs: const <DrinkLog>[],
      lifetime: <String, DrinkStats>{
        'coke': DrinkStats.empty(),
        'pepsi': DrinkStats.empty(),
        'dew': DrinkStats.empty(),
      },
    );
  }

  factory TelemetryStorageModel.fromJson(Map<String, dynamic> json) {
    final String activeId = json['activeDrinkId'] as String? ?? 'coke';
    final String sizeId = json['selectedSizeId'] as String? ?? 'can_330';

    final List<dynamic> rawLogs =
        json['logs'] as List<dynamic>? ?? const <dynamic>[];
    final List<DrinkLog> parsedLogs = rawLogs
        .whereType<Map<String, dynamic>>()
        .map(DrinkLog.fromJson)
        .toList();

    final Map<String, dynamic>? rawLifetime =
        json['lifetime'] as Map<String, dynamic>?;
    final Map<String, DrinkStats> parsedLifetime = <String, DrinkStats>{};
    for (final DrinkSpec spec in DrinkSpec.all) {
      final Object? entry = rawLifetime?[spec.id];
      if (entry is Map<String, dynamic>) {
        parsedLifetime[spec.id] = DrinkStats.fromJson(entry);
      } else {
        parsedLifetime[spec.id] = DrinkStats.empty();
      }
    }

    return TelemetryStorageModel(
      activeDrinkId: activeId,
      selectedSizeId: sizeId,
      logs: parsedLogs,
      lifetime: parsedLifetime,
    );
  }

  final String activeDrinkId;
  final String selectedSizeId;
  final List<DrinkLog> logs;
  final Map<String, DrinkStats> lifetime;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activeDrinkId': activeDrinkId,
      'selectedSizeId': selectedSizeId,
      'logs': logs.map((DrinkLog e) => e.toJson()).toList(),
      'lifetime': lifetime.map(
        (String key, DrinkStats value) => MapEntry<String, dynamic>(
          key,
          value.toJson(),
        ),
      ),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static TelemetryStorageModel fromJsonString(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return TelemetryStorageModel.fromJson(decoded);
    }
    return TelemetryStorageModel.initial();
  }
}
