import '../data/course.dart';
import '../data/reading.dart';
import '../data/stories.dart';

/// What the reader knows about one word in a story.
class StoryWord {
  final String hanzi;
  final String pinyin;
  final String meaning;
  final Word? courseWord; // the course word, if the course teaches it
  const StoryWord(this.hanzi, this.pinyin, this.meaning, this.courseWord);

  /// The HSK level (1 to 4) of this word, or null if it isn't on an HSK list.
  int? get hskLevel => courseWord?.hsk == true ? levelOfWord(hanzi) : null;

  bool get isHsk1 => hskLevel == 1;
}

/// Looks up a word from a story or a reading article. Returns null for punctuation or unknown words.
StoryWord? lookupStoryWord(String token) {
  if (storyPunctuation.contains(token)) return null;
  // A story extra wins: it can be a different word written like a course word,
  // such as 只 zhī (for animals) and the HSK 3 word 只 zhǐ (only).
  final extra = storyExtras[token] ?? readingExtras[token];
  if (extra != null) return StoryWord(token, extra.$1, extra.$2, null);
  final w = wordFor(token);
  if (w != null) return StoryWord(w.hanzi, w.pinyin, w.meaning, w);
  return null;
}

/// How hard a story is, worked out from its words.
class StoryLevel {
  final int totalWords; // every word, counting repeats (names left out)
  final Map<int, int> byLevel; // how many of them are HSK 1, 2 and 3 words; 0 = none of these
  final int level; // the HSK level the story is written at
  final Set<String> newWords; // different words above that level, or outside HSK
  const StoryLevel(this.totalWords, this.byLevel, this.level, this.newWords);

  /// Share of the words that are HSK 1 words.
  double get hskShare => shareUpTo(1);

  /// Share of the words that are on the lists of HSK 1 up to [lv].
  double shareUpTo(int lv) {
    if (totalWords == 0) return 1;
    var n = 0;
    for (var l = 1; l <= lv; l++) {
      n += byLevel[l] ?? 0;
    }
    return n / totalWords;
  }

  /// "HSK 2" when nearly every word is HSK 2 or easier, "HSK 2+" when it needs
  /// a few extra words as well.
  String get label => shareUpTo(level) >= 0.85 ? 'HSK $level' : 'HSK $level+';
}

StoryLevel levelOf(Story story) {
  var total = 0;
  final by = <int, int>{};
  final words = <String, int>{}; // word → its level (0 for none)
  for (final p in story.paragraphs) {
    for (final t in p.tokens) {
      final w = lookupStoryWord(t);
      if (w == null || storyNames.contains(t)) continue;
      total++;
      final lv = storyHskNumbers.contains(t) ? 1 : (w.hskLevel ?? 0);
      by[lv] = (by[lv] ?? 0) + 1;
      words[t] = lv;
    }
  }
  // The level is the lowest one that covers at least 95% of the HSK words used.
  final hskTotal = total - (by[0] ?? 0);
  var level = 1;
  for (final lv in levels) {
    level = lv;
    var n = 0;
    for (var l = 1; l <= lv; l++) {
      n += by[l] ?? 0;
    }
    if (hskTotal == 0 || n / hskTotal >= 0.95) break;
  }
  final fresh = {for (final e in words.entries) if (e.value == 0 || e.value > level) e.key};
  return StoryLevel(total, by, level, fresh);
}

/// Share of a story's words (counting repeats) that the learner has already learned.
double knownShare(Story story, Set<String> learned) {
  var total = 0, known = 0;
  for (final p in story.paragraphs) {
    for (final t in p.tokens) {
      if (lookupStoryWord(t) == null) continue;
      total++;
      if (learned.contains(t)) known++;
    }
  }
  return total == 0 ? 1 : known / total;
}
