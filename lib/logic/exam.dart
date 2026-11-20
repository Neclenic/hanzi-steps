import 'dart:math';

import '../data/course.dart';
import '../data/exam.dart';

enum ExamPart { listening, reading }

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
  });
}

/// How the mini exam is scored, like the real HSK 1: listening and reading are
/// worth 100 points each, 200 in total, and 120 is a pass.
const examMaxScore = 200;
const examPassScore = 120;
const examTime = Duration(minutes: 15);
const examQuestionsPerPart = 10;

int partScore(int right) => (right * 100 / examQuestionsPerPart).round();

String _pinyinOf(String hanzi) => wordFor(hanzi)?.pinyin ?? '';

/// Builds a fresh mini exam: 10 listening questions, then 10 reading questions.
List<ExamQuestion> buildExam({Random? random}) {
  final r = random ?? Random();
  List<T> pick<T>(List<T> from, int n) => ([...from]..shuffle(r)).take(n).toList();
  final pics = [...examPictureWords]..shuffle(r);
  final sents = [...examPictureSentences]..shuffle(r);
  final qas = [...examQAs]..shuffle(r);
  final gaps = pick(examGaps, 2);
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
    final others = pick(examPictureSentences.where((x) => x.picture != s.picture).map((x) => x.picture).toSet().toList(), 2);
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

  const l = ExamPart.listening, rd = ExamPart.reading;
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
  ];
}
