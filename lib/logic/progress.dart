import 'dart:convert';
import 'dart:math';

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
  List<int> get lastWeekXp => lastDaysXp(7);

  /// XP earned on each of the last [n] days (up to 30), oldest first.
  List<int> lastDaysXp(int n) {
    final d = _days, t = _today();
    return [for (var i = n - 1; i >= 0; i--) d[_key(t.subtract(Duration(days: i)))] ?? 0];
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
    if (!wasMet && goalMetToday) {
      await _prefs.setInt('goalDays', goalDays + 1);
      onGoalChanged?.call();
    }
  }

  /// XP from practice outside lessons (speaking practice, the exam).
  Future<void> addXp(int n) async {
    await _addXp(n);
    notifyListeners();
  }

  // ---- Mini exam ----

  static String _examKey(int level) => level == 1 ? 'examBest' : 'examBest$level';

  /// Best HSK 1 mini exam score out of 200, or null if never taken.
  int? get bestExam => bestExamFor(1);

  /// Best mini exam score for one HSK level, or null if never taken.
  int? bestExamFor(int level) => _prefs.getInt(_examKey(level));
  int get examsTaken => _prefs.getInt('examsTaken') ?? 0;

  /// Levels whose mini exam has been passed.
  Set<int> get examsPassed => (_prefs.getStringList('examsPassed') ?? const []).map(int.parse).toSet();

  /// Did any mini exam get full marks?
  bool get examFullMarks => _prefs.getBool('examFullMarks') ?? false;

  Future<void> finishExam(int score, int earnedXp, {int level = 1, bool passed = false, bool fullMarks = false}) async {
    if (score > (bestExamFor(level) ?? -1)) await _prefs.setInt(_examKey(level), score);
    await _prefs.setInt('examsTaken', examsTaken + 1);
    if (passed) await _prefs.setStringList('examsPassed', {...examsPassed, level}.map((e) => '$e').toList());
    if (fullMarks) await _prefs.setBool('examFullMarks', true);
    await _addXp(earnedXp);
    notifyListeners();
  }

  // ---- Counters and practice results (for stats and badges) ----

  Map<String, dynamic> _json(String key) {
    try {
      return (jsonDecode(_prefs.getString(key) ?? '{}') as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  /// How many times something has happened, e.g. 'speakRight' or 'typedRight'.
  int count(String name) => (_json('counters')[name] as num?)?.toInt() ?? 0;

  Future<void> bump(String name, [int n = 1]) async {
    final c = _json('counters');
    c[name] = ((c[name] as num?) ?? 0) + n;
    await _prefs.setString('counters', jsonEncode(c));
    notifyListeners();
  }

  Map<String, (int, int)> _rightTotal(String key) => _json(key).map((k, v) {
        final l = (v as List).cast<num>();
        return MapEntry(k, (l[0].toInt(), l[1].toInt()));
      });

  Future<void> _addRightTotal(String key, String item, bool right) async {
    final m = _json(key);
    final l = ((m[item] as List?) ?? [0, 0]).cast<num>();
    m[item] = [l[0] + (right ? 1 : 0), l[1] + 1];
    await _prefs.setString(key, jsonEncode(m));
  }

  /// Right and total answers for each tone, as {1: (right, total)}.
  Map<int, (int, int)> get toneStats => _rightTotal('toneStats').map((k, v) => MapEntry(int.parse(k), v));

  /// Remembers whether a tone (1–4) was heard or said right.
  Future<void> recordTone(int tone, bool right) async {
    if (tone < 1 || tone > 4) return;
    await _addRightTotal('toneStats', '$tone', right);
    notifyListeners();
  }

  /// Right and total answers for each tone pair, as {"3-4": (right, total)}.
  Map<String, (int, int)> get pairStats => _rightTotal('pairStats');

  Future<void> recordPair(String pair, bool right) async {
    await _addRightTotal('pairStats', pair, right);
    notifyListeners();
  }

  /// The words answered wrong most often, trickiest first.
  List<(Word, int)> get troubleWords {
    final t = _trouble;
    final out = <(Word, int)>[
      for (final e in t.entries)
        if (wordFor(e.key) case final w?) (w, e.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return out;
  }

  /// Every word learned so far (finished lessons and words added from stories), each once.
  int get wordsLearned => {...learnedWords.map((w) => w.hanzi), ..._review.keys}.length;

  // ---- Dialogues and games ----
  Set<String> get dialoguesDone => (_prefs.getStringList('dialoguesDone') ?? const []).toSet();

  Future<void> finishDialogue(String id, int earnedXp) async {
    await _prefs.setStringList('dialoguesDone', {...dialoguesDone, id}.toList());
    await _addXp(earnedXp);
    notifyListeners();
  }

  int gameBest(String game) => _prefs.getInt('gameBest_$game') ?? 0;

  /// Saves a game score and returns true if it's a new best.
  Future<bool> finishGame(String game, int score, int earnedXp) async {
    final best = score > gameBest(game);
    if (best) await _prefs.setInt('gameBest_$game', score);
    await _addXp(earnedXp);
    notifyListeners();
    return best;
  }

  // ---- Badges ----
  Set<String> get badgesSeen => (_prefs.getStringList('badgesSeen') ?? const []).toSet();
  Future<void> setBadgesSeen(Set<String> ids) => _prefs.setStringList('badgesSeen', ids.toList());

  /// The longest streak so far.
  int get bestStreak => max(_prefs.getInt('bestStreak') ?? 0, streak);

  /// On how many days the daily goal was reached.
  int get goalDays => _prefs.getInt('goalDays') ?? 0;

  /// Counts today towards the daily streak.
  Future<void> _bumpStreak() async {
    final today = _today();
    final last = _prefs.getString('lastDay');
    final gap = last == null ? null : today.difference(DateTime.parse(last)).inDays;
    if (gap != 0) {
      final next = gap == 1 ? streak + 1 : 1;
      await _prefs.setInt('streak', next);
      await _prefs.setString('lastDay', today.toIso8601String());
      if (next > (_prefs.getInt('bestStreak') ?? 0)) await _prefs.setInt('bestStreak', next);
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
    for (final k in ['completed', 'xp', 'streak', 'lastDay', 'trouble', 'review', 'storiesRead', 'xpDays', 'examBest', 'examBest2', 'examBest3', 'examsTaken', 'examsPassed', 'examFullMarks',
      'counters', 'toneStats', 'pairStats', 'dialoguesDone', 'badgesSeen', 'bestStreak', 'goalDays',
      'gameBest_match', 'gameBest_fall']) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
