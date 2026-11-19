import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/char_stories.dart';
import '../data/course.dart';
import '../data/grammar.dart';
import '../logic/exercises.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/char_story_card.dart';
import '../widgets/character_writer.dart';
import '../widgets/tone_shape.dart';

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// Plays through one lesson, screen by screen.
/// Questions answered wrong are asked again at the end.
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Progress progress;
  const LessonScreen({super.key, required this.lesson, required this.progress});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<LessonStep> _queue = buildLesson(widget.lesson, withAudio: Speech.instance.available.value);
  late final int _originalLength = _queue.length;
  int _index = 0;

  int? _selected;
  final List<int> _built = []; // sentence tiles picked so far (positions in the bank)
  bool _checked = false;
  bool _matchDone = false;
  bool _writeDone = false;

  int _questions = 0;
  int _firstTryRight = 0;
  final Set<LessonStep> _missed = {};
  final Map<String, bool> _wordResults = {}; // word → right every time this lesson
  bool _finished = false;
  int _earnedXp = 0;

  LessonStep get _step => _queue[_index];

  @override
  void initState() {
    super.initState();
    _autoPlay();
  }

  /// The Chinese that belongs to the current screen, if any.
  String? get _stepAudio => switch (_step) {
        TeachWordStep s => s.word.hanzi,
        TeachToneStep s => s.example.hanzi,
        GrammarStep() => null,
        ChoiceStep s => s.speak,
        // Don't give the sentence away before it's built.
        SentenceStep s => _checked ? s.sentence.hanzi : null,
        WriteStep s => s.char,
        MatchStep() => null,
      };

  /// Is the answer on the current question screen right?
  bool get _isRight => switch (_step) {
        ChoiceStep s => _selected == s.correct,
        SentenceStep s => s.isCorrect([for (final i in _built) s.bank[i]]),
        _ => true,
      };

  /// Read the current screen's Chinese aloud once it appears.
  void _autoPlay() {
    final text = _stepAudio;
    if (text == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_finished) Speech.instance.say(text);
    });
  }

  bool get _canPress => switch (_step) {
        TeachWordStep() || TeachToneStep() || GrammarStep() => true,
        ChoiceStep() => _selected != null,
        SentenceStep() => _built.isNotEmpty,
        WriteStep() => true, // can always skip writing
        MatchStep() => _matchDone,
      };

  void _primary() {
    if (!_canPress || _finished) return;
    final step = _step;
    if ((step is ChoiceStep || step is SentenceStep) && !_checked) {
      final right = _isRight;
      setState(() {
        _checked = true;
        if (!_missed.contains(step)) {
          _questions++;
          if (right) _firstTryRight++;
        }
        if (!right) {
          _missed.add(step);
          _queue.add(step); // try it again later
        }
      });
      // Hear the right answer once more.
      final answerAudio = switch (step) {
        ChoiceStep s => s.options[s.correct].speak ?? s.speak,
        SentenceStep s => s.sentence.hanzi,
        _ => null,
      };
      if (answerAudio != null) Speech.instance.say(answerAudio);
      // Remember which words are tricky, for Practice.
      if (step is ChoiceStep && step.wordKey != null) {
        widget.progress.recordAnswer(step.wordKey!, right);
        _wordResults[step.wordKey!] = (_wordResults[step.wordKey!] ?? true) && right;
      }
      // Remember how each tone went, for the stats page.
      if (step is ChoiceStep && step.tone != null) widget.progress.recordTone(step.tone!, right);
      return;
    }
    _next();
  }

  Future<void> _next() async {
    if (_index + 1 >= _queue.length) {
      final accuracy = _questions == 0 ? 1.0 : _firstTryRight / _questions;
      _earnedXp = 10 + (accuracy * 10).round();
      await widget.progress.finishLesson(widget.lesson, _earnedXp, results: _wordResults);
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _built.clear();
      _checked = false;
      _matchDone = false;
      _writeDone = false;
    });
    _autoPlay();
  }

  void _select(int i) {
    final step = _step;
    if (step is! ChoiceStep || _checked || i >= step.options.length) return;
    setState(() => _selected = i);
    final audio = step.options[i].speak;
    if (audio != null) Speech.instance.say(audio);
  }

  void _addTile(int i) {
    final step = _step;
    if (step is! SentenceStep || _checked || i >= step.bank.length || _built.contains(i)) return;
    setState(() => _built.add(i));
    Speech.instance.say(step.bank[i]);
  }

  void _removeTile(int i) {
    if (_checked) return;
    setState(() => _built.remove(i));
  }

  Future<void> _quit() async {
    if (_finished) return Navigator.pop(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Leave this lesson?'),
        content: const Text("Your progress in this lesson won't be saved."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep learning')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Leave')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter || k == LogicalKeyboardKey.space) {
      _finished ? Navigator.pop(context) : _primary();
      return KeyEventResult.handled;
    }
    const digits = [
      LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4, LogicalKeyboardKey.digit5, LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7, LogicalKeyboardKey.digit8, LogicalKeyboardKey.digit9,
    ];
    final d = digits.indexOf(k);
    if (d >= 0) {
      _step is SentenceStep ? _addTile(d) : _select(d);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace && _built.isNotEmpty) {
      _removeTile(_built.last);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.keyR) {
      final text = _stepAudio;
      if (text != null) Speech.instance.say(text);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      _quit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _finished ? _results() : _lessonBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lessonBody() {
    final scheme = Theme.of(context).colorScheme;
    // Progress counts the original steps; retries make the bar wait at the end.
    final progress = (_index.clamp(0, _originalLength)) / _originalLength;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 24, 8),
        child: Row(children: [
          IconButton(onPressed: _quit, icon: const Icon(Icons.close), tooltip: 'Leave lesson (Esc)'),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 14,
                  color: _green,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ]),
      ),
      if (_index >= _originalLength)
        Text('Let\'s try the ones you missed', style: TextStyle(color: scheme.onSurfaceVariant)),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(alignment: Alignment.topCenter, fit: StackFit.passthrough, children: [
              ...previous,
              if (current != null) current,
            ]),
            child: KeyedSubtree(key: ValueKey(_index), child: _stepView(_step)),
          ),
        ),
      ),
      _bottomBar(),
    ]);
  }

  Widget _stepView(LessonStep step) => switch (step) {
        TeachWordStep s => _TeachWord(word: s.word),
        TeachToneStep s => _TeachTone(step: s),
        GrammarStep s => GrammarCard(tip: s.tip),
        ChoiceStep s => _ChoiceView(step: s, selected: _selected, checked: _checked, onSelect: _select),
        SentenceStep s => _SentenceView(
            step: s, built: _built, checked: _checked, onAdd: _addTile, onRemove: _removeTile),
        WriteStep s => _WriteView(step: s, onDone: () => setState(() => _writeDone = true)),
        MatchStep s => _MatchView(
            words: s.words,
            onDone: () => setState(() => _matchDone = true),
          ),
      };

  Widget _bottomBar() {
    final step = _step;
    final scheme = Theme.of(context).colorScheme;
    String label = step is WriteStep && !_writeDone ? 'Skip' : 'Continue';
    Color? panel;
    Widget? feedback;

    if (step is ChoiceStep || step is SentenceStep) {
      if (!_checked) {
        label = 'Check';
      } else {
        final right = _isRight;
        final answer = switch (step) {
          ChoiceStep s => s.options[s.correct].label,
          SentenceStep s => '${s.sentence.hanzi}  (${s.sentence.pinyin})',
          _ => '',
        };
        final explain = switch (step) {
          ChoiceStep s => s.explain,
          SentenceStep s => right ? '${s.sentence.hanzi} (${s.sentence.pinyin}) means "${s.sentence.meaning}"' : null,
          _ => null,
        };
        panel = (right ? _green : _red).withValues(alpha: 0.12);
        feedback = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(right ? Icons.check_circle : Icons.cancel, color: right ? _green : _red),
            const SizedBox(width: 8),
            Text(right ? 'Nice!' : 'Not quite',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: right ? _green : _red)),
          ]),
          if (!right) ...[
            const SizedBox(height: 4),
            Text('Correct answer: $answer', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          if (explain != null) ...[
            const SizedBox(height: 4),
            Text(explain),
          ],
        ]);
      }
    }

    final wrong = _checked && !_isRight;
    return Container(
      color: panel,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (feedback != null) ...[
          FadeSlideIn(key: ValueKey('fb$_index'), from: const Offset(0, 0.4), child: feedback),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: wrong ? _red : _green,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _canPress ? _primary : null,
            child: Text(label.toUpperCase()),
          ),
        ),
        const SizedBox(height: 6),
        Text(
            [
              step is SentenceStep ? 'Tip: press 1–9 to add a word, Backspace to undo' : 'Tip: press 1–4 to choose',
              'Enter to continue',
              if (Speech.instance.available.value) 'R to hear it again',
            ].join(', '),
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      ]),
    );
  }

  Widget _results() {
    final scheme = Theme.of(context).colorScheme;
    final pct = _questions == 0 ? 100 : (_firstTryRight * 100 / _questions).round();
    return Stack(children: [
      Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const PopIn(child: Text('🎉', style: TextStyle(fontSize: 72))),
        const SizedBox(height: 12),
        Text(widget.lesson.kind == LessonKind.practice ? 'Practice complete!' : 'Lesson complete!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(widget.lesson.title, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ResultTile(label: 'XP earned', count: _earnedXp, prefix: '+', value: '', color: Colors.amber.shade700),
          const SizedBox(width: 16),
          _ResultTile(label: 'First-try accuracy', value: '$pct%', color: _green),
          const SizedBox(width: 16),
          _ResultTile(label: 'Day streak', value: '${widget.progress.streak} 🔥', color: Colors.orange),
        ]),
        const SizedBox(height: 40),
        SizedBox(
          width: 280,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO PATH', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ])),
      ),
      const Positioned.fill(child: Confetti()),
    ]);
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final int? count; // when set, the number counts up
  final String prefix;
  const _ResultTile({required this.label, required this.value, required this.color, this.count, this.prefix = ''});

  @override
  Widget build(BuildContext context) => Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: color, width: 2), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          count != null
              ? CountUp(value: count!, prefix: prefix, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))
              : Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ]),
      );
}

// ---------- Teaching cards ----------

class _NewBadge extends StatelessWidget {
  final String text;
  const _NewBadge(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold)),
      );
}

class _TeachWord extends StatelessWidget {
  final Word word;
  const _TeachWord({required this.word});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      const _NewBadge('NEW WORD'),
      const SizedBox(height: 32),
      PopIn(child: Text(word.hanzi, style: const TextStyle(fontSize: 96))),
      SpeakButton(word.hanzi),
      Text(word.pinyin, style: TextStyle(fontSize: 30, color: scheme.primary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Text(word.meaning, style: const TextStyle(fontSize: 24)),
      if (word.note != null) ...[
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lightbulb_outline),
              const SizedBox(width: 8),
              Flexible(child: Text(word.note!)),
            ]),
          ),
        ),
      ],
      for (final story in storiesFor(word.hanzi).take(2)) ...[
        const SizedBox(height: 12),
        CharStoryCard(story),
      ],
    ]);
  }
}

class _TeachTone extends StatelessWidget {
  final TeachToneStep step;
  const _TeachTone({required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = step.tone;
    return Column(children: [
      _NewBadge('TONE ${t.number}'),
      const SizedBox(height: 24),
      Text(t.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ToneShape(tone: t.number, size: 120, color: scheme.primary, showGrid: true),
      const SizedBox(height: 16),
      Text(t.howTo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(step.example.marked, style: TextStyle(fontSize: 56, color: scheme.primary, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SpeakButton(step.example.hanzi!),
      ]),
      Text('${step.example.hanzi}  ·  ${step.example.meaning}', style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 16),
      Text('Same sound "ma", different tone, different word!',
          style: TextStyle(color: scheme.onSurfaceVariant)),
    ]);
  }
}

// ---------- Multiple choice ----------

class _ChoiceView extends StatelessWidget {
  final ChoiceStep step;
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelect;
  const _ChoiceView({required this.step, required this.selected, required this.checked, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(step.instruction, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      if (step.listening) ...[
        const SizedBox(height: 24),
        Center(child: SpeakButton(step.speak!, size: 96, filled: true)),
        if (checked && step.speak != null)
          Center(child: Text(step.speak!, style: const TextStyle(fontSize: 40))),
      ],
      if (step.prompt != null) ...[
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(step.prompt!, style: const TextStyle(fontSize: 72)),
          if (step.speak != null) ...[const SizedBox(width: 8), SpeakButton(step.speak!)],
        ]),
        if (step.promptSub != null && (!step.promptSubIsPinyin || Settings.instance.showPinyin))
          Center(child: Text(step.promptSub!, style: TextStyle(fontSize: 20, color: scheme.onSurfaceVariant))),
      ],
      const SizedBox(height: 28),
      LayoutBuilder(builder: (context, c) {
        final twoCols = c.maxWidth > 480;
        final w = twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final (i, o) in step.options.indexed)
            SizedBox(width: w, child: _optionTile(context, i, o)),
        ]);
      }),
    ]);
  }

  Widget _optionTile(BuildContext context, int i, ChoiceOption o) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outlineVariant;
    Color? bg;
    if (checked && i == step.correct) {
      border = _green;
      bg = _green.withValues(alpha: 0.12);
    } else if (checked && i == selected) {
      border = _red;
      bg = _red.withValues(alpha: 0.12);
    } else if (i == selected) {
      border = scheme.primary;
      bg = scheme.primaryContainer.withValues(alpha: 0.5);
    }
    final wrongPick = checked && i == selected && i != step.correct;
    final rightAnswer = checked && i == step.correct;
    return Shake(
      trigger: wrongPick ? 'wrong' : null,
      child: AnimatedScale(
        scale: rightAnswer ? 1.04 : (i == selected && !checked ? 0.98 : 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: _optionMaterial(context, i, o, bg, border),
      ),
    );
  }

  Widget _optionMaterial(BuildContext context, int i, ChoiceOption o, Color? bg, Color border) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: bg ?? scheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: checked ? null : () => onSelect(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(8)),
              child: Text('${i + 1}', style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
            const SizedBox(width: 14),
            if (o.tone != null) ...[
              ToneShape(tone: o.tone!, size: 28, color: scheme.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.label, style: TextStyle(fontSize: o.big ? 30 : 18, fontWeight: FontWeight.w500)),
                if (o.sub != null && (!o.subIsPinyin || Settings.instance.showPinyin)) Text(o.sub!, style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------- Matching game ----------

class _MatchView extends StatefulWidget {
  final List<Word> words;
  final VoidCallback onDone;
  const _MatchView({required this.words, required this.onDone});

  @override
  State<_MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<_MatchView> {
  late final List<Word> _left = [...widget.words]..shuffle();
  late final List<Word> _right = [...widget.words]..shuffle();
  Word? _pickLeft;
  Word? _pickRight;
  final Set<Word> _matched = {};
  Word? _wrongL, _wrongR;

  void _tryMatch() {
    final l = _pickLeft, r = _pickRight;
    if (l == null || r == null) return;
    if (l == r) {
      _matched.add(l);
      _pickLeft = _pickRight = null;
      if (_matched.length == widget.words.length) widget.onDone();
    } else {
      _wrongL = l;
      _wrongR = r;
      _pickLeft = _pickRight = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongL = _wrongR = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Match the pairs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(children: [
            for (final w in _left)
              _tile(w, Settings.instance.showPinyin ? '${w.hanzi}\n${w.pinyin}' : w.hanzi, _pickLeft == w, _wrongL == w, () {
                Speech.instance.say(w.hanzi);
                setState(() {
                  _pickLeft = w;
                  _tryMatch();
                });
              }),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(children: [
            for (final w in _right)
              _tile(w, w.meaning, _pickRight == w, _wrongR == w, () {
                setState(() {
                  _pickRight = w;
                  _tryMatch();
                });
              }),
          ]),
        ),
      ]),
      if (_matched.length == widget.words.length) ...[
        const SizedBox(height: 16),
        const Center(child: Text('All matched!', style: TextStyle(color: _green, fontSize: 18, fontWeight: FontWeight.bold))),
      ],
    ]);
  }

  Widget _tile(Word w, String text, bool picked, bool wrong, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    final done = _matched.contains(w);
    final border = wrong ? _red : (picked ? scheme.primary : (done ? _green : scheme.outlineVariant));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: done ? 0.45 : 1,
        child: Material(
          color: picked ? scheme.primaryContainer.withValues(alpha: 0.5) : scheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: done ? null : onTap,
            child: SizedBox(
              height: 72,
              width: double.infinity,
              child: Center(child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18))),
            ),
          ),
        ),
      ),
    );
  }
}

/// A speaker button that reads Chinese aloud. Hidden when there's no voice.
class SpeakButton extends StatelessWidget {
  final String text;
  final double size;
  final bool filled;
  const SpeakButton(this.text, {super.key, this.size = 40, this.filled = false});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: Speech.instance.available,
        builder: (context, ok, _) {
          if (!ok) {
            return filled
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('(No Chinese voice on this computer)'),
                  )
                : const SizedBox.shrink();
          }
          final scheme = Theme.of(context).colorScheme;
          final icon = Icon(Icons.volume_up_rounded, size: size * 0.6);
          void play() => Speech.instance.say(text);
          return filled
              ? SizedBox(
                  width: size,
                  height: size,
                  child: IconButton.filled(
                    onPressed: play,
                    icon: icon,
                    tooltip: 'Play again (R)',
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF2E86AB), foregroundColor: Colors.white),
                  ),
                )
              : IconButton(onPressed: play, icon: icon, color: scheme.primary, tooltip: 'Listen (R)');
        },
      );
}

// ---------- Sentence building ----------

class _SentenceView extends StatelessWidget {
  final SentenceStep step;
  final List<int> built;
  final bool checked;
  final ValueChanged<int> onAdd;
  final ValueChanged<int> onRemove;
  const _SentenceView({
    required this.step,
    required this.built,
    required this.checked,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Build this sentence in Chinese', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Text('"${step.sentence.meaning}"', style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 20),
      // The answer line: tap a tile to take it back.
      Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.outlineVariant, width: 2),
            bottom: BorderSide(color: scheme.outlineVariant, width: 2),
          ),
        ),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final i in built) _WordTile(text: step.bank[i], onTap: checked ? null : () => onRemove(i)),
        ]),
      ),
      const SizedBox(height: 28),
      // The word bank.
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
        for (final (i, t) in step.bank.indexed)
          built.contains(i)
              ? _WordTile(text: t, ghost: true)
              : _WordTile(text: t, number: i + 1, onTap: checked ? null : () => onAdd(i)),
      ]),
    ]);
  }
}

class _WordTile extends StatelessWidget {
  final String text;
  final int? number;
  final bool ghost;
  final VoidCallback? onTap;
  const _WordTile({required this.text, this.number, this.ghost = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pinyin = Settings.instance.showPinyin ? wordFor(text)?.pinyin : null;
    return Opacity(
      opacity: ghost ? 0.25 : 1,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: scheme.outlineVariant, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: ghost ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(text, style: const TextStyle(fontSize: 26)),
              if (pinyin != null) Text(pinyin, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              if (number != null && !ghost)
                Text('$number', style: TextStyle(fontSize: 10, color: scheme.outline)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------- Writing ----------

class _WriteView extends StatelessWidget {
  final WriteStep step;
  final VoidCallback onDone;
  const _WriteView({required this.step, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = step.word;
    return Column(children: [
      const Text('Write this character', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(
        w.hanzi.length > 1 ? '${step.char} from ${w.hanzi} (${w.pinyin}) "${w.meaning}"' : '${w.hanzi} (${w.pinyin}) "${w.meaning}"',
        style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Text('Watch the strokes, then trace them in order with your mouse or finger.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      CharacterWriter(char: step.char, size: 280, onComplete: (_) => onDone()),
    ]);
  }
}

// ---------- Grammar ----------

/// A grammar tip: the pattern, a short explanation and examples you can hear.
class GrammarCard extends StatelessWidget {
  final GrammarTip tip;
  const GrammarCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Center(child: _NewBadge('GRAMMAR TIP')),
      const SizedBox(height: 20),
      Text(tip.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Center(
        child: PopIn(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(tip.pattern, style: TextStyle(fontSize: 22, color: scheme.onPrimaryContainer)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(tip.explain, style: const TextStyle(fontSize: 17)),
      const SizedBox(height: 12),
      for (final (i, e) in tip.examples.indexed)
        FadeSlideIn(
          delay: Duration(milliseconds: 120 * (i + 1)),
          child: Card(
            child: ListTile(
              title: Text(e.hanzi, style: const TextStyle(fontSize: 24)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (Settings.instance.showPinyin)
                  Text(e.pinyin, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                Text(e.en),
              ]),
              trailing: SpeakButton(e.hanzi),
            ),
          ),
        ),
    ]);
  }
}
