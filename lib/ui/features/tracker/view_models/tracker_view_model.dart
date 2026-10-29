import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/telemetry_storage_model.dart';
import '../../../../data/repositories/soda_repository.dart';
import '../../../../domain/models/drink_log.dart';
import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../../../../domain/models/portion_size.dart';
import '../../../../domain/models/wrapped_summary.dart';
import '../../../../domain/use_cases/backfill_logs_use_case.dart';
import '../../../../domain/use_cases/compute_wrapped_use_case.dart';

/// Central reactive ViewModel (`ChangeNotifier`) for Jamal's Addiction.
class TrackerViewModel extends ChangeNotifier {
  TrackerViewModel({
    required SodaRepository repository,
    BackfillLogsUseCase backfillUseCase = const BackfillLogsUseCase(),
    ComputeWrappedUseCase computeWrappedUseCase =
        const ComputeWrappedUseCase(),
  })  : _repository = repository,
        _backfillUseCase = backfillUseCase,
        _computeWrappedUseCase = computeWrappedUseCase {
    _init();
  }

  final SodaRepository _repository;
  final BackfillLogsUseCase _backfillUseCase;
  final ComputeWrappedUseCase _computeWrappedUseCase;

  late String _activeDrinkId;
  late String _selectedSizeId;
  late List<DrinkLog> _logs;
  late Map<String, DrinkStats> _lifetime;
  ThemeMode _themeMode = ThemeMode.dark;

  // Last logged drink ID for pop-animation feedback
  String? _lastLoggedDrinkId;
  int _lastLogPulseTick = 0;

  void _init() {
    final TelemetryStorageModel loaded = _repository.loadTelemetry();
    _activeDrinkId = loaded.activeDrinkId;
    _selectedSizeId = loaded.selectedSizeId;
    _logs = List<DrinkLog>.from(loaded.logs);
    _lifetime = Map<String, DrinkStats>.from(loaded.lifetime);

    final String? storedTheme = _repository.loadThemeMode();
    if (storedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
  }

  // --- Getters ---
  String get activeDrinkId => _activeDrinkId;
  DrinkSpec get activeDrink => DrinkSpec.byId(_activeDrinkId);

  String get selectedSizeId => _selectedSizeId;
  PortionSize get selectedSize => PortionSize.byId(_selectedSizeId);

  List<DrinkLog> get logs => List<DrinkLog>.unmodifiable(_logs);
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String? get lastLoggedDrinkId => _lastLoggedDrinkId;
  int get lastLogPulseTick => _lastLogPulseTick;

  String get todayKey => DrinkLog.formatDateKey(DateTime.now());

  List<DrinkLog> get todayLogs {
    final String tk = todayKey;
    return _logs.where((DrinkLog l) => l.dateKey == tk).toList();
  }

  bool get canUndo => todayLogs.isNotEmpty;

  DrinkStats todayStatsFor(String drinkId) {
    final String tk = todayKey;
    int count = 0;
    int ml = 0;
    final Map<String, int> bySize = <String, int>{
      'can_330': 0,
      'bottle_500': 0,
      'bottle_1000': 0,
      'bottle_2000': 0,
    };
    for (final DrinkLog l in _logs) {
      if (l.drinkId == drinkId && l.dateKey == tk) {
        count++;
        ml += l.ml;
        bySize[l.sizeId] = (bySize[l.sizeId] ?? 0) + 1;
      }
    }
    return DrinkStats(count: count, ml: ml, bySize: bySize);
  }

  DrinkStats lifetimeStatsFor(String drinkId) {
    return _lifetime[drinkId] ?? DrinkStats.empty();
  }

  DrinkStats get totalTodayStats {
    int count = 0;
    int ml = 0;
    final Map<String, int> bySize = <String, int>{
      'can_330': 0,
      'bottle_500': 0,
      'bottle_1000': 0,
      'bottle_2000': 0,
    };
    for (final DrinkSpec spec in DrinkSpec.all) {
      final DrinkStats s = todayStatsFor(spec.id);
      count += s.count;
      ml += s.ml;
      s.bySize.forEach((String k, int v) {
        bySize[k] = (bySize[k] ?? 0) + v;
      });
    }
    return DrinkStats(count: count, ml: ml, bySize: bySize);
  }

  DrinkStats get totalLifetimeStats {
    int count = 0;
    int ml = 0;
    final Map<String, int> bySize = <String, int>{
      'can_330': 0,
      'bottle_500': 0,
      'bottle_1000': 0,
      'bottle_2000': 0,
    };
    for (final DrinkSpec spec in DrinkSpec.all) {
      final DrinkStats s = lifetimeStatsFor(spec.id);
      count += s.count;
      ml += s.ml;
      s.bySize.forEach((String k, int v) {
        bySize[k] = (bySize[k] ?? 0) + v;
      });
    }
    return DrinkStats(count: count, ml: ml, bySize: bySize);
  }

  List<DrinkLog> logsForDateKey(String dateKey) {
    return _logs.where((DrinkLog l) => l.dateKey == dateKey).toList();
  }

  WrappedSummary computeWrapped({
    required WrappedPeriod period,
    required int offset,
  }) {
    return _computeWrappedUseCase.execute(
      allLogs: _logs,
      period: period,
      offset: offset,
    );
  }

  // --- Commands / Mutations ---

  Future<void> selectDrink(String drinkId) async {
    if (_activeDrinkId == drinkId) {
      return;
    }
    _activeDrinkId = drinkId;
    await HapticFeedback.selectionClick();
    notifyListeners();
    await _persist();
  }

  Future<void> selectDrinkByDelta(int delta) async {
    final int currentIndex =
        DrinkSpec.all.indexWhere((DrinkSpec d) => d.id == _activeDrinkId);
    final int nextIndex =
        (currentIndex + delta).clamp(0, DrinkSpec.all.length - 1);
    if (nextIndex != currentIndex) {
      await selectDrink(DrinkSpec.all[nextIndex].id);
    }
  }

  Future<void> selectSize(String sizeId) async {
    if (_selectedSizeId == sizeId) {
      return;
    }
    _selectedSizeId = sizeId;
    await HapticFeedback.selectionClick();
    notifyListeners();
    await _persist();
  }

  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await HapticFeedback.lightImpact();
    notifyListeners();
    await _repository.saveThemeMode(
      _themeMode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  /// Logs a single drink for today using either [sizeOverrideId] or [selectedSizeId].
  Future<DrinkLog> logDrink(
    String drinkId, {
    String? sizeOverrideId,
  }) async {
    final PortionSize size =
        PortionSize.byId(sizeOverrideId ?? _selectedSizeId);
    final DateTime now = DateTime.now();
    final int ts = now.millisecondsSinceEpoch;
    final DrinkLog entry = DrinkLog(
      id: 'log_${ts}_${_logs.length}_$drinkId',
      drinkId: drinkId,
      sizeId: size.id,
      ml: size.ml,
      timestamp: ts,
      dateKey: DrinkLog.formatDateKey(now),
    );

    _logs.add(entry);
    final DrinkStats currentLife = _lifetime[drinkId] ?? DrinkStats.empty();
    _lifetime[drinkId] = currentLife.increment(size);
    _lastLoggedDrinkId = drinkId;
    _lastLogPulseTick++;

    await HapticFeedback.mediumImpact();
    notifyListeners();
    await _persist();
    return entry;
  }

  /// Removes the most recent log for [drinkId] recorded today.
  Future<DrinkLog?> removeDrinkToday(String drinkId) async {
    final String tk = todayKey;
    for (int i = _logs.length - 1; i >= 0; i--) {
      final DrinkLog item = _logs[i];
      if (item.drinkId == drinkId && item.dateKey == tk) {
        _logs.removeAt(i);
        final PortionSize sz = PortionSize.byId(item.sizeId);
        final DrinkStats currentLife = _lifetime[drinkId] ?? DrinkStats.empty();
        _lifetime[drinkId] = currentLife.decrement(sz);
        await HapticFeedback.lightImpact();
        notifyListeners();
        await _persist();
        return item;
      }
    }
    return null;
  }

  /// Undoes the most recent log recorded today across all drinks.
  Future<DrinkLog?> undoLastTodayLog() async {
    final String tk = todayKey;
    for (int i = _logs.length - 1; i >= 0; i--) {
      final DrinkLog item = _logs[i];
      if (item.dateKey == tk) {
        _logs.removeAt(i);
        final PortionSize sz = PortionSize.byId(item.sizeId);
        final DrinkStats currentLife =
            _lifetime[item.drinkId] ?? DrinkStats.empty();
        _lifetime[item.drinkId] = currentLife.decrement(sz);
        await HapticFeedback.lightImpact();
        notifyListeners();
        await _persist();
        return item;
      }
    }
    return null;
  }

  /// Deletes a specific log entry by ID (used in the Soda Calendar day log list).
  Future<void> deleteLogById(String logId) async {
    final int idx = _logs.indexWhere((DrinkLog l) => l.id == logId);
    if (idx == -1) {
      return;
    }
    final DrinkLog removed = _logs.removeAt(idx);
    final PortionSize sz = PortionSize.byId(removed.sizeId);
    final DrinkStats currentLife =
        _lifetime[removed.drinkId] ?? DrinkStats.empty();
    _lifetime[removed.drinkId] = currentLife.decrement(sz);

    await HapticFeedback.lightImpact();
    notifyListeners();
    await _persist();
  }

  /// Adds backfilled logs for either a single day or distributed across a date range.
  Future<int> backfillDrinks({
    required String drinkId,
    required String sizeId,
    required int count,
    required bool isRange,
    required DateTime singleDate,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final PortionSize size = PortionSize.byId(sizeId);
    final List<DrinkLog> generated = isRange
        ? _backfillUseCase.generateDateRange(
            drinkId: drinkId,
            size: size,
            count: count,
            startDate: startDate,
            endDate: endDate,
          )
        : _backfillUseCase.generateSingleDay(
            drinkId: drinkId,
            size: size,
            count: count,
            date: singleDate,
          );

    _logs.addAll(generated);
    DrinkStats currentLife = _lifetime[drinkId] ?? DrinkStats.empty();
    for (int i = 0; i < generated.length; i++) {
      currentLife = currentLife.increment(size);
    }
    _lifetime[drinkId] = currentLife;

    await HapticFeedback.heavyImpact();
    notifyListeners();
    await _persist();
    return generated.length;
  }

  /// Resets only today's logs and subtracts them from lifetime totals.
  Future<int> resetTodayOnly() async {
    final String tk = todayKey;
    final List<DrinkLog> todayItems =
        _logs.where((DrinkLog l) => l.dateKey == tk).toList();
    if (todayItems.isEmpty) {
      return 0;
    }
    for (final DrinkLog item in todayItems) {
      final PortionSize sz = PortionSize.byId(item.sizeId);
      final DrinkStats currentLife =
          _lifetime[item.drinkId] ?? DrinkStats.empty();
      _lifetime[item.drinkId] = currentLife.decrement(sz);
    }
    _logs.removeWhere((DrinkLog l) => l.dateKey == tk);
    await HapticFeedback.mediumImpact();
    notifyListeners();
    await _persist();
    return todayItems.length;
  }

  /// Wipes all logs and lifetime scores across all drinks.
  Future<void> wipeEntireLifetime() async {
    _logs.clear();
    _lifetime = <String, DrinkStats>{
      for (final DrinkSpec spec in DrinkSpec.all) spec.id: DrinkStats.empty(),
    };
    await HapticFeedback.heavyImpact();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final TelemetryStorageModel snapshot = TelemetryStorageModel(
      activeDrinkId: _activeDrinkId,
      selectedSizeId: _selectedSizeId,
      logs: _logs,
      lifetime: _lifetime,
    );
    await _repository.saveTelemetry(snapshot);
  }
}
