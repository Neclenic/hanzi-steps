import 'dart:math';

import 'package:flutter/material.dart';

import '../data/idioms.dart';
import '../logic/idioms.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/word_sheet.dart';
import 'textbook_screen.dart';

/// Idiom stories (成语故事): famous four-character sayings and the tales behind them.
class IdiomsScreen extends StatelessWidget {
  final Progress progress;
  const IdiomsScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final read = progress.idiomsRead;
        return Scaffold(
          appBar: AppBar(title: const Text('Idiom stories 成语故事')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(
                  'Chinese has thousands of four-character sayings (成语 chéngyǔ). Most come from an old story. '
                  'Read the story, then take the short quiz.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final (i, idiom) in idioms.indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: min(40 * i, 300)),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Text(idiom.panels.first.$1.split(' ').first, style: const TextStyle(fontSize: 32)),
                        title: Text(idiom.chars, style: const TextStyle(fontSize: 26)),
                        subtitle: Text('${idiom.pinyin} · ${idiom.meaning}'),
                        trailing: read.contains(idiom.id)
                            ? const Icon(Icons.check_circle, color: Color(0xFF2E9E5B))
                            : const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => IdiomStoryScreen(progress: progress, idiom: idiom),
                        )),
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

class IdiomStoryScreen extends StatefulWidget {
  final Progress progress;
  final Idiom idiom;
  const IdiomStoryScreen({super.key, required this.progress, required this.idiom});

  @override
  State<IdiomStoryScreen> createState() => _IdiomStoryScreenState();
}

class _IdiomStoryScreenState extends State<IdiomStoryScreen> {
  bool _pinyin = true;

  void _word(String token) {
    final w = idiomWord(token);
    if (w == null) return;
    Speech.instance.say(token);
    showWordSheet(context, widget.progress, w);
  }

  void _quiz() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TbQuizScreen(
          title: '${widget.idiom.chars} · 小测验',
          build: () => buildIdiomQuiz(widget.idiom),
          note: '${widget.idiom.chars}: ${widget.idiom.meaning}.',
          onFinish: (right, total) async {
            final xp = 8 + 2 * right;
            await widget.progress.finishIdiom(widget.idiom.id, xp);
            return xp;
          },
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idiom = widget.idiom;
    return Scaffold(
      appBar: AppBar(title: Text(idiom.chars), actions: [
        IconButton(
          tooltip: _pinyin ? 'Hide pinyin' : 'Show pinyin',
          icon: Icon(_pinyin ? Icons.abc : Icons.text_fields),
          onPressed: () => setState(() => _pinyin = !_pinyin),
        ),
      ]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: [
            PopIn(
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (final ch in idiom.chars.split('')) Padding(padding: const EdgeInsets.all(2), child: TianZiGe(ch, size: 64)),
                ]),
                const SizedBox(height: 6),
                Text(idiom.pinyin, style: TextStyle(fontSize: 20, color: scheme.primary)),
                Text('"${idiom.literal}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text('Means: ${idiom.meaning}', textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                TextButton.icon(
                  onPressed: () => Speech.instance.say(idiom.chars),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Hear it'),
                ),
              ]),
            ),
            const Divider(height: 24),
            for (final (i, line) in idiom.story.indexed) ...[
              for (final (pic, at) in idiom.panels)
                if (at == i) _Panel(pic),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconButton(
                    tooltip: 'Hear this line',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.volume_up_outlined, color: scheme.primary),
                    onPressed: () => Speech.instance.say(line.text),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      RubyLine(line, pinyin: _pinyin, size: 24, onWord: _word),
                      const SizedBox(height: 2),
                      Text(line.en, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                    ]),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('When to say it: ${idiom.situation}'),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: _quiz,
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('TAKE THE QUIZ'),
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap any word to see what it means.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.outline)),
          ]),
        ),
      ),
    );
  }
}

/// A picture for the story, made of emoji.
class _Panel extends StatelessWidget {
  final String pic;
  const _Panel(this.pic);

  @override
  Widget build(BuildContext context) => FadeSlideIn(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer,
            ]),
          ),
          child: Text(pic, style: const TextStyle(fontSize: 44, letterSpacing: 6)),
        ),
      );
}

