import 'package:flutter/material.dart';

import 'logic/progress.dart';
import 'logic/settings.dart';
import 'logic/speech.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  await Settings.instance.load();
  // Look for a Chinese voice, but never let that hold up the app for long.
  await Speech.instance.init().timeout(const Duration(seconds: 3), onTimeout: () {});
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
