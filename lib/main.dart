import 'package:flutter/material.dart';

import 'logic/progress.dart';
import 'logic/reminders.dart';
import 'logic/settings.dart';
import 'logic/speech.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  await Settings.instance.load();
  // Look for a Chinese voice, but never let that hold up the app for long.
  await Speech.instance.init().timeout(const Duration(seconds: 3), onTimeout: () {});
  // Set this week's reminders, and skip today's once the goal is reached.
  progress.onGoalChanged = () => refreshReminders(progress);
  refreshReminders(progress);
  runApp(HanziStepsApp(progress: progress));
}

class HanziStepsApp extends StatelessWidget {
  final Progress progress;
  const HanziStepsApp({super.key, required this.progress});

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
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: HomeScreen(progress: progress),
    );
  }
}
