// Everything the app can read aloud, including text it puts together while running
// (a whole story, 一本书, a gap-fill with its answer filled in…). test/voice_coverage_test.dart
// checks that each has a natural-voice recording.

import 'dart:math';

import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/dialogues.dart';
import 'package:hanzi_steps/data/exam.dart';
import 'package:hanzi_steps/data/idioms.dart';
import 'package:hanzi_steps/data/listening.dart';
import 'package:hanzi_steps/data/look_alikes.dart';
import 'package:hanzi_steps/data/measure_words.dart';
import 'package:hanzi_steps/data/radicals.dart';
import 'package:hanzi_steps/data/stories.dart';
import 'package:hanzi_steps/data/survival.dart';
import 'package:hanzi_steps/data/textbook.dart';
import 'package:hanzi_steps/logic/numbers.dart';
import 'package:hanzi_steps/logic/textbook.dart';

final _cjk = RegExp(r'[一-鿿]');
final _notCjk = RegExp(r'[^一-鿿]');

/// The words of a text written with spaces between them (punctuation left out).
Iterable<String> _tokens(String spaced) =>
    spaced.split(' ').map((t) => t.replaceAll(_notCjk, '')).where((t) => t.isNotEmpty);

/// Every text the app reads aloud as one recording.
Set<String> spokenTexts() {
  final out = <String>{};
  void add(String t) {
    final s = t.replaceAll(RegExp(r'\s'), '');
    if (_cjk.hasMatch(s)) out.add(s);
  }

  void addLine(String spaced) {
    add(spaced);
    _tokens(spaced).forEach(add); // tapping a word reads it
  }

  // Course words, each of their characters (writing practice), and sentences with their tiles.
  for (final l in allLessons) {
    for (final w in l.words) {
      add(w.hanzi);
      for (final c in w.hanzi.split('')) {
        add(c);
      }
    }
    for (final s in l.sentences) {
      add(s.hanzi);
      s.tiles.forEach(add);
    }
  }
  // Stories: each paragraph, each word, and the whole story.
  for (final s in stories) {
    for (final p in s.paragraphs) {
      addLine(p.zh);
    }
    add(s.paragraphs.map((p) => p.text).join());
    for (final q in s.questions) {
      add(q.zh);
      q.options.forEach(add);
    }
  }
  for (final k in [...storyExtras.keys, ...textbookExtras.keys, ...idiomExtras.keys]) {
    add(k);
  }
  // Textbook: lines and words, the whole text, new characters, exercises with answers filled in.
  final r = Random(1);
  for (final u in tbUnits) {
    for (final l in u.lessons) {
      for (final line in l.lines) {
        addLine(line.zh);
      }
      add(l.lines.map((x) => x.text).join());
      for (final c in l.chars) {
        add(c.char);
        c.words.forEach(add);
      }
      for (final f in l.fills) {
        _tokens(f.zh).forEach(add);
        f.options.forEach(add);
        add(tbText(f.zh).replaceFirst('＿', f.options.first));
      }
      for (final a in l.asks) {
        addLine(a.zh);
        a.options.forEach(add);
      }
      for (final o in l.orders) {
        addLine(o.zh);
        add(buildWordOrder(o.zh, o.en, r).answer.join());
      }
      addLine(l.speak.model.zh);
    }
    for (final (ch, _, _) in u.corner.radical.chars) {
      add(ch);
    }
    for (final (look, _) in u.corner.discoveries) {
      add(look.replaceAll(_notCjk, ''));
    }
    for (final p in u.corner.poems) {
      for (final line in p.lines) {
        addLine(line.zh);
      }
      add(p.lines.map((x) => x.text).join());
    }
  }
  // Idioms and their stories.
  for (final i in idioms) {
    add(i.chars);
    for (final line in i.story) {
      addLine(line.zh);
    }
  }
  // Dialogues, survival phrases, listening clips.
  for (final d in dialogues) {
    for (final l in d.lines) {
      addLine(l.zh);
      for (final (w, _) in l.wrong) {
        add(w);
      }
    }
  }
  for (final p in phrasePacks) {
    for (final x in p.phrases) {
      addLine(x.zh);
    }
  }
  for (final c in listenClips) {
    for (final l in c.lines) {
      add(l.zh);
    }
    for (final q in c.questions) {
      add(q.zh);
      q.options.forEach(add);
    }
  }
  // Counting words: 一本书, 两本书, 这本书.
  for (final m in measureWords) {
    add(m.char);
    for (final n in m.nouns) {
      for (final number in ['一', '两', '这']) {
        add('$number${m.char}$n');
      }
    }
  }
  // Radicals and look-alikes.
  for (final rad in radicals) {
    for (final (c, _, _) in rad.chars) {
      add(c);
    }
  }
  plainChars.forEach(add);
  for (final g in lookAlikeGroups) {
    for (final c in g.chars) {
      add(c.char);
      add(c.example);
    }
  }
  // Exam listening.
  for (final set in examSets.values) {
    for (final s in set.pictureSentences) {
      add(s.zh);
    }
  }
  return out;
}

/// The short pieces that numbers, prices, dates and times are read from (see splitIntoPieces).
Set<String> numberPieces() => {
      ...'零一二两三四五六七八九十百千幺块毛月号年点分半刻'.split(''),
      for (var n = 1; n < 100; n++) ...[chineseNumber(n), chineseNumber(n, liang: true)],
      for (var n = 1; n < 10; n++) ...['${chineseNumber(n, liang: true)}百', '${chineseNumber(n)}百'],
      for (var n = 1; n < 100; n++) '${chineseNumber(n, liang: true)}块',
      for (var n = 1; n < 10; n++) ...['${chineseNumber(n, liang: true)}毛', '块${chineseNumber(n)}'],
      for (var n = 1; n <= 12; n++) ...['${chineseNumber(n)}月', '${chineseNumber(n, liang: true)}点'],
      for (var n = 1; n <= 31; n++) '${chineseNumber(n)}号',
      for (var n = 1; n < 10; n++) '零${chineseNumber(n)}分',
      for (var n = 10; n < 60; n++) '${chineseNumber(n)}分',
      '一刻', '三刻', '早上', '上午', '中午', '下午', '晚上',
      ...weekdayHanzi,
      for (var y = 2015; y <= 2035; y++) '${'$y'.split('').map((d) => '零一二三四五六七八九'[int.parse(d)]).join()}年',
    };

/// Examples of every kind of number the numbers drill reads.
List<String> numberExamples() => [
      for (var y = 0; y < 1000; y++)
        for (final j in [0, 5, 9])
          if (y > 0 || j > 0) price(y, j).speak,
      phone('13912345678').speak,
      phone('18800000000').speak,
      for (var m = 1; m <= 12; m++)
        for (var d = 1; d <= 31; d += 3) date(m, d, weekday: (d % 7) + 1, year: d < 10 ? 2020 + d : null).speak,
      for (var h = 0; h < 24; h++)
        for (var m = 0; m < 60; m += 5) ...[clockTime(h, m).speak, clockTime(h, m, useKe: true).speak],
    ];
