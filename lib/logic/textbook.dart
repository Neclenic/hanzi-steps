import 'dart:math';

import '../data/course.dart';
import '../data/stories.dart';
import '../data/textbook.dart';

/// Looks up a word from a textbook lesson: textbook extras first, then story extras,
/// then the course. Returns null for punctuation.
Word? tbWord(String token) {
  if (tbPunctuation.contains(token)) return null;
  final t = textbookExtras[token];
  if (t != null) return Word(token, t.$1, t.$2, hsk: false);
  final s = storyExtras[token];
  if (s != null) return Word(token, s.$1, s.$2, hsk: false);
  return wordFor(token);
}

/// One word of a line, with the pinyin of each of its characters.
/// Punctuation comes back with an empty pinyin list.
typedef RubyWord = (String token, List<String> pinyin);

/// Splits a line into words, giving each character its syllable.
/// Throws if the pinyin doesn't have one syllable per character.
List<RubyWord> rubyWords(TbLine line) {
  final syl = line.syllables;
  var i = 0;
  final out = <RubyWord>[];
  for (final t in line.tokens) {
    if (tbPunctuation.contains(t)) {
      out.add((t, const []));
      continue;
    }
    final n = t.length;
    if (i + n > syl.length) throw StateError('Not enough pinyin in "${line.zh}"');
    out.add((t, syl.sublist(i, i + n)));
    i += n;
  }
  if (i != syl.length) throw StateError('Too much pinyin in "${line.zh}"');
  return out;
}

/// Plain text of a line or a sentence written with spaces.
String tbText(String spaced) => spaced.split(' ').where((t) => t.isNotEmpty).join();

/// Chinese numbers for "第一单元" and "语文园地一".
const tbNumbers = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

String tbUnitLabel(TbUnit u) => '第${tbNumbers[u.number]}单元';
String tbCornerLabel(TbUnit u) => '语文园地${tbNumbers[u.number]}';

// ---------------- Exercises ----------------

sealed class TbQuestion {
  const TbQuestion();
}

/// Pick one of a few answers.
class TbChoice extends TbQuestion {
  final String heading; // e.g. "读拼音，选汉字 · Read the pinyin, pick the character"
  final String prompt; // the big thing asked about
  final String? promptSub; // e.g. English under a sentence
  final bool promptIsPinyin; // the prompt itself is pinyin (never hidden)
  final List<String> options;
  final int correct;
  final String? explain; // shown after checking
  final String? speak; // Chinese read out after checking
  final bool bigOptions; // options are single characters
  final String? tag; // what the question is about, for drills that keep score
  const TbChoice({
    required this.heading,
    required this.prompt,
    this.promptSub,
    this.promptIsPinyin = false,
    required this.options,
    required this.correct,
    this.explain,
    this.speak,
    this.bigOptions = false,
    this.tag,
  });
}

/// Put the words in order (连词成句).
class TbBuild extends TbQuestion {
  final List<String> answer; // the words in order (no punctuation)
  final String end; // punctuation at the end, shown after the last word
  final List<String> bank; // the same words, shuffled
  final String en;
  const TbBuild(this.answer, this.end, this.bank, this.en);

  bool isRight(List<String> built) => built.join() == answer.join();
}

const _hPinyin = '读拼音，选汉字 · Read the pinyin, pick the character';
const _hMeaning = '这个字是什么意思？ · What does it mean?';
const _hWords = '组词 · Which word uses this character?';
const _hFill = '选词填空 · Fill the gap';
const _hAsk = '读一读，选一选 · Read and choose';
const _hRadical = '识字加油站 · Which one has this radical?';

String _charLabel(TbChar c) => '${c.char} · ${c.pinyin} · ${c.meaning}';

String _wordLabel(String w) {
  final word = tbWord(w);
  return word == null ? w : '$w ${word.pinyin}: ${word.meaning}';
}

List<String> _shuffledWith(String right, Iterable<String> wrong, Random r, {int n = 3}) {
  final others = {...wrong}..remove(right);
  final picked = (others.toList()..shuffle(r)).take(n - 1);
  return [right, ...picked]..shuffle(r);
}

/// A question about one new character. [kind]: 0 pinyin → character, 1 meaning, 2 words.
TbQuestion _charQuestion(TbChar c, List<TbChar> pool, int kind, Random r) {
  final others = [for (final o in pool) if (o.char != c.char) o];
  if (kind == 2 && c.words.isNotEmpty) {
    final right = c.words[r.nextInt(c.words.length)];
    final wrong = {
      for (final o in others)
        for (final w in o.words)
          if (!w.contains(c.char)) w,
    };
    if (wrong.length >= 2) {
      final opts = _shuffledWith(right, wrong, r);
      return TbChoice(
        heading: _hWords,
        prompt: c.char,
        options: opts,
        correct: opts.indexOf(right),
        explain: _wordLabel(right),
        speak: right,
      );
    }
  }
  if (kind == 1) {
    final wrong = [for (final o in others) if (o.meaning != c.meaning) o.meaning];
    final opts = _shuffledWith(c.meaning, wrong, r);
    return TbChoice(
      heading: _hMeaning,
      prompt: c.char,
      options: opts,
      correct: opts.indexOf(c.meaning),
      explain: _charLabel(c),
      speak: c.char,
    );
  }
  // Characters that sound the same would make it a guess, so leave them out.
  final wrong = [for (final o in others) if (o.pinyin != c.pinyin) o.char];
  final opts = _shuffledWith(c.char, wrong, r);
  return TbChoice(
    heading: _hPinyin,
    prompt: c.pinyin,
    promptIsPinyin: true,
    options: opts,
    correct: opts.indexOf(c.char),
    explain: _charLabel(c),
    speak: c.char,
    bigOptions: true,
  );
}

TbQuestion _fillQuestion(TbFill f, Random r) {
  final opts = [...f.options]..shuffle(r);
  final right = f.options.first;
  return TbChoice(
    heading: _hFill,
    prompt: tbText(f.zh),
    promptSub: f.en,
    options: opts,
    correct: opts.indexOf(right),
    explain: tbText(f.zh).replaceFirst('＿', right),
    speak: tbText(f.zh).replaceFirst('＿', right),
    bigOptions: f.options.every((o) => o.length == 1),
  );
}

TbQuestion _askQuestion(TbAsk a, Random r) {
  final opts = [for (final o in a.options) tbText(o)]..shuffle(r);
  final right = tbText(a.options.first);
  return TbChoice(
    heading: _hAsk,
    prompt: tbText(a.zh),
    promptSub: a.en,
    options: opts,
    correct: opts.indexOf(right),
    speak: right,
  );
}

TbQuestion _buildQuestion(TbOrder o, Random r) => buildWordOrder(o.zh, o.en, r);

/// A word-order question from a sentence with spaces between the words ("我 想 退房 。").
TbBuild buildWordOrder(String zh, String en, Random r) {
  final tokens = zh.split(' ').where((t) => t.isNotEmpty).toList();
  final end = tokens.isNotEmpty && tbPunctuation.contains(tokens.last) ? tokens.removeLast() : '';
  // Inner punctuation (a comma) stays attached to the word before it.
  final words = <String>[];
  for (final t in tokens) {
    if (tbPunctuation.contains(t) && words.isNotEmpty) {
      words[words.length - 1] += t;
    } else {
      words.add(t);
    }
  }
  var bank = [...words]..shuffle(r);
  // Make sure the shuffled bank isn't already in order.
  for (var tries = 0; tries < 5 && bank.join() == words.join() && words.length > 1; tries++) {
    bank = [...words]..shuffle(r);
  }
  return TbBuild(words, end, bank, en);
}

/// The exercises (练习) for one lesson: a question for each new character, then the
/// lesson's own gap-fills, questions and word-order tasks.
List<TbQuestion> buildTbExercises(TbLesson lesson, {Random? random}) {
  final r = random ?? Random();
  final unit = tbUnitOf(lesson);
  // Distractors come from the whole unit, so there are always enough.
  final pool = [for (final l in unit.lessons) ...l.chars];
  final start = r.nextInt(3);
  return [
    for (final (i, c) in lesson.chars.indexed) _charQuestion(c, pool, (start + i) % 3, r),
    for (final f in lesson.fills) _fillQuestion(f, r),
    for (final a in lesson.asks) _askQuestion(a, r),
    for (final o in lesson.orders) _buildQuestion(o, r),
  ];
}

/// The review (字词句运用) at the end of a unit: the unit's characters, its radical,
/// and a mix of the lessons' gap-fills and word-order tasks.
List<TbQuestion> buildTbReview(TbUnit unit, {Random? random, int chars = 6}) {
  final r = random ?? Random();
  final pool = [for (final l in unit.lessons) ...l.chars];
  final picked = ([...pool]..shuffle(r)).take(chars).toList();
  final fills = [for (final l in unit.lessons) ...l.fills]..shuffle(r);
  final orders = [for (final l in unit.lessons) ...l.orders]..shuffle(r);
  return [
    for (final (i, c) in picked.indexed) _charQuestion(c, pool, i % 3, r),
    _radicalQuestion(unit.corner.radical, r),
    for (final f in fills.take(2)) _fillQuestion(f, r),
    for (final o in orders.take(1)) _buildQuestion(o, r),
  ];
}

/// Characters, none of which have any of the radicals used in the review corners.
const _noRadical = ['人', '大', '小', '上', '下', '六', '十', '天', '月', '火'];

TbQuestion _radicalQuestion(TbRadical rad, Random r) {
  final (char, py, meaning) = rad.chars[r.nextInt(rad.chars.length)];
  final opts = _shuffledWith(char, _noRadical, r);
  return TbChoice(
    heading: _hRadical,
    prompt: rad.radical,
    promptSub: rad.meaning,
    options: opts,
    correct: opts.indexOf(char),
    explain: '$char · $py · $meaning',
    speak: char,
    bigOptions: true,
  );
}
