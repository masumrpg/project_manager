import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _autoSyncKey = 'autoSyncEnabled';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isAutoSyncEnabled() async {
    return (await _prefs).getBool(_autoSyncKey) ?? true; // Default to true
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    (await _prefs).setBool(_autoSyncKey, enabled);
  }
}
