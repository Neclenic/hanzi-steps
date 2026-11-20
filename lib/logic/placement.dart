import 'dart:math';

import '../data/course.dart';

/// A part of a course checked together in the placement test: two units at a time.
class PlacementStep {
  final List<Unit> units;
  const PlacementStep(this.units);

  List<Lesson> get lessons => [for (final u in units) ...u.lessons];
  List<Word> get words => [for (final l in lessons) ...l.words];
}

/// The steps of one HSK course, two units each, in course order.
List<PlacementStep> placementSteps(int level) {
  final units = unitsOf(level).where((u) => u.lessons.any((l) => l.kind == LessonKind.vocab)).toList();
  return [
    for (var i = 0; i < units.length; i += 2) PlacementStep(units.sublist(i, min(i + 2, units.length))),
  ];
}

/// One placement question. [askMeaning]: see the characters and pick the meaning;
/// otherwise see the meaning and pick the characters. No pinyin is shown.
class PlacementQuestion {
  final Word word;
  final bool askMeaning;
  final List<Word> options;
  const PlacementQuestion(this.word, this.askMeaning, this.options);
}

/// [n] questions about words from one step, each with three wrong answers from the same course.
List<PlacementQuestion> placementQuestions(PlacementStep step, int level, {int n = 3, Random? random}) {
  final r = random ?? Random();
  final words = {for (final w in step.words) w.hanzi: w}.values.toList()..shuffle(r);
  final pool = {for (final l in lessonsOf(level)) for (final w in l.words) w.hanzi: w}.values.toList();
  final out = <PlacementQuestion>[];
  for (final w in words.take(n)) {
    final others = (pool.where((o) => o.hanzi != w.hanzi && o.meaning != w.meaning).toList()..shuffle(r)).take(3);
    final options = [w, ...others]..shuffle(r);
    out.add(PlacementQuestion(w, out.length.isEven, options));
  }
  return out;
}

/// A step counts as known when at least 2 of its 3 questions are right.
bool stepPassed(int right, int asked) => right * 3 >= asked * 2;

/// The lessons to mark as done when the first [passedSteps] steps of a course are known.
/// For HSK 1 this includes the tones unit at the start.
List<Lesson> lessonsToSkip(int level, int passedSteps) {
  if (passedSteps <= 0) return const [];
  final steps = placementSteps(level);
  final known = steps.take(passedSteps).expand((s) => s.lessons).toSet();
  // Everything in the course up to the last known lesson, in order (so the tones unit too).
  final chain = lessonsOf(level);
  final last = chain.lastIndexWhere(known.contains);
  return chain.take(last + 1).toList();
}
