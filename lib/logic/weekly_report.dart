import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/course.dart';
import 'progress.dart';

/// One week's numbers, compared with the week before.
class WeekNumbers {
  final int xp, minutes, newWords, activeDays;
  const WeekNumbers(this.xp, this.minutes, this.newWords, this.activeDays);

  factory WeekNumbers.of(Progress p, int weeksAgo) =>
      WeekNumbers(p.weekXp(weeksAgo), p.weekSeconds(weeksAgo) ~/ 60, p.weekNewWords(weeksAgo), p.weekActiveDays(weeksAgo));
}

class WeeklyReport {
  final WeekNumbers now, before;
  final int streak;
  final (int tone, int right, int total)? weakestTone;
  final List<(Word, int)> tricky;
  const WeeklyReport(this.now, this.before, this.streak, this.weakestTone, this.tricky);

  factory WeeklyReport.of(Progress p) {
    (int, int, int)? weakest;
    for (final e in p.toneStats.entries) {
      final (right, total) = e.value;
      if (total < 3) continue;
      if (weakest == null || right / total < weakest.$2 / weakest.$3) weakest = (e.key, right, total);
    }
    return WeeklyReport(WeekNumbers.of(p, 0), WeekNumbers.of(p, 1), p.streak, weakest, p.troubleWords.take(3).toList());
  }
}

/// The report comes up on the home screen once a week, after a few days of practice.
bool reportDue(Progress p, {DateTime? now}) {
  final seen = p.reportSeen;
  if (p.weekXp() == 0) return false;
  if (seen == null) return p.weekActiveDays() >= 3;
  final t = now ?? DateTime.now();
  return DateTime(t.year, t.month, t.day).difference(DateTime.parse(seen)).inDays >= 7;
}

/// Counts the minutes the app is open and in front, for the weekly report.
class TimeTracker with WidgetsBindingObserver {
  final Progress progress;
  TimeTracker(this.progress);

  Timer? _timer;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _run();
  }

  void _run() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => progress.addSeconds(60));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _run();
    } else {
      // Not in front (another window has focus, or the app is hidden): stop counting.
      _timer?.cancel();
      _timer = null;
    }
  }
}
