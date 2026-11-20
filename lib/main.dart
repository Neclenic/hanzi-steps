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

class HanziStepsApp extends StatelessWidget {
  final Progress progress;
  final GlobalKey<NavigatorState>? navigatorKey;
  const HanziStepsApp({super.key, required this.progress, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness b) => ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD7263D), brightness: b),
          useMaterial3: true,
          // Screens slide and fade into each other.
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          }),
        );
    return MaterialApp(
      title: 'Hanzi Steps',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: HomeScreen(progress: progress),
    );
  }
}
