import 'dart:math';

import '../data/course.dart';
import '../data/dialogues.dart';
import '../data/stories.dart';
import 'progress.dart';
import 'tone_pairs.dart';

/// A badge to earn. [goal] and [now] give the progress towards it, e.g. 3 of 7 days.
class HsBadge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final int goal;
  final int Function(Progress p) now;
  const HsBadge(this.id, this.emoji, this.title, this.description, this.goal, this.now);

  bool earned(Progress p) => now(p) >= goal;
  double share(Progress p) => min(1, now(p) / goal);
}

int _lessonsDone(Progress p) => allLessons.where(p.isDone).length;
int _levelDone(Progress p, int level) => lessonsOf(level).every(p.isDone) ? 1 : 0;
int _pairsRight(Progress p) => tonePairs.where((t) => (p.pairStats[t.key]?.$1 ?? 0) > 0).length;
int _bestGame(Progress p) => max(p.gameBest('match'), p.gameBest('fall'));

final badges = <HsBadge>[
  HsBadge('first-lesson', '👣', 'First steps', 'Finish your first lesson.', 1, _lessonsDone),
  HsBadge('ten-lessons', '📚', 'Ten lessons', 'Finish 10 lessons.', 10, _lessonsDone),
  HsBadge('fifty-lessons', '🏔️', 'Mountain climber', 'Finish 50 lessons.', 50, _lessonsDone),
  HsBadge('hsk1', '🥉', 'HSK 1 complete', 'Finish every HSK 1 lesson.', 1, (p) => _levelDone(p, 1)),
  HsBadge('hsk2', '🥈', 'HSK 2 complete', 'Finish every HSK 2 lesson.', 1, (p) => _levelDone(p, 2)),
  HsBadge('hsk3', '🥇', 'HSK 3 complete', 'Finish every HSK 3 lesson.', 1, (p) => _levelDone(p, 3)),
  HsBadge('streak3', '🔥', 'On fire', 'Keep a 3-day streak.', 3, (p) => p.bestStreak),
  HsBadge('streak7', '📅', 'One week', 'Keep a 7-day streak.', 7, (p) => p.bestStreak),
  HsBadge('streak30', '🌋', 'Unstoppable', 'Keep a 30-day streak.', 30, (p) => p.bestStreak),
  HsBadge('goal1', '🎯', 'Goal!', 'Reach your daily goal.', 1, (p) => p.goalDays),
  HsBadge('goal7', '🏹', 'Sharp shooter', 'Reach your daily goal on 7 days.', 7, (p) => p.goalDays),
  HsBadge('words50', '🌱', 'Sprouting', 'Learn 50 words.', 50, (p) => p.wordsLearned),
  HsBadge('words150', '🌿', 'Growing', 'Learn 150 words.', 150, (p) => p.wordsLearned),
  HsBadge('words300', '🌳', 'Tall tree', 'Learn 300 words.', 300, (p) => p.wordsLearned),
  HsBadge('words600', '🌲', 'Forest', 'Learn 600 words.', 600, (p) => p.wordsLearned),
  HsBadge('story1', '📖', 'First story', 'Read a story to the end.', 1, (p) => p.storiesRead.length),
  HsBadge('stories', '🐛', 'Bookworm', 'Read every story.', stories.length, (p) => p.storiesRead.length),
  HsBadge('dialogue3', '💬', 'Chatterbox', 'Finish 3 dialogues.', 3, (p) => p.dialoguesDone.length),
  HsBadge('dialogues', '🗣️', 'Smooth talker', 'Finish every dialogue.', dialogues.length, (p) => p.dialoguesDone.length),
  HsBadge('speak20', '🎤', 'Clear voice', 'Get your tones right 20 times when speaking.', 20, (p) => p.count('speakRight')),
  HsBadge('pairs', '🎵', 'Tone master', 'Get each of the 20 tone pairs right in the tone quiz.', 20, _pairsRight),
  HsBadge('typed50', '⌨️', 'Pinyin typist', 'Type 50 words right.', 50, (p) => p.count('typedRight')),
  HsBadge('exam', '📝', 'Exam ready', 'Pass a mini exam.', 1, (p) => p.examsPassed.length),
  HsBadge('exam-all', '🎓', 'Graduate', 'Pass the HSK 1, 2 and 3 mini exams.', 3, (p) => p.examsPassed.length),
  HsBadge('exam-full', '💯', 'Top marks', 'Get full marks in a mini exam.', 1, (p) => p.examFullMarks ? 1 : 0),
  HsBadge('game20', '🎮', 'High score', 'Score 20 in a quick game.', 20, _bestGame),
];

/// The ids of the badges earned so far.
Set<String> earnedBadges(Progress p) => {for (final b in badges) if (b.earned(p)) b.id};

HsBadge badgeById(String id) => badges.firstWhere((b) => b.id == id);
