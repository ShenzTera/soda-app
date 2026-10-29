import 'package:shared_preferences/shared_preferences.dart';

/// Low-level key-value storage wrapper around `SharedPreferences`.
class LocalStorageService {
  LocalStorageService(this._prefs);

  static const String telemetryStorageKey = 'fizz_luxury_soda_telemetry_v1';
  static const String themeModeStorageKey = 'jamals_addiction_theme_mode_v1';

  final SharedPreferences _prefs;

  String? readTelemetryJson() {
    return _prefs.getString(telemetryStorageKey);
  }

  Future<bool> writeTelemetryJson(String jsonString) {
    return _prefs.setString(telemetryStorageKey, jsonString);
  }

  String? readThemeMode() {
    return _prefs.getString(themeModeStorageKey);
  }

  Future<bool> writeThemeMode(String modeName) {
    return _prefs.setString(themeModeStorageKey, modeName);
  }
}
