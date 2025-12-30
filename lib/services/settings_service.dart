import 'package:shared_preferences/shared_preferences.dart';
import 'unit_converter.dart';

class SettingsService {
  static const String _unitSystemKey = 'unit_system';
  static const String _soundEnabledKey = 'sound_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Unit system
  UnitSystem get unitSystem {
    final value = _prefs?.getString(_unitSystemKey);
    if (value == 'imperial') {
      return UnitSystem.imperial;
    } else if (value == 'metric') {
      return UnitSystem.metric;
    }
    // Default: auto-detect
    return UnitConverter.getPreferredSystem();
  }

  set unitSystem(UnitSystem system) {
    _prefs?.setString(_unitSystemKey, system == UnitSystem.imperial ? 'imperial' : 'metric');
  }

  // Sound enabled
  bool get soundEnabled {
    return _prefs?.getBool(_soundEnabledKey) ?? false;
  }

  set soundEnabled(bool enabled) {
    _prefs?.setBool(_soundEnabledKey, enabled);
  }
}

// Global instance
final settingsService = SettingsService();
