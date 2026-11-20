import 'dart:math';

import '../data/measure_words.dart';
import 'textbook.dart';

const _hPick = '选量词 · Pick the counting word';
const _hNoun = '哪个可以？ · Which one can it count?';

String nounLabel(String noun) {
  final w = tbWord(noun);
  return w == null ? noun : '$noun ${w.pinyin}: ${w.meaning}';
}

/// A round of counting-word questions. [weak] measures come up more often.
List<TbChoice> buildMeasureDrill({Random? random, int count = 10, Map<String, (int, int)> stats = const {}}) {
  final r = random ?? Random();
  final pool = [for (final m in measureWords) if (m.char != '个') m];
  // Each measure is drawn by weight: 1, plus 1 for each mistake (capped at 3 more).
  final weighted = [
    for (final m in pool)
      for (var i = 0; i < 1 + min(3, (stats[m.char]?.$2 ?? 0) - (stats[m.char]?.$1 ?? 0)).clamp(0, 3); i++) m,
  ];
  final out = <TbChoice>[];
  final usedNouns = <String>{};
  var tries = 0;
  while (out.length < count && tries++ < 200) {
    final m = weighted[r.nextInt(weighted.length)];
    if (r.nextInt(3) < 2) {
      // 两 ＿ 书: pick the counting word.
      final noun = m.nouns[r.nextInt(m.nouns.length)];
      if (!usedNouns.add(noun)) continue;
      final fits = measuresFor(noun);
      final wrong = [for (final o in pool) if (!fits.contains(o.char)) o.char]..shuffle(r);
      final opts = [m.char, ...wrong.take(2)]..shuffle(r);
      final number = r.nextBool() ? '两' : (r.nextBool() ? '一' : '这');
      final en = number == '这' ? 'this' : (number == '两' ? 'two' : 'one');
      final w = tbWord(noun);
      out.add(TbChoice(
        heading: _hPick,
        prompt: '$number ＿ $noun',
        promptSub: '$en ${w?.meaning ?? noun}',
        options: opts,
        correct: opts.indexOf(m.char),
        explain: '$number${m.char}$noun · ${m.char} ${m.pinyin}: ${m.use}',
        speak: '$number${m.char}$noun',
        bigOptions: true,
        tag: m.char,
      ));
    } else {
      // Which noun goes with 辆?
      final right = m.nouns[r.nextInt(m.nouns.length)];
      final wrong = {
        for (final o in pool)
          for (final n in o.nouns)
            if (!measuresFor(n).contains(m.char)) n,
      }.toList()
        ..shuffle(r);
      final opts = [right, ...wrong.take(2)]..shuffle(r);
      out.add(TbChoice(
        heading: _hNoun,
        prompt: '一${m.char}…',
        promptSub: '${m.char} ${m.pinyin}: ${m.use}',
        options: opts,
        correct: opts.indexOf(right),
        explain: '一${m.char}$right · ${nounLabel(right)}',
        speak: '一${m.char}$right',
        tag: m.char,
      ));
    }
  }
  return out;
}
