import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/logic/exercises.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/strokes.dart';
import 'package:hanzi_steps/widgets/character_writer.dart';
import 'package:hanzi_steps/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays a whole lesson like a learner would: picks option 1, and when told
/// the correct answer, picks that one on the retry.
Future<Progress> playThrough(WidgetTester tester, Lesson lesson, {Progress? existing}) async {
  if (existing == null) SharedPreferences.setMockInitialValues({});
  final progress = existing ?? await Progress.load();
  await tester.runAsync(() => StrokeLibrary.instance.load());
  await tester.binding.setSurfaceSize(const Size(1000, 1400));
  await tester.pumpWidget(MaterialApp(home: LessonScreen(lesson: lesson, progress: progress)));
  await tester.pumpAndSettle();

  final known = <String, String>{};
  // Listening questions look identical on screen, so include what is spoken.
  String screenKey() => [
        ...find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((t) => !t.startsWith('Let')),
        ...find.byType(SpeakButton).evaluate().map((e) => (e.widget as SpeakButton).text),
      ].join('|');
  for (var guard = 0; guard < 200; guard++) {
    if (find.textContaining(' complete!').evaluate().isNotEmpty) break;
    if (find.text('Write this character').evaluate().isNotEmpty) {
      // Draw every stroke along its centre line, like a learner tracing it.
      final writer = tester.widget<CharacterWriter>(find.byType(CharacterWriter));
      final data = StrokeLibrary.instance.get(writer.char)!;
      final box = tester.getRect(find.descendant(of: find.byType(CharacterWriter), matching: find.byType(CustomPaint)).first);
      Offset toScreen(Offset p) => box.topLeft + p * (box.width / 1024);
      for (final median in data.medians) {
        final pts = resample(median, 12);
        final g = await tester.startGesture(toScreen(pts.first));
        for (final p in pts.skip(1)) {
          await g.moveTo(toScreen(p));
        }
        await g.up();
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text('SKIP'), findsNothing, reason: 'writing ${writer.char} was not accepted');
    }
    if (find.text('Build this sentence in Chinese').evaluate().isNotEmpty) {
      final meaning = (find.textContaining('"').evaluate().first.widget as Text).data!.replaceAll('"', '');
      final sentence = lesson.sentences.firstWhere((x) => x.meaning == meaning);
      for (final t in sentence.tiles) {
        // Tap a tile in the word bank that is still free (a word can appear twice).
        final free = find.byWidgetPredicate((w) {
          if (w.runtimeType.toString() != 'WordTile') return false;
          final d = w as dynamic;
          return d.text == t && d.number != null && d.ghost == false;
        });
        await tester.tap(free.first);
        await tester.pump();
      }
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text('Nice!'), findsOneWidget, reason: 'sentence "$meaning" not accepted');
    }
    if (find.text('Match the pairs').evaluate().isNotEmpty && find.text('All matched!').evaluate().isEmpty) {
      for (final w in lesson.words) {
        final left = find.text('${w.hanzi}\n${w.pinyin}');
        if (left.evaluate().isEmpty) continue;
        await tester.tap(left);
        await tester.pump();
        await tester.tap(find.text(w.meaning).last);
        await tester.pump(const Duration(milliseconds: 600));
      }
      await tester.pumpAndSettle();
    }
    if (find.text('CHECK').evaluate().isNotEmpty) {
      final key = screenKey();
      final answer = known[key];
      if (answer != null) {
        await tester.tap(find.text(answer).first);
      } else {
        await tester.tap(find.text('1'));
      }
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      final keyBefore = screenKey();
      await tester.pumpAndSettle();
      final correct = find.textContaining('Correct answer: ');
      if (correct.evaluate().isNotEmpty) {
        known[keyBefore] = ((correct.evaluate().first.widget as Text).data!.replaceFirst('Correct answer: ', ''));
      }
    }
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
  }
  expect(find.textContaining(' complete!'), findsOneWidget, reason: lesson.id);
  if (lesson.kind != LessonKind.practice) expect(progress.isDone(lesson), isTrue);
  expect(progress.xp, greaterThan(0));
  return progress;
}

void main() {
  for (final audio in [false, true]) {
    for (final lesson in allLessons) {
      testWidgets('can finish ${lesson.id} (sound ${audio ? 'on' : 'off'})', (t) async {
        Speech.instance.available.value = audio;
        await playThrough(t, lesson);
      });
    }
  }

  testWidgets('words come back for review on the right days', (t) async {
    Speech.instance.available.value = false;
    final lesson = allLessons.firstWhere((l) => l.id == 'greet-1');
    final progress = await playThrough(t, lesson); // makes some mistakes along the way
    final due = progress.dueWords.map((w) => w.hanzi).toSet();
    final missed = progress.learnedWords.map((w) => w.hanzi).where(due.contains);
    // Words answered wrong are due again today; words answered right wait until tomorrow.
    expect(due, isNotEmpty);
    expect(due.length, lessThan(lesson.words.length + 1));
    expect(missed, isNotEmpty);
    // A review session with the due words plays through end to end.
    await playThrough(t, practiceLesson(progress.dueWords), existing: progress);
  });

  testWidgets('practice reviews the words you got wrong', (t) async {
    Speech.instance.available.value = false;
    final lesson = allLessons.firstWhere((l) => l.id == 'greet-1');
    final progress = await playThrough(t, lesson); // picks option 1 first, so makes mistakes
    expect(progress.weakWordCount, greaterThan(0));
    final words = progress.wordsToPractice();
    expect(words, isNotEmpty);
    await playThrough(t, practiceLesson(words), existing: progress);
  });
}
