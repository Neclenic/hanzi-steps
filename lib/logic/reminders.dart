import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'progress.dart';
import 'settings.dart';

/// The daily reminder: a notification at a chosen time that nudges you to
/// reach your daily XP goal and keep your streak.
///
/// Windows can't repeat a notification by itself, so the app sets one
/// reminder for each of the next 7 days, every time it opens. Days where the
/// goal is already reached are skipped.
class Reminders {
  Reminders._();
  static final Reminders instance = Reminders._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const _days = 7;
  static const _darwin = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestSoundPermission: false,
    requestBadgePermission: false,
  );

  /// Reminders work in the Windows and Mac apps (and on phones), not in a browser.
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> _init() async {
    if (_ready) return true;
    if (!supported) return false;
    try {
      _ready = await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
              // Ask for permission only when reminders are switched on.
              iOS: _darwin,
              macOS: _darwin,
              windows: WindowsInitializationSettings(
                appName: 'Hanzi Steps',
                appUserModelId: 'HanziSteps.App.Desktop.1',
                guid: '5b0a8c2e-6f3d-4d7a-9a51-2f9e3c7b1d44',
              ),
            ),
          ) ??
          false;
    } catch (e) {
      debugPrint('Reminders not available: $e');
      _ready = false;
    }
    return _ready;
  }

  /// Asks the computer for permission to show notifications (needed on Mac).
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    try {
      final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (mac != null) return await mac.requestPermissions(alert: true, sound: true) ?? false;
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Notification permission failed: $e');
      return false;
    }
    return true; // Windows doesn't ask
  }

  /// Sets the reminders for the coming week at [hour]:[minute], or removes
  /// them when [on] is false. [doneToday] skips today's reminder.
  Future<void> schedule({
    required bool on,
    required int hour,
    required int minute,
    required int goal,
    required bool doneToday,
    required int streak,
  }) async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
      if (!on) return;
      final now = DateTime.now();
      for (var d = 0; d < _days; d++) {
        final day = DateTime(now.year, now.month, now.day + d, hour, minute);
        if (day.isBefore(now.add(const Duration(minutes: 1)))) continue;
        if (d == 0 && doneToday) continue;
        await _plugin.zonedSchedule(
          id: 100 + d,
          title: _titles[(now.day + d) % _titles.length],
          body: d == 0 && streak > 0
              ? 'Earn $goal XP today to keep your $streak-day streak going.'
              : 'A quick lesson earns your $goal XP for today.',
          // An exact moment in time; the computer shows it at that local time.
          scheduledDate: tz.TZDateTime.from(day, tz.UTC),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails('daily', 'Daily reminder'),
            macOS: DarwinNotificationDetails(),
            iOS: DarwinNotificationDetails(),
            windows: WindowsNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Could not set reminders: $e');
    }
  }

  /// Shows a reminder right now, so you can check that notifications work.
  Future<bool> showTest() async {
    if (!await _init()) return false;
    try {
      await _plugin.show(
        id: 99,
        title: '你好! This is your Hanzi Steps reminder',
        body: 'Reminders will look like this.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('daily', 'Daily reminder'),
          macOS: DarwinNotificationDetails(),
          iOS: DarwinNotificationDetails(),
          windows: WindowsNotificationDetails(),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Test notification failed: $e');
      return false;
    }
  }

  static const _titles = [
    '加油! Time for some Chinese',
    '你好! Your daily lesson is waiting',
    '一点儿 a day: keep your streak alive',
    'Ready for a few new words? 我们走吧!',
  ];
}

/// Sets the reminders again from the saved settings, e.g. at start-up, after a
/// settings change, or once the daily goal is reached.
Future<void> refreshReminders(Progress progress) {
  final s = Settings.instance;
  return Reminders.instance.schedule(
    on: s.reminderOn,
    hour: s.reminderHour,
    minute: s.reminderMinute,
    goal: progress.dailyGoal,
    doneToday: progress.goalMetToday,
    streak: progress.streak,
  );
}
