import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/idioms.dart';
import 'package:hanzi_steps/data/measure_words.dart';
import 'package:hanzi_steps/data/radicals.dart';
import 'package:hanzi_steps/data/textbook.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/daily_challenge.dart';
import 'package:hanzi_steps/logic/idioms.dart';
import 'package:hanzi_steps/logic/measure_drill.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/radical_quiz.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/strokes.dart';
import 'package:hanzi_steps/logic/textbook.dart';
import 'package:hanzi_steps/logic/version.dart';
import 'package:hanzi_steps/logic/weekly_report.dart';
import 'package:hanzi_steps/screens/home_screen.dart';
import 'package:hanzi_steps/screens/idioms_screen.dart';
import 'package:hanzi_steps/screens/measure_words_screen.dart';
import 'package:hanzi_steps/screens/memory_writing_screen.dart';
import 'package:hanzi_steps/screens/radicals_screen.dart';
import 'package:hanzi_steps/screens/settings_screen.dart';
import 'package:hanzi_steps/screens/weekly_report_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  Speech.instance.available.value = false;
  await Settings.instance.load();
  Settings.instance.level = 1;
  return Progress.load();
}

/// A date whose challenge is [id].
DateTime _dayFor(String id) {
  for (var d = 20000; d < 20100; d++) {
    if (challengeForDay(d).id == id) {
      final t = DateTime.fromMillisecondsSinceEpoch(d * 86400000, isUtc: true);
      return DateTime(t.year, t.month, t.day);
    }
  }
  throw StateError(id);
}

/// Answers a TbQuizScreen question: taps the right option, checks, continues.
Future<void> _answer(WidgetTester tester, String option) async {
  await tester.tap(find.text(option).last);
  await tester.pump();
  await tester.tap(find.text('CHECK'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('CONTINUE'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => loopingAnimations = false);
  setUpAll(() => StrokeLibrary.instance.loadFromString(File('assets/strokes/strokes.json').readAsStringSync()));

  group('daily challenge', () {
    test('challenges have unique ids and sensible goals', () {
      expect(dailyChallenges.map((c) => c.id).toSet(), hasLength(dailyChallenges.length));
      for (final c in dailyChallenges) {
        expect(c.goal, greaterThan(0));
      }
      // Every challenge comes round within two weeks or so.
      expect({for (var d = 0; d < dailyChallenges.length; d++) challengeForDay(d).id}, hasLength(dailyChallenges.length));
    });

    test('counts from the start of the day, then pays out once', () async {
      final progress = await _fresh();
      final day = _dayFor('dialogue');
      await progress.finishDialogue('old', 5); // before the challenge started: doesn't count
      await startChallenge(progress, now: day);
      var st = challengeToday(progress, now: day);
      expect(st.challenge.id, 'dialogue');
      expect(st.done, 0);
      expect(await claimChallenge(progress, now: day), isFalse);
      await progress.finishDialogue('d1', 5);
      st = challengeToday(progress, now: day);
      expect(st.complete, isTrue);
      final xp = progress.xp;
      expect(await claimChallenge(progress, now: day), isTrue);
      expect(progress.xp, xp + challengeBonus);
      expect(challengeToday(progress, now: day).claimed, isTrue);
      expect(await claimChallenge(progress, now: day), isFalse, reason: 'only once');
      expect(progress.count('challengesDone'), 1);
    });

    test('the XP challenge uses today\'s XP', () async {
      final progress = await _fresh();
      final day = _dayFor('xp40');
      await startChallenge(progress, now: day);
      await progress.addXp(25);
      expect(challengeToday(progress, now: day).done, 25);
      await progress.addXp(25);
      expect(challengeToday(progress, now: day).complete, isTrue);
    });

    test('finishing activities moves the run counters', () async {
      final progress = await _fresh();
      await progress.finishLesson(allLessons.first, 10);
      await progress.finishStory('s', 5);
      await progress.finishTextbook('tb-1', 5);
      await progress.finishGame('match', 3, 2);
      await progress.finishIdiom('id-snake', 5);
      expect(progress.count('lessonRuns'), 1);
      expect(progress.count('storyRuns'), 1);
      expect(progress.count('textbookRuns'), 1);
      expect(progress.count('gameRuns'), 1);
      expect(progress.count('idiomRuns'), 1);
    });
  });

  group('counting words', () {
    test('every noun can be looked up, and measures are unique', () {
      expect(measureWords.map((m) => m.char).toSet(), hasLength(measureWords.length));
      for (final m in measureWords) {
        expect(m.nouns, isNotEmpty);
        for (final n in m.nouns) {
          expect(tbWord(n), isNotNull, reason: n);
        }
      }
    });

    test('drill questions have one right answer', () {
      for (var seed = 0; seed < 40; seed++) {
        final qs = buildMeasureDrill(random: Random(seed));
        expect(qs, hasLength(10));
        for (final q in qs) {
          expect(q.options.toSet(), hasLength(3), reason: q.prompt);
          expect(q.options, isNot(contains('个')), reason: '个 is never offered');
          final m = q.tag!;
          if (q.prompt.contains('＿')) {
            final noun = q.prompt.split(' ').last;
            expect(q.options[q.correct], m);
            for (final (i, o) in q.options.indexed) {
              if (i != q.correct) expect(measuresFor(noun), isNot(contains(o)), reason: '$o $noun');
            }
          } else {
            expect(measuresFor(q.options[q.correct]), contains(m));
            for (final (i, o) in q.options.indexed) {
              if (i != q.correct) expect(measuresFor(o), isNot(contains(m)), reason: '$m $o');
            }
          }
        }
      }
    });

    test('the drill leans towards measures you miss', () {
      final stats = {'辆': (0, 6)};
      var n = 0;
      for (var seed = 0; seed < 30; seed++) {
        n += buildMeasureDrill(random: Random(seed), stats: stats).where((q) => q.tag == '辆').length;
      }
      expect(n / 30, greaterThan(10 / 13), reason: 'more than an even share');
    });

    testWidgets('drill answers are scored per counting word', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: MeasureWordsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('Counting words 量词'), findsOneWidget);
      await tester.tap(find.text('START THE DRILL'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 of 10'), findsOneWidget);
      await tester.tap(find.text('1').first); // pick the first option
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(progress.measureStats.values.fold(0, (a, s) => a + s.$2), 1);
    });
  });

  group('radicals', () {
    test('data is tidy, and plain characters have none of the radicals', () {
      expect(radicals.map((r) => r.form).toSet(), hasLength(radicals.length));
      final all = {for (final r in radicals) ...r.chars.map((c) => c.$1)};
      for (final r in radicals) {
        expect(r.chars.length, greaterThanOrEqualTo(3), reason: r.form);
        expect(r.chars.map((c) => c.$1).toSet(), hasLength(r.chars.length), reason: r.form);
      }
      for (final c in plainChars) {
        expect(all, isNot(contains(c)));
      }
    });

    test('quiz questions are valid', () {
      for (var seed = 0; seed < 20; seed++) {
        for (final q in [...buildRadicalQuiz(random: Random(seed)), ...buildRadicalQuiz(random: Random(seed), only: radicals[seed % radicals.length], count: 4)]) {
          expect(q.options.toSet(), hasLength(3));
          expect(q.correct, inInclusiveRange(0, 2));
        }
      }
    });

    testWidgets('the grid opens a radical and its quiz', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      await tester.pumpWidget(MaterialApp(home: RadicalsScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('氵'));
      await tester.pumpAndSettle();
      expect(find.text('氵 · 三点水'), findsOneWidget);
      expect(find.text('河'), findsOneWidget);
      await tester.tap(find.text('Quick quiz on 氵'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 of 4'), findsOneWidget);
    });
  });

  group('idiom stories', () {
    test('every story lines up and every word can be looked up', () {
      final missing = <String>{};
      for (final i in idioms) {
        expect(i.chars.length, 4, reason: i.chars);
        expect(i.pinyin.split(' '), hasLength(4), reason: i.chars);
        expect(i.storyA.toSet(), hasLength(3), reason: i.chars);
        for (final (_, at) in i.panels) {
          expect(at, lessThan(i.story.length));
        }
        for (final line in i.story) {
          expect(() => rubyWords(line), returnsNormally, reason: line.zh);
          for (final t in line.tokens) {
            if (!tbPunctuation.contains(t) && idiomWord(t) == null) missing.add(t);
          }
        }
      }
      expect(missing, isEmpty);
      expect(idioms.map((i) => i.id).toSet(), hasLength(idioms.length));
    });

    test('the quiz has a right answer each time', () {
      for (var seed = 0; seed < 20; seed++) {
        for (final i in idioms) {
          final qs = buildIdiomQuiz(i, random: Random(seed));
          expect(qs, hasLength(4));
          for (final q in qs.cast<TbChoice>()) {
            expect(q.options.toSet(), hasLength(3), reason: '${i.chars} ${q.heading}');
          }
          final gap = qs[1] as TbChoice;
          expect(gap.prompt.replaceFirst('＿', gap.options[gap.correct]), i.chars);
        }
      }
    });

    testWidgets('read a story and finish its quiz', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2400));
      await tester.pumpWidget(MaterialApp(home: IdiomsScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('画蛇添足'));
      await tester.pumpAndSettle();
      expect(find.text('"draw a snake and add feet"'), findsOneWidget);
      await tester.tap(find.text('TAKE THE QUIZ'));
      await tester.pumpAndSettle();
      final i = idiomById('id-snake');
      await _answer(tester, i.meaning);
      // The gap question: find which character is missing from the prompt.
      final prompt = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').firstWhere((s) => s.contains('＿') && s.length == 4);
      await _answer(tester, i.chars[prompt.indexOf('＿')]);
      await _answer(tester, i.chars);
      await tester.tap(find.text(i.storyA.first));
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('+16 XP'), findsOneWidget);
      expect(progress.idiomsRead, contains('id-snake'));
    });
  });

  group('write from memory', () {
    test('picks characters that have stroke data', () async {
      final picked = pickMemoryChars(const [], StrokeLibrary.instance.has, random: Random(1));
      expect(picked, isNotEmpty);
      for (final (c, w) in picked) {
        expect(StrokeLibrary.instance.has(c), isTrue);
        expect(w.hanzi, contains(c));
      }
      final learned = lessonsOf(1).take(4).expand((l) => l.words).toList();
      final five = pickMemoryChars(learned, StrokeLibrary.instance.has, random: Random(2));
      expect(five, hasLength(5));
      expect(five.map((e) => e.$1).toSet(), hasLength(5));
    });

    test('every textbook character to write has stroke data', () {
      for (final l in tbLessons) {
        for (final c in l.chars.where((c) => c.write)) {
          expect(StrokeLibrary.instance.has(c.char), isTrue, reason: '${c.char} in ${l.title}');
        }
      }
    });

    testWidgets('the screen shows a gap and no outline', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: MemoryWritingScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Write from memory · 1 of'), findsOneWidget);
      expect(find.textContaining('□'), findsOneWidget);
    });
  });

  group('update check', () {
    test('compares versions', () {
      expect(isNewerVersion('v1.2.1', '1.2.0'), isTrue);
      expect(isNewerVersion('1.10.0', '1.9.3'), isTrue);
      expect(isNewerVersion('v2.0.0', '1.99.99'), isTrue);
      expect(isNewerVersion('v1.2.0', '1.2.0'), isFalse);
      expect(isNewerVersion('v1.1.0', '1.2.0'), isFalse);
      expect(isNewerVersion('nonsense', '1.2.0'), isFalse);
    });

    test('appVersion matches pubspec.yaml', () {
      final v = RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1);
      expect(appVersion, v);
    });

    test('finds a newer release, at most once a day', () async {
      final progress = await _fresh();
      final u = UpdateChecker.instance;
      var calls = 0;
      u.fetcher = () async {
        calls++;
        return '{"tag_name":"v9.0.0","html_url":"https://example.com/r","draft":false,"prerelease":false}';
      };
      final found = await u.check(progress);
      expect(found?.version, '9.0.0');
      expect(u.available?.url, 'https://example.com/r');
      await u.check(progress);
      expect(calls, 1, reason: 'already checked today');
      await u.check(progress, force: true);
      expect(calls, 2);
      u.fetcher = () async => '{"tag_name":"v1.0.0"}';
      expect(await u.check(progress, force: true), isNull);
      u.fetcher = () async => null; // no internet
      expect(await u.check(progress, force: true), isNull);
      Settings.instance.updateCheck = false;
      await progress.reset();
      calls = 0;
      u.fetcher = () async {
        calls++;
        return null;
      };
      await u.check(progress);
      expect(calls, 0, reason: 'turned off in Settings');
      Settings.instance.updateCheck = true;
    });

    testWidgets('settings shows the version and the switch', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      await tester.pumpWidget(MaterialApp(home: SettingsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('Hanzi Steps $appVersion'), findsOneWidget);
      expect(find.text('Tell me when a new version is out'), findsOneWidget);
    });
  });

  group('weekly report', () {
    test('adds up time, words and XP for this week and last', () async {
      final progress = await _fresh();
      await progress.addSeconds(600);
      await progress.finishLesson(allLessons.first, 10, results: {for (final w in allLessons.first.words) w.hanzi: true});
      final r = WeeklyReport.of(progress);
      expect(r.now.minutes, 10);
      expect(r.now.xp, 10);
      expect(r.now.newWords, allLessons.first.words.length);
      expect(r.now.activeDays, 1);
      expect(r.before.xp, 0);
      expect(r.weakestTone, isNull);
      for (var i = 0; i < 3; i++) {
        await progress.recordTone(3, false);
        await progress.recordTone(1, true);
      }
      expect(WeeklyReport.of(progress).weakestTone?.$1, 3);
    });

    test('comes up once a week after a few days of practice', () async {
      final now = DateTime.now();
      String key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final days = {for (var i = 0; i < 3; i++) key(now.subtract(Duration(days: i))): 10};
      var progress = await _fresh({'xpDays': '{${days.entries.map((e) => '"${e.key}":${e.value}').join(',')}}'});
      expect(reportDue(progress), isTrue);
      await progress.setReportSeen();
      expect(reportDue(progress), isFalse);
      expect(reportDue(progress, now: now.add(const Duration(days: 7))), isTrue);
      progress = await _fresh();
      expect(reportDue(progress), isFalse, reason: 'nothing done yet');
    });

    testWidgets('the report page opens', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: WeeklyReportScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('Time in the app'), findsOneWidget);
      expect(find.text('Trickiest words'), findsOneWidget);
      expect(progress.reportSeen, Progress.todayKey);
    });
  });

  test('new badges are listed', () async {
    final progress = await _fresh();
    for (final id in ['challenge7', 'measure30', 'memory20', 'radicals30', 'idioms']) {
      expect(badges.map((b) => b.id), contains(id));
    }
    await progress.bump('memoryRight', 20);
    expect(earnedBadges(progress), contains('memory20'));
  });

  testWidgets('home screen shows the challenge and opens the new activities', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 2200));
    await tester.pumpWidget(MaterialApp(home: HomeScreen(progress: progress)));
    await tester.pumpAndSettle();
    expect(find.text('DAILY CHALLENGE'), findsOneWidget);
    expect(progress.challengeState['day'], Progress.todayKey, reason: 'started when first shown');
    for (final (tile, title) in [
      ('Counting words', 'Counting words 量词'),
      ('From memory', 'Write from memory · 1 of 5'),
      ('Idiom stories', 'Idiom stories 成语故事'),
      ('Radicals', 'Radicals 部首'),
    ]) {
      await tester.tap(find.text(tile).first);
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: tile);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
