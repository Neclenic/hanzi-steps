import 'dart:math';

import 'package:flutter/material.dart';

import '../data/survival.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../logic/survival_quiz.dart';
import '../widgets/anim.dart';
import 'speaking_screen.dart';
import 'textbook_screen.dart';

/// Travel packs: phrases for taxis, restaurants, hotels, shops, directions and emergencies.
class SurvivalScreen extends StatelessWidget {
  final Progress progress;
  const SurvivalScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Survival phrases')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListenableBuilder(
            listenable: progress,
            builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
              Text(
                'The phrases you need on a trip, with the answers you are likely to hear. '
                'Listen, say them out loud, then test yourself.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, c) {
                final perRow = c.maxWidth >= 520 ? 3 : 2;
                final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
                return Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final (i, pack) in phrasePacks.indexed)
                    SizedBox(
                      width: w,
                      child: FadeSlideIn(
                        delay: Duration(milliseconds: min(40 * i, 300)),
                        child: _PackCard(pack: pack, done: progress.count('phrases_${pack.id}') > 0, onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PhrasePackScreen(progress: progress, pack: pack),
                          ));
                        }),
                      ),
                    ),
                ]);
              }),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final PhrasePack pack;
  final bool done;
  final VoidCallback onTap;
  const _PackCard({required this.pack, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PressBounce(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(pack.scene, style: const TextStyle(fontSize: 30)),
                const Spacer(),
                if (done) const Icon(Icons.check_circle, color: Color(0xFF2E9E5B), size: 20),
              ]),
              const SizedBox(height: 6),
              Text(pack.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${pack.zhTitle} ${pack.pinyinTitle}', style: TextStyle(color: scheme.primary)),
              Text('${pack.phrases.length} phrases', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// One pack: every phrase with its sound, then a quiz and speaking practice.
class PhrasePackScreen extends StatelessWidget {
  final Progress progress;
  final PhrasePack pack;
  const PhrasePackScreen({super.key, required this.progress, required this.pack});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final toSay = [for (final p in pack.phrases) if (!p.hear) p];
    return Scaffold(
      appBar: AppBar(title: Text('${pack.scene} ${pack.title} · ${pack.zhTitle}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListenableBuilder(
            listenable: Settings.instance,
            builder: (context, _) => ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
              Text(pack.intro, style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () => openPhraseQuiz(context, progress, pack),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Quiz'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SpeakingScreen(
                      progress: progress,
                      title: 'Say it · ${pack.title}',
                      items: [for (final p in toSay) SpeakItem(p.hanzi, p.pinyin, p.en)],
                    ),
                  )),
                  icon: const Icon(Icons.mic),
                  label: const Text('Say them'),
                ),
              ]),
              const SizedBox(height: 12),
              for (final (i, p) in pack.phrases.indexed)
                FadeSlideIn(delay: Duration(milliseconds: min(30 * i, 300)), child: _PhraseCard(phrase: p)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final Phrase phrase;
  const _PhraseCard({required this.phrase});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = phrase;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: p.hear ? scheme.secondaryContainer.withValues(alpha: 0.5) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (p.hear)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    Icon(Icons.hearing, size: 14, color: scheme.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text("You'll hear", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scheme.onSecondaryContainer)),
                  ]),
                ),
              Text(p.hanzi, style: const TextStyle(fontSize: 24)),
              if (Settings.instance.showPinyin) Text(p.pinyin, style: TextStyle(fontSize: 15, color: scheme.primary)),
              Text(p.en, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (p.note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(p.note!, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                ),
            ]),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: Speech.instance.available,
            builder: (context, ok, _) => ok
                ? Column(children: [
                    IconButton(icon: const Icon(Icons.volume_up), tooltip: 'Listen', onPressed: () => Speech.instance.say(p.hanzi)),
                    IconButton(
                      icon: const Icon(Icons.slow_motion_video),
                      tooltip: 'Listen slowly',
                      onPressed: () => Speech.instance.say(p.hanzi, slow: true),
                    ),
                  ])
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

void openPhraseQuiz(BuildContext context, Progress progress, PhrasePack pack) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TbQuizScreen(
        title: '${pack.zhTitle} · ${pack.title} quiz',
        build: () => buildPhraseQuiz(pack),
        onFinish: (right, total) async {
          await progress.bump('phrases_${pack.id}');
          final xp = 5 + right;
          await progress.addXp(xp);
          return xp;
        },
      ),
    ));
