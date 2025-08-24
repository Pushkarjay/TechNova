import 'package:flutter/foundation.dart';

/// Simple in-memory theme service used by the prototype.
/// Default is dark theme. This uses a ValueNotifier so UI can listen
/// without adding a larger state management dependency.
class ThemeService {
  static final ValueNotifier<bool> isDark = ValueNotifier<bool>(true);
  static void toggle() => isDark.value = !isDark.value;
}
