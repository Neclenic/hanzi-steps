import '../data/course.dart';
import 'pitch.dart';

const _marked = {
  'a': ['ā', 'á', 'ǎ', 'à'],
  'e': ['ē', 'é', 'ě', 'è'],
  'i': ['ī', 'í', 'ǐ', 'ì'],
  'o': ['ō', 'ó', 'ǒ', 'ò'],
  'u': ['ū', 'ú', 'ǔ', 'ù'],
  'ü': ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
};

final _plainOf = {
  for (final e in _marked.entries)
    for (final m in e.value) m: e.key,
};

/// Pinyin letters only, without tone marks, spaces, apostrophes or numbers.
/// "ü" and "v" count as the same letter, as on a keyboard.
String pinyinLetters(String s) {
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final plain = _plainOf[c] ?? c;
    if (plain == 'ü' || plain == 'v') {
      b.write('v');
    } else if (RegExp(r'[a-z]').hasMatch(plain)) {
      b.write(plain);
    }
  }
  return b.toString();
}

/// Puts a tone mark on one syllable, e.g. ("hao", 3) → "hǎo".
/// The mark goes on a or e if there is one, on the o of "ou", otherwise on the last vowel.
String markSyllable(String syl, int tone) {
  final s = syl.replaceAll('v', 'ü');
  if (tone < 1 || tone > 4) return s;
  int at;
  if (s.contains('a')) {
    at = s.indexOf('a');
  } else if (s.contains('e')) {
    at = s.indexOf('e');
  } else if (s.contains('ou')) {
    at = s.indexOf('o');
  } else {
    at = -1;
    for (var i = s.length - 1; i >= 0; i--) {
      if (_marked.containsKey(s[i])) {
        at = i;
        break;
      }
    }
  }
  if (at < 0) return s;
  return s.substring(0, at) + _marked[s[at]]![tone - 1] + s.substring(at + 1);
}

/// Turns typed pinyin with tone numbers into tone marks as you type,
/// e.g. "ni3hao3" → "nǐhǎo" and "nv3" → "nǚ". 5 and 0 mean the light tone.
String numberedToMarked(String input) {
  final out = StringBuffer();
  final syl = StringBuffer();
  for (final c in input.split('')) {
    if (RegExp(r'[0-5]').hasMatch(c)) {
      out.write(markSyllable(syl.toString(), int.parse(c)));
      syl.clear();
    } else if (RegExp(r'[a-zA-Züv]').hasMatch(c)) {
      syl.write(c);
    } else {
      out.write(syl.toString().replaceAll('v', 'ü'));
      syl.clear();
      out.write(c);
    }
  }
  out.write(syl.toString().replaceAll('v', 'ü'));
  return out.toString();
}

/// The tones in typed pinyin: from numbers ("ni3hao3") or from tone marks ("nǐhǎo").
/// Light tones typed as 5 or 0 come back as 0.
List<int> typedTones(String typed) {
  final digits = RegExp(r'[0-5]').allMatches(typed).map((m) => int.parse(m[0]!)).toList();
  if (digits.isNotEmpty) return [for (final d in digits) d == 5 ? 0 : d];
  return tonesOf(typed);
}

/// The result of checking typed pinyin.
class TypedCheck {
  final bool lettersOk;
  final bool tonesOk;
  final List<int> expected; // the word's tones (0 = light)
  final List<int> typed;
  const TypedCheck(this.lettersOk, this.tonesOk, this.expected, this.typed);
  bool get ok => lettersOk && tonesOk;
}

/// Tones that are also accepted for 一 and 不, which change tone depending on the next word.
const _flexible = {'一': {1, 2, 4}, '不': {2, 4}};

/// Checks typed pinyin against a word. Light tones may be left out or typed as 5 or 0.
TypedCheck checkTyped(String typed, Word word) {
  final lettersOk = pinyinLetters(typed) == pinyinLetters(word.pinyin);
  final expected = tonesOf(word.pinyin);
  final got = typedTones(typed);
  var chars = word.hanzi.split('');
  // In words like 一点儿 yìdiǎnr, the 儿 is only an "r" sound, not a syllable.
  if (chars.length != expected.length) chars = chars.where((c) => c != '儿').toList();
  bool fits(int i, int t) {
    if (expected[i] == t) return true;
    final allowed = chars.length == expected.length ? _flexible[chars[i]] : null;
    return allowed != null && allowed.contains(t);
  }

  bool tonesOk;
  if (got.length == expected.length) {
    tonesOk = [for (var i = 0; i < got.length; i++) fits(i, got[i])].every((x) => x);
  } else {
    // Light tones left out: compare the other syllables only.
    final positions = [for (var i = 0; i < expected.length; i++) if (expected[i] != 0) i];
    tonesOk = got.length == positions.length &&
        [for (var j = 0; j < got.length; j++) fits(positions[j], got[j])].every((x) => x);
  }
  return TypedCheck(lettersOk, tonesOk, expected, got);
}
