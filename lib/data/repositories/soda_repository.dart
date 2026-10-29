import '../../domain/models/drink_log.dart';
import '../../domain/models/drink_spec.dart';
import '../../domain/models/drink_stats.dart';
import '../../domain/models/portion_size.dart';
import '../models/telemetry_storage_model.dart';
import '../services/local_storage_service.dart';

/// Single source of truth for soda telemetry state and persistence.
class SodaRepository {
  SodaRepository(this._storageService);

  final LocalStorageService _storageService;

  TelemetryStorageModel loadTelemetry() {
    final String? raw = _storageService.readTelemetryJson();
    if (raw == null || raw.isEmpty) {
      return TelemetryStorageModel.initial();
    }
    try {
      final TelemetryStorageModel loaded =
          TelemetryStorageModel.fromJsonString(raw);
      return _reconcileLifetimeWithLogs(loaded);
    } on FormatException {
      return TelemetryStorageModel.initial();
    }
  }

  Future<void> saveTelemetry(TelemetryStorageModel model) async {
    await _storageService.writeTelemetryJson(model.toJsonString());
  }

  String? loadThemeMode() => _storageService.readThemeMode();

  Future<void> saveThemeMode(String mode) async {
    await _storageService.writeThemeMode(mode);
  }

  /// Ensures `lifetime` totals are never smaller than the sum of recorded `logs`.
  TelemetryStorageModel _reconcileLifetimeWithLogs(
    TelemetryStorageModel model,
  ) {
    final Map<String, DrinkStats> fromLogs = <String, DrinkStats>{
      for (final DrinkSpec d in DrinkSpec.all) d.id: DrinkStats.empty(),
    };
    for (final DrinkLog log in model.logs) {
      final PortionSize sz = PortionSize.byId(log.sizeId);
      final DrinkStats current = fromLogs[log.drinkId] ?? DrinkStats.empty();
      fromLogs[log.drinkId] = DrinkStats(
        count: current.count + 1,
        ml: current.ml + log.ml,
        bySize: <String, int>{
          ...current.bySize,
          sz.id: (current.bySize[sz.id] ?? 0) + 1,
        },
      );
    }

    final Map<String, DrinkStats> merged = <String, DrinkStats>{};
    for (final DrinkSpec d in DrinkSpec.all) {
      final DrinkStats stored = model.lifetime[d.id] ?? DrinkStats.empty();
      final DrinkStats logged = fromLogs[d.id] ?? DrinkStats.empty();
      if (logged.count > stored.count || logged.ml > stored.ml) {
        merged[d.id] = logged;
      } else {
        merged[d.id] = stored;
      }
    }

    return TelemetryStorageModel(
      activeDrinkId: model.activeDrinkId,
      selectedSizeId: model.selectedSizeId,
      logs: model.logs,
      lifetime: merged,
    );
  }
}
