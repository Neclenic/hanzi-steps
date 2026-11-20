import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/dialogues.dart';
import 'package:hanzi_steps/data/idioms.dart';
import 'package:hanzi_steps/data/pinyin_chart.dart';
import 'package:hanzi_steps/data/survival.dart';
import 'package:hanzi_steps/logic/speech.dart';

void main() {
  final index = File('assets/voice/index.txt').readAsLinesSync().where((l) => l.isNotEmpty).toSet();

  test('recordings are named the same way as tool/make_voice.py names them', () {
    expect(clipName('我是学生'), '6604dd6c9425');
    expect(clipName('我 是 学生'), clipName('我是学生'), reason: 'spaces between words do not matter');
  });

  test('every listed recording is in the app, and every file is listed', () {
    final files = Directory('assets/voice').listSync().map((f) => f.uri.pathSegments.last).where((n) => n.endsWith('.mp3'));
    expect(files.map((n) => n.replaceAll('.mp3', '')).toSet(), index);
    expect(index.length, greaterThan(3000));
  });

  test('words, dialogues, idioms, phrases and the pinyin chart all have natural recordings', () {
    final missing = <String>[
      for (final level in levels)
        for (final w in hskWordsOf(level))
          if (!index.contains(clipName(w.hanzi))) w.hanzi,
      for (final d in dialogues)
        for (final l in d.lines)
          if (!index.contains(clipName(l.hanzi))) l.hanzi,
      for (final i in idioms)
        if (!index.contains(clipName(i.chars))) i.chars,
      for (final p in phrasePacks)
        for (final x in p.phrases)
          if (!index.contains(clipName(x.hanzi))) x.hanzi,
      for (final tones in pinyinChart.values)
        for (final t in tones)
          if (t != null && !index.contains(clipName(t.$1))) t.$1,
    ];
    expect(missing, isEmpty, reason: 'run python3 tool/make_voice.py to record new text');
  });
}
