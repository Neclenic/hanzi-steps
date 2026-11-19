import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/stories.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/story_words.dart';
import 'package:hanzi_steps/screens/stories_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('every word in every story and question can be looked up', () {
    for (final s in stories) {
      final texts = [...s.paragraphs.map((p) => p.zh), ...s.questions.map((q) => q.zh)];
      for (final text in texts) {
        for (final t in text.split(' ').where((t) => t.isNotEmpty)) {
          final known = storyPunctuation.contains(t) || lookupStoryWord(t) != null;
          expect(known, isTrue, reason: '"$t" in story ${s.id} is not in the course or storyExtras');
        }
      }
    }
  });

  test('story extras do not repeat course words', () {
    for (final k in storyExtras.keys) {
      expect(wordFor(k), isNull, reason: '$k is already a course word');
    }
  });

  test('questions are well formed', () {
    for (final s in stories) {
      expect(s.questions, isNotEmpty);
      for (final q in s.questions) {
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.options.toSet().length, q.options.length, reason: '${s.id}: ${q.zh}');
        expect(q.correct, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });

  test('stories are labelled HSK 1 and mostly use HSK 1 words', () {
    for (final s in stories) {
      final level = levelOf(s);
      // ignore: avoid_print
      print('${s.id}: ${level.label}, ${(level.hskShare * 100).round()}% HSK 1, new: ${level.newWords.join(' ')}');
      expect(level.hskShare, greaterThan(0.65), reason: s.id);
    }
    // Everyday stories stay within HSK 1; the fables need a few extra words.
    final hsk1 = stories.where((s) => levelOf(s).label == 'HSK 1').length;
    expect(hsk1, greaterThanOrEqualTo(8));
  });

  testWidgets('read a story, look up a word, add it to review, answer the questions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Speech.instance.available.value = false;
    final progress = await Progress.load();
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    final story = stories.first;
    await tester.pumpWidget(MaterialApp(home: StoryReaderScreen(story: story, progress: progress)));
    await tester.pumpAndSettle();

    // Tap 医生 (doctor) and add it to the review list.
    await tester.tap(find.text('医生'));
    await tester.pumpAndSettle();
    expect(find.text('doctor'), findsOneWidget);
    await tester.tap(find.text('Add to my review list'));
    await tester.pumpAndSettle();
    expect(find.text('On your review list'), findsOneWidget);
    expect(progress.dueWords.map((w) => w.hanzi), contains('医生'));
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();

    // English translation toggles.
    await tester.tap(find.byTooltip('Show English').first);
    await tester.pumpAndSettle();
    expect(find.text(story.paragraphs.first.en), findsOneWidget);

    await tester.tap(find.text('ANSWER THE QUESTIONS'));
    await tester.pumpAndSettle();
    for (final q in story.questions) {
      await tester.tap(find.text(q.options[q.correct]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RIGHT! CONTINUE'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Story finished!'), findsOneWidget);
    expect(progress.storiesRead, contains(story.id));
    expect(progress.xp, 5 + 5 * story.questions.length);
  });
}
