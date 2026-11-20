import 'package:flutter/material.dart';

import '../data/pinyin_chart.dart';
import '../logic/pinyin_input.dart';
import '../logic/pinyin_quiz.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import '../widgets/tone_shape.dart';
import 'textbook_screen.dart';

/// Every Mandarin syllable, grouped by its first sound. Tap one to hear it in all four tones.
class PinyinChartScreen extends StatefulWidget {
  final Progress progress;
  const PinyinChartScreen({super.key, required this.progress});

  @override
  State<PinyinChartScreen> createState() => _PinyinChartScreenState();
}

class _PinyinChartScreenState extends State<PinyinChartScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = chartByInitial(_query.isEmpty ? null : searchSyllables(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Pinyin chart 拼音表')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: quizGreen,
        foregroundColor: Colors.white,
        onPressed: () => openToneQuiz(context, widget.progress),
        icon: const Icon(Icons.play_arrow),
        label: const Text('TONE QUIZ'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
            Text(
              'Every sound in Mandarin is one of these ${pinyinChart.length} syllables, said with one of four tones. '
              'Tap a syllable to hear all four tones in real characters.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Find a syllable, like zhong or lü (type v for ü)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No syllable starts like that.', textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            for (final (initial, syllables) in groups)
              _InitialCard(initial: initial, syllables: syllables, onTap: (s) => showSyllableTones(context, s)),
          ]),
        ),
      ),
    );
  }
}

/// One first sound (b, zh, …): a tip on saying it, and its syllables.
class _InitialCard extends StatelessWidget {
  final String initial;
  final List<String> syllables;
  final ValueChanged<String> onTap;
  const _InitialCard({required this.initial, required this.syllables, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tip = initialTips[initial];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 56,
              child: Text(initial.isEmpty ? 'a e o' : initial,
                  style: TextStyle(fontSize: initial.isEmpty ? 18 : 26, fontWeight: FontWeight.bold, color: scheme.primary)),
            ),
            if (tip != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(tip, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final s in syllables)
              PressBounce(
                child: ActionChip(
                  label: Text(showSyllable(s), style: const TextStyle(fontSize: 16)),
                  onPressed: () => onTap(s),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

/// A sheet with one syllable in all four tones. Tap a tone to hear it.
Future<void> showSyllableTones(BuildContext context, String syllable) {
  final tones = pinyinChart[syllable]!;
  final heard = [for (final c in tones) if (c != null) c.$1];
  if (heard.isNotEmpty) Speech.instance.say(heard.join('，'), slow: true);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ToneSheet(syllable: syllable, tones: tones),
  );
}

class _ToneSheet extends StatelessWidget {
  final String syllable;
  final List<(String, String)?> tones;
  const _ToneSheet({required this.syllable, required this.tones});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final heard = [for (final c in tones) if (c != null) c.$1];
    final tip = initialTips[initialOf(syllable)];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text(showSyllable(syllable), style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: scheme.primary)),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: Speech.instance.available,
              builder: (context, ok, _) => ok
                  ? FilledButton.tonalIcon(
                      onPressed: () => Speech.instance.say(heard.join('，'), slow: true),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('All four'),
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
          if (tip != null && initialOf(syllable).isNotEmpty)
            Text(tip, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, c) {
            final perRow = c.maxWidth >= 520 ? 4 : 2;
            final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
            return Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (i, entry) in tones.indexed)
                SizedBox(width: w, child: PopIn(child: _ToneBox(syllable: syllable, tone: i + 1, entry: entry))),
            ]);
          }),
          const SizedBox(height: 12),
          Text(
            'You hear each tone in a real character, because a voice can only say words, not bare sounds. '
            'A dash means no common character uses that tone.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ]),
      ),
    );
  }
}

class _ToneBox extends StatelessWidget {
  final String syllable;
  final int tone;
  final (String, String)? entry;
  const _ToneBox({required this.syllable, required this.tone, required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = entry;
    final color = e == null ? scheme.outline : scheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      color: e == null ? scheme.surfaceContainerLow : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: e == null ? null : () => Speech.instance.say(e.$1, slow: true),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text('Tone $tone', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ToneShape(tone: tone, size: 26, color: color),
            Text(markSyllable(syllable, tone), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
            Text(e?.$1 ?? '–', style: TextStyle(fontSize: 34, color: e == null ? scheme.outline : null)),
            SizedBox(
              height: 32,
              child: Text(e == null ? 'not used' : (e.$2.isEmpty ? '' : e.$2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ),
            if (e != null) Icon(Icons.volume_up, size: 18, color: scheme.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}

void openToneQuiz(BuildContext context, Progress progress) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TbQuizScreen(
        title: '声调 · Tone quiz',
        note: 'Read the character, pick its tone. You hear it after you check.',
        build: () => buildToneQuiz(),
        onAnswer: (q, right) {
          if (right) progress.bump('toneQuizRight');
        },
        onFinish: (right, total) async {
          final xp = 5 + right;
          await progress.addXp(xp);
          return xp;
        },
      ),
    ));
