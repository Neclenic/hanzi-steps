import '../data/course.dart';
import '../data/stories.dart';

/// What the reader knows about one word in a story.
class StoryWord {
  final String hanzi;
  final String pinyin;
  final String meaning;
  final Word? courseWord; // the course word, if the course teaches it
  const StoryWord(this.hanzi, this.pinyin, this.meaning, this.courseWord);

  bool get isHsk1 => courseWord?.hsk == true && hskWords.contains(courseWord);
}

/// Looks up a word from a story. Returns null for punctuation or unknown words.
StoryWord? lookupStoryWord(String token) {
  if (storyPunctuation.contains(token)) return null;
  final w = wordFor(token);
  if (w != null) return StoryWord(w.hanzi, w.pinyin, w.meaning, w);
  final extra = storyExtras[token];
  if (extra != null) return StoryWord(token, extra.$1, extra.$2, null);
  return null;
}

/// How hard a story is, worked out from its words.
class StoryLevel {
  final int totalWords; // every word, counting repeats
  final int hskWords; // of those, how many are HSK 1 words
  final Set<String> newWords; // different words outside HSK 1
  const StoryLevel(this.totalWords, this.hskWords, this.newWords);

  double get hskShare => totalWords == 0 ? 1 : hskWords / totalWords;

  /// For now the app only has the HSK 1 list. When HSK 2 and 3 lists are added,
  /// this is where a story gets sorted into the higher levels.
  String get label => hskShare >= 0.85 ? 'HSK 1' : 'HSK 1+';
}

StoryLevel levelOf(Story story) {
  var total = 0, hsk = 0;
  final fresh = <String>{};
  for (final p in story.paragraphs) {
    for (final t in p.tokens) {
      final w = lookupStoryWord(t);
      if (w == null || storyNames.contains(t)) continue;
      total++;
      if (w.isHsk1 || storyHskNumbers.contains(t)) {
        hsk++;
      } else {
        fresh.add(t);
      }
    }
  }
  return StoryLevel(total, hsk, fresh);
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
