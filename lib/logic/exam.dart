import 'dart:math';

import '../data/course.dart';
import '../data/exam.dart';

enum ExamPart { listening, reading, writing }

String partName(ExamPart p) => switch (p) {
      ExamPart.listening => 'Listening',
      ExamPart.reading => 'Reading',
      ExamPart.writing => 'Writing',
    };

/// One answer to pick: words, a picture, or both.
class ExamOption {
  final String label;
  final String? pinyin;
  final String? picture;
  const ExamOption(this.label, {this.pinyin, this.picture});
}

/// One exam question, ready to show.
class ExamQuestion {
  final ExamPart part;
  final String instruction;
  final String? speak; // what is played aloud (listening)
  final String? picture; // a big picture above the question
  final String? text; // what is written (reading), or the listening text when there's no voice
  final String? textPinyin;
  final List<ExamOption> options;
  final int correct;
  final bool trueFalse;
  final String? gapPinyin; // writing: the pinyin of the missing character
  final String? statement; // HSK 4: the ★ statement to judge
  final String? statementPinyin;
  const ExamQuestion({
    required this.part,
    required this.instruction,
    required this.options,
    required this.correct,
    this.speak,
    this.picture,
    this.text,
    this.textPinyin,
    this.trueFalse = false,
    this.gapPinyin,
    this.statement,
    this.statementPinyin,
  });
}

/// How the mini exam is scored, like the real HSK 1 and 2: listening and reading are
/// worth 100 points each, 200 in total, and 120 is a pass. HSK 3 and 4 add a writing
/// part, so they are out of 300 and 180 is a pass.
const examMaxScore = 200;
const examPassScore = 120;
const examTime = Duration(minutes: 15);
const examQuestionsPerPart = 10;
const examWritingQuestions = 5;

int examMaxFor(int level) => level >= 3 ? 300 : 200;
int examPassFor(int level) => level >= 3 ? 180 : 120;
Duration examTimeFor(int level) => switch (level) {
      >= 4 => const Duration(minutes: 25),
      3 => const Duration(minutes: 20),
      _ => examTime,
    };

/// Each part is worth 100 points.
int partScore(int right, [int questions = examQuestionsPerPart]) => (right * 100 / questions).round();

String _pinyinOf(String hanzi) => wordFor(hanzi)?.pinyin ?? '';

/// Builds a fresh mini exam for an HSK level: 10 listening questions, then 10 reading
/// questions, and for HSK 3 and 4 also 5 writing questions.
List<ExamQuestion> buildExam({int level = 1, Random? random}) {
  final r = random ?? Random();
  final set = examSets[level]!;
  List<T> pick<T>(List<T> from, int n) => ([...from]..shuffle(r)).take(n).toList();
  final pics = [...set.pictureWords]..shuffle(r);
  final sents = [...set.pictureSentences]..shuffle(r);
  final qas = [...set.qas]..shuffle(r);
  final gaps = pick(set.gaps, 2);
  var pi = 0, si = 0, qi = 0;

  const tf = [ExamOption('✓', pinyin: 'matches'), ExamOption('✗', pinyin: "doesn't match")];

  // Does the picture match the word? Half the time it does.
  ExamQuestion trueFalse(ExamPart part) {
    final w = pics[pi++];
    final matches = r.nextBool();
    final shown = matches ? w : pics.firstWhere((x) => x != w && !pics.take(pi).contains(x));
    final listening = part == ExamPart.listening;
    return ExamQuestion(
      part: part,
      instruction: listening ? 'Listen. Does the picture match what you hear?' : 'Does the picture match the word?',
      speak: listening ? w.hanzi : null,
      picture: shown.picture,
      text: w.hanzi,
      textPinyin: _pinyinOf(w.hanzi),
      options: tf,
      correct: matches ? 0 : 1,
      trueFalse: true,
    );
  }

  // Which picture goes with the sentence?
  ExamQuestion pictureChoice(ExamPart part) {
    final s = sents[si++];
    final others = pick(set.pictureSentences.where((x) => x.picture != s.picture).map((x) => x.picture).toSet().toList(), 2);
    final options = [s.picture, ...others]..shuffle(r);
    final listening = part == ExamPart.listening;
    return ExamQuestion(
      part: part,
      instruction: listening ? 'Listen. Which picture goes with the sentence?' : 'Which picture goes with the sentence?',
      speak: listening ? s.zh : null,
      text: s.zh,
      textPinyin: s.pinyin,
      options: [for (final o in options) ExamOption('', picture: o)],
      correct: options.indexOf(s.picture),
    );
  }

  // Pick the right reply.
  ExamQuestion reply(ExamPart part) {
    final q = qas[qi++];
    final order = [0, 1, 2]..shuffle(r);
    final listening = part == ExamPart.listening;
    return ExamQuestion(
      part: part,
      instruction: listening ? 'Listen to the question. Which is the right reply?' : 'Which is the right reply?',
      speak: listening ? q.q : null,
      text: q.q,
      textPinyin: q.qPinyin,
      options: [for (final i in order) ExamOption(q.replies[i].$1, pinyin: q.replies[i].$2)],
      correct: order.indexOf(0),
    );
  }

  // Fill the gap.
  ExamQuestion gap(ExamGap g) {
    final order = [0, 1, 2]..shuffle(r);
    return ExamQuestion(
      part: ExamPart.reading,
      instruction: 'Which word fills the gap?',
      text: g.zh,
      textPinyin: g.pinyin,
      options: [for (final i in order) ExamOption(g.options[i], pinyin: _pinyinOf(g.options[i]))],
      correct: order.indexOf(0),
    );
  }

  // HSK 4: is the ★ statement right?
  const rw = [ExamOption('✓', pinyin: 'right'), ExamOption('✗', pinyin: 'wrong')];
  final judges = [...set.judges]..shuffle(r);
  var ji = 0;
  ExamQuestion judge(ExamPart part) {
    final j = judges[ji++];
    final listening = part == ExamPart.listening;
    return ExamQuestion(
      part: part,
      instruction: listening ? 'Listen. Is the statement right?' : 'Read. Is the statement right?',
      speak: listening ? j.passage : null,
      text: j.passage,
      textPinyin: j.passagePinyin,
      statement: j.statement,
      statementPinyin: j.statementPinyin,
      options: rw,
      correct: j.right ? 0 : 1,
      trueFalse: true,
    );
  }

  // HSK 4 writing: which sentence has the words in the right order?
  ExamQuestion order(ExamOrder o) {
    final order = [0, 1, 2]..shuffle(r);
    return ExamQuestion(
      part: ExamPart.writing,
      instruction: 'Which sentence puts the words in the right order? (In the real exam you write it.)',
      text: o.pieces.join('  /  '),
      options: [for (final i in order) ExamOption(o.options[i])],
      correct: order.indexOf(0),
    );
  }

  // Which character is missing?
  ExamQuestion charQuestion(ExamChar c) {
    final order = [0, 1, 2]..shuffle(r);
    return ExamQuestion(
      part: ExamPart.writing,
      instruction: 'Which character is missing? (In the real exam you write it by hand.)',
      text: c.zh,
      textPinyin: c.pinyin,
      options: [for (final i in order) ExamOption(c.options[i])],
      correct: order.indexOf(0),
      gapPinyin: c.gapPinyin,
    );
  }

  const l = ExamPart.listening, rd = ExamPart.reading;
  if (set.judges.isNotEmpty) {
    return [
      // Listening: 5 statements to judge, 5 replies.
      for (var i = 0; i < 5; i++) judge(l),
      for (var i = 0; i < 5; i++) reply(l),
      // Reading: 5 gaps, 5 statements to judge.
      for (final g in pick(set.gaps, 5)) gap(g),
      for (var i = 0; i < 5; i++) judge(rd),
      // Writing: words in the right order.
      for (final o in pick(set.orders, examWritingQuestions)) order(o),
    ];
  }
  return [
    // Listening: 3 picture checks, 3 picture choices, 4 replies.
    for (var i = 0; i < 3; i++) trueFalse(l),
    for (var i = 0; i < 3; i++) pictureChoice(l),
    for (var i = 0; i < 4; i++) reply(l),
    // Reading: 2 picture checks, 3 picture choices, 3 replies, 2 gaps.
    for (var i = 0; i < 2; i++) trueFalse(rd),
    for (var i = 0; i < 3; i++) pictureChoice(rd),
    for (var i = 0; i < 3; i++) reply(rd),
    for (final g in gaps) gap(g),
    // Writing (HSK 3): pick the missing character.
    for (final c in pick(set.chars, set.chars.isEmpty ? 0 : examWritingQuestions)) charQuestion(c),
  ];
}
