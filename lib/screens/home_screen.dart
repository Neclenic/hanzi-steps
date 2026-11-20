import 'package:flutter/material.dart';

import '../data/course.dart';
import '../data/stories.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/exercises.dart';
import 'lesson_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';
import 'writing_screen.dart';

/// The main screen: a path of lessons grouped into units.
class HomeScreen extends StatelessWidget {
  final Progress progress;
  const HomeScreen({super.key, required this.progress});

  Future<void> _open(BuildContext context, Lesson lesson) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonScreen(lesson: lesson, progress: progress),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Hanzi Steps 汉字', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            _Stat(icon: Icons.local_fire_department, color: Colors.orange, value: '${progress.streak}', tip: 'Day streak'),
            _Stat(icon: Icons.bolt, color: Colors.amber.shade700, value: '${progress.xp}', tip: 'Total XP'),
            IconButton(
              icon: const Icon(Icons.draw),
              tooltip: 'Writing practice',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WritingScreen(progress: progress),
              )),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(progress: progress),
              )),
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
                _CourseCard(progress: progress),
                Card(
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book, size: 32),
                    title: const Text('Stories', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${progress.storiesRead.length} of ${stories.length} read · '
                        'short stories using HSK 1 words'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StoriesScreen(progress: progress),
                    )),
                  ),
                ),
                for (final unit in course) ...[
                  if (unit.bonus && unit == course.firstWhere((u) => u.bonus))
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 4),
                      child: Text('Bonus units: extra words outside HSK 1. Open any time.',
                          textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                    ),
                  _UnitHeader(unit: unit),
                  for (final (i, lesson) in unit.lessons.indexed)
                    _LessonNode(
                      lesson: lesson,
                      color: Color(unit.colorValue),
                      offset: i.isEven ? -60 : 60,
                      done: progress.isDone(lesson),
                      unlocked: progress.isUnlocked(lesson),
                      onTap: () => _open(context, lesson),
                    ),
                  const SizedBox(height: 16),
                ],
                Text('More courses coming later.',
                    textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  final VoidCallback onTap;
  const _LessonNode({
    required this.lesson,
    required this.color,
    required this.offset,
    required this.done,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = unlocked ? color : scheme.surfaceContainerHighest;
    final icon = done ? Icons.check : (unlocked ? Icons.star : Icons.lock);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(children: [
          Tooltip(
            message: unlocked ? 'Start "${lesson.title}"' : 'Finish the lesson before this one to unlock',
            child: Material(
              color: fill,
              shape: const CircleBorder(),
              elevation: unlocked ? 4 : 0,
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
          const SizedBox(height: 6),
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
  const _CourseCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hsk = hskWords.map((w) => w.hanzi).toSet();
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
            const Text('HSK 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('$learned / $total words learned', style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : learned / total,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
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
