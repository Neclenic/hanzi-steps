import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/course.dart';
import '../data/stories.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/exercises.dart';
import '../logic/settings.dart';
import '../data/dialogues.dart';
import '../data/grammar.dart';
import '../logic/badges.dart';
import '../data/exam.dart';
import '../logic/exam.dart';
import '../data/culture.dart';
import '../data/look_alikes.dart';
import '../data/textbook.dart';
import '../data/idioms.dart';
import '../data/radicals.dart';
import '../logic/daily_challenge.dart';
import '../logic/version.dart';
import '../logic/weekly_report.dart';
import '../widgets/panda.dart';
import 'culture_screen.dart';
import 'idioms_screen.dart';
import 'measure_words_screen.dart';
import 'memory_writing_screen.dart';
import 'pinyin_chart_screen.dart';
import 'radicals_screen.dart';
import 'weekly_report_screen.dart';
import 'dialogue_screen.dart';
import 'dictation_screen.dart';
import 'look_alikes_screen.dart';
import 'my_words_screen.dart';
import 'numbers_screen.dart';
import 'placement_screen.dart';
import 'word_search_screen.dart';
import 'exam_screen.dart';
import 'games_screen.dart';
import 'grammar_screen.dart';
import 'stats_screen.dart';
import 'tone_pairs_screen.dart';
import 'typing_screen.dart';
import 'speaking_screen.dart';
import 'lesson_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';
import 'survival_screen.dart';
import 'textbook_screen.dart';
import 'writing_screen.dart';
import '../widgets/anim.dart';

/// The main screen: today's goal, practice activities, and a path of lessons
/// grouped into units, for the chosen HSK level.
class HomeScreen extends StatelessWidget {
  final Progress progress;
  const HomeScreen({super.key, required this.progress});

  Future<void> _open(BuildContext context, Lesson lesson) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonScreen(lesson: lesson, progress: progress),
    ));
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  /// Opens the activity that today's challenge is about.
  void _openChallenge(BuildContext context, ChallengeGo go, Lesson? current) {
    final p = progress;
    final screen = switch (go) {
      ChallengeGo.lesson => null,
      ChallengeGo.dialogue => DialoguesScreen(progress: p),
      ChallengeGo.story => StoriesScreen(progress: p),
      ChallengeGo.textbook => TextbookScreen(progress: p),
      ChallengeGo.tonePairs => TonePairsScreen(progress: p),
      ChallengeGo.numbers => NumbersScreen(progress: p),
      ChallengeGo.lookAlikes => LookAlikesScreen(progress: p),
      ChallengeGo.dictation => DictationScreen(progress: p),
      ChallengeGo.typing => TypingScreen(progress: p),
      ChallengeGo.measures => MeasureWordsScreen(progress: p),
      ChallengeGo.memory => MemoryWritingScreen(progress: p),
      ChallengeGo.idioms => IdiomsScreen(progress: p),
      ChallengeGo.games => GamesScreen(progress: p),
      ChallengeGo.none => null,
    };
    if (screen != null) {
      _push(context, screen);
    } else if (go == ChallengeGo.lesson && current != null) {
      _open(context, current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settings = Settings.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([progress, settings]),
      builder: (context, _) {
        final level = settings.level;
        // The next lesson to do in this course gets a pulsing ring and a "START" bubble.
        final current = lessonsOf(level).where((l) => progress.isUnlocked(l) && !progress.isDone(l)).firstOrNull;
        final units = unitsOf(level);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hanzi Steps 汉字', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              _Stat(icon: Icons.local_fire_department, color: Colors.orange, value: progress.streak, tip: 'Day streak'),
              _Stat(icon: Icons.bolt, color: Colors.amber.shade700, value: progress.xp, tip: 'Total XP'),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Word search',
                onPressed: () => _push(context, WordSearchScreen(progress: progress)),
              ),
              IconButton(
                icon: const Icon(Icons.draw),
                tooltip: 'Writing practice',
                onPressed: () => _push(context, WritingScreen(progress: progress)),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => _push(context, SettingsScreen(progress: progress)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: _PracticeButton(progress: progress, onStart: (l) => _open(context, l)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  const _NoVoiceBanner(),
                  const _UpdateBanner(),
                  if (!progress.placementSeen && progress.completed.isEmpty)
                    FadeSlideIn(child: _PlacementCard(progress: progress, onOpen: () => _push(context, PlacementScreen(progress: progress)))),
                  FadeSlideIn(child: _GoalCard(progress: progress)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 20),
                    child: _ChallengeCard(progress: progress, onGo: (go) => _openChallenge(context, go, current)),
                  ),
                  if (reportDue(progress))
                    FadeSlideIn(child: _ReportCard(onOpen: () => _push(context, WeeklyReportScreen(progress: progress)))),
                  FadeSlideIn(delay: const Duration(milliseconds: 40), child: PandaCard(progress: progress)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _TextbookCard(progress: progress, onOpen: () => _push(context, TextbookScreen(progress: progress))),
                  ),
                  const SizedBox(height: 4),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _ActivityGrid(tiles: [
                      _ActivityTile(
                        icon: Icons.menu_book,
                        color: const Color(0xFF2E86AB),
                        title: 'Stories',
                        subtitle: '${progress.storiesRead.length} of ${stories.length} read',
                        onTap: () => _push(context, StoriesScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.forum_outlined,
                        color: const Color(0xFF7B61FF),
                        title: 'Dialogues',
                        subtitle: '${progress.dialoguesDone.length} of ${dialogues.length} done',
                        onTap: () => _push(context, DialoguesScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.luggage_outlined,
                        color: const Color(0xFF00838F),
                        title: 'Survival phrases',
                        subtitle: 'Taxi, restaurant, hotel, help',
                        onTap: () => _push(context, SurvivalScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.mic,
                        color: const Color(0xFF3BB273),
                        title: 'Speaking',
                        subtitle: 'Say it, check your tones',
                        onTap: () => _push(context, SpeakingScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.graphic_eq,
                        color: const Color(0xFFE4572E),
                        title: 'Tone pairs',
                        subtitle: 'The 20 tone combinations',
                        onTap: () => _push(context, TonePairsScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.grid_on,
                        color: const Color(0xFF5E35B1),
                        title: 'Pinyin chart',
                        subtitle: 'Every syllable, all four tones',
                        onTap: () => _push(context, PinyinChartScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.hearing,
                        color: const Color(0xFF1565C0),
                        title: 'Dictation',
                        subtitle: 'Hear a sentence, build it',
                        onTap: () => _push(context, DictationScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.keyboard_alt_outlined,
                        color: const Color(0xFF00897B),
                        title: 'Type pinyin',
                        subtitle: 'Hear a word, type it',
                        onTap: () => _push(context, TypingScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF2E7D32),
                        title: 'Numbers',
                        subtitle: 'Prices, phones, dates, times',
                        onTap: () => _push(context, NumbersScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.compare_arrows,
                        color: const Color(0xFFAD1457),
                        title: 'Look-alikes',
                        subtitle: '${lookAlikeGroups.length} groups like 人 · 入',
                        onTap: () => _push(context, LookAlikesScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.format_list_numbered,
                        color: const Color(0xFF6A1B9A),
                        title: 'Counting words',
                        subtitle: '个 本 张 件 只 杯 and more',
                        onTap: () => _push(context, MeasureWordsScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.edit_note,
                        color: const Color(0xFF37474F),
                        title: 'From memory',
                        subtitle: 'Write with no outline (默写)',
                        onTap: () => _push(context, MemoryWritingScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.auto_stories_outlined,
                        color: const Color(0xFFBF360C),
                        title: 'Idiom stories',
                        subtitle: '${progress.idiomsRead.length} of ${idioms.length} read · 画蛇添足',
                        onTap: () => _push(context, IdiomsScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.extension_outlined,
                        color: const Color(0xFF0277BD),
                        title: 'Radicals',
                        subtitle: '${radicals.length} parts like 氵 口 女',
                        onTap: () => _push(context, RadicalsScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.lightbulb_outline,
                        color: const Color(0xFF8D6E63),
                        title: 'Grammar',
                        subtitle: '${grammarTips.length} short tips',
                        onTap: () => _push(context, GrammarScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.temple_buddhist_outlined,
                        color: const Color(0xFFC62828),
                        title: 'Culture',
                        subtitle: '${cultureNotes.length} notes on life in China',
                        onTap: () => _push(context, CultureScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.search,
                        color: const Color(0xFF455A64),
                        title: 'Word search',
                        subtitle: 'Look up any course word',
                        onTap: () => _push(context, WordSearchScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.star_outline,
                        color: const Color(0xFFF9A825),
                        title: 'My words',
                        subtitle: progress.myWords.isEmpty ? 'Save words with ☆' : '${progress.myWords.length} saved',
                        onTap: () => _push(context, MyWordsScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.sports_esports_outlined,
                        color: const Color(0xFFF4A259),
                        title: 'Games',
                        subtitle: 'Speed match, falling characters',
                        onTap: () => _push(context, GamesScreen(progress: progress)),
                      ),
                      if (examSets.containsKey(level))
                      _ActivityTile(
                        icon: Icons.timer_outlined,
                        color: const Color(0xFFD7263D),
                        title: 'Mini exam',
                        subtitle: progress.bestExamFor(level) == null
                            ? 'HSK $level style test'
                            : 'HSK $level best: ${progress.bestExamFor(level)} / ${examMaxFor(level)}',
                        onTap: () => _push(context, ExamIntroScreen(progress: progress, level: level)),
                      ),
                      _ActivityTile(
                        icon: Icons.explore_outlined,
                        color: const Color(0xFF6D4C41),
                        title: 'Placement test',
                        subtitle: 'Skip what you already know',
                        onTap: () => _push(context, PlacementScreen(progress: progress)),
                      ),
                      _ActivityTile(
                        icon: Icons.insights,
                        color: const Color(0xFF546E7A),
                        title: 'Stats & badges',
                        subtitle: '${earnedBadges(progress).length} of ${badges.length} badges',
                        onTap: () => _push(context, StatsScreen(progress: progress)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SegmentedButton<int>(
                      segments: [for (final l in levels) ButtonSegment(value: l, label: Text('HSK $l'))],
                      selected: {level},
                      onSelectionChanged: (v) => settings.level = v.first,
                    ),
                  ),
                  const SizedBox(height: 8),
                  KeyedSubtree(
                    key: ValueKey(level),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      FadeSlideIn(child: _CourseCard(progress: progress, level: level)),
                      if (level > 1 && !lessonsOf(level - 1).every(progress.isDone))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Tip: HSK $level builds on HSK ${level - 1}. You can start here any time, '
                            'but finishing HSK ${level - 1} first makes it easier.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      for (final unit in units) ...[
                        FadeSlideIn(child: _UnitHeader(unit: unit)),
                        for (final (i, lesson) in unit.lessons.indexed)
                          FadeSlideIn(
                            delay: Duration(milliseconds: 60 * i),
                            child: _LessonNode(
                              lesson: lesson,
                              color: Color(unit.colorValue),
                              offset: i.isEven ? -60 : 60,
                              done: progress.isDone(lesson),
                              unlocked: progress.isUnlocked(lesson),
                              current: lesson == current,
                              onTap: () => _open(context, lesson),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        level < levels.last
                            ? 'Next: HSK ${level + 1}. Pick it at the top of the path.'
                            : 'You have reached the end of HSK 3. 太棒了!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Today's XP towards the daily goal, as a ring, plus the last 7 days as bars.
class _GoalCard extends StatelessWidget {
  final Progress progress;
  const _GoalCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goal = progress.dailyGoal, today = progress.xpToday;
    final met = today >= goal;
    final week = progress.lastWeekXp;
    final most = [goal, ...week].reduce((a, b) => a > b ? a : b);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final color = met ? const Color(0xFF2E9E5B) : Colors.amber.shade700;
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (c) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Daily goal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GoalPicker(progress: progress),
                ReminderSettings(progress: progress),
              ]),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            AnimatedRing(
              value: goal == 0 ? 1 : today / goal,
              color: color,
              size: 72,
              stroke: 8,
              child: met
                  ? const PopIn(child: Icon(Icons.check_rounded, size: 34, color: Color(0xFF2E9E5B)))
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedCount(value: today, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('/ $goal', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(met ? 'Daily goal reached! 🎉' : 'Daily goal: $goal XP',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  met
                      ? 'Come back tomorrow to keep your streak.'
                      : '${goal - today} XP to go today${Settings.instance.reminderOn ? '' : ' · tap to set a reminder'}',
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            // The last 7 days, today on the right.
            SizedBox(
              height: 56,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < 7; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: most == 0 ? 0 : week[i] / most),
                        duration: Duration(milliseconds: 500 + 60 * i),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Container(
                          width: 10,
                          height: 4 + 34 * v,
                          decoration: BoxDecoration(
                            color: week[i] >= goal ? const Color(0xFF2E9E5B) : (week[i] > 0 ? Colors.amber.shade600 : scheme.surfaceContainerHighest),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(days[now.subtract(Duration(days: 6 - i)).weekday - 1],
                          style: TextStyle(
                              fontSize: 10,
                              color: i == 6 ? scheme.primary : scheme.onSurfaceVariant,
                              fontWeight: i == 6 ? FontWeight.bold : null)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A small card on the home screen that opens a practice activity.
/// Practice activities in rows of three (two on a narrow window).
class _ActivityGrid extends StatelessWidget {
  final List<Widget> tiles;
  const _ActivityGrid({required this.tiles});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final perRow = c.maxWidth >= 540 ? 4 : (c.maxWidth >= 400 ? 3 : 2);
        final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
        return Wrap(spacing: 8, runSpacing: 8, children: [for (final t in tiles) SizedBox(width: w, child: t)]);
      });
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActivityTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => PressBounce(
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 18, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
                const SizedBox(height: 8),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Two lines tall, so tiles in a row line up.
                SizedBox(
                  height: 34,
                  child: Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// Today's small task, with a bonus for finishing it.
class _ChallengeCard extends StatelessWidget {
  final Progress progress;
  final ValueChanged<ChallengeGo> onGo;
  const _ChallengeCard({required this.progress, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final st = challengeToday(progress);
    final c = st.challenge;
    final s = progress.challengeState;
    if (s['day'] != Progress.todayKey || s['id'] != c.id) {
      // Today's challenge counts from the moment it is first shown.
      WidgetsBinding.instance.addPostFrameCallback((_) => startChallenge(progress));
    }
    final Widget action;
    if (st.claimed) {
      action = const Chip(avatar: Icon(Icons.check, size: 18, color: Color(0xFF2E9E5B)), label: Text('Done'));
    } else if (st.complete) {
      action = PopIn(
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E9E5B)),
          onPressed: () async {
            if (await claimChallenge(progress) && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge done! +$challengeBonus XP 🎉')));
            }
          },
          child: const Text('CLAIM +$challengeBonus XP'),
        ),
      );
    } else if (c.go != ChallengeGo.none) {
      action = OutlinedButton(onPressed: () => onGo(c.go), child: const Text('GO'));
    } else {
      action = const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(children: [
          Text(c.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DAILY CHALLENGE', style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold, color: scheme.primary)),
              Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: AnimatedBar(value: st.done / c.goal)),
                const SizedBox(width: 8),
                Text('${st.done} / ${c.goal}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ]),
              if (!st.claimed && !st.complete)
                Text('Bonus: +$challengeBonus XP', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              if (st.claimed) Text('Come back tomorrow for a new one.', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(width: 8),
          action,
        ]),
      ),
    );
  }
}

/// Once a week: your weekly report is ready.
class _ReportCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _ReportCard({required this.onOpen});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(top: 8),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: ListTile(
          leading: const Text('📊', style: TextStyle(fontSize: 28)),
          title: const Text('Your weekly report is ready'),
          subtitle: const Text('Words learned, time spent and your weakest tone'),
          trailing: TextButton(onPressed: onOpen, child: const Text('OPEN')),
          onTap: onOpen,
        ),
      );
}

/// Shown when a newer version is on GitHub.
class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: UpdateChecker.instance,
        builder: (context, _) {
          final u = UpdateChecker.instance.available;
          if (u == null) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(top: 8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
              child: Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(child: Text('Hanzi Steps ${u.version} is out! You have $appVersion.')),
                FilledButton(onPressed: () => launchUrl(Uri.parse(u.url)), child: const Text('GET IT')),
                IconButton(tooltip: 'Not now', icon: const Icon(Icons.close), onPressed: UpdateChecker.instance.dismiss),
              ]),
            ),
          );
        },
      );
}

/// The textbook, with the next lesson to do.
class _TextbookCard extends StatelessWidget {
  final Progress progress;
  final VoidCallback onOpen;
  const _TextbookCard({required this.progress, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = progress.textbookDone;
    final next = tbLessons.where((l) => !done.contains(l.id)).firstOrNull;
    final count = tbLessons.where((l) => done.contains(l.id)).length;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(colors: [Color(0xFFD7263D), Color(0xFFF18F01)]),
              ),
              child: const Text('课本', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Textbook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  next == null
                      ? 'All ${tbLessons.length} lessons done!'
                      : 'Next: lesson ${next.number}, ${next.title} (${next.titleEn}) · $count of ${tbLessons.length} done',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}

class _PlacementCard extends StatelessWidget {
  final Progress progress;
  final VoidCallback onOpen;
  const _PlacementCard({required this.progress, required this.onOpen});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(top: 8),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Row(children: [
            const Text('🧭', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Already know some Chinese? Take a short placement test and skip the lessons you know.'),
            ),
            TextButton(onPressed: onOpen, child: const Text('TAKE IT')),
            IconButton(
              tooltip: 'No thanks',
              icon: const Icon(Icons.close),
              onPressed: progress.setPlacementSeen,
            ),
          ]),
        ),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String tip;
  const _Stat({required this.icon, required this.color, required this.value, required this.tip});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 4),
            AnimatedCount(value: value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
        ),
      );
}

class _UnitHeader extends StatelessWidget {
  final Unit unit;
  const _UnitHeader({required this.unit});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(unit.colorValue), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (unit.tag.isNotEmpty)
            Text(unit.tag.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(unit.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(unit.description, style: const TextStyle(color: Colors.white70)),
        ]),
      );
}

class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final Color color;
  final double offset;
  final bool done;
  final bool unlocked;
  final bool current;
  final VoidCallback onTap;
  const _LessonNode({
    required this.lesson,
    required this.color,
    required this.offset,
    required this.done,
    required this.unlocked,
    required this.onTap,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = unlocked ? color : scheme.surfaceContainerHighest;
    final icon = done ? Icons.check : (unlocked ? Icons.star : Icons.lock);
    Widget button = Tooltip(
      message: unlocked ? 'Start "${lesson.title}"' : 'Finish the lesson before this one to unlock',
      child: PressBounce(
        enabled: unlocked,
        child: Material(
          color: fill,
          shape: CircleBorder(side: done ? BorderSide(color: Colors.amber.shade600, width: 4) : BorderSide.none),
          elevation: unlocked ? 4 : 0,
          shadowColor: color,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: unlocked ? onTap : null,
            child: SizedBox(
              width: 76,
              height: 76,
              child: Icon(icon, size: 36, color: unlocked ? Colors.white : scheme.outline),
            ),
          ),
        ),
      ),
    );
    if (current) button = PulseRing(color: color, size: 76, child: button);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: current ? 0 : 10),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(children: [
          if (current)
            Bob(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('START', style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          button,
          SizedBox(height: current ? 0 : 6),
          Text(lesson.title, style: TextStyle(fontWeight: FontWeight.w600, color: unlocked ? null : scheme.outline)),
          Text(lesson.subtitle, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// Shown only when no Chinese voice was found, with how to add one.
class _NoVoiceBanner extends StatelessWidget {
  const _NoVoiceBanner();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: Speech.instance.available,
        builder: (context, ok, _) => ok
            ? const SizedBox.shrink()
            : Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: const Icon(Icons.volume_off),
                  title: const Text('Sound is off: no Chinese voice found'),
                  subtitle: const Text('Lessons still work, but you won\'t hear the words. Tap to see how to add a voice.'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Add a Chinese voice'),
                      content: const Text(
                        'Windows: Settings → Time & language → Speech → Manage voices → Add voices → '
                        'choose "Chinese (Simplified, China)". Then restart the app.\n\n'
                        'Mac: System Settings → Accessibility → Spoken Content → System voice → Manage Voices → '
                        'Chinese (China mainland), download a voice such as Tingting. Then restart the app.',
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                    ),
                  ),
                ),
              ),
      );
}

/// "Practice" reviews words from finished lessons, trickiest first.
class _PracticeButton extends StatelessWidget {
  final Progress progress;
  final ValueChanged<Lesson> onStart;
  const _PracticeButton({required this.progress, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final words = progress.wordsToPractice();
    if (words.length < 2) return const SizedBox.shrink(); // finish a word lesson first
    final due = progress.dueWords.length;
    return FloatingActionButton.extended(
      onPressed: () => onStart(practiceLesson(progress.wordsToPractice())),
      icon: Icon(due > 0 ? Icons.replay : Icons.fitness_center),
      label: Text(due > 0 ? 'Review ($due ${due == 1 ? 'word' : 'words'} due)' : 'Practice'),
      tooltip: due > 0
          ? 'These words are due: reviewing them now helps you remember them for longer'
          : 'Nothing is due. Practise the words you find hardest',
    );
  }
}

/// Shows how far along HSK 1 you are and how well the words are sticking.
class _CourseCard extends StatelessWidget {
  final Progress progress;
  final int level;
  const _CourseCard({required this.progress, required this.level});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hsk = hskWordsOf(level).map((w) => w.hanzi).toSet();
    final learned = progress.learnedWords.where((w) => hsk.contains(w.hanzi)).map((w) => w.hanzi).toSet().length;
    final total = hsk.length;
    final boxes = progress.boxCounts;
    final strong = boxes[4] + boxes[5] + boxes[6];
    final due = progress.dueWords.length;
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('HSK $level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('$learned / $total words learned', style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 8),
          AnimatedBar(value: total == 0 ? 0 : learned / total),
          const SizedBox(height: 8),
          Text(
            learned == 0
                ? 'Finish lessons to add words to your review list.'
                : '$strong ${strong == 1 ? 'word' : 'words'} well remembered · '
                    '${due == 0 ? 'nothing to review today' : '$due due for review today'}',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ]),
      ),
    );
  }
}
