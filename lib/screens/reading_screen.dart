import 'package:flutter/material.dart';

import '../data/reading.dart';
import '../logic/progress.dart';
import '../logic/story_words.dart';
import '../widgets/anim.dart';
import 'stories_screen.dart' show StoryReaderScreen;

const _green = Color(0xFF2E9E5B);

/// Reading practice: HSK 4 and 5 articles with questions, every word tappable.
class ReadingScreen extends StatelessWidget {
  final Progress progress;
  const ReadingScreen({super.key, required this.progress});

  void _open(BuildContext context, ReadingArticle a) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => StoryReaderScreen(
          story: a.asStory,
          progress: progress,
          onArticleFinish: (right, xp) => progress.finishReading(a.id, right, xp),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levels = {for (final a in readingArticles) a.level}.toList()..sort();
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final learned = progress.learnedWords.map((w) => w.hanzi).toSet();
        final done = progress.readingDone;
        return Scaffold(
          appBar: AppBar(title: const Text('Reading practice 阅读')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(
                  'Short news reports, opinions and stories at HSK 4 and 5 level, like the reading part of the exam. '
                  'Tap any word to hear it and see what it means, then answer three questions.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                for (final level in levels) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                    child: Text('HSK $level level',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
                  ),
                  for (final (i, a) in readingArticles.where((a) => a.level == level).indexed)
                    FadeSlideIn(
                      delay: Duration(milliseconds: 50 * i),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _open(context, a),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(children: [
                              Text(a.emoji, style: const TextStyle(fontSize: 34)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(a.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
                                  Text(a.titleEn, style: TextStyle(color: scheme.onSurfaceVariant)),
                                  const SizedBox(height: 4),
                                  Text(a.blurb, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Wrap(spacing: 6, runSpacing: 6, children: [
                                    _Chip(a.kind, scheme.primaryContainer, scheme.onPrimaryContainer),
                                    _Chip('You know ${(knownShare(a.asStory, learned) * 100).round()}% of the words',
                                        scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
                                    if (done.contains(a.id))
                                      _Chip('Best: ${progress.readingBest(a.id)} / ${a.questions.length}',
                                          scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
                                  ]),
                                ]),
                              ),
                              if (done.contains(a.id))
                                const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: _green)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                Text('Articles read: ${done.length} of ${readingArticles.length}',
                    textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Chip(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
      );
}
