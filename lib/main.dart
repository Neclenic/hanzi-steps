import 'package:flutter/material.dart';

import 'logic/progress.dart';
import 'logic/reminders.dart';
import 'logic/settings.dart';
import 'logic/speech.dart';
import 'logic/version.dart';
import 'logic/weekly_report.dart';
import 'screens/home_screen.dart';
import 'widgets/badge_watcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  await Settings.instance.load();
  // Look for a Chinese voice, but never let that hold up the app for long.
  await Speech.instance.init().timeout(const Duration(seconds: 3), onTimeout: () {});
  // Set this week's reminders, and skip today's once the goal is reached.
  progress.onGoalChanged = () => refreshReminders(progress);
  refreshReminders(progress);
  // Shows a note when a badge is earned.
  final navigator = GlobalKey<NavigatorState>();
  BadgeWatcher(progress, navigator).start();
  // Counts minutes in the app for the weekly report.
  TimeTracker(progress).start();
  // Looks for a newer version on GitHub (once a day, in the background).
  UpdateChecker.instance.check(progress);
  runApp(HanziStepsApp(progress: progress, navigatorKey: navigator));
}

/// Fonts for Chinese characters, in order of preference. Without these, a computer set to another
/// language may borrow a Japanese font, which draws some characters (喝, 啡, 说…) differently from
/// the Simplified Chinese forms learners need. One of these is on every Windows PC and Mac.
const chineseFonts = [
  'Microsoft YaHei', // Windows
  'Microsoft YaHei UI',
  'PingFang SC', // Mac
  'Hiragino Sans GB',
  'Noto Sans CJK SC', // Linux and others
  'Noto Sans SC',
  'Source Han Sans SC',
  'WenQuanYi Micro Hei',
];

class HanziStepsApp extends StatelessWidget {
  final Progress progress;
  final GlobalKey<NavigatorState>? navigatorKey;
  const HanziStepsApp({super.key, required this.progress, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness b) => ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD7263D), brightness: b),
          useMaterial3: true,
          // Latin text keeps the system font; Chinese characters use a Simplified Chinese font.
          fontFamilyFallback: chineseFonts,
          // Screens slide and fade into each other.
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          }),
        );
    // Rebuilds when the light/dark choice changes in Settings.
    return ListenableBuilder(
      listenable: Settings.instance,
      builder: (context, _) => MaterialApp(
        title: 'Hanzi Steps',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        themeMode: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][Settings.instance.themeChoice.clamp(0, 2)],
        home: HomeScreen(progress: progress),
      ),
    );
  }
}
