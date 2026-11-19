import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/logic/pitch.dart';

/// A voice-like sound (a few harmonics) whose pitch follows [hz] over [seconds].
List<double> voice(double Function(double t) hz, {double seconds = 0.45, double gap = 0}) {
  final n = (seconds * sampleRate).round();
  final out = <double>[for (var i = 0; i < (gap * sampleRate).round(); i++) 0];
  var phase = 0.0;
  final r = Random(1);
  for (var i = 0; i < n; i++) {
    final t = i / n;
    phase += 2 * pi * hz(t) / sampleRate;
    final env = sin(pi * t).clamp(0.0, 1.0); // fade in and out
    out.add(env * (0.5 * sin(phase) + 0.25 * sin(2 * phase) + 0.12 * sin(3 * phase)) + (r.nextDouble() - 0.5) * 0.01);
  }
  return out;
}

double lerp(double a, double b, double t) => a + (b - a) * t;

final shapes = <int, double Function(double)>{
  1: (t) => 230,
  2: (t) => lerp(170, 250, t * t),
  3: (t) => t < 0.55 ? lerp(185, 140, t / 0.55) : lerp(140, 190, (t - 0.55) / 0.45),
  4: (t) => lerp(280, 165, t),
};

void main() {
  test('reads the pitch of a steady voice', () {
    final p = trackPitch(voice((t) => 200, seconds: 0.5));
    final hz = medianPitch(p)!;
    expect(hz, closeTo(200, 4));
  });

  for (final tone in [1, 2, 3, 4]) {
    test('recognises tone $tone', () {
      final p = trackPitch(voice(shapes[tone]!));
      // Use a reference pitch like a speaker's usual voice (about 210 Hz here).
      final syl = splitSyllables(p, 1, 210);
      expect(syl, hasLength(1));
      expect(classifyTone(syl.first.semitones).tone, tone);
    });
  }

  test('splits two syllables with a pause between them', () {
    final samples = [...voice(shapes[3]!), ...voice(shapes[4]!, gap: 0.08)];
    final p = trackPitch(samples);
    final syl = splitSyllables(p, 2, 210);
    expect(syl, hasLength(2));
    expect(classifyTone(syl[0].semitones).tone, 3);
    expect(classifyTone(syl[1].semitones).tone, 4);
  });

  test('silence has no pitch', () {
    final p = trackPitch(List.filled(8000, 0.0));
    expect(medianPitch(p), isNull);
  });

  test('reads tones from pinyin', () {
    expect(tonesOf('nǐ hǎo'), [3, 3]);
    expect(spokenTones(tonesOf('nǐ hǎo')), [2, 3]);
    expect(tonesOf('xièxie'), [4, 0]);
    expect(tonesOf('Zhōngguó'), [1, 2]);
    expect(tonesOf("nǚ'ér"), [3, 2]);
    expect(tonesOf('piàoliang'), [4, 0]);
    expect(tonesOf('gōnggòng qìchē'), [1, 4, 4, 1]);
  });

  test('every course word has one tone per syllable it is written with', () {
    for (final w in allWords) {
      final t = tonesOf(w.pinyin);
      // Words like 一点儿 yìdiǎnr have an extra "r" but no extra syllable.
      expect(t.length, inInclusiveRange(1, w.hanzi.length), reason: '${w.hanzi} ${w.pinyin} → $t');
      if (!w.hanzi.contains('儿')) expect(t.length, w.hanzi.length, reason: '${w.hanzi} ${w.pinyin} → $t');
    }
  });
}
