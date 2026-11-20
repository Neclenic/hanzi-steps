import 'package:flutter/material.dart';

import '../data/char_stories.dart';
import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/word_lookup.dart';
import 'char_story_card.dart';

/// A star button that puts a word on "My words", or takes it off.
class MyWordButton extends StatelessWidget {
  final String hanzi;
  final Progress progress;
  final bool compact; // just the star icon
  const MyWordButton({super.key, required this.hanzi, required this.progress, this.compact = false});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final saved = progress.isMyWord(hanzi);
          final icon = Icon(saved ? Icons.star : Icons.star_border, color: saved ? Colors.amber.shade700 : null);
          if (compact) {
            return IconButton(
              icon: icon,
              tooltip: saved ? 'Remove from My words' : 'Add to My words',
              onPressed: () => progress.toggleMyWord(hanzi),
            );
          }
          return OutlinedButton.icon(
            onPressed: () => progress.toggleMyWord(hanzi),
            icon: icon,
            label: Text(saved ? 'In My words' : 'Add to My words'),
          );
        },
      );
}

/// Shows everything about one word in a sheet from the bottom.
Future<void> showWordSheet(BuildContext context, Progress progress, Word word) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => WordDetails(word: word, progress: progress),
    );

/// A word's pinyin, meaning, sound, where it's taught, how its characters are built, and look-alikes.
class WordDetails extends StatelessWidget {
  final Word word;
  final Progress progress;
  const WordDetails({super.key, required this.word, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = word;
    final taught = whereTaught(w.hanzi);
    final learned = taught != null && progress.isDone(taught.$2);
    final stories = storiesFor(w.hanzi);
    final looks = lookAlikesFor(w.hanzi);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(w.hanzi, style: const TextStyle(fontSize: 48))),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: Speech.instance.available,
              builder: (context, ok, _) => ok
                  ? IconButton(icon: const Icon(Icons.volume_up), tooltip: 'Listen', onPressed: () => Speech.instance.say(w.hanzi))
                  : const SizedBox.shrink(),
            ),
          ]),
          Text(w.pinyin, style: TextStyle(fontSize: 22, color: scheme.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(w.meaning, style: const TextStyle(fontSize: 18)),
          if (w.note != null) ...[
            const SizedBox(height: 6),
            Text(w.note!, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Icon(learned ? Icons.check_circle : Icons.school_outlined, size: 18, color: learned ? Colors.green : scheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                taught == null
                    ? 'Extra word from the stories, not taught in a lesson'
                    : '${taught.$1.tag.isEmpty ? 'HSK ${taught.$1.level}' : taught.$1.tag} · ${taught.$1.title}\n'
                        'Lesson "${taught.$2.title}"${learned ? ' (done)' : ''}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          MyWordButton(hanzi: w.hanzi, progress: progress),
          for (final s in stories) ...[const SizedBox(height: 12), SizedBox(width: double.infinity, child: CharStoryCard(s))],
          for (final g in looks) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Don\'t mix up ${g.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(g.tip),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
