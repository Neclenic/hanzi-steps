import 'dart:math';

import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/badges.dart';
import '../logic/exercises.dart';
import '../logic/progress.dart';
import '../logic/tone_pairs.dart';
import '../widgets/anim.dart';
import '../widgets/tone_shape.dart';
import 'lesson_screen.dart';
import 'tone_pairs_screen.dart' show PairShape;

/// Your numbers: XP over the last weeks, how each tone is going, the words and tone
/// pairs you miss most, and your badges.
class StatsScreen extends StatelessWidget {
  final Progress progress;
  const StatsScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Stats and badges')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              FadeSlideIn(child: _Overview(progress: progress)),
              _Section('XP in the last 14 days', child: _XpChart(progress: progress)),
              _Section('Your tones', child: _ToneBars(progress: progress)),
              _Section('Tone pairs to practise', child: _HardPairs(progress: progress)),
              _Section('Words you miss most', child: _HardWords(progress: progress)),
              _Section('Badges', child: _BadgeGrid(progress: progress)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section(this.title, {required this.child});

  @override
  Widget build(BuildContext context) => FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ]),
        ),
      );
}

class _Overview extends StatelessWidget {
  final Progress progress;
  const _Overview({required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final tiles = [
      ('⚡', 'Total XP', p.xp),
      ('🔥', 'Day streak', p.streak),
      ('🏅', 'Best streak', p.bestStreak),
      ('🎯', 'Goal days', p.goalDays),
      ('🈶', 'Words learned', p.wordsLearned),
      ('✅', 'Lessons done', allLessons.where(p.isDone).length),
      ('📖', 'Stories read', p.storiesRead.length),
      ('💬', 'Dialogues', p.dialoguesDone.length),
    ];
    return LayoutBuilder(builder: (context, c) {
      final perRow = c.maxWidth > 520 ? 4 : 2;
      final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        for (final (emoji, label, value) in tiles)
          SizedBox(
            width: w,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AnimatedCount(value: value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
      ]);
    });
  }
}

/// One bar per day, today on the right. Hover or long-press a bar for its value.
class _XpChart extends StatelessWidget {
  final Progress progress;
  const _XpChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = progress.lastDaysXp(14);
    final goal = progress.dailyGoal;
    final top = max(goal, days.fold(0, max)).toDouble();
    final now = DateTime.now();
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const h = 120.0;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(children: [
          SizedBox(
            height: h + 18,
            child: Stack(children: [
              // The daily goal as a dashed-looking guide line.
              Positioned(
                left: 0,
                right: 0,
                top: 18 + h - h * goal / top,
                child: Row(children: [
                  Expanded(child: Container(height: 1, color: scheme.outline)),
                  const SizedBox(width: 4),
                  Text('goal $goal', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                ]),
              ),
              Positioned.fill(
                top: 18,
                right: 44,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final (i, xp) in days.indexed)
                    Expanded(
                      child: Tooltip(
                        message: '${_dayLabel(now, 13 - i, names)}: $xp XP',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: xp / top),
                              duration: Duration(milliseconds: 500 + 30 * i),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => Container(
                                height: max(xp > 0 ? 3.0 : 1.0, h * v),
                                decoration: BoxDecoration(
                                  color: xp == 0 ? scheme.outlineVariant : scheme.primary,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 44),
            child: Row(children: [
              for (var i = 0; i < 14; i++)
                Expanded(
                  child: Text(i == 13 ? 'today' : (i % 2 == 1 ? names[now.subtract(Duration(days: 13 - i)).weekday - 1][0] : ''),
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  static String _dayLabel(DateTime now, int daysAgo, List<String> names) {
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    final d = now.subtract(Duration(days: daysAgo));
    return '${names[d.weekday - 1]} ${d.day}.${d.month}.';
  }
}

class _ToneBars extends StatelessWidget {
  final Progress progress;
  const _ToneBars({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = progress.toneStats;
    if (stats.values.every((s) => s.$2 < 3)) {
      return const _Empty('Do a tone lesson, the tone quiz or some speaking practice, and your tones will show up here.');
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          for (var t = 1; t <= 4; t++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                ToneShape(tone: t, size: 22, color: scheme.primary),
                const SizedBox(width: 8),
                SizedBox(width: 56, child: Text('Tone $t')),
                Expanded(
                  child: AnimatedBar(
                    value: (stats[t]?.$2 ?? 0) == 0 ? 0 : stats[t]!.$1 / stats[t]!.$2,
                    height: 12,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 92,
                  child: Text(
                    (stats[t]?.$2 ?? 0) == 0 ? 'not yet' : '${(100 * stats[t]!.$1 / stats[t]!.$2).round()}% of ${stats[t]!.$2}',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ]),
            ),
          Text('Right answers from tone lessons, the tone quiz, typing and speaking.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _HardPairs extends StatelessWidget {
  final Progress progress;
  const _HardPairs({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = progress.pairStats;
    final hard = [
      for (final p in tonePairs)
        if (stats[p.key] case final s? when s.$2 >= 2 && s.$1 < s.$2) (p, s),
    ]..sort((a, b) => (a.$2.$1 / a.$2.$2).compareTo(b.$2.$1 / b.$2.$2));
    if (hard.isEmpty) {
      return const _Empty('Nothing here yet. Try the tone quiz on the Tone pairs page.');
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: [
        for (final (p, s) in hard.take(5))
          ListTile(
            leading: PairShape(p, size: 20, color: scheme.primary),
            title: Text('Tone ${p.label}'),
            subtitle: Text(tonePairExamples[p]!.take(3).map((w) => w.hanzi).join(' · ')),
            trailing: Text('${s.$1} of ${s.$2} right'),
          ),
      ]),
    );
  }
}

class _HardWords extends StatelessWidget {
  final Progress progress;
  const _HardWords({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final words = progress.troubleWords.take(10).toList();
    if (words.isEmpty) return const _Empty('No tricky words right now. Well done!');
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: [
        for (final (w, n) in words)
          ListTile(
            dense: true,
            leading: Text(w.hanzi, style: const TextStyle(fontSize: 24)),
            title: Text(w.pinyin, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
            subtitle: Text(w.meaning),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < min(5, (n + 1) ~/ 2); i++) Icon(Icons.circle, size: 8, color: scheme.error),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LessonScreen(lesson: practiceLesson([for (final (w, _) in words.take(8)) w]), progress: progress),
            )),
            icon: const Icon(Icons.fitness_center),
            label: const Text('Practise these words'),
          ),
        ),
      ]),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final Progress progress;
  const _BadgeGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final earned = badges.where((b) => b.earned(progress)).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('$earned of ${badges.length} earned', style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, c) {
        final perRow = c.maxWidth > 520 ? 4 : 3;
        final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (i, b) in badges.indexed)
            SizedBox(
              width: w,
              child: FadeSlideIn(
                delay: Duration(milliseconds: 20 * i),
                child: Tooltip(message: b.description, child: _BadgeTile(badge: b, progress: progress)),
              ),
            ),
        ]);
      }),
    ]);
  }
}

class _BadgeTile extends StatelessWidget {
  final HsBadge badge;
  final Progress progress;
  const _BadgeTile({required this.badge, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final got = badge.earned(progress);
    return Card(
      margin: EdgeInsets.zero,
      color: got ? (scheme.brightness == Brightness.dark ? const Color(0xFF4A3B10) : const Color(0xFFFFF4CC)) : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: got ? Colors.amber.shade600 : Colors.transparent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Opacity(
            opacity: got ? 1 : 0.3,
            child: got
                ? PopIn(child: Text(badge.emoji, style: const TextStyle(fontSize: 34)))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0, //
                    ]),
                    child: Text(badge.emoji, style: const TextStyle(fontSize: 34)),
                  ),
          ),
          const SizedBox(height: 4),
          Text(badge.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          // Fixed heights, so all tiles in a row line up.
          SizedBox(
            height: 30,
            child: Text(badge.description, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ),
          SizedBox(
            height: 28,
            child: got
                ? Center(
                    child: Text('Earned!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                  )
                : Column(children: [
                    const SizedBox(height: 4),
                    AnimatedBar(value: badge.share(progress), height: 5, color: Colors.amber.shade700),
                    const SizedBox(height: 2),
                    Text('${min(badge.now(progress), badge.goal)} / ${badge.goal}',
                        style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                  ]),
          ),
        ]),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}
