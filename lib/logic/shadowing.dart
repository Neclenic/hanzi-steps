import 'dart:math';

import '../data/course.dart';
import '../data/dialogues.dart';
import '../data/survival.dart';
import 'pitch.dart';

/// Something to shadow: a sentence Xiaoxiao says, which the learner repeats straight away.
class ShadowItem {
  final String hanzi;
  final String pinyin;
  final String meaning;
  const ShadowItem(this.hanzi, this.pinyin, this.meaning);

  int get syllables => max(1, tonesOf(pinyin).length);
}

/// The groups of sentences to shadow.
enum ShadowSet {
  lessons('Sentences from your lessons', 'The example sentences of the course, up to where you are'),
  dialogues('Dialogue lines', 'Everyday conversations, one line at a time'),
  phrases('Survival phrases', 'Taxi, restaurant, hotel and more');

  final String title;
  final String subtitle;
  const ShadowSet(this.title, this.subtitle);
}

/// Every course sentence, in course order.
List<ShadowItem> courseShadowItems([Iterable<Lesson>? lessons]) => [
      for (final l in lessons ?? allLessons)
        for (final s in l.sentences) ShadowItem(s.hanzi, s.pinyin, s.meaning),
    ];

List<ShadowItem> dialogueShadowItems() => [
      for (final d in dialogues)
        for (final l in d.lines) ShadowItem(l.hanzi, l.pinyin, l.en),
    ];

List<ShadowItem> phraseShadowItems() => [
      for (final p in phrasePacks)
        for (final x in p.phrases)
          if (!x.hear) ShadowItem(x.hanzi, x.pinyin, x.en),
    ];

/// Everything that can be shadowed (used to prepare Xiaoxiao's pitch lines).
List<ShadowItem> allShadowItems() {
  final seen = <String>{};
  return [
    for (final i in [...courseShadowItems(), ...dialogueShadowItems(), ...phraseShadowItems()])
      if (seen.add(i.hanzi)) i,
  ];
}

/// A round of up to [count] items. Lesson sentences come from finished lessons
/// ([done]); with too few of those, the first lessons of the course fill in.
List<ShadowItem> shadowRound(ShadowSet set, {Set<String> done = const {}, int count = 8, Random? random}) {
  final r = random ?? Random();
  List<ShadowItem> pool;
  switch (set) {
    case ShadowSet.lessons:
      final finished = courseShadowItems(allLessons.where((l) => done.contains(l.id)));
      pool = finished.length >= count ? finished : courseShadowItems().take(max(count, finished.length + count)).toList();
    case ShadowSet.dialogues:
      pool = dialogueShadowItems();
    case ShadowSet.phrases:
      pool = phraseShadowItems();
  }
  final seen = <String>{};
  pool = [for (final i in pool) if (seen.add(i.hanzi)) i]..shuffle(r);
  return pool.take(count).toList();
}

/// How Xiaoxiao says one item: how long it takes and her pitch in each syllable
/// (semitones from her usual pitch). Made by tool/make_pitch.dart.
class VoiceLine {
  final Duration length;
  final List<List<double>> syllables; // empty when her syllables couldn't be told apart
  const VoiceLine(this.length, this.syllables);

  static VoiceLine fromJson(Map<String, dynamic> j) => VoiceLine(
        Duration(milliseconds: j['d'] as int),
        [for (final s in (j['s'] as List? ?? const [])) [for (final v in s as List) (v as num).toDouble()]],
      );
}

/// A score from 0 to 100 for one attempt: the share of checked syllables with the right tone.
int shadowScore(int right, int checked) => checked == 0 ? 0 : (100 * right / checked).round();
