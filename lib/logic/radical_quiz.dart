import 'dart:math';

import '../data/radicals.dart';
import 'textbook.dart';

const _hHas = '哪个字有这个部首？ · Which character has this part?';
const _hMeans = '这个部首是什么意思？ · What does this part mean?';

/// A round of radical questions: spot the character with a part, or say what a part means.
/// With [only], every question is about that one radical.
List<TbChoice> buildRadicalQuiz({Random? random, int count = 8, Radical? only}) {
  final r = random ?? Random();
  final pool = only == null ? ([...radicals]..shuffle(r)) : [only];
  final out = <TbChoice>[];
  for (var i = 0; out.length < count; i++) {
    final rad = pool[i % pool.length];
    final askMeaning = only == null ? i.isOdd : i % 4 == 3;
    if (askMeaning) {
      final wrong = [for (final o in radicals) if (o.meaning != rad.meaning) o.meaning]..shuffle(r);
      final opts = [rad.meaning, ...wrong.take(2)]..shuffle(r);
      out.add(TbChoice(
        heading: _hMeans,
        prompt: rad.form,
        promptSub: '${rad.name} ${rad.namePinyin}',
        options: opts,
        correct: opts.indexOf(rad.meaning),
        explain: '${rad.form}: ${rad.meaning}. ${rad.note}',
      ));
    } else {
      final (char, py, meaning) = rad.chars[r.nextInt(rad.chars.length)];
      final wrong = [...plainChars]..shuffle(r);
      final opts = [char, ...wrong.take(2)]..shuffle(r);
      out.add(TbChoice(
        heading: _hHas,
        prompt: rad.form,
        promptSub: '${rad.name} · ${rad.meaning}',
        options: opts,
        correct: opts.indexOf(char),
        explain: '$char · $py · $meaning',
        speak: char,
        bigOptions: true,
      ));
    }
  }
  return out;
}
