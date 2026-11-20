import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/culture.dart';
import 'package:hanzi_steps/data/look_alikes.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/exercises.dart';
import 'package:hanzi_steps/logic/numbers.dart';
import 'package:hanzi_steps/logic/panda.dart';
import 'package:hanzi_steps/logic/placement.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/word_lookup.dart';
import 'package:hanzi_steps/screens/culture_screen.dart';
import 'package:hanzi_steps/screens/dictation_screen.dart';
import 'package:hanzi_steps/screens/home_screen.dart';
import 'package:hanzi_steps/screens/lesson_screen.dart';
import 'package:hanzi_steps/screens/look_alikes_screen.dart';
import 'package:hanzi_steps/screens/my_words_screen.dart';
import 'package:hanzi_steps/screens/numbers_screen.dart';
import 'package:hanzi_steps/screens/placement_screen.dart';
import 'package:hanzi_steps/screens/word_search_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:hanzi_steps/widgets/panda.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  Speech.instance.available.value = false;
  await Settings.instance.load();
  Settings.instance.level = 1;
  return Progress.load();
}

void main() {
  setUp(() => loopingAnimations = false);

  group('numbers in real life', () {
    test('writes numbers the way they are said', () {
      const cases = {
        0: '零', 7: '七', 10: '十', 12: '十二', 20: '二十', 22: '二十二', 100: '一百', 105: '一百零五',
        110: '一百一十', 115: '一百一十五', 1000: '一千', 1005: '一千零五', 1015: '一千零一十五', 1200: '一千二百',
      };
      cases.forEach((n, zh) => expect(chineseNumber(n), zh, reason: '$n'));
      expect(chineseNumber(2, liang: true), '两');
      expect(chineseNumber(200, liang: true), '两百');
      expect(chineseNumber(12, liang: true), '十二', reason: '两 is only for a 2 on its own or before 百 and 千');
      expect(numberPinyin('一百'), 'yìbǎi');
      expect(numberPinyin('一千'), 'yìqiān');
      expect(numberPinyin('十二'), "shí'èr");
    });

    test('prices, phone numbers, dates and times', () {
      expect(price(3, 5).hanzi, '三块五');
      expect(price(3, 5).figures, '¥3.50');
      expect(price(2, 0).hanzi, '两块');
      expect(price(0, 5).hanzi, '五毛');
      expect(price(12, 2).pinyin, "shí'èr kuài èr");

      final p = phone('13812345678');
      expect(p.hanzi, '幺三八，幺二三四，五六七八');
      expect(p.figures, '138 1234 5678');
      expect(p.pinyin, startsWith('yāo sān bā'));

      final d = date(11, 20, weekday: 5);
      expect(d.hanzi, '十一月二十号，星期五');
      expect(d.figures, 'Friday 20 November');
      expect(d.pinyin, 'shíyī yuè èrshí hào xīngqīwǔ');
      expect(date(1, 1, year: 2026).hanzi, '二零二六年一月一号');
      expect(date(3, 2, weekday: 7).pinyin, endsWith('xīngqītiān'));

      expect(clockTime(14, 30).hanzi, '下午两点半');
      expect(clockTime(14, 30).pinyin, 'xiàwǔ liǎng diǎn bàn');
      expect(clockTime(8, 15, useKe: true).hanzi, '早上八点一刻');
      expect(clockTime(12, 5).hanzi, '中午十二点零五分');
      expect(clockTime(21, 45).figures, '21:45');
    });

    test('wrong answers are different from the answer and from each other', () {
      final r = Random(3);
      for (final kind in NumberKind.values) {
        for (var i = 0; i < 200; i++) {
          final n = randomLifeNumber(kind, r);
          final wrong = numberDistractors(n, r);
          expect(wrong, hasLength(3), reason: n.figures);
          expect(wrong.map((w) => w.figures).toSet(), hasLength(3), reason: n.figures);
          expect(wrong.any((w) => w.figures == n.figures), isFalse, reason: n.figures);
        }
      }
    });

    test('a round has 10 questions and choice questions include the answer', () {
      for (final kind in [...NumberKind.values, null]) {
        final round = buildNumberRound(kind, voice: true, random: Random(5));
        expect(round, hasLength(10));
        for (final q in round) {
          if (q.ask == NumberAsk.type) {
            expect(q.answer.kind, NumberKind.phone);
          } else {
            expect(q.options, contains(q.answer));
            expect(q.options, hasLength(4));
          }
        }
      }
    });

    testWidgets('type a phone number, then pick a price', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final phoneQ = NumberQuestion(phone('13912345678'), NumberAsk.type, const []);
      final priceAnswer = price(3, 5);
      final priceQ = NumberQuestion(priceAnswer, NumberAsk.read, [price(5, 3), priceAnswer, price(13, 5), price(3, 0)]);
      await tester.pumpWidget(MaterialApp(home: NumberRoundScreen(progress: progress, questions: [phoneQ, priceQ])));
      await tester.pumpAndSettle();
      expect(find.text(phoneQ.answer.pinyin), findsOneWidget, reason: 'without a voice the pinyin is shown');
      await tester.enterText(find.byKey(const ValueKey('digitsInput')), '139 1234 5678');
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('三块五'), findsOneWidget);
      await tester.tap(find.text('¥3.50'));
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('Numbers round done!'), findsOneWidget);
      expect(progress.count('numbersRight'), 2);
      expect(progress.xp, 7);
    });
  });

  group('look-alike characters', () {
    test('every group is sound', () {
      final ids = <String>{};
      for (final g in lookAlikeGroups) {
        expect(ids.add(g.id), isTrue, reason: 'duplicate id ${g.id}');
        expect(g.chars.length, greaterThanOrEqualTo(2), reason: g.id);
        expect(g.chars.map((c) => c.char).toSet(), hasLength(g.chars.length), reason: g.id);
        for (final c in g.chars) {
          expect(c.example, contains(c.char), reason: c.example);
          expect(c.gap, contains('＿'), reason: c.example);
          // The other characters of the group must not already be in the example.
          for (final o in g.chars.where((o) => o != c)) {
            expect(c.gap.contains(o.char), isFalse, reason: '${c.example} contains ${o.char}');
          }
        }
      }
    });

    test('a drill has 10 questions; a one-group drill asks each character twice', () async {
      final progress = await _fresh();
      expect(buildLookAlikeDrill(progress, random: Random(1)), hasLength(10));
      final g = lookAlikeGroups.firstWhere((g) => g.id == 'qing');
      final qs = buildLookAlikeDrill(progress, only: g, random: Random(1));
      expect(qs, hasLength(g.chars.length * 2));
      for (final c in g.chars) {
        expect(qs.where((q) => q.answer == c), hasLength(2));
      }
    });

    testWidgets('answer a look-alike question', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final g = lookAlikeGroups.firstWhere((g) => g.id == 'mai');
      final q = LookAlikeQuestion(g, g.chars[1], true, g.chars);
      await tester.pumpWidget(MaterialApp(home: LookAlikeDrill(progress: progress, questions: [q])));
      await tester.pumpAndSettle();
      expect(find.text('＿东西'), findsOneWidget);
      await tester.tap(find.text('卖'));
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      expect(progress.lookAlikeStats['mai'], (1, 1));
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('Drill done!'), findsOneWidget);
    });

    testWidgets('the list opens', (tester) async {
      final progress = await _fresh();
      await tester.pumpWidget(MaterialApp(home: LookAlikesScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('人 · 入 · 八'));
      await tester.pumpAndSettle();
      expect(find.text('Practise this group'), findsOneWidget);
    });
  });

  group('dictation', () {
    test('a beginner gets sentences from the first lessons', () async {
      final progress = await _fresh();
      final items = dictationSentences(progress, random: Random(2));
      expect(items, hasLength(8));
      expect(items.map((e) => e.$1).toSet(), hasLength(8));
    });

    test('sentences come from finished lessons', () async {
      final progress = await _fresh();
      final done = lessonsOf(1).where((l) => l.sentences.isNotEmpty).take(4).toList();
      for (final l in done) {
        await progress.finishLesson(l, 10);
      }
      final items = dictationSentences(progress, n: 6, random: Random(2));
      for (final (_, l) in items) {
        expect(done, contains(l));
      }
    });

    testWidgets('build a heard sentence from tiles', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      final lesson = lessonsOf(1).firstWhere((l) => l.sentences.isNotEmpty);
      final s = lesson.sentences.first;
      await tester.pumpWidget(MaterialApp(home: DictationScreen(progress: progress, items: [(s, lesson)])));
      await tester.pumpAndSettle();
      expect(find.text('Read the pinyin, then build the sentence'), findsOneWidget);
      // Tap the tiles in order: the bank is the lower row (the last match of each word).
      for (final t in s.tiles) {
        await tester.tap(find.text(t).last);
        await tester.pump();
      }
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      expect(progress.count('dictationRight'), 1);
    });

    testWidgets('type a heard sentence in pinyin, with or without tones', (tester) async {
      final progress = await _fresh();
      Speech.instance.available.value = true; // pretend there's a voice
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      const s = Sentence(['我', '是', '学生'], 'wǒ shì xuésheng', 'I am a student.');
      final lesson = lessonsOf(1).firstWhere((l) => l.sentences.isNotEmpty);
      await tester.pumpWidget(MaterialApp(home: DictationScreen(progress: progress, items: [(s, lesson), (s, lesson)])));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Type pinyin'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('dictationInput')), 'wo shi xuesheng');
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      expect(find.textContaining('Add tone numbers next time'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('dictationInput')), 'wo3 shi2 xue2sheng');
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Not quite'), findsOneWidget, reason: 'shì is the 4th tone');
      Speech.instance.available.value = false;
    });
  });

  group('word search and my words', () {
    test('finds words by characters, pinyin and English', () {
      expect(searchWords('好').first.hanzi, '好');
      expect(searchWords('hao').first.hanzi, '好');
      expect(searchWords('hao').map((w) => w.hanzi), isNot(contains('找')), reason: 'zhao is not hao');
      expect(searchWords('hao').map((w) => w.hanzi), contains('爱好'), reason: 'hao as a later syllable');
      expect(searchWords('hao4').map((w) => w.hanzi), contains('号'));
      expect(searchWords('hao4').map((w) => w.hanzi), isNot(contains('好')));
      expect(searchWords('teacher').map((w) => w.hanzi), contains('老师'));
      expect(searchWords('nü').map((w) => w.hanzi), contains('女'));
      expect(searchWords('xyzzy'), isEmpty);
    });

    test('looks up course words and story extras, and where they are taught', () {
      expect(lookupWord('老师')!.pinyin, 'lǎoshī');
      expect(lookupWord('小明')!.hsk, isFalse);
      expect(lookupWord('不是一个词'), isNull);
      expect(whereTaught('你')!.$2.id, 'greet-1');
      expect(lookAlikesFor('休息').map((g) => g.id), contains('xiu-ti'));
    });

    testWidgets('save a word from search and practise My words', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: WordSearchScreen(progress: progress, initialQuery: 'teacher')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('老师'));
      await tester.pumpAndSettle();
      expect(find.text('Add to My words'), findsOneWidget);
      await tester.tap(find.text('Add to My words'));
      await tester.pumpAndSettle();
      expect(find.text('In My words'), findsOneWidget);
      expect(progress.myWords, ['老师']);
      await progress.toggleMyWord('学生');

      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: MyWordsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('2 saved words. Tap ★ to remove one.'), findsOneWidget);
      await tester.tap(find.text('PRACTISE THESE'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget, reason: 'a practice lesson opened');
    });

    test('toggling a word twice takes it off the list', () async {
      final progress = await _fresh();
      expect(await progress.toggleMyWord('猫'), isTrue);
      expect(await progress.toggleMyWord('狗'), isTrue);
      expect(progress.myWords, ['狗', '猫'], reason: 'newest first');
      expect(await progress.toggleMyWord('猫'), isFalse);
      expect(progress.myWords, ['狗']);
    });
  });

  group('placement test', () {
    test('steps cover every word unit, and skipping includes the tones unit', () {
      for (final level in levels) {
        final steps = placementSteps(level);
        final covered = steps.expand((s) => s.lessons).toSet();
        for (final l in lessonsOf(level).where((l) => l.kind == LessonKind.vocab)) {
          expect(covered, contains(l), reason: l.id);
        }
      }
      final skip = lessonsToSkip(1, 1);
      expect(skip.first, lessonsOf(1).first, reason: 'the tones lessons come first');
      expect(skip.any((l) => l.kind == LessonKind.tones), isTrue);
      expect(lessonsToSkip(1, 0), isEmpty);
      expect(stepPassed(2, 3), isTrue);
      expect(stepPassed(1, 3), isFalse);
    });

    test('questions are about words from their step', () {
      final step = placementSteps(2)[1];
      for (final q in placementQuestions(step, 2, random: Random(7))) {
        expect(step.words, contains(q.word));
        expect(q.options, contains(q.word));
        expect(q.options.map((o) => o.meaning).toSet(), hasLength(4));
      }
    });

    test('skipped lessons are done and their words come back over two weeks', () async {
      final progress = await _fresh();
      final skip = lessonsToSkip(1, 2);
      await progress.skipLessons(skip);
      expect(skip.every(progress.isDone), isTrue);
      expect(progress.placementSeen, isTrue);
      expect(progress.dueWords, isEmpty, reason: 'nothing is due on the same day');
      expect(progress.wordsLearned, greaterThan(20));
    });

    testWidgets('know the first part, then stop', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlacementScreen(progress: progress))),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      final first = placementSteps(1).first.words;
      // Part 1: answer right.
      for (var i = 0; i < 3; i++) {
        final askMeaning = find.text('What does this mean?').evaluate().isNotEmpty;
        final w = askMeaning
            ? first.firstWhere((w) => find.text(w.hanzi).evaluate().isNotEmpty)
            : first.firstWhere((w) => find.text('Which one means "${w.meaning}"?').evaluate().isNotEmpty);
        await tester.tap(find.text(askMeaning ? w.meaning : w.hanzi).last);
        await tester.pumpAndSettle();
      }
      // Part 2: don't know.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('I don\'t know (0)'));
        await tester.pumpAndSettle();
      }
      final unit = placementSteps(1).first.units.last;
      expect(find.text('You know HSK 1 up to "${unit.title}"'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('skipLessons')));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(lessonsToSkip(1, 1).every(progress.isDone), isTrue);
    });
  });

  group('culture notes', () {
    test('each note belongs to a real lesson, one note per lesson', () {
      final ids = {for (final l in allLessons) l.id};
      final seen = <String>{};
      for (final n in cultureNotes) {
        expect(ids, contains(n.lessonId), reason: n.title);
        expect(seen.add(n.lessonId), isTrue, reason: 'two notes for ${n.lessonId}');
        expect(n.text.length, greaterThan(60), reason: n.title);
      }
      expect(cultureNotes.length, greaterThanOrEqualTo(30));
    });

    test('a lesson with a note shows it', () {
      final lesson = allLessons.firstWhere((l) => l.id == 'food-1');
      final steps = buildLesson(lesson, random: Random(1));
      expect(steps.whereType<CultureStep>(), hasLength(1));
    });

    testWidgets('the culture page opens a note', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: CultureScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(cultureNotes.first.title));
      await tester.pumpAndSettle();
      expect(find.text('DID YOU KNOW?'), findsOneWidget);
    });
  });

  group('pet panda', () {
    test('grows with XP', () {
      expect(pandaStageFor(0), 0);
      expect(pandaStageFor(149), 0);
      expect(pandaStageFor(150), 1);
      expect(pandaStageFor(5000), pandaStages.length - 1);
    });

    test('its mood follows your reviews and your daily goal', () {
      expect(pandaMood(daysAway: null, due: 0, goalMet: false), PandaMood.asleep);
      expect(pandaMood(daysAway: 0, due: 0, goalMet: true), PandaMood.happy);
      expect(pandaMood(daysAway: 0, due: 2, goalMet: false), PandaMood.content);
      expect(pandaMood(daysAway: 0, due: 8, goalMet: true), PandaMood.hungry);
      expect(pandaMood(daysAway: 0, due: 25, goalMet: true), PandaMood.sad);
      expect(pandaMood(daysAway: 4, due: 0, goalMet: false), PandaMood.sad);
      expect(pandaSays(PandaMood.sad, name: 'Bao', due: 0, daysAway: 4), isNot(contains('0 words')));
    });

    testWidgets('the panda card shows its name and can be fed', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await progress.finishLesson(lessonsOf(1)[2], 20); // a word lesson: its words are due for review
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PandaCard(progress: progress))));
      await tester.pumpAndSettle();
      expect(find.text('Bamboo'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
      await progress.setPandaName('Bao');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PandaCard(progress: progress))));
      await tester.pumpAndSettle();
      expect(find.text('Bao'), findsOneWidget);
    });

    test('new badges', () async {
      final progress = await _fresh();
      for (final id in ['numbers30', 'looks30', 'dictation10', 'mywords10', 'panda']) {
        expect(badges.any((b) => b.id == id), isTrue, reason: id);
      }
      await progress.bump('dictationRight', 10);
      expect(earnedBadges(progress), contains('dictation10'));
    });
  });

  testWidgets('home screen opens the new activities', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 2000));
    await tester.pumpWidget(MaterialApp(home: HomeScreen(progress: progress)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Already know some Chinese?'), findsOneWidget);
    for (final (tile, title) in [
      ('Numbers', 'Numbers in real life'),
      ('Look-alikes', 'Look-alike characters'),
      ('Dictation', 'Dictation · 1 of 8'),
      ('Culture', 'Culture notes'),
      ('My words', 'My words'),
      ('Placement test', 'Placement test'),
    ]) {
      await tester.tap(find.text(tile).first);
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: tile);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Word search').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('searchInput')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    // Dismissing the placement card hides it.
    await tester.tap(find.byTooltip('No thanks'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Already know some Chinese?'), findsNothing);
  });
}
