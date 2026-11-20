import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/exercises.dart';
import '../logic/progress.dart';
import '../logic/word_lookup.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart';
import 'word_search_screen.dart';

/// The words saved with the ☆ button, from stories, dialogues and word search,
/// with a button to practise only these.
class MyWordsScreen extends StatelessWidget {
  final Progress progress;
  const MyWordsScreen({super.key, required this.progress});

  /// The saved words that can still be found, newest first.
  static List<Word> wordsOf(Progress p) => [
        for (final h in p.myWords)
          if (lookupWord(h) case final w?) w,
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final words = wordsOf(progress);
        return Scaffold(
          appBar: AppBar(
            title: const Text('My words'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Find words to add',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WordSearchScreen(progress: progress),
                )),
              ),
            ],
          ),
          floatingActionButton: words.length < 2
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: quizGreen,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('PRACTISE ${words.length > 12 ? '12 OF THESE' : 'THESE'}'),
                  onPressed: () {
                    // Up to 12 words, the ones you get wrong most often first.
                    final trouble = {for (final (w, t) in progress.troubleWords) w.hanzi: t};
                    final pick = [...words]..sort((a, b) => (trouble[b.hanzi] ?? 0).compareTo(trouble[a.hanzi] ?? 0));
                    final chosen = (pick.take(12).toList()..shuffle());
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LessonScreen(lesson: practiceLesson(chosen), progress: progress),
                    ));
                  },
                ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: words.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('⭐', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        const Text('No saved words yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Tap a word in a story or a dialogue, or look one up in Word search, '
                          'then tap ☆ to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ]),
                    )
                  : ListView(padding: const EdgeInsets.fromLTRB(8, 8, 8, 96), children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          '${words.length} saved ${words.length == 1 ? 'word' : 'words'}. Tap ★ to remove one.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      for (final w in words) WordRow(word: w, progress: progress),
                      if (words.length < 2)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Save one more word to start practising.',
                              textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                        ),
                    ]),
            ),
          ),
        );
      },
    );
  }
}
