import 'dart:math';

import '../data/course.dart';
import '../data/grammar.dart';

/// One screen inside a lesson.
sealed class LessonStep {
  const LessonStep();
}

/// Teaches a new word before it is quizzed.
class TeachWordStep extends LessonStep {
  final Word word;
  const TeachWordStep(this.word);
}

/// A short grammar tip card.
class GrammarStep extends LessonStep {
  final GrammarTip tip;
  const GrammarStep(this.tip);
}

/// Teaches one of the four tones.
class TeachToneStep extends LessonStep {
  final ToneInfo tone;
  final ToneSyllable example;
  const TeachToneStep(this.tone, this.example);
}

class ChoiceOption {
  final String label;
  final String? sub; // smaller text under the label
  final int? tone; // if set, a small tone shape is drawn
  final bool big; // show label large (for Chinese characters)
  final String? speak; // Chinese to read aloud when this option is tapped
  final bool subIsPinyin; // hide [sub] when the learner turns pinyin off
  const ChoiceOption(this.label, {this.sub, this.tone, this.big = false, this.speak, this.subIsPinyin = false});
}

/// A multiple-choice question.
class ChoiceStep extends LessonStep {
  final String instruction; // e.g. "What does this mean?"
  final String? prompt; // the big thing being asked about
  final String? promptSub; // smaller text under the prompt (e.g. pinyin)
  final List<ChoiceOption> options;
  final int correct;
  final String? explain; // shown after answering
  final String? speak; // Chinese read aloud with the prompt
  final bool listening; // true: the prompt is only heard, not shown
  final String? wordKey; // the word being tested, for the review list
  final bool promptSubIsPinyin; // hide [promptSub] when the learner turns pinyin off
  final int? tone; // the tone being tested (1–4), for the stats page
  const ChoiceStep({
    required this.instruction,
    this.prompt,
    this.promptSub,
    required this.options,
    required this.correct,
    this.explain,
    this.speak,
    this.listening = false,
    this.wordKey,
    this.promptSubIsPinyin = false,
    this.tone,
  });
}

/// Build a Chinese sentence by tapping word tiles in the right order.
class SentenceStep extends LessonStep {
  final Sentence sentence;
  final List<String> bank; // tiles to pick from: the right ones plus a few extras, shuffled
  const SentenceStep(this.sentence, this.bank);

  bool isCorrect(List<String> built) => built.join() == sentence.hanzi;
}

/// Write a character stroke by stroke.
class WriteStep extends LessonStep {
  final String char;
  final Word word; // the word it comes from, for pinyin and meaning
  const WriteStep(this.char, this.word);
}

/// Tap-to-match characters with meanings.
class MatchStep extends LessonStep {
  final List<Word> words;
  const MatchStep(this.words);
}

/// Builds the list of screens for a lesson. A new random order each time.
/// [withAudio] adds "listen and choose" questions; only use it when a
/// Chinese voice is available on this computer.
List<LessonStep> buildLesson(Lesson lesson, {Random? random, bool withAudio = false}) {
  final rnd = random ?? Random();
  return switch (lesson.kind) {
    LessonKind.tones => _toneLesson(lesson, rnd, withAudio),
    LessonKind.vocab => _vocabLesson(lesson, rnd, withAudio),
    LessonKind.practice => _practice(lesson, rnd, withAudio),
  };
}

/// A practice lesson made from words the learner finds hard.
Lesson practiceLesson(List<Word> words) => Lesson(
      id: 'practice',
      title: 'Practice',
      subtitle: 'Review tricky words',
      kind: LessonKind.practice,
      words: words,
    );

List<LessonStep> _practice(Lesson lesson, Random rnd, bool withAudio) {
  final steps = <LessonStep>[];
  for (final w in lesson.words) {
    final kinds = [
      () => _meaningOf(w, lesson, rnd),
      () => _hanziFor(w, lesson, rnd),
      () => _pinyinFor(w, lesson, rnd),
      if (withAudio) () => _listenFor(w, lesson, rnd),
    ]..shuffle(rnd);
    // Two different question types per word.
    steps.add(kinds[0]());
    steps.add(kinds[1]());
  }
  steps.shuffle(rnd);
  final forMatch = [...lesson.words]..shuffle(rnd);
  if (forMatch.length >= 2) steps.add(MatchStep(forMatch.take(4).toList()));
  return steps;
}

SentenceStep _sentenceStep(Sentence s, Lesson lesson, Random rnd) {
  // Add up to two wrong tiles from this lesson's words.
  final extras = lesson.words.map((w) => w.hanzi).where((h) => !s.tiles.contains(h)).toList()..shuffle(rnd);
  final bank = [...s.tiles, ...extras.take(2)]..shuffle(rnd);
  return SentenceStep(s, bank);
}

String _toneName(int n) => tones[n - 1].name;

ChoiceStep _whichTone(ToneSyllable s, Random rnd) => ChoiceStep(
      instruction: 'Which tone is this?',
      prompt: s.marked,
      promptSub: s.hanzi == null ? null : '${s.hanzi} · ${s.meaning}',
      options: [for (final t in tones) ChoiceOption(t.name, sub: t.mark, tone: t.number)],
      correct: s.tone - 1,
      tone: s.tone,
      speak: s.hanzi,
      explain: '${s.marked} has the ${_toneName(s.tone).toLowerCase()}: ${tones[s.tone - 1].howTo}',
    );

List<LessonStep> _toneLesson(Lesson lesson, Random rnd, bool withAudio) {
  final steps = <LessonStep>[];
  final syl = lesson.syllables;
  final teachesAllFour = {for (final s in syl) s.tone}.length == 4 && syl.length == 4;

  if (teachesAllFour) {
    for (final s in syl) {
      steps.add(TeachToneStep(tones[s.tone - 1], s));
    }
  }

  final drills = [...syl, ...syl]..shuffle(rnd);
  steps.addAll(drills.map((s) => _whichTone(s, rnd)));

  // "Which one means X?" — forces the learner to see that tone changes meaning.
  final withMeaning = syl.where((s) => s.meaning != null).toList()..shuffle(rnd);
  for (final s in withMeaning.take(3)) {
    final others = syl.where((o) => o != s).toList()..shuffle(rnd);
    final opts = [s, ...others.take(3)]..shuffle(rnd);
    steps.add(ChoiceStep(
      instruction: 'Which one means "${s.meaning}"?',
      options: [for (final o in opts) ChoiceOption(o.marked, sub: o.hanzi, big: true, speak: o.hanzi)],
      correct: opts.indexOf(s),
      explain: '${s.hanzi} ${s.marked} means "${s.meaning}".',
    ));
  }

  // Listening: hear a syllable, pick its tone.
  if (withAudio) {
    final heard = syl.where((s) => s.hanzi != null).toList()..shuffle(rnd);
    for (final s in heard.take(4)) {
      steps.add(ChoiceStep(
        instruction: 'Listen. Which tone did you hear?',
        listening: true,
        speak: s.hanzi,
        options: [for (final t in tones) ChoiceOption(t.name, sub: t.mark, tone: t.number)],
        correct: s.tone - 1,
        tone: s.tone,
        explain: 'That was ${s.hanzi} ${s.marked} (${s.meaning}), ${_toneName(s.tone).toLowerCase()}.',
      ));
    }
  }
  return steps;
}

List<T> _pickOthers<T>(List<T> pool, T correct, int n, Random rnd, bool Function(T a, T b) same) {
  final out = <T>[];
  final shuffled = [...pool]..shuffle(rnd);
  for (final p in shuffled) {
    if (out.length == n) break;
    if (same(p, correct) || out.any((o) => same(o, p))) continue;
    out.add(p);
  }
  return out;
}

/// Wrong options come from this lesson first, then from the rest of the course.
List<Word> _distractors(Word w, Lesson lesson, Random rnd, bool Function(Word a, Word b) same) {
  final fromLesson = _pickOthers(lesson.words, w, 3, rnd, same);
  if (fromLesson.length == 3) return fromLesson;
  final rest = allWords.where((x) => !lesson.words.contains(x)).toList();
  final more = _pickOthers(rest, w, 3 - fromLesson.length, rnd,
      (a, b) => same(a, b) || fromLesson.any((f) => same(f, a)));
  return [...fromLesson, ...more];
}

ChoiceStep _meaningOf(Word w, Lesson lesson, Random rnd) {
  final opts = [w, ..._distractors(w, lesson, rnd, (a, b) => a.meaning == b.meaning)]..shuffle(rnd);
  return ChoiceStep(
    instruction: 'What does this mean?',
    prompt: w.hanzi,
    promptSub: w.pinyin,
    promptSubIsPinyin: true,
    options: [for (final o in opts) ChoiceOption(o.meaning)],
    correct: opts.indexOf(w),
    speak: w.hanzi,
    wordKey: w.hanzi,
    explain: '${w.hanzi} (${w.pinyin}) means "${w.meaning}".',
  );
}

ChoiceStep _hanziFor(Word w, Lesson lesson, Random rnd) {
  final opts = [w, ..._distractors(w, lesson, rnd, (a, b) => a.hanzi == b.hanzi || a.meaning == b.meaning)]
    ..shuffle(rnd);
  return ChoiceStep(
    instruction: 'Pick the Chinese for "${w.meaning}"',
    options: [for (final o in opts) ChoiceOption(o.hanzi, sub: o.pinyin, big: true, speak: o.hanzi, subIsPinyin: true)],
    correct: opts.indexOf(w),
    wordKey: w.hanzi,
    explain: '"${w.meaning}" is ${w.hanzi} (${w.pinyin}).',
  );
}

ChoiceStep _pinyinFor(Word w, Lesson lesson, Random rnd) {
  final opts = [w, ..._distractors(w, lesson, rnd, (a, b) => a.pinyin == b.pinyin)]..shuffle(rnd);
  return ChoiceStep(
    instruction: 'How do you say this?',
    prompt: w.hanzi,
    options: [for (final o in opts) ChoiceOption(o.pinyin)],
    correct: opts.indexOf(w),
    wordKey: w.hanzi,
    explain: '${w.hanzi} is read ${w.pinyin} and means "${w.meaning}".',
  );
}

List<LessonStep> _vocabLesson(Lesson lesson, Random rnd, bool withAudio) {
  final steps = <LessonStep>[];
  // 1. Teach each word, then check it straight away.
  for (final w in lesson.words) {
    steps.add(TeachWordStep(w));
    steps.add(_meaningOf(w, lesson, rnd));
  }
  // A grammar tip, if this lesson has one.
  if (grammarFor(lesson.id) case final tip?) steps.add(GrammarStep(tip));
  // 2. Mixed practice in a random order.
  final practice = <LessonStep>[
    for (final w in lesson.words) _hanziFor(w, lesson, rnd),
    for (final w in lesson.words) _pinyinFor(w, lesson, rnd),
  ]..shuffle(rnd);
  // Listening: hear a word, pick what it means.
  if (withAudio) {
    practice.addAll(lesson.words.map((w) => _listenFor(w, lesson, rnd)));
    practice.shuffle(rnd);
  }
  steps.addAll(practice);
  // Build the lesson's example sentences.
  steps.addAll(lesson.sentences.map((s) => _sentenceStep(s, lesson, rnd)));
  // Write up to two of the new characters.
  steps.addAll(newCharacters(lesson).take(2).map((c) => WriteStep(c.$1, c.$2)));
  // 3. Finish with a matching game.
  final forMatch = [...lesson.words]..shuffle(rnd);
  steps.add(MatchStep(forMatch.take(4).toList()));
  return steps;
}

ChoiceStep _listenFor(Word w, Lesson lesson, Random rnd) {
  // Words that sound the same (like 他 and 她, both tā) can't be told apart by ear.
  final opts = [
    w,
    ..._distractors(w, lesson, rnd, (a, b) => a.meaning == b.meaning || a.pinyin == b.pinyin),
  ]..shuffle(rnd);
  return ChoiceStep(
    instruction: 'Listen. What does it mean?',
    listening: true,
    speak: w.hanzi,
    options: [for (final o in opts) ChoiceOption(o.meaning)],
    correct: opts.indexOf(w),
    wordKey: w.hanzi,
    explain: 'You heard ${w.hanzi} (${w.pinyin}): "${w.meaning}".',
  );
}

/// Characters that appear for the first time in this lesson, with the word they come from.
List<(String, Word)> newCharacters(Lesson lesson) {
  final seen = <String>{};
  for (final l in allLessons) {
    if (l.id == lesson.id) break;
    for (final w in l.words) {
      seen.addAll(w.hanzi.split(''));
    }
  }
  final out = <(String, Word)>[];
  for (final w in lesson.words) {
    for (final c in w.hanzi.split('')) {
      if (seen.add(c)) out.add((c, w));
    }
  }
  return out;
}
