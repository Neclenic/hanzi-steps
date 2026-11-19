import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/char_stories.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/dialogues.dart';
import 'package:hanzi_steps/data/exam.dart';
import 'package:hanzi_steps/data/grammar.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/exam.dart';
import 'package:hanzi_steps/logic/pinyin_input.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/tone_pairs.dart';
import 'package:hanzi_steps/screens/dialogue_screen.dart';
import 'package:hanzi_steps/screens/exam_screen.dart';
import 'package:hanzi_steps/screens/games_screen.dart';
import 'package:hanzi_steps/screens/grammar_screen.dart';
import 'package:hanzi_steps/screens/home_screen.dart';
import 'package:hanzi_steps/screens/stats_screen.dart';
import 'package:hanzi_steps/screens/tone_pairs_screen.dart';
import 'package:hanzi_steps/screens/typing_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _punctuation = {'，', '。', '？', '！', '、'};

/// Words taught in [lessonId] and every lesson before it.
Set<String> _knownBy(String lessonId) {
  final known = <String>{};
  for (final l in allLessons) {
    known.addAll(l.words.map((w) => w.hanzi));
    if (l.id == lessonId) break;
  }
  return known;
}

Future<Progress> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  Speech.instance.available.value = false;
  await Settings.instance.load();
  return Progress.load();
}

void main() {
  setUp(() => loopingAnimations = false);

  group('tone pairs', () {
    test('there are 20 pairs and each has at least four example words', () {
      expect(tonePairs, hasLength(20));
      for (final p in tonePairs) {
        expect(tonePairExamples[p]!.length, greaterThanOrEqualTo(4), reason: p.label);
        for (final w in tonePairExamples[p]!) {
          expect(pairOf(w), p, reason: w.hanzi);
        }
      }
    });

    test('a quiz has four different options and the answer is one of them', () async {
      final progress = await _fresh();
      for (var seed = 0; seed < 30; seed++) {
        for (final q in buildPairQuiz(progress, random: Random(seed))) {
          expect(q.options.toSet(), hasLength(4));
          expect(q.correct, greaterThanOrEqualTo(0));
          expect(pairOf(q.word), q.pair);
        }
      }
    });

    testWidgets('answer a tone quiz question', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final qs = buildPairQuiz(progress, n: 2, random: Random(4));
      await tester.pumpWidget(MaterialApp(home: TonePairQuiz(progress: progress, questions: qs)));
      await tester.pumpAndSettle();
      expect(find.text(qs.first.word.hanzi), findsOneWidget, reason: 'without a voice, the word is shown');
      await tester.tap(find.text('Tone ${qs.first.pair.label}'));
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      expect(progress.pairStats[qs.first.pair.key], (1, 1));
    });

    testWidgets('the tone pairs page shows the grid', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: TonePairsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.byType(PairShape), findsNWidgets(20));
    });
  });

  group('typing pinyin', () {
    const nihao = Word('你好', 'nǐ hǎo', 'hello');
    const xiexie = Word('谢谢', 'xièxie', 'thank you');
    const nver = Word('女儿', "nǚ'ér", 'daughter');
    const yidianr = Word('一点儿', 'yìdiǎnr', 'a little');

    test('turns tone numbers into tone marks', () {
      expect(numberedToMarked('ni3hao3'), 'nǐhǎo');
      expect(numberedToMarked('xie4xie'), 'xièxie');
      expect(numberedToMarked('nv3er2'), 'nǚér');
      expect(numberedToMarked('gou3'), 'gǒu');
      expect(numberedToMarked('dui4'), 'duì');
      expect(numberedToMarked('liu4'), 'liù');
    });

    test('accepts the right answer typed in different ways', () {
      for (final typed in ['ni3hao3', 'ni3 hao3', 'Ni3Hao3', 'nǐhǎo', 'nǐ hǎo']) {
        expect(checkTyped(typed, nihao).ok, isTrue, reason: typed);
      }
      for (final typed in ['xie4xie', 'xie4xie5', 'xie4xie0', 'xièxie']) {
        expect(checkTyped(typed, xiexie).ok, isTrue, reason: typed);
      }
      expect(checkTyped('nv3er2', nver).ok, isTrue);
      expect(checkTyped("nü3'er2", nver).ok, isTrue);
      // 一 can be typed with its own tone or with the changed one.
      expect(checkTyped('yi4dian3r', yidianr).ok, isTrue);
      expect(checkTyped('yi1dian3r', yidianr).ok, isTrue);
    });

    test('notices wrong tones and wrong sounds', () {
      final c = checkTyped('ni2hao3', nihao);
      expect(c.lettersOk, isTrue);
      expect(c.tonesOk, isFalse);
      expect(checkTyped('ni3hao', nihao).ok, isFalse, reason: 'a missing tone is wrong');
      expect(checkTyped('ni3hai3', nihao).lettersOk, isFalse);
      expect(checkTyped('xie4xie4', xiexie).ok, isFalse);
    });

    test('every course word can be typed back from its own pinyin', () {
      for (final w in allWords) {
        expect(checkTyped(w.pinyin, w).ok, isTrue, reason: '${w.hanzi} ${w.pinyin}');
      }
    });

    testWidgets('type an answer and see it checked', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: TypingScreen(progress: progress, words: const [nihao, xiexie])));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ni3hao3');
      await tester.pump();
      expect(find.text('nǐhǎo'), findsOneWidget, reason: 'live preview');
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xie3xie');
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Not quite'), findsOneWidget);
      expect(find.textContaining('The sounds are right'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('Typing round done!'), findsOneWidget);
      expect(progress.count('typedRight'), 1);
    });
  });

  group('character stories', () {
    test('every story is for a character used in the course', () {
      final chars = {for (final w in allWords) ...w.hanzi.split('')};
      final seen = <String>{};
      for (final s in charStories) {
        expect(chars, contains(s.char), reason: s.char);
        expect(seen.add(s.char), isTrue, reason: 'two stories for ${s.char}');
        expect(s.hint, isNotEmpty);
      }
      expect(storiesFor('你好').map((s) => s.char), containsAll(['你', '好']));
    });
  });

  group('grammar tips', () {
    test('each tip belongs to a real lesson, one per lesson', () {
      final ids = allLessons.map((l) => l.id).toSet();
      final used = <String>{};
      for (final t in grammarTips) {
        expect(ids, contains(t.lessonId));
        expect(used.add(t.lessonId), isTrue, reason: 'two tips in ${t.lessonId}');
        expect(t.examples, isNotEmpty);
      }
    });

    test('examples only use words taught by that lesson', () {
      for (final t in grammarTips) {
        final known = _knownBy(t.lessonId);
        for (final e in t.examples) {
          expect(e.pinyin, isNotEmpty, reason: e.zh);
          expect(e.en, isNotEmpty, reason: e.zh);
          for (final w in e.zh.split(' ')) {
            if (_punctuation.contains(w)) continue;
            expect(known, contains(w), reason: '"$w" in ${t.lessonId}: ${e.zh}');
          }
        }
      }
    });

    testWidgets('the grammar page lists every tip', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 6000));
      await tester.pumpWidget(MaterialApp(home: GrammarScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(grammarTips.length));
      await tester.tap(find.text(grammarTips.first.title));
      await tester.pumpAndSettle();
      expect(find.text('GRAMMAR TIP'), findsOneWidget);
    });
  });

  group('dialogues', () {
    test('every word is a course word, and every reply has two wrong options', () {
      for (final d in dialogues) {
        expect(d.lines.any((l) => l.isYours), isTrue, reason: d.id);
        for (final l in d.lines) {
          for (final w in [l.zh, for (final x in l.wrong) x.$1].expand((s) => s.split(' '))) {
            if (_punctuation.contains(w) || dialogueNames.containsKey(w)) continue;
            expect(wordFor(w), isNotNull, reason: '"$w" in ${d.id}');
          }
          if (l.isYours) {
            expect(l.wrong, hasLength(2));
            expect(l.wrong.map((x) => x.$1), isNot(contains(l.zh)));
          }
        }
      }
      expect(dialogues.map((d) => d.id).toSet(), hasLength(dialogues.length));
      expect({for (final d in dialogues) dialogueLevel(d)}, containsAll([1, 2, 3]));
    });

    testWidgets('play a dialogue to the end', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      final d = dialogues.first;
      await tester.pumpWidget(MaterialApp(home: DialogueScreen(dialogue: d, progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START'));
      for (final line in d.lines.where((l) => l.isYours)) {
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        // Pick a wrong reply first, then the right one.
        await tester.tap(find.text(line.wrong.first.$1.replaceAll(' ', '')));
        await tester.pumpAndSettle();
        expect(find.text("That doesn't fit. Try another one."), findsOneWidget);
        await tester.tap(find.text(line.hanzi).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('CONTINUE'));
      }
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Conversation done!'), findsOneWidget);
      expect(progress.dialoguesDone, contains(d.id));
    });
  });

  group('mini exams for HSK 2 and 3', () {
    test('exam words are course words of the right level and questions make sense', () {
      for (final level in [2, 3]) {
        final set = examSets[level]!;
        for (final p in set.pictureWords) {
          expect(wordFor(p.hanzi), isNotNull, reason: p.hanzi);
        }
        for (final g in set.gaps) {
          for (final o in g.options) {
            expect(wordFor(o), isNotNull, reason: o);
          }
        }
        expect(set.pictureWords.map((p) => p.picture).toSet(), hasLength(set.pictureWords.length));
        expect(set.pictureSentences.map((p) => p.picture).toSet(), hasLength(set.pictureSentences.length));
        for (var seed = 0; seed < 100; seed++) {
          final qs = buildExam(level: level, random: Random(seed));
          expect(qs.where((q) => q.part == ExamPart.listening), hasLength(10));
          expect(qs.where((q) => q.part == ExamPart.reading), hasLength(10));
          expect(qs.where((q) => q.part == ExamPart.writing), hasLength(level == 3 ? examWritingQuestions : 0));
          for (final q in qs) {
            final keys = q.options.map((o) => '${o.label}${o.picture}').toList();
            expect(keys.toSet().length, keys.length, reason: 'duplicate options: ${q.text}');
          }
        }
      }
      for (final c in examChars3) {
        expect(c.options.toSet(), hasLength(3));
        expect(c.pinyin.toLowerCase(), contains(c.gapPinyin), reason: c.zh);
      }
      expect(examMaxFor(3), 300);
      expect(examPassFor(3), 180);
    });

    testWidgets('take the HSK 3 exam with full marks', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final qs = buildExam(level: 3, random: Random(7));
      await tester.pumpWidget(MaterialApp(home: ExamScreen(progress: progress, questions: qs, level: 3)));
      await tester.pump();
      for (final q in qs) {
        final o = q.options[q.correct];
        await tester.tap(find.text(o.picture ?? o.label).last);
        await tester.pump();
        await tester.tap(find.text(q == qs.last ? 'FINISH' : 'NEXT'));
        await tester.pump(const Duration(milliseconds: 400));
      }
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('300 / 300'), findsWidgets);
      expect(find.textContaining('Writing'), findsWidgets);
      expect(progress.bestExamFor(3), 300);
      expect(progress.examsPassed, contains(3));
      expect(progress.examFullMarks, isTrue);
    });
  });

  group('badges and stats', () {
    test('badges are earned from progress', () async {
      final progress = await _fresh();
      expect(earnedBadges(progress), isEmpty);
      await progress.finishLesson(allLessons.first, 10);
      expect(earnedBadges(progress), contains('first-lesson'));
      await progress.addXp(20);
      expect(earnedBadges(progress), contains('goal1'));
      expect(progress.goalDays, 1);
      expect(progress.bestStreak, 1);
      await progress.finishExam(200, 30, level: 1, passed: true, fullMarks: true);
      expect(earnedBadges(progress), containsAll(['exam', 'exam-full']));
      expect(badges.map((b) => b.id).toSet(), hasLength(badges.length));
    });

    test('tone, pair and word results are remembered', () async {
      final progress = await _fresh();
      await progress.recordTone(3, false);
      await progress.recordTone(3, true);
      await progress.recordPair('3-4', false);
      await progress.recordAnswer('你', false);
      await progress.recordAnswer('你', false);
      expect(progress.toneStats[3], (1, 2));
      expect(progress.pairStats['3-4'], (0, 1));
      expect(progress.troubleWords.first.$1.hanzi, '你');
    });

    testWidgets('the stats page shows numbers, tones, words and badges', (tester) async {
      final progress = await _fresh();
      await progress.finishLesson(allLessons.first, 15);
      for (var i = 0; i < 4; i++) {
        await progress.recordTone(1 + i % 4, i.isEven);
      }
      await progress.recordAnswer('你', false);
      await tester.binding.setSurfaceSize(const Size(900, 4000));
      await tester.pumpWidget(MaterialApp(home: StatsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('Words you miss most'), findsOneWidget);
      expect(find.text('First steps'), findsOneWidget);
      expect(find.text('Practise these words'), findsOneWidget);
      expect(find.textContaining('of ${badges.length} earned'), findsOneWidget);
    });
  });

  group('quick games', () {
    test('game words never share a meaning', () async {
      final progress = await _fresh();
      final words = gameWords(progress);
      expect(words.length, greaterThanOrEqualTo(12));
      expect(words.map((w) => w.meaning).toSet(), hasLength(words.length));
    });

    testWidgets('speed match: a right pair scores, and the game ends on time', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      await tester.pumpWidget(MaterialApp(home: SpeedMatchGame(progress: progress, time: const Duration(seconds: 5))));
      await tester.pump();
      // Tap any character, then its meaning.
      final words = gameWords(progress);
      final w = words.firstWhere((w) => find.text(w.hanzi).evaluate().isNotEmpty);
      await tester.tap(find.text(w.hanzi));
      await tester.pump();
      await tester.tap(find.text(w.meaning));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1 pts'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text('1 points'), findsOneWidget);
      expect(progress.gameBest('match'), 1);
    });

    testWidgets('falling characters: catch the right one, lose lives on misses', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      await tester.pumpWidget(MaterialApp(home: FallingGame(progress: progress, random: Random(2))));
      final words = gameWords(progress);
      // Wait for the word asked for to fall into view, then catch it.
      String target() => (tester.widget<Text>(find.textContaining('"').first).data!).replaceAll('"', '');
      var caught = false;
      for (var i = 0; i < 100 && !caught; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        final w = words.firstWhere((w) => w.meaning == target());
        final tile = find.text(w.hanzi);
        if (tile.evaluate().isNotEmpty) {
          await tester.tap(tile, warnIfMissed: false);
          await tester.pump();
          caught = true;
        }
      }
      expect(caught, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1 pts'), findsOneWidget);
      // Leave it alone: the next targets reach the ground and the lives run out.
      for (var i = 0; i < 400 && find.textContaining('points').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('1 points'), findsOneWidget);
      expect(progress.gameBest('fall'), 1);
    });
  });

  testWidgets('home screen opens every new activity', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    await tester.pumpWidget(MaterialApp(home: HomeScreen(progress: progress)));
    await tester.pumpAndSettle();
    for (final (tile, title) in [
      ('Dialogues', 'Dialogues'),
      ('Tone pairs', 'Tone pairs'),
      ('Type pinyin', 'Type the pinyin · 1 of 10'),
      ('Games', 'Quick games'),
      ('Grammar', 'Grammar tips'),
      ('Stats & badges', 'Stats and badges'),
    ]) {
      await tester.tap(find.text(tile));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: tile);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    Settings.instance.level = 2;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mini exam'));
    await tester.pumpAndSettle();
    expect(find.text('Mini HSK 2 exam'), findsOneWidget);
    Settings.instance.level = 1;
  });
}
