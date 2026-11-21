import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/synonyms.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart' show SpeakButton;

/// Words with similar meanings: how to tell them apart, and a drill.
class SynonymsScreen extends StatelessWidget {
  final Progress progress;
  const SynonymsScreen({super.key, required this.progress});

  void _drill(BuildContext context, [SynonymPair? only]) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SynonymDrill(progress: progress, pair: only),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showPinyin = Settings.instance.showPinyin;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final stats = progress.synonymStats;
        return Scaffold(
          appBar: AppBar(title: const Text('Similar words 近义词')),
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
                Text(
                  'These pairs mean almost the same thing, but only one fits in a sentence. The HSK 4 and 5 exams test them a lot. '
                  'Tap a pair to see the difference. The drill asks the pairs you miss more often.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final (i, p) in synonymPairs.indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: min(30 * i, 300)),
                    child: Card(
                      child: ExpansionTile(
                        shape: const Border(),
                        title: Text(p.title, style: const TextStyle(fontSize: 26)),
                        subtitle: Text(
                          [
                            p.words.map((w) => w.meaning).join(' · '),
                            if (stats[p.id] case final s?) '${s.$1} of ${s.$2} right',
                          ].join('\n'),
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final w in p.words)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(w.zh, style: const TextStyle(fontSize: 26)),
                                SpeakButton(w.zh, size: 22),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('${w.pinyin} · ${w.meaning}\n${w.use}', style: const TextStyle(fontSize: 13)),
                                ),
                              ]),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('💡 '),
                              Expanded(child: Text(p.tip)),
                            ]),
                          ),
                          const SizedBox(height: 10),
                          for (final e in p.examples)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => Speech.instance.say(e.zh),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Icon(Icons.volume_up, size: 18, color: scheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(e.zh, style: const TextStyle(fontSize: 18)),
                                      if (showPinyin)
                                        Text(e.pinyin, style: TextStyle(fontSize: 13, color: scheme.primary)),
                                      Text(e.en, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                                    ]),
                                  ),
                                ]),
                              ),
                            ),
                          const SizedBox(height: 4),
                          TextButton.icon(
                            onPressed: () => _drill(context, p),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Practise this pair'),
                          ),
                        ],
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

/// One drill question: which word of the pair fills the gap?
class SynonymQuestion {
  final SynonymPair pair;
  final SynExample example;
  const SynonymQuestion(this.pair, this.example);
  SynWord get answer => pair.words[example.answer];
}

/// [n] questions, never the same sentence twice. Pairs answered wrong more often come up more.
/// With [only], every sentence of that pair once.
List<SynonymQuestion> buildSynonymDrill(Progress progress, {SynonymPair? only, int n = 10, Random? random}) {
  final r = random ?? Random();
  if (only != null) return [for (final e in [...only.examples]..shuffle(r)) SynonymQuestion(only, e)];
  final stats = progress.synonymStats;
  double weight(SynonymPair p) {
    final s = stats[p.id];
    if (s == null) return 2; // not tried yet
    return 1 + 3 * (1 - s.$1 / max(1, s.$2));
  }

  final out = <SynonymQuestion>[];
  final used = <SynExample>{};
  final pairs = [...synonymPairs];
  while (out.length < n) {
    final left = [for (final p in pairs) if (p.examples.any((e) => !used.contains(e))) p];
    if (left.isEmpty) break;
    // Try not to ask the same pair twice in a row.
    final choices = left.length > 1 && out.isNotEmpty ? left.where((p) => p != out.last.pair).toList() : left;
    final total = choices.fold<double>(0, (a, p) => a + weight(p));
    var pick = r.nextDouble() * total;
    var p = choices.last;
    for (final x in choices) {
      pick -= weight(x);
      if (pick <= 0) {
        p = x;
        break;
      }
    }
    final free = p.examples.where((e) => !used.contains(e)).toList();
    final e = free[r.nextInt(free.length)];
    used.add(e);
    out.add(SynonymQuestion(p, e));
  }
  return out;
}

class SynonymDrill extends StatefulWidget {
  final Progress progress;
  final SynonymPair? pair;
  final List<SynonymQuestion>? questions;
  const SynonymDrill({super.key, required this.progress, this.pair, this.questions});

  @override
  State<SynonymDrill> createState() => _SynonymDrillState();
}

class _SynonymDrillState extends State<SynonymDrill> {
  late List<SynonymQuestion> _qs = widget.questions ?? _build();
  int _i = 0;
  int? _picked;
  bool _checked = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  List<SynonymQuestion> _build() => buildSynonymDrill(widget.progress, only: widget.pair);
  SynonymQuestion get _q => _qs[_i];
  bool get _isRight => _picked == _q.example.answer;

  Future<void> _press() async {
    if (_done) return;
    if (!_checked) {
      if (_picked == null) return;
      final right = _isRight;
      setState(() {
        _checked = true;
        if (right) _right++;
      });
      Speech.instance.say(_q.example.zh);
      await widget.progress.recordSynonym(_q.pair.id, right);
      if (right) await widget.progress.bump('synonymRight');
      return;
    }
    if (_i + 1 >= _qs.length) {
      _xp = 5 + _right;
      await widget.progress.bump('synonymDrills');
      await widget.progress.addXp(_xp);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _i++;
      _picked = null;
      _checked = false;
    });
  }

  void _again() => setState(() {
        _qs = _build();
        _i = 0;
        _picked = null;
        _checked = false;
        _right = 0;
        _done = false;
      });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showPinyin = Settings.instance.showPinyin;
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent || _done) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _press();
          return KeyEventResult.handled;
        }
        final n = int.tryParse(e.character ?? '');
        if (!_checked && n != null && n >= 1 && n <= _q.pair.words.length) {
          setState(() => _picked = n - 1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? 'Similar words' : 'Similar words · ${_i + 1} of ${_qs.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Drill done!',
                    right: _right,
                    total: _qs.length,
                    xp: _xp,
                    note: 'Pairs you mix up come back more often.',
                    onAgain: _again,
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(key: ValueKey(_i), padding: const EdgeInsets.all(24), children: [
                        const Text('Which word fits?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Center(
                          child: PopIn(
                            child: Column(children: [
                              Text(_checked ? _q.example.zh : _q.pair.gap(_q.example),
                                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, height: 1.4)),
                              // The pinyin would give the answer away, so it only shows once checked.
                              if (showPinyin && _checked)
                                Text(_q.example.pinyin, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: scheme.primary)),
                              const SizedBox(height: 4),
                              Text(_q.example.en, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
                          for (final (i, w) in _q.pair.words.indexed)
                            SizedBox(
                              width: 150,
                              child: AnswerTile(
                                number: i + 1,
                                selected: _picked == i,
                                checked: _checked,
                                isCorrect: i == _q.example.answer,
                                onTap: () => setState(() => _picked = i),
                                child: Column(children: [
                                  Text(w.zh, style: const TextStyle(fontSize: 34)),
                                  if (showPinyin) Text(w.pinyin, style: const TextStyle(fontSize: 13)),
                                  if (_checked) Text(w.meaning, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                                ]),
                              ),
                            ),
                        ]),
                      ]),
                    ),
                    QuizBottomBar(
                      checked: _checked,
                      right: _isRight,
                      canPress: _checked || _picked != null,
                      correctAnswer: '${_q.answer.zh} (${_q.answer.pinyin}, ${_q.answer.meaning})',
                      explain: _q.pair.tip,
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
