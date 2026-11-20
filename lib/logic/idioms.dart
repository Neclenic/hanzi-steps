import 'dart:math';

import '../data/course.dart';
import '../data/idioms.dart';
import 'textbook.dart';

/// Looks up a word in an idiom story: the story's own words first, then the textbook and course.
Word? idiomWord(String token) {
  final i = idiomExtras[token];
  if (i != null) return Word(token, i.$1, i.$2, hsk: false);
  return tbWord(token);
}

const _hMeaning = '这个成语是什么意思？ · What does this saying mean?';
const _hGap = '补全成语 · Fill in the missing character';
const _hFits = '哪个成语合适？ · Which saying fits?';
const _hStory = '故事 · About the story';

List<T> _pick<T>(T right, Iterable<T> wrong, Random r, {int n = 3}) {
  final others = {...wrong}..remove(right);
  return [right, ...(others.toList()..shuffle(r)).take(n - 1)]..shuffle(r);
}

/// The quiz after reading one idiom story: its meaning, a missing character,
/// when you'd use it, and a question about the story.
List<TbQuestion> buildIdiomQuiz(Idiom idiom, {Random? random}) {
  final r = random ?? Random();
  final others = [for (final i in idioms) if (i.id != idiom.id) i];
  final label = '${idiom.chars} · ${idiom.pinyin}';

  final meanings = _pick(idiom.meaning, others.map((o) => o.meaning), r);

  // Hide one character; wrong answers come from the other idioms.
  final gapAt = r.nextInt(4);
  final missing = idiom.chars[gapAt];
  final otherChars = {for (final o in others) ...o.chars.split('')}..removeAll(idiom.chars.split(''));
  final chars = _pick(missing, otherChars, r);
  final gapped = idiom.chars.replaceRange(gapAt, gapAt + 1, '＿');

  final fits = _pick(idiom.chars, others.map((o) => o.chars), r);
  final story = [...idiom.storyA]..shuffle(r);

  return [
    TbChoice(
      heading: _hMeaning,
      prompt: idiom.chars,
      promptSub: idiom.pinyin,
      options: meanings,
      correct: meanings.indexOf(idiom.meaning),
      explain: '$label: ${idiom.meaning}',
      speak: idiom.chars,
    ),
    TbChoice(
      heading: _hGap,
      prompt: gapped,
      promptSub: '"${idiom.literal}"',
      options: chars,
      correct: chars.indexOf(missing),
      explain: label,
      speak: idiom.chars,
      bigOptions: true,
    ),
    TbChoice(
      heading: _hFits,
      prompt: idiom.situation,
      options: fits,
      correct: fits.indexOf(idiom.chars),
      explain: '$label: ${idiom.meaning}',
      speak: idiom.chars,
    ),
    TbChoice(
      heading: _hStory,
      prompt: idiom.storyQ,
      options: story,
      correct: story.indexOf(idiom.storyA.first),
    ),
  ];
}
