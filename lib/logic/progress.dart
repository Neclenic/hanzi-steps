import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/course.dart';

/// Remembers which lessons are done, total XP and the daily streak.
/// Saved on the computer so it is still there next time the app opens.
class Progress extends ChangeNotifier {
  final SharedPreferences _prefs;
  Progress._(this._prefs);

  static Future<Progress> load() async => Progress._(await SharedPreferences.getInstance());

  Set<String> get completed => (_prefs.getStringList('completed') ?? const []).toSet();
  int get xp => _prefs.getInt('xp') ?? 0;

  int get streak {
    final last = _prefs.getString('lastDay');
    if (last == null) return 0;
    final gap = _today().difference(DateTime.parse(last)).inDays;
    return gap <= 1 ? (_prefs.getInt('streak') ?? 0) : 0;
  }

  bool isDone(Lesson l) => completed.contains(l.id);

  /// Lessons open one after another within each HSK course. The first lesson of
  /// HSK 2 and HSK 3 is always open, so you can start a later course straight away.
  bool isUnlocked(Lesson l) {
    final unit = course.firstWhere((u) => u.lessons.any((x) => x.id == l.id));
    final chain = lessonsOf(unit.level);
    final i = chain.indexWhere((x) => x.id == l.id);
    return i <= 0 || isDone(chain[i - 1]);
  }

  // ---- Spaced review ----
  // Each learned word sits in a "box" from 1 to 6. Remembering a word moves it up a box,
  // and higher boxes wait longer before the word comes back:
  //   box 1: 1 day, 2: 2 days, 3: 4 days, 4: 7 days, 5: 15 days, 6: 30 days.
  // Forgetting a word sends it back to box 1, due again today.
  static const _waitDays = [0, 1, 2, 4, 7, 15, 30];

  Map<String, List<int>> get _review {
    try {
      return (jsonDecode(_prefs.getString('review') ?? '{}') as Map)
          .map((k, v) => MapEntry(k as String, (v as List).cast<int>()));
    } catch (_) {
      return {};
    }
  }

  static int _dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;
  static int get _todayNumber => _dayNumber(DateTime.now());

  /// Updates review boxes after a lesson or review. [results]: word → answered right every time.
  Future<void> _applyReview(Map<String, bool> results) async {
    final r = _review;
    final today = _todayNumber;
    results.forEach((word, right) {
      final box = r[word]?[0] ?? 0;
      final next = right ? (box + 1).clamp(1, 6) : 1;
      r[word] = [next, today + (right ? _waitDays[next] : 0)];
    });
    await _prefs.setString('review', jsonEncode(r));
  }

  /// Learned words that are due for review today, the least-known first.
  List<Word> get dueWords {
    final r = _review;
    final today = _todayNumber;
    // Words from finished lessons, plus words added from stories.
    final pool = {...learnedWords, ...allWords.where((w) => r.containsKey(w.hanzi))};
    final due = pool.where((w) => (r[w.hanzi]?[1] ?? today) <= today).toList()
      ..sort((a, b) => (r[a.hanzi]?[0] ?? 0).compareTo(r[b.hanzi]?[0] ?? 0));
    return due;
  }

  /// How many words are in each box (index 0 = not learned yet).
  List<int> get boxCounts {
    final r = _review;
    final counts = List.filled(7, 0);
    for (final w in allWords) {
      counts[r[w.hanzi]?[0] ?? 0]++;
    }
    return counts;
  }

  // ---- Word review ----
  // For each word we keep a "trouble" score: +2 when answered wrong, -1 when right.
  // Practice picks the words with the highest scores.

  Map<String, int> get _trouble {
    try {
      return (jsonDecode(_prefs.getString('trouble') ?? '{}') as Map).cast<String, int>();
    } catch (_) {
      return {};
    }
  }

  Future<void> recordAnswer(String wordKey, bool right) async {
    final t = _trouble;
    final next = (t[wordKey] ?? 0) + (right ? -1 : 2);
    if (next <= 0) {
      t.remove(wordKey);
    } else {
      t[wordKey] = next;
    }
    await _prefs.setString('trouble', jsonEncode(t));
  }

  /// Words from finished lessons, ready for review.
  List<Word> get learnedWords => [
        for (final l in allLessons)
          if (isDone(l)) ...l.words,
      ];

  /// How many learned words you've been getting wrong.
  int get weakWordCount => learnedWords.where((w) => (_trouble[w.hanzi] ?? 0) > 0).length;

  /// Up to [n] words to practise: words due for review first, then the trickiest,
  /// topped up with random learned words.
  List<Word> wordsToPractice({int n = 8}) {
    final t = _trouble;
    final picked = dueWords.take(n).toList();
    final rest = learnedWords.where((w) => !picked.contains(w)).toList()..shuffle();
    rest.sort((a, b) => (t[b.hanzi] ?? 0).compareTo(t[a.hanzi] ?? 0));
    return [...picked, ...rest.take(n - picked.length)];
  }

  Future<void> finishLesson(Lesson l, int earnedXp, {Map<String, bool> results = const {}}) async {
    await _applyReview(results);
    if (l.kind != LessonKind.practice) {
      await _prefs.setStringList('completed', {...completed, l.id}.toList());
    }
    await _addXp(earnedXp);
    notifyListeners();
  }

  // ---- Daily goal ----

  /// XP earned on each recent day, as {"2026-11-19": 35}.
  Map<String, int> get _days {
    try {
      return (jsonDecode(_prefs.getString('xpDays') ?? '{}') as Map).map((k, v) => MapEntry(k as String, v as int));
    } catch (_) {
      return {};
    }
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// XP earned today.
  int get xpToday => _days[_key(_today())] ?? 0;

  /// XP earned on each of the last 7 days, oldest first (today is last).
  List<int> get lastWeekXp {
    final d = _days, t = _today();
    return [for (var i = 6; i >= 0; i--) d[_key(t.subtract(Duration(days: i)))] ?? 0];
  }

  /// How much XP a day the learner is aiming for.
  int get dailyGoal => _prefs.getInt('dailyGoal') ?? 20;
  Future<void> setDailyGoal(int v) async {
    await _prefs.setInt('dailyGoal', v);
    notifyListeners();
  }

  bool get goalMetToday => xpToday >= dailyGoal;

  /// Called when the daily goal is reached (used to update the reminders).
  VoidCallback? onGoalChanged;

  /// Adds XP to the total and to today, and counts today for the streak.
  Future<void> _addXp(int n) async {
    final wasMet = goalMetToday;
    await _prefs.setInt('xp', xp + n);
    final d = _days, today = _key(_today());
    d[today] = (d[today] ?? 0) + n;
    // Keep only the last few weeks.
    final keys = d.keys.toList()..sort();
    for (final k in keys.take(keys.length > 30 ? keys.length - 30 : 0)) {
      d.remove(k);
    }
    await _prefs.setString('xpDays', jsonEncode(d));
    await _bumpStreak();
    if (!wasMet && goalMetToday) onGoalChanged?.call();
  }

  /// XP from practice outside lessons (speaking practice, the exam).
  Future<void> addXp(int n) async {
    await _addXp(n);
    notifyListeners();
  }

  // ---- Mini exam ----

  /// Best mini exam score out of 200, or null if never taken.
  int? get bestExam => _prefs.getInt('examBest');
  int get examsTaken => _prefs.getInt('examsTaken') ?? 0;

  Future<void> finishExam(int score, int earnedXp) async {
    if (score > (bestExam ?? -1)) await _prefs.setInt('examBest', score);
    await _prefs.setInt('examsTaken', examsTaken + 1);
    await _addXp(earnedXp);
    notifyListeners();
  }

  /// Counts today towards the daily streak.
  Future<void> _bumpStreak() async {
    final today = _today();
    final last = _prefs.getString('lastDay');
    final gap = last == null ? null : today.difference(DateTime.parse(last)).inDays;
    if (gap != 0) {
      await _prefs.setInt('streak', gap == 1 ? streak + 1 : 1);
      await _prefs.setString('lastDay', today.toIso8601String());
    }
  }

  /// Puts a word on the review list (from a story), due today. Returns false if it was already there.
  Future<bool> addToReview(Word w) async {
    final r = _review;
    if (r.containsKey(w.hanzi)) return false;
    r[w.hanzi] = [1, _todayNumber];
    await _prefs.setString('review', jsonEncode(r));
    notifyListeners();
    return true;
  }

  bool isInReview(Word w) => _review.containsKey(w.hanzi);

  // ---- Stories ----
  Set<String> get storiesRead => (_prefs.getStringList('storiesRead') ?? const []).toSet();

  Future<void> finishStory(String id, int earnedXp) async {
    await _prefs.setStringList('storiesRead', {...storiesRead, id}.toList());
    await _addXp(earnedXp);
    notifyListeners();
  }

  Future<void> reset() async {
    for (final k in ['completed', 'xp', 'streak', 'lastDay', 'trouble', 'review', 'storiesRead', 'xpDays', 'examBest', 'examsTaken']) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
