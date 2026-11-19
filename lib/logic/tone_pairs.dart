import '../data/course.dart';
import 'pitch.dart';

/// A combination of two tones, like 3 + 4. The second tone can be 0, the light tone.
class TonePair {
  final int first; // 1–4
  final int second; // 0–4
  const TonePair(this.first, this.second);

  String get key => '$first-$second';
  String get label => '$first + ${second == 0 ? 'light' : second}';

  /// How the pair is actually said: two third tones become 2 + 3.
  List<int> get spoken => spokenTones([first, second]);

  @override
  bool operator ==(Object other) => other is TonePair && other.first == first && other.second == second;
  @override
  int get hashCode => key.hashCode;
}

/// The 20 tone pairs: four first tones, each followed by tone 1, 2, 3, 4 or the light tone.
final tonePairs = <TonePair>[
  for (var a = 1; a <= 4; a++)
    for (final b in [1, 2, 3, 4, 0]) TonePair(a, b),
];

Map<TonePair, List<Word>>? _examples;

/// Two-character course words for each tone pair, easiest (HSK 1) first.
Map<TonePair, List<Word>> get tonePairExamples {
  final cached = _examples;
  if (cached != null) return cached;
  final map = <TonePair, List<Word>>{for (final p in tonePairs) p: <Word>[]};
  final seen = <String>{};
  for (final w in allWords) {
    if (w.hanzi.length != 2 || w.pinyin.contains(' ') || !seen.add(w.hanzi)) continue;
    final t = tonesOf(w.pinyin);
    if (t.length != 2 || t[0] == 0) continue;
    // 一 and 不 change their tone, which would muddle the drill.
    if (w.hanzi.contains('一') || w.hanzi.contains('不')) continue;
    map[TonePair(t[0], t[1])]?.add(w);
  }
  return _examples = map;
}

/// The tone pair of a two-syllable word, or null.
TonePair? pairOf(Word w) {
  final t = tonesOf(w.pinyin);
  if (t.length != 2 || t[0] == 0) return null;
  return TonePair(t[0], t[1]);
}
