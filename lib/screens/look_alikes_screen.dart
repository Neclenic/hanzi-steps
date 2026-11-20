import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/look_alikes.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';

/// Characters that are easy to mix up, with a tip for each group and a drill.
class LookAlikesScreen extends StatelessWidget {
  final Progress progress;
  const LookAlikesScreen({super.key, required this.progress});

  void _drill(BuildContext context, [LookAlikeGroup? only]) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => LookAlikeDrill(progress: progress, group: only),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final stats = progress.lookAlikeStats;
        return Scaffold(
          appBar: AppBar(title: const Text('Look-alike characters')),
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
                  'These characters look alike or sound the same. Tap a group to see how to tell them apart. '
                  'The drill asks the groups you miss more often.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final (i, g) in lookAlikeGroups.indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: min(30 * i, 300)),
                    child: Card(
                      child: ExpansionTile(
                        shape: const Border(),
                        title: Text(g.title, style: const TextStyle(fontSize: 28)),
                        subtitle: Text(
                          [
                            g.chars.map((c) => '${c.pinyin} ${c.meaning}').join(' · '),
                            if (stats[g.id] case final s?) '${s.$1} of ${s.$2} right',
                          ].join('\n'),
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final c in g.chars)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [
                                Text(c.char, style: const TextStyle(fontSize: 26)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('${c.pinyin} · ${c.meaning}\n${c.example} ${c.examplePinyin}: ${c.exampleMeaning}',
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ]),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('💡 '),
                              Expanded(child: Text(g.tip)),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _drill(context, g),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Practise this group'),
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

/// One drill question: pick which character of a group fits.
class LookAlikeQuestion {
  final LookAlikeGroup group;
  final LookAlike answer;
  final bool gap; // true: fill the gap in the example word; false: pick by meaning
  final List<LookAlike> options;
  const LookAlikeQuestion(this.group, this.answer, this.gap, this.options);
}

/// [n] questions. Groups answered wrong more often come up more.
List<LookAlikeQuestion> buildLookAlikeDrill(Progress progress, {LookAlikeGroup? only, int n = 10, Random? random}) {
  final r = random ?? Random();
  final stats = progress.lookAlikeStats;
  double weight(LookAlikeGroup g) {
    final s = stats[g.id];
    if (s == null) return 2; // not tried yet
    return 1 + 3 * (1 - s.$1 / max(1, s.$2));
  }

  final out = <LookAlikeQuestion>[];
  final groups = only == null ? lookAlikeGroups : [only];
  final count = only == null ? n : only.chars.length * 2;
  var lastChar = '';
  while (out.length < count) {
    LookAlikeGroup g;
    if (groups.length == 1) {
      g = groups.first;
    } else {
      final total = groups.fold<double>(0, (a, g) => a + weight(g));
      var pick = r.nextDouble() * total;
      g = groups.last;
      for (final x in groups) {
        pick -= weight(x);
        if (pick <= 0) {
          g = x;
          break;
        }
      }
    }
    final a = only == null ? g.chars[r.nextInt(g.chars.length)] : g.chars[out.length % g.chars.length];
    if (a.char == lastChar) continue;
    lastChar = a.char;
    // Characters that sound the same can only be told apart by meaning or by the example.
    final gap = only == null ? r.nextBool() : out.length >= g.chars.length;
    out.add(LookAlikeQuestion(g, a, gap, [...g.chars]..shuffle(r)));
  }
  return out;
}

class LookAlikeDrill extends StatefulWidget {
  final Progress progress;
  final LookAlikeGroup? group;
  final List<LookAlikeQuestion>? questions;
  const LookAlikeDrill({super.key, required this.progress, this.group, this.questions});

  @override
  State<LookAlikeDrill> createState() => _LookAlikeDrillState();
}

class _LookAlikeDrillState extends State<LookAlikeDrill> {
  late List<LookAlikeQuestion> _qs = widget.questions ?? _build();
  int _i = 0;
  int? _picked;
  bool _checked = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  List<LookAlikeQuestion> _build() => buildLookAlikeDrill(widget.progress, only: widget.group);
  LookAlikeQuestion get _q => _qs[_i];
  bool get _isRight => _picked != null && _q.options[_picked!].char == _q.answer.char;

  Future<void> _press() async {
    if (_done) return;
    if (!_checked) {
      if (_picked == null) return;
      final right = _isRight;
      setState(() {
        _checked = true;
        if (right) _right++;
      });
      Speech.instance.say(_q.gap ? _q.answer.example : _q.answer.char);
      await widget.progress.recordLookAlike(_q.group.id, right);
      if (right) await widget.progress.bump('lookAlikeRight');
      return;
    }
    if (_i + 1 >= _qs.length) {
      _xp = 5 + _right;
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
        if (!_checked && n != null && n >= 1 && n <= _q.options.length) {
          setState(() => _picked = n - 1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? 'Look-alikes' : 'Look-alikes · ${_i + 1} of ${_qs.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Drill done!',
                    right: _right,
                    total: _qs.length,
                    xp: _xp,
                    note: 'Groups you mix up come back more often.',
                    onAgain: _again,
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(key: ValueKey(_i), padding: const EdgeInsets.all(24), children: [
                        Text(
                          _q.gap ? 'Which character fills the gap?' : 'Which character means this?',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: PopIn(
                            child: Column(children: [
                              if (_q.gap) ...[
                                Text(_checked ? _q.answer.example : _q.answer.gap, style: const TextStyle(fontSize: 48)),
                                if (showPinyin) Text(_q.answer.examplePinyin, style: TextStyle(fontSize: 18, color: scheme.primary)),
                                Text(_q.answer.exampleMeaning, style: TextStyle(color: scheme.onSurfaceVariant)),
                              ] else ...[
                                Text('"${_q.answer.meaning}"', style: const TextStyle(fontSize: 30)),
                                // The sound would give the answer away, so it only shows once checked.
                                if (showPinyin && _checked)
                                  Text(_q.answer.pinyin, style: TextStyle(fontSize: 18, color: scheme.primary)),
                              ],
                            ]),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
                          for (final (i, o) in _q.options.indexed)
                            SizedBox(
                              width: 120,
                              child: AnswerTile(
                                number: i + 1,
                                selected: _picked == i,
                                checked: _checked,
                                isCorrect: o.char == _q.answer.char,
                                onTap: () => setState(() => _picked = i),
                                child: Column(children: [
                                  Text(o.char, style: const TextStyle(fontSize: 44)),
                                  if (_checked)
                                    Text('${o.pinyin}\n${o.meaning}',
                                        textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
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
                      correctAnswer: '${_q.answer.char} (${_q.answer.pinyin}, ${_q.answer.meaning})',
                      explain: _q.group.tip,
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
