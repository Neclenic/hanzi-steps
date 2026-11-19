import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/logic/exercises.dart';

void main() {
  test('every lesson builds valid questions', () {
    for (var seed = 0; seed < 50; seed++) {
      for (final lesson in allLessons) {
        final steps = buildLesson(lesson, random: Random(seed), withAudio: seed.isEven);
        expect(steps, isNotEmpty, reason: lesson.id);
        for (final s in steps.whereType<ChoiceStep>()) {
          final labels = s.options.map((o) => o.label).toList();
          expect(labels.toSet().length, labels.length, reason: 'duplicate options in ${lesson.id}: $labels');
          expect(s.correct, inInclusiveRange(0, s.options.length - 1));
          expect(s.options.length, greaterThanOrEqualTo(2));
          if (s.listening) {
            expect(s.speak, isNotNull);
            // Listening options must not include a word that sounds the same as the answer.
            final heard = allWords.where((w) => w.hanzi == s.speak).firstOrNull;
            if (heard != null && lesson.kind == LessonKind.vocab) {
              for (final o in s.options) {
                final w = allWords.firstWhere((x) => x.meaning == o.label);
                if (w != heard) expect(w.pinyin, isNot(heard.pinyin), reason: 'sound-alike in ${lesson.id}');
              }
            }
          }
        }
      }
    }
  });

  test('sentences only use words taught in that lesson or earlier', () {
    final known = <String>{};
    for (final lesson in allLessons) {
      known.addAll(lesson.words.map((w) => w.hanzi));
      for (final s in lesson.sentences) {
        for (final t in s.tiles) {
          expect(known, contains(t), reason: '"$t" in "${s.hanzi}" (${lesson.id}) is not taught yet');
        }
      }
    }
  });

  test('no two words share the same meaning', () {
    final meanings = allWords.map((w) => w.meaning).toList();
    expect(meanings.toSet().length, meanings.length);
  });

  test('HSK 1 has exactly 150 words, none repeated', () {
    final words = hskWords.map((w) => w.hanzi).toList();
    expect(words.length, 150);
    expect(words.toSet().length, 150);
    final everything = allWords.map((w) => w.hanzi).toList();
    expect(everything.toSet().length, everything.length, reason: 'a word is taught twice');
  });
}
