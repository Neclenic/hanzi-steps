import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../logic/pinyin_input.dart';
import '../logic/tone_pairs.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import '../widgets/tone_shape.dart';
import 'lesson_screen.dart' show SpeakButton;
import 'speaking_screen.dart';

/// Two tone shapes side by side, with a dot for the light tone.
class PairShape extends StatelessWidget {
  final TonePair pair;
  final double size;
  final Color color;
  const PairShape(this.pair, {super.key, this.size = 26, required this.color});

  Widget _one(int t) => t == 0
      ? SizedBox(width: size * 1.3, height: size, child: Center(child: Icon(Icons.circle, size: size / 4, color: color)))
      : ToneShape(tone: t, size: size, color: color);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [_one(pair.first), SizedBox(width: size / 5), _one(pair.second)]);
}

/// The 20 tone pairs: a grid to explore, a quiz, and speaking practice.
class TonePairsScreen extends StatelessWidget {
  final Progress progress;
  const TonePairsScreen({super.key, required this.progress});

  static List<SpeakItem> _items(List<Word> words) => [for (final w in words) SpeakItem(w.hanzi, w.pinyin, w.meaning)];

  void _sayPair(BuildContext context, TonePair p) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SpeakingScreen(
          progress: progress,
          title: 'Say tone pair ${p.label}',
          items: _items(examplesFor(p, progress)),
        ),
      ));

  void _sayMix(BuildContext context) {
    final r = Random();
    final words = [for (final p in tonePairs) (examplesFor(p, progress)..shuffle(r)).first]..shuffle(r);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SpeakingScreen(progress: progress, title: 'Say the tone pairs', items: _items(words)),
    ));
  }

  void _showPair(BuildContext context, TonePair p) {
    final words = examplesFor(p, progress).take(8).toList();
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              PairShape(p, size: 34, color: scheme.primary),
              const SizedBox(width: 12),
              Text('Tone ${p.label}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
            if (p.first == 3 && p.second == 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Two third tones in a row: the first one is said as a second tone, so it sounds like 2 + 3.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            if (p.first == 3 && p.second != 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('A third tone before another tone is usually only the low part: it dips and stays low.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            const SizedBox(height: 8),
            for (final w in words)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(w.hanzi, style: const TextStyle(fontSize: 28)),
                title: Text(w.pinyin, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                subtitle: Text(w.meaning),
                trailing: SpeakButton(w.hanzi),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(c);
                _sayPair(context, p);
              },
              icon: const Icon(Icons.mic),
              label: const Text('Practise saying these'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final stats = progress.pairStats;
        return Scaffold(
          appBar: AppBar(title: const Text('Tone pairs')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(
                  'Most Chinese words have two syllables, and tones sound a little different next to each other. '
                  'Practising the 20 pairs is the quickest way to sound natural.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TonePairQuiz(progress: progress),
                      )),
                      icon: const Icon(Icons.headphones),
                      label: const Text('Tone quiz'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _sayMix(context),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.mic, size: 18),
                        SizedBox(width: 8),
                        Text('Say them'),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  const SizedBox(width: 56),
                  for (final b in ['+ 1', '+ 2', '+ 3', '+ 4', '+ light'])
                    Expanded(
                      child: Text(b, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ),
                ]),
                for (var a = 1; a <= 4; a++)
                  FadeSlideIn(
                    delay: Duration(milliseconds: 60 * a),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        SizedBox(
                          width: 56,
                          child: Text('Tone $a', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        for (final p in tonePairs.where((p) => p.first == a))
                          Expanded(child: _PairTile(pair: p, stat: stats[p.key], onTap: () => _showPair(context, p))),
                      ]),
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Tap a pair to hear example words. The small number shows how often you got it right in the quiz.',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _PairTile extends StatelessWidget {
  final TonePair pair;
  final (int, int)? stat;
  final VoidCallback onTap;
  const _PairTile({required this.pair, required this.stat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = stat;
    final share = s == null || s.$2 == 0 ? null : s.$1 / s.$2;
    final color = share == null
        ? scheme.outlineVariant
        : share >= 0.8
            ? quizGreen
            : share >= 0.5
                ? Colors.amber.shade700
                : quizRed;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: PressBounce(
        child: Material(
          color: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: color, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(children: [
                FittedBox(child: PairShape(pair, size: 16, color: scheme.primary)),
                const SizedBox(height: 4),
                Text(s == null ? '–' : '${s.$1}/${s.$2}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example words for a pair, words from your level and below first.
List<Word> examplesFor(TonePair p, Progress progress) {
  final level = Settings.instance.level;
  final all = tonePairExamples[p]!;
  final learned = progress.learnedWords.map((w) => w.hanzi).toSet();
  int rank(Word w) => learned.contains(w.hanzi) ? 0 : ((levelOfWord(w.hanzi) ?? 9) <= level ? 1 : 2);
  final sorted = [...all]..sort((a, b) => rank(a).compareTo(rank(b)));
  return sorted;
}

/// One question in the tone pair quiz.
class PairQuestion {
  final Word word;
  final TonePair pair;
  final List<TonePair> options;
  const PairQuestion(this.word, this.pair, this.options);
  int get correct => options.indexOf(pair);
}

/// Builds a round of tone pair questions. Pairs you often miss come up more.
List<PairQuestion> buildPairQuiz(Progress progress, {int n = 10, Random? random}) {
  final r = random ?? Random();
  final stats = progress.pairStats;
  double weight(TonePair p) {
    final s = stats[p.key];
    if (s == null) return 2;
    return 1 + 3 * (s.$2 - s.$1) / max(1, s.$2);
  }

  final out = <PairQuestion>[];
  final used = <String>{};
  while (out.length < n) {
    final total = tonePairs.fold(0.0, (a, p) => a + weight(p));
    var x = r.nextDouble() * total;
    var pair = tonePairs.last;
    for (final p in tonePairs) {
      x -= weight(p);
      if (x <= 0) {
        pair = p;
        break;
      }
    }
    final words = examplesFor(pair, progress).take(6).toList()..shuffle(r);
    final word = words.firstWhere((w) => !used.contains(w.hanzi), orElse: () => words.first);
    used.add(word.hanzi);
    // Wrong options share one tone with the right answer, which makes you listen closely.
    final near = tonePairs.where((p) => p != pair && (p.first == pair.first || p.second == pair.second)).toList()..shuffle(r);
    final options = [pair, ...near.take(3)]..shuffle(r);
    out.add(PairQuestion(word, pair, options));
  }
  return out;
}

/// Hear a two-syllable word (or read it, when there's no Chinese voice) and pick its tones.
class TonePairQuiz extends StatefulWidget {
  final Progress progress;
  final List<PairQuestion>? questions;
  const TonePairQuiz({super.key, required this.progress, this.questions});

  @override
  State<TonePairQuiz> createState() => _TonePairQuizState();
}

class _TonePairQuizState extends State<TonePairQuiz> {
  late List<PairQuestion> _qs = widget.questions ?? buildPairQuiz(widget.progress);
  int _i = 0;
  int? _selected;
  bool _checked = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  PairQuestion get _q => _qs[_i];
  bool get _listening => Speech.instance.available.value;

  @override
  void initState() {
    super.initState();
    _play();
  }

  void _play() {
    if (!_listening) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_done) Speech.instance.say(_q.word.hanzi);
    });
  }

  Future<void> _press() async {
    if (_selected == null) return;
    if (!_checked) {
      final right = _selected == _q.correct;
      final chosen = _q.options[_selected!];
      setState(() {
        _checked = true;
        if (right) _right++;
      });
      if (!_listening) Speech.instance.say(_q.word.hanzi);
      await widget.progress.recordPair(_q.pair.key, right);
      await widget.progress.recordTone(_q.pair.first, chosen.first == _q.pair.first);
      if (_q.pair.second != 0) await widget.progress.recordTone(_q.pair.second, chosen.second == _q.pair.second);
      await widget.progress.recordAnswer(_q.word.hanzi, right);
      return;
    }
    if (_i + 1 >= _qs.length) {
      _xp = 5 + _right;
      await widget.progress.bump('pairRounds');
      await widget.progress.addXp(_xp);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _i++;
      _selected = null;
      _checked = false;
    });
    _play();
  }

  void _again() => setState(() {
        _qs = buildPairQuiz(widget.progress);
        _i = 0;
        _selected = null;
        _checked = false;
        _right = 0;
        _done = false;
        _play();
      });

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent || _done) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _press();
      return KeyEventResult.handled;
    }
    final d = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3, LogicalKeyboardKey.digit4]
        .indexOf(k);
    if (d >= 0 && !_checked && d < _q.options.length) {
      setState(() => _selected = d);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.keyR) {
      Speech.instance.say(_q.word.hanzi);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? 'Tone quiz' : 'Tone quiz · ${_i + 1} of ${_qs.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Tone quiz done!',
                    right: _right,
                    total: _qs.length,
                    xp: _xp,
                    note: 'The tone pairs page shows which pairs need more practice.',
                    onAgain: _again,
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(padding: const EdgeInsets.all(24), children: [
                        Text(_listening ? 'Listen. Which tones do you hear?' : 'Which tones does this word have?',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        if (_listening) Center(child: SpeakButton(_q.word.hanzi, size: 88, filled: true)),
                        if (!_listening || _checked)
                          Center(
                            child: PopIn(
                              key: ValueKey('w$_i$_checked'),
                              child: Column(children: [
                                Text(_q.word.hanzi, style: const TextStyle(fontSize: 64)),
                                Text(_checked ? _q.word.pinyin : pinyinLetters(_q.word.pinyin).replaceAll('v', 'ü'),
                                    style: TextStyle(fontSize: 24, color: scheme.primary, fontWeight: FontWeight.w600)),
                                Text(_q.word.meaning, style: TextStyle(color: scheme.onSurfaceVariant)),
                              ]),
                            ),
                          ),
                        const SizedBox(height: 20),
                        for (final (i, p) in _q.options.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnswerTile(
                              number: i + 1,
                              selected: _selected == i,
                              checked: _checked,
                              isCorrect: i == _q.correct,
                              onTap: () => setState(() => _selected = i),
                              child: Row(children: [
                                PairShape(p, size: 24, color: scheme.primary),
                                const SizedBox(width: 12),
                                Text('Tone ${p.label}', style: const TextStyle(fontSize: 17)),
                              ]),
                            ),
                          ),
                      ]),
                    ),
                    QuizBottomBar(
                      checked: _checked,
                      right: _selected == _q.correct,
                      canPress: _selected != null,
                      correctAnswer: 'tone ${_q.pair.label}',
                      explain: _checked
                          ? '${_q.word.hanzi} ${_q.word.pinyin} (${_q.word.meaning})'
                              '${_q.pair.first == 3 && _q.pair.second == 3 ? ': written 3 + 3, said 2 + 3' : ''}'
                          : null,
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
