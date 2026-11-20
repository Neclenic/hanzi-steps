import '../data/course.dart';
import '../data/look_alikes.dart';
import '../data/stories.dart';
import 'pinyin_input.dart';

/// Finds a word by its characters: a course word, or an extra word from the stories.
Word? lookupWord(String hanzi) {
  final w = wordFor(hanzi);
  if (w != null) return w;
  final extra = storyExtras[hanzi];
  if (extra != null) return Word(hanzi, extra.$1, extra.$2, hsk: false);
  return null;
}

/// Where a word is taught: its unit and lesson, or null if no lesson teaches it.
(Unit, Lesson)? whereTaught(String hanzi) {
  for (final u in course) {
    for (final l in u.lessons) {
      if (l.words.any((w) => w.hanzi == hanzi)) return (u, l);
    }
  }
  return null;
}

/// The look-alike groups a word's characters belong to.
List<LookAlikeGroup> lookAlikesFor(String hanzi) => [
      for (final g in lookAlikeGroups)
        if (g.chars.any((c) => hanzi.contains(c.char))) g,
    ];

/// Every course word once, in the order the course teaches them.
final List<Word> courseWords = () {
  final seen = <String>{};
  return [
    for (final w in allWords)
      if (seen.add('${w.hanzi}|${w.pinyin}')) w,
  ];
}();

/// Does [part] appear in [letters] at the start of a syllable? It must follow the end of
/// another syllable (a vowel, or n, g or r), so "hao" is found in nihao but not in zhao or shao.
bool _startsSyllable(String letters, String part) {
  for (var i = letters.indexOf(part, 1); i > 0; i = letters.indexOf(part, i + 1)) {
    if ('aeiouvngr'.contains(letters[i - 1])) return true;
  }
  return false;
}

/// Searches the course by characters, pinyin (with or without tones) or English meaning.
List<Word> searchWords(String query, {int limit = 60}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final letters = pinyinLetters(q);
  final marked = numberedToMarked(q).replaceAll(' ', '');
  final hasTones = marked != pinyinLetters(marked) && RegExp('[āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ0-5]').hasMatch(q);
  // Only letters (no tones): it may be toneless pinyin.
  final plainPinyin = RegExp(r'^[a-zü ]+$').hasMatch(q);
  final scored = <(Word, int)>[];
  for (final w in courseWords) {
    final py = w.pinyin.toLowerCase();
    final pyLetters = pinyinLetters(py);
    final meaning = w.meaning.toLowerCase();
    int? score;
    if (w.hanzi == q) {
      score = 0;
    } else if (w.hanzi.contains(q)) {
      score = 1;
    } else if (hasTones && py.replaceAll(' ', '').startsWith(marked)) {
      score = py.replaceAll(' ', '') == marked ? 2 : 3;
    } else if (!hasTones && letters.isNotEmpty && plainPinyin && pyLetters.startsWith(letters)) {
      score = pyLetters == letters ? 2 : 4;
    } else if (!hasTones && letters.length >= 2 && plainPinyin && _startsSyllable(pyLetters, letters)) {
      score = 5; // a later syllable, like hao in 你好
    } else if (RegExp('(^|[^a-z])${RegExp.escape(q)}').hasMatch(meaning)) {
      score = meaning == q || meaning.startsWith('$q ') || meaning.startsWith('to $q') ? 2 : 5;
    }
    if (score != null) scored.add((w, score));
  }
  scored.sort((a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$1.hanzi.length.compareTo(b.$1.hanzi.length));
  return [for (final (w, _) in scored.take(limit)) w];
}
