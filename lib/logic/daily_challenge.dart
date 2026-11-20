import 'progress.dart';

/// Where tapping the challenge card takes you.
enum ChallengeGo { lesson, dialogue, story, textbook, tonePairs, numbers, lookAlikes, dictation, typing, measures, memory, idioms, games, none }

/// One small task for the day. Progress is a counter's growth since the day began.
class DailyChallenge {
  final String id;
  final String emoji;
  final String title;
  final String counter; // a Progress counter, or 'xp' for today's XP
  final int goal;
  final ChallengeGo go;
  const DailyChallenge(this.id, this.emoji, this.title, this.counter, this.goal, this.go);
}

const challengeBonus = 20;

const dailyChallenges = <DailyChallenge>[
  DailyChallenge('lessons2', '👣', 'Finish 2 lessons', 'lessonRuns', 2, ChallengeGo.lesson),
  DailyChallenge('dialogue', '💬', 'Finish a dialogue', 'dialogueRuns', 1, ChallengeGo.dialogue),
  DailyChallenge('numbers8', '💴', 'Get 8 number questions right', 'numbersRight', 8, ChallengeGo.numbers),
  DailyChallenge('story', '📖', 'Read a story to the end', 'storyRuns', 1, ChallengeGo.story),
  DailyChallenge('measures8', '🧮', 'Get 8 counting words right', 'measureRight', 8, ChallengeGo.measures),
  DailyChallenge('textbook', '🎒', 'Finish a textbook lesson', 'textbookRuns', 1, ChallengeGo.textbook),
  DailyChallenge('pairs', '🎵', 'Do a round of tone pairs', 'pairRounds', 1, ChallengeGo.tonePairs),
  DailyChallenge('memory3', '✍️', 'Write 3 characters from memory', 'memoryRight', 3, ChallengeGo.memory),
  DailyChallenge('looks6', '🔍', 'Get 6 look-alikes right', 'lookAlikeRight', 6, ChallengeGo.lookAlikes),
  DailyChallenge('idiom', '🐍', 'Read an idiom story', 'idiomRuns', 1, ChallengeGo.idioms),
  DailyChallenge('dictation3', '👂', 'Get 3 dictation sentences right', 'dictationRight', 3, ChallengeGo.dictation),
  DailyChallenge('typed8', '⌨️', 'Type 8 words in pinyin', 'typedRight', 8, ChallengeGo.typing),
  DailyChallenge('game', '🎮', 'Play a quick game', 'gameRuns', 1, ChallengeGo.games),
  DailyChallenge('xp40', '⚡', 'Earn 40 XP today', 'xp', 40, ChallengeGo.none),
];

/// Days since 1 Jan 1970, so everyone gets the same challenge on the same day.
int dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

DailyChallenge challengeForDay(int day) => dailyChallenges[day % dailyChallenges.length];

/// Today's challenge and how far along it is.
class ChallengeStatus {
  final DailyChallenge challenge;
  final int done;
  final bool claimed;
  const ChallengeStatus(this.challenge, this.done, this.claimed);
  bool get complete => done >= challenge.goal;
}

int _value(Progress p, DailyChallenge c) => c.counter == 'xp' ? p.xpToday : p.count(c.counter);

/// Reads today's challenge. If it hasn't been started yet today, progress starts from now.
ChallengeStatus challengeToday(Progress p, {DateTime? now}) {
  final today = Progress.todayKey;
  final s = p.challengeState;
  final c = challengeForDay(dayNumber(now ?? DateTime.now()));
  final fresh = s['day'] != today || s['id'] != c.id;
  final base = c.counter == 'xp' ? 0 : (fresh ? _value(p, c) : (s['base'] as num?)?.toInt() ?? 0);
  final done = (_value(p, c) - base).clamp(0, c.goal);
  return ChallengeStatus(c, done, !fresh && s['claimed'] == true);
}

/// Saves where today's challenge starts from, the first time it is seen today.
Future<void> startChallenge(Progress p, {DateTime? now}) async {
  final c = challengeForDay(dayNumber(now ?? DateTime.now()));
  final s = p.challengeState;
  if (s['day'] == Progress.todayKey && s['id'] == c.id) return;
  await p.setChallengeState({'day': Progress.todayKey, 'id': c.id, 'base': _value(p, c), 'claimed': false});
}

/// Gives the bonus once the challenge is complete. Returns false if it isn't ready.
Future<bool> claimChallenge(Progress p, {DateTime? now}) async {
  final st = challengeToday(p, now: now);
  if (!st.complete || st.claimed) return false;
  final s = {...p.challengeState, 'claimed': true};
  await p.setChallengeState(s);
  await p.bump('challengesDone');
  await p.addXp(challengeBonus);
  return true;
}
