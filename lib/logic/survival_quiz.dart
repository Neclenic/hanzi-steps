import 'dart:math';

import '../data/survival.dart';
import 'textbook.dart';

const _hMeans = '这句话是什么意思？ · What does it mean?';
const _hSay = '怎么说？ · How do you say it?';
const _hHear = '你会听到… · You might hear this. What does it mean?';

/// A round of questions on one phrase pack: what a phrase means, how to say something,
/// and putting a phrase's words in order.
List<TbQuestion> buildPhraseQuiz(PhrasePack pack, {Random? random, int count = 8}) {
  final r = random ?? Random();
  final phrases = [...pack.phrases]..shuffle(r);
  final out = <TbQuestion>[];
  for (var i = 0; out.length < count && i < count * 3; i++) {
    final p = phrases[i % phrases.length];
    final others = [for (final o in pack.phrases) if (o != p) o]..shuffle(r);
    final kind = i % 3;
    if (p.hear || kind == 0) {
      final opts = [p.en, ...others.take(2).map((o) => o.en)]..shuffle(r);
      out.add(TbChoice(
        heading: p.hear ? _hHear : _hMeans,
        prompt: p.hanzi,
        promptSub: p.pinyin,
        options: opts,
        correct: opts.indexOf(p.en),
        explain: '${p.hanzi} · ${p.pinyin}',
        speak: p.hanzi,
      ));
    } else if (kind == 1 || p.zh.split(' ').length < 4) {
      final mine = others.where((o) => !o.hear).toList();
      final opts = [p.hanzi, ...mine.take(2).map((o) => o.hanzi)]..shuffle(r);
      out.add(TbChoice(
        heading: _hSay,
        prompt: p.en,
        options: opts,
        correct: opts.indexOf(p.hanzi),
        explain: '${p.hanzi} · ${p.pinyin}',
        speak: p.hanzi,
      ));
    } else {
      out.add(buildWordOrder(p.zh, p.en, r));
    }
  }
  return out;
}
