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

  /// Use the natural recorded voice where there is a recording (otherwise the computer's voice).
  bool get naturalVoice => _prefs?.getBool('naturalVoice') ?? true;
  set naturalVoice(bool v) {
    _prefs?.setBool('naturalVoice', v);
    notifyListeners();
  }

  /// Which course the home screen shows: HSK 1, 2 or 3.
  int get level => _prefs?.getInt('level') ?? 1;
  set level(int v) {
    _prefs?.setInt('level', v);
    notifyListeners();
  }

  /// Daily reminder on or off, and its time.
  bool get reminderOn => _prefs?.getBool('reminderOn') ?? false;
  set reminderOn(bool v) {
    _prefs?.setBool('reminderOn', v);
    notifyListeners();
  }

  int get reminderHour => _prefs?.getInt('reminderHour') ?? 19;
  int get reminderMinute => _prefs?.getInt('reminderMinute') ?? 0;
  void setReminderTime(int hour, int minute) {
    _prefs?.setInt('reminderHour', hour);
    _prefs?.setInt('reminderMinute', minute);
    notifyListeners();
  }

  /// Light or dark colours: 0 = follow the computer, 1 = always light, 2 = always dark.
  int get themeChoice => _prefs?.getInt('themeChoice') ?? 0;
  set themeChoice(int v) {
    _prefs?.setInt('themeChoice', v);
    notifyListeners();
  }

  /// Look on GitHub once a day for a newer version of the app.
  bool get updateCheck => _prefs?.getBool('updateCheck') ?? true;
  set updateCheck(bool v) {
    _prefs?.setBool('updateCheck', v);
    notifyListeners();
  }
}
