import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme service that persists the user's preference in SharedPreferences.
class ThemeService {
  static final ValueNotifier<bool> isDark = ValueNotifier<bool>(true);
  static const _key = 'pref_is_dark';

  /// Initialize from persisted preference.
  static Future<void> init() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final val = sp.getBool(_key);
      if (val != null) isDark.value = val;
    } catch (e) {
      // ignore errors; keep default
    }
  }

  static Future<void> toggle() async {
    isDark.value = !isDark.value;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_key, isDark.value);
    } catch (e) {
      // ignore persistence errors for prototype
    }
  }
}
