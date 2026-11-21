import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/logic/speech.dart';

import 'spoken_texts.dart';

// Makes sure everything the app reads aloud has a natural-voice recording.
// If this fails, it writes what is missing to build/ and says how to record it.
void main() {
  final index = File('assets/voice/index.txt').readAsLinesSync().where((l) => l.isNotEmpty).toSet();

  test('everything the app reads aloud has a recording', () {
    final missing = [for (final t in spokenTexts()) if (!index.contains(clipName(t))) t]..sort();
    if (missing.isNotEmpty) {
      Directory('build').createSync(recursive: true);
      File('build/voice_missing.txt').writeAsStringSync('${missing.join('\n')}\n');
    }
    expect(missing, isEmpty,
        reason: '${missing.length} texts have no recording. Run: python3 tool/make_voice.py --extra build/voice_missing.txt');
  });

  test('numbers, prices, dates and times can be read from recorded pieces', () {
    final pieces = numberPieces();
    final missing = [for (final p in pieces) if (!index.contains(pieceName(p))) p]..sort();
    if (missing.isNotEmpty) {
      Directory('build').createSync(recursive: true);
      File('build/voice_pieces.txt').writeAsStringSync('${missing.join('\n')}\n');
    }
    expect(missing, isEmpty,
        reason: '${missing.length} number pieces have no recording. Run: python3 tool/make_voice.py --pieces build/voice_pieces.txt');
    for (final n in numberExamples()) {
      expect(splitIntoPieces(n, (t) => index.contains(pieceName(t))), isNotNull, reason: n);
    }
  });

  test('pieces split the way they are said', () {
    final pieces = numberPieces();
    bool has(String t) => pieces.contains(t);
    expect(splitIntoPieces('三十五块五', has), ['三十五块', '五']);
    expect(splitIntoPieces('下午两点半', has), ['下午', '两点', '半']);
    expect(splitIntoPieces('三月十五号，星期二', has), ['三月', '十五号', '星期二']);
    expect(splitIntoPieces('幺三九，幺二三四', has), ['幺', '三', '九', '幺', '二', '三', '四']);
    expect(splitIntoPieces('你好', has), isNull, reason: 'only number words have pieces');
  });
}
