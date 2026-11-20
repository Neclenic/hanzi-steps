// Works out Xiaoxiao's pitch line for every sentence that can be shadowed, so the
// shadowing screen can draw her line next to yours. Needs ffmpeg.
// Run from the project folder after tool/make_voice.py:  dart run tool/make_pitch.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hanzi_steps/logic/pitch.dart';
import 'package:hanzi_steps/logic/shadowing.dart';

String clipName(String text) =>
    sha1.convert(utf8.encode(text.replaceAll(RegExp(r'\s'), ''))).toString().substring(0, 12);

List<double> squeeze(List<double> v, int n) {
  if (v.length <= n) return [for (final x in v) (x * 10).round() / 10];
  return [for (var i = 0; i < n; i++) (v[(i * (v.length - 1) / (n - 1)).round()] * 10).round() / 10];
}

Future<void> main() async {
  final out = <String, Object>{};
  var lines = 0;
  for (final item in allShadowItems()) {
    final name = clipName(item.hanzi);
    final file = File('assets/voice/$name.mp3');
    if (!file.existsSync()) continue;
    final r = await Process.run('ffmpeg', ['-v', 'error', '-i', file.path, '-f', 's16le', '-ac', '1', '-ar', '$sampleRate', '-'],
        stdoutEncoding: null);
    final samples = pcm16ToSamples(Uint8List.fromList(r.stdout as List<int>));
    final points = trackPitch(samples);
    final ref = medianPitch(points);
    final expected = spokenTones(tonesOf(item.pinyin));
    final parts = ref == null ? const <SyllableContour>[] : splitSyllables(points, expected.length, ref);
    final ok = parts.length == expected.length;
    if (ok) lines++;
    out[name] = {
      'd': (samples.length * 1000 / sampleRate).round(),
      if (ok) 's': [for (final p in parts) squeeze(p.semitones, 12)],
    };
  }
  File('assets/voice/pitch.json').writeAsStringSync(jsonEncode(out));
  stdout.writeln('${out.length} items, $lines with a pitch line');
}
