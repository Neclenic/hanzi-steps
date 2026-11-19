import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/logic/strokes.dart';

void main() {
  setUpAll(() => StrokeLibrary.instance.loadFromString(File('assets/strokes/strokes.json').readAsStringSync()));

  test('every character in the course has stroke data', () {
    final chars = {for (final w in allWords) ...w.hanzi.split('')};
    final missing = chars.where((c) => !StrokeLibrary.instance.has(c));
    expect(missing, isEmpty);
  });

  test('drawing along the right stroke is accepted, in every character', () {
    for (final c in StrokeLibrary.instance.characters) {
      final d = StrokeLibrary.instance.get(c)!;
      for (var i = 0; i < d.count; i++) {
        // A slightly shaky version of the real stroke.
        final drawn = [
          for (final (k, p) in resample(d.medians[i], 20).indexed) p + Offset(k.isEven ? 10 : -10, k.isEven ? -8 : 8),
        ];
        expect(strokeMatches(drawn, d.medians[i]), isTrue, reason: '$c stroke ${i + 1}');
      }
    }
  });

  test('drawing a stroke backwards is rejected', () {
    final d = StrokeLibrary.instance.get('一')!;
    expect(strokeMatches(d.medians[0].reversed.toList(), d.medians[0]), isFalse);
    final ten = StrokeLibrary.instance.get('十')!;
    expect(strokeMatches(ten.medians[0].reversed.toList(), ten.medians[0]), isFalse);
  });

  test('drawing the wrong stroke is rejected', () {
    final ten = StrokeLibrary.instance.get('十')!; // horizontal first, then vertical
    expect(strokeMatches(ten.medians[1], ten.medians[0]), isFalse);
    final mouth = StrokeLibrary.instance.get('口');
    if (mouth != null) expect(strokeMatches(mouth.medians[2], mouth.medians[0]), isFalse);
  });

  test('a click is not a stroke', () {
    final d = StrokeLibrary.instance.get('八')!;
    expect(strokeMatches([d.medians[0].first, d.medians[0].first], d.medians[0]), isFalse);
  });
}
