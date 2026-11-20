import 'dart:math';

import '../data/pinyin_chart.dart';
import 'pinyin_input.dart';
import 'textbook.dart';

const _hTone = '这个字读第几声？ · Which tone is it?';

/// How a chart syllable is shown: ü instead of v.
String showSyllable(String syllable) => syllable.replaceAll('v', 'ü');

/// The chart syllables, filtered by what the learner typed ("lv", "lü", "zh"…).
/// Tone marks and numbers in the search are ignored.
List<String> searchSyllables(String query) {
  final q = pinyinLetters(query.trim()).replaceAll('ü', 'v').replaceAll(RegExp('[^a-z]'), '');
  return [for (final s in pinyinChart.keys) if (s.startsWith(q)) s];
}

/// The chart grouped by initial, in teaching order (b p m f …, then syllables with no initial).
List<(String, List<String>)> chartByInitial([Iterable<String>? only]) {
  final syllables = only ?? pinyinChart.keys;
  return [
    for (final i in pinyinInitials)
      if (syllables.where((s) => initialOf(s) == i).toList() case final list when list.isNotEmpty) (i, list),
  ];
}

/// A round of "which tone?" questions: a course character, and its syllable with each of the four tones.
List<TbChoice> buildToneQuiz({Random? random, int count = 8}) {
  final r = random ?? Random();
  final pool = <(String, int, String, String)>[
    for (final MapEntry(key: syl, value: tones) in pinyinChart.entries)
      for (final (t, c) in tones.indexed)
        if (c != null && c.$2.isNotEmpty) (syl, t + 1, c.$1, c.$2),
  ]..shuffle(r);
  final seen = <String>{};
  final out = <TbChoice>[];
  for (final (syl, tone, char, meaning) in pool) {
    if (out.length == count) break;
    if (!seen.add(char)) continue;
    final opts = [for (var t = 1; t <= 4; t++) markSyllable(syl, t)];
    out.add(TbChoice(
      heading: _hTone,
      prompt: char,
      promptSub: meaning,
      options: opts,
      correct: tone - 1,
      explain: '$char · ${opts[tone - 1]} · $meaning (tone $tone)',
      speak: char,
      tag: syl,
    ));
  }
  return out;
}
