import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The learner's choices from the Settings screen, saved between runs.
class Settings extends ChangeNotifier {
  Settings._();
  static final Settings instance = Settings._();

  SharedPreferences? _prefs;

  Future<void> load() async => _prefs = await SharedPreferences.getInstance();

  /// Show pinyin under characters in questions. Turning it off is good reading practice.
  /// (New-word cards always show pinyin.)
  bool get showPinyin => _prefs?.getBool('showPinyin') ?? true;
  set showPinyin(bool v) {
    _prefs?.setBool('showPinyin', v);
    notifyListeners();
  }

  /// Speech speed: 0 = slow, 1 = normal.
  int get speechSpeed => _prefs?.getInt('speechSpeed') ?? 0;
  set speechSpeed(int v) {
    _prefs?.setInt('speechSpeed', v);
    notifyListeners();
  }
}
