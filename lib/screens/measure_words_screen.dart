import 'dart:math';

import 'package:flutter/material.dart';

import '../data/measure_words.dart';
import '../logic/measure_drill.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/textbook.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'textbook_screen.dart';

/// Counting words (量词): what each one counts, and a drill.
class MeasureWordsScreen extends StatelessWidget {
  final Progress progress;
  const MeasureWordsScreen({super.key, required this.progress});

  void _drill(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TbQuizScreen(
          title: '量词 · Counting words',
          build: () => buildMeasureDrill(stats: progress.measureStats),
          note: 'The drill asks the counting words you miss more often.',
          onAnswer: (q, right) {
            if (q is TbChoice && q.tag != null) progress.recordMeasure(q.tag!, right);
          },
          onFinish: (right, total) async {
            final xp = 5 + right;
            await progress.addXp(xp);
            return xp;
          },
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final stats = progress.measureStats;
        return Scaffold(
          appBar: AppBar(title: const Text('Counting words 量词')),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: quizGreen,
            foregroundColor: Colors.white,
            onPressed: () => _drill(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('START THE DRILL'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💡 '),
                    Expanded(child: Text(measureTip)),
                  ]),
                ),
                const SizedBox(height: 12),
                for (final (i, m) in measureWords.indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: min(30 * i, 300)),
                    child: Card(
                      child: ListTile(
                        leading: TianZiGe(m.char, size: 48),
                        title: Text('${m.pinyin} · ${m.use}'),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(spacing: 6, runSpacing: 4, children: [
                            for (final n in m.nouns)
                              ActionChip(
                                visualDensity: VisualDensity.compact,
                                label: Text('一${m.char}$n'),
                                tooltip: nounLabel(n),
                                onPressed: () => Speech.instance.say('一${m.char}$n'),
                              ),
                            if (stats[m.char] case final s?)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${s.$1} of ${s.$2} right', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                              ),
                          ]),
                        ),
                        onTap: () => Speech.instance.say(m.char),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
