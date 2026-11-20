import 'dart:math';

import 'package:flutter/material.dart';

import '../data/radicals.dart';
import '../logic/progress.dart';
import '../logic/radical_quiz.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'textbook_screen.dart';

/// The common parts characters are built from, with the characters that use them.
class RadicalsScreen extends StatelessWidget {
  final Progress progress;
  const RadicalsScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Radicals 部首')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: quizGreen,
        foregroundColor: Colors.white,
        onPressed: () => openRadicalQuiz(context, progress),
        icon: const Icon(Icons.play_arrow),
        label: const Text('QUIZ'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
            Text(
              'Most characters are built from parts. One part, the radical (部首 bùshǒu), often hints at the meaning: '
              'everything with 氵 has to do with water. Tap a radical to see the characters that use it.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              final perRow = c.maxWidth >= 560 ? 4 : 3;
              final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
              return Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (i, rad) in radicals.indexed)
                  SizedBox(
                    width: w,
                    child: FadeSlideIn(
                      delay: Duration(milliseconds: min(20 * i, 300)),
                      child: PressBounce(
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => RadicalDetailScreen(progress: progress, radical: rad),
                            )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: Column(children: [
                                Text(rad.form, style: TextStyle(fontSize: 40, color: scheme.primary)),
                                Text(rad.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(rad.chars.take(4).map((c) => c.$1).join(' '),
                                    style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]);
            }),
          ]),
        ),
      ),
    );
  }
}

void openRadicalQuiz(BuildContext context, Progress progress, [Radical? only]) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TbQuizScreen(
        title: only == null ? '部首 · Radicals quiz' : '${only.form} · ${only.meaning}',
        build: () => buildRadicalQuiz(only: only, count: only == null ? 8 : 4),
        onAnswer: (q, right) {
          if (right) progress.bump('radicalRight');
        },
        onFinish: (right, total) async {
          final xp = 5 + right;
          await progress.addXp(xp);
          return xp;
        },
      ),
    ));

/// One radical: what it means, and the characters that use it.
class RadicalDetailScreen extends StatelessWidget {
  final Progress progress;
  final Radical radical;
  const RadicalDetailScreen({super.key, required this.progress, required this.radical});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = radical;
    return Scaffold(
      appBar: AppBar(title: Text('${r.form} · ${r.name}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              PopIn(child: TianZiGe(r.form, size: 96, color: scheme.primary)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${r.name} · ${r.namePinyin}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(r.meaning, style: TextStyle(fontSize: 16, color: scheme.primary)),
                  const SizedBox(height: 4),
                  Text(r.note),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            Text('Characters with ${r.form}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final (c, py, meaning) in r.chars)
              Card(
                child: ListTile(
                  leading: Text(c, style: const TextStyle(fontSize: 34)),
                  title: Text(py, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                  subtitle: Text(meaning),
                  trailing: const Icon(Icons.volume_up_outlined),
                  onTap: () => Speech.instance.say(c),
                ),
              ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.icon(
                onPressed: () => openRadicalQuiz(context, progress, r),
                icon: const Icon(Icons.quiz_outlined),
                label: Text('Quick quiz on ${r.form}'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
