import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/exam.dart';
import 'package:hanzi_steps/logic/exam.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/screens/exam_screen.dart';
import 'package:hanzi_steps/screens/home_screen.dart';
import 'package:hanzi_steps/screens/speaking_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pitch_test.dart' show voice, shapes;

void main() {
  setUp(() => loopingAnimations = false);

  group('HSK courses', () {
    test('HSK 2 and HSK 3 have about 150 and 300 words', () {
      expect(hskWordsOf(2).length, inInclusiveRange(145, 160));
      expect(hskWordsOf(3).length, inInclusiveRange(290, 320));
    });

    test('every lesson has at least four words and a sentence', () {
      for (final l in [...lessonsOf(2), ...lessonsOf(3)]) {
        expect(l.words.length, greaterThanOrEqualTo(4), reason: l.id);
        expect(l.sentences, isNotEmpty, reason: l.id);
      }
    });

    test('lesson ids are unique', () {
      final ids = allLessons.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('the first lesson of each HSK course is open', () async {
      SharedPreferences.setMockInitialValues({});
      final p = await Progress.load();
      expect(p.isUnlocked(lessonsOf(2).first), isTrue);
      expect(p.isUnlocked(lessonsOf(3).first), isTrue);
      expect(p.isUnlocked(lessonsOf(2)[1]), isFalse);
      await p.finishLesson(lessonsOf(2).first, 10);
      expect(p.isUnlocked(lessonsOf(2)[1]), isTrue);
    });
  });

  group('daily goal', () {
    test('XP counts towards today and the week', () async {
      SharedPreferences.setMockInitialValues({});
      final p = await Progress.load();
      var reached = 0;
      p.onGoalChanged = () => reached++;
      expect(p.dailyGoal, 20);
      await p.addXp(12);
      expect(p.xpToday, 12);
      expect(p.goalMetToday, isFalse);
      await p.finishStory('x', 10);
      expect(p.xpToday, 22);
      expect(p.goalMetToday, isTrue);
      expect(reached, 1);
      await p.addXp(5);
      expect(reached, 1, reason: 'only reported once a day');
      expect(p.lastWeekXp, [0, 0, 0, 0, 0, 0, 27]);
      await p.setDailyGoal(50);
      expect(p.goalMetToday, isFalse);
      expect(p.streak, 1);
    });
  });

  group('mini exam', () {
    test('every exam has 10 listening and 10 reading questions that make sense', () {
      for (var seed = 0; seed < 200; seed++) {
        final qs = buildExam(random: Random(seed));
        expect(qs.where((q) => q.part == ExamPart.listening).length, examQuestionsPerPart);
        expect(qs.where((q) => q.part == ExamPart.reading).length, examQuestionsPerPart);
        for (final q in qs) {
          expect(q.correct, inInclusiveRange(0, q.options.length - 1));
          final keys = q.options.map((o) => '${o.label}${o.picture}').toList();
          expect(keys.toSet().length, keys.length, reason: 'duplicate options: ${q.text}');
          if (q.part == ExamPart.listening) expect(q.speak, isNotNull);
        }
        // No question is asked twice in one exam.
        final texts = qs.where((q) => !q.trueFalse).map((q) => q.text).toList();
        expect(texts.toSet().length, texts.length);
      }
    });

    test('exam words are course words', () {
      for (final p in examPictureWords) {
        expect(wordFor(p.hanzi), isNotNull, reason: p.hanzi);
      }
      for (final g in examGaps) {
        for (final o in g.options) {
          expect(wordFor(o), isNotNull, reason: o);
        }
        expect(g.zh, contains('（  ）'));
      }
      final pics = examPictureSentences.map((s) => s.picture).toList();
      expect(pics.toSet().length, pics.length, reason: 'each sentence needs its own picture');
    });

    test('scoring matches the real HSK 1', () {
      expect(partScore(10) * 2, examMaxScore);
      expect(partScore(6) * 2, examPassScore);
    });

    testWidgets('take the exam and see the score', (tester) async {
      SharedPreferences.setMockInitialValues({});
      Speech.instance.available.value = false;
      await Settings.instance.load();
      final progress = await Progress.load();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final qs = buildExam(random: Random(3));
      await tester.pumpWidget(MaterialApp(home: ExamScreen(progress: progress, questions: qs)));
      await tester.pump();
      for (final q in qs) {
        // Answer every question correctly.
        final state = tester.state(find.byType(ExamScreen));
        expect(state, isNotNull);
        final o = q.options[q.correct];
        if (q.trueFalse) {
          await tester.tap(find.text(o.label).last);
        } else if (o.picture != null) {
          await tester.tap(find.text(o.picture!).last);
        } else {
          await tester.tap(find.text(o.label).last);
        }
        await tester.pump();
        await tester.tap(find.text(q == qs.last ? 'FINISH' : 'NEXT'));
        await tester.pump(const Duration(milliseconds: 400));
      }
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Pass!'), findsOneWidget);
      expect(progress.bestExam, 200);
      expect(progress.xp, greaterThan(0));
    });

    testWidgets('the exam ends when time runs out', (tester) async {
      SharedPreferences.setMockInitialValues({});
      Speech.instance.available.value = false;
      final progress = await Progress.load();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(
        home: ExamScreen(progress: progress, questions: buildExam(random: Random(1)), time: const Duration(seconds: 3)),
      ));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Not a pass yet'), findsOneWidget);
      expect(progress.bestExam, 0);
    });
  });

  group('speaking practice', () {
    test('checks the tones of a recording of 你好', () {
      // 你好 is said ní hǎo: a rising tone, then a dipping one.
      final samples = [...voice(shapes[2]!), ...voice(shapes[3]!, gap: 0.1)];
      final c = checkRecording(samples, 'nǐ hǎo', ref: 210);
      expect(c.problem, isNull);
      expect(c.expected, [2, 3]);
      expect(c.heard.map((h) => h!.tone), [2, 3]);
      expect(c.ok, isTrue);
    });

    test('notices a wrong tone', () {
      final c = checkRecording(voice(shapes[4]!), 'mā', ref: 210);
      expect(c.ok, isFalse);
      expect(c.heard.single!.tone, 4);
    });

    test('says so when it hears nothing', () {
      final c = checkRecording(List.filled(16000, 0.0), 'mā');
      expect(c.problem, isNotNull);
    });

    testWidgets('the speaking screen shows a word and its tones', (tester) async {
      SharedPreferences.setMockInitialValues({});
      Speech.instance.available.value = false;
      final progress = await Progress.load();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: SpeakingScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('妈'), findsOneWidget);
      expect(find.text('tone 1'), findsOneWidget);
      await tester.tap(find.text('My words'));
      await tester.pumpAndSettle();
      expect(find.textContaining('tone'), findsWidgets);
    });
  });

  testWidgets('home screen switches between HSK 1, 2 and 3', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Speech.instance.available.value = true;
    await Settings.instance.load();
    final progress = await Progress.load();
    await tester.binding.setSurfaceSize(const Size(900, 2200));
    await tester.pumpWidget(MaterialApp(home: HomeScreen(progress: progress)));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal: 20 XP'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Meet the four tones'), findsOneWidget);
    await tester.tap(find.text('HSK 2'));
    await tester.pumpAndSettle();
    expect(find.text('Brothers and sisters'), findsOneWidget);
    expect(find.text('START'), findsOneWidget, reason: 'HSK 2 can be started straight away');
    await tester.tap(find.text('HSK 3'));
    await tester.pumpAndSettle();
    expect(find.text('Grandparents'), findsOneWidget);
    expect(Settings.instance.level, 3);
    await tester.tap(find.text('Mini exam'));
    await tester.pumpAndSettle();
    expect(find.text('START THE EXAM'), findsOneWidget);
    Settings.instance.level = 1;
  });
}
