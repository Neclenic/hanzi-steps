import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/textbook.dart';
import 'package:hanzi_steps/logic/pinyin_input.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/textbook.dart';
import 'package:hanzi_steps/screens/textbook_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:hanzi_steps/widgets/quiz_parts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  Speech.instance.available.value = false;
  await Settings.instance.load();
  return Progress.load();
}

void main() {
  setUp(() => loopingAnimations = false);

  test('textbook has 3 books, 9 units and 27 lessons', () {
    expect(tbUnitsOf(1).length, 3);
    expect(tbUnitsOf(2).length, 3);
    expect(tbUnitsOf(3).length, 3);
    expect(tbLessons.length, 27);
    for (final (i, l) in tbLessons.indexed) {
      expect(l.number, i + 1);
    }
    final ids = {for (final l in tbLessons) l.id, for (final u in tbUnits) u.corner.id};
    expect(ids.length, 36);
  });

  test('every line has one pinyin syllable per character', () {
    final lines = [
      for (final l in tbLessons) ...[...l.lines, l.speak.model],
      for (final u in tbUnits)
        for (final p in u.corner.poems) ...p.lines,
    ];
    for (final line in lines) {
      expect(() => rubyWords(line), returnsNormally, reason: line.zh);
    }
  });

  test('every word in the lessons can be looked up', () {
    final missing = <String>{};
    for (final l in tbLessons) {
      final spaced = [
        ...l.lines.map((x) => x.zh),
        l.speak.model.zh,
        for (final f in l.fills) f.zh,
        for (final a in l.asks) a.zh,
        for (final o in l.orders) o.zh,
      ];
      for (final s in spaced) {
        for (final t in s.split(' ')) {
          if (t.isEmpty || t == '＿' || tbPunctuation.contains(t)) continue;
          if (tbWord(t) == null) missing.add(t);
        }
      }
      for (final c in l.chars) {
        for (final w in c.words) {
          if (tbWord(w) == null) missing.add(w);
          expect(w.contains(c.char), isTrue, reason: '${c.char} in $w');
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('new characters appear in their lesson, and each lesson has some to write', () {
    for (final l in tbLessons) {
      final text = l.lines.map((x) => x.text).join() + l.titlePy;
      for (final c in l.chars) {
        expect(text.contains(c.char) || l.title.contains(c.char), isTrue, reason: '${c.char} in ${l.title}');
      }
      expect(l.chars.where((c) => c.write), isNotEmpty, reason: l.title);
      expect(l.chars.length, inInclusiveRange(5, 8));
    }
  });

  test('pinyin of new characters matches the text', () {
    for (final l in tbLessons) {
      final py = <String, Set<String>>{};
      for (final line in l.lines) {
        for (final (t, s) in rubyWords(line)) {
          for (var i = 0; i < s.length; i++) {
            py.putIfAbsent(t[i], () => {}).add(s[i].toLowerCase());
          }
        }
      }
      for (final c in l.chars) {
        if (py[c.char] == null) continue;
        // A light (toneless) syllable in the text is fine: 朋友 is péngyou.
        final ok = py[c.char]!.any((s) => s == c.pinyin || (s == pinyinLetters(s) && s == pinyinLetters(c.pinyin)));
        expect(ok, isTrue, reason: '${c.char} in ${l.title}: ${py[c.char]}');
      }
    }
  });

  test('gap-fills have one gap and answers that fit', () {
    for (final l in tbLessons) {
      for (final f in l.fills) {
        expect('＿'.allMatches(f.zh).length, 1, reason: f.zh);
        expect(f.options.toSet().length, 3, reason: f.zh);
      }
      for (final a in l.asks) {
        expect(a.options.toSet().length, 3, reason: a.zh);
      }
    }
  });

  test('exercises build for every lesson and unit, with a right answer each time', () {
    for (var seed = 0; seed < 20; seed++) {
      final r = Random(seed);
      for (final l in tbLessons) {
        final qs = buildTbExercises(l, random: r);
        expect(qs.length, greaterThanOrEqualTo(8), reason: l.title);
        for (final q in qs) {
          switch (q) {
            case TbChoice c:
              expect(c.options.length, 3, reason: c.prompt);
              expect(c.options.toSet().length, 3, reason: c.prompt);
              expect(c.correct, inInclusiveRange(0, 2));
            case TbBuild b:
              expect(b.isRight(b.answer), isTrue);
              expect(b.bank.toList()..sort(), b.answer.toList()..sort());
          }
        }
      }
      for (final u in tbUnits) {
        expect(buildTbReview(u, random: r).length, greaterThanOrEqualTo(8));
      }
    }
  });

  test('radical families: each character has the radical', () {
    const parts = {
      '女': ['妈', '姐', '妹', '她', '好', '奶'],
    };
    for (final u in tbUnits) {
      expect(u.corner.radical.chars.length, 6);
    }
    expect(tbUnits.first.corner.radical.chars.map((c) => c.$1), parts['女']);
  });

  testWidgets('every lesson and review corner page opens', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    for (final l in tbLessons) {
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: TbLessonScreen(progress: progress, lesson: l)));
      await tester.pumpAndSettle();
      expect(find.text(l.title), findsWidgets, reason: l.title);
      expect(find.text('DO THE EXERCISES'), findsOneWidget);
    }
    for (final u in tbUnits) {
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: TbCornerScreen(progress: progress, unit: u)));
      await tester.pumpAndSettle();
      expect(find.text(u.corner.poems.first.title), findsOneWidget);
    }
  });

  testWidgets('the book list switches books and opens a lesson', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    await tester.pumpWidget(MaterialApp(home: TextbookScreen(progress: progress)));
    await tester.pumpAndSettle();
    expect(find.text('数一数'), findsOneWidget);
    await tester.tap(find.text('第二册 · Book 2'));
    await tester.pumpAndSettle();
    expect(find.text('教室里'), findsOneWidget);
    await tester.tap(find.text('教室里'));
    await tester.pumpAndSettle();
    expect(find.text('New characters'), findsOneWidget);
  });

  testWidgets('do a lesson\'s exercises, all right, and it is marked done', (tester) async {
    final progress = await _fresh();
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    final lesson = tbLessons.firstWhere((l) => l.id == 'tb-9');
    final qs = buildTbExercises(lesson, random: Random(3));
    await tester.pumpWidget(MaterialApp(
      home: TbQuizScreen(
        title: 'test',
        build: () => qs,
        onFinish: (right, total) async {
          await progress.finishTextbook(lesson.id, 10 + right);
          return 10 + right;
        },
      ),
    ));
    await tester.pumpAndSettle();
    for (final q in qs) {
      switch (q) {
        case TbChoice c:
          await tester.tap(find.widgetWithText(AnswerTile, c.options[c.correct]));
        case TbBuild b:
          for (final w in b.answer) {
            await tester.tap(find.text(w).last);
            await tester.pump();
          }
      }
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
    }
    expect(find.text('练习完成！ Well done!'), findsOneWidget);
    expect(progress.textbookDone, contains('tb-9'));
    expect(progress.xp, 10 + qs.length);
  });
}
