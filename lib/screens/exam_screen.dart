import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/exam.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// Explains the mini exam before it starts.
class ExamIntroScreen extends StatelessWidget {
  final Progress progress;
  final int level;
  const ExamIntroScreen({super.key, required this.progress, this.level = 1});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final best = progress.bestExamFor(level);
    final max = examMaxFor(level), pass = examPassFor(level);
    final time = examTimeFor(level);
    return Scaffold(
      appBar: AppBar(title: Text('Mini HSK $level exam')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const FadeSlideIn(child: Center(child: Text('📝', style: TextStyle(fontSize: 64)))),
            const SizedBox(height: 8),
            Text('A practice test in the style of the real HSK $level exam',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _Row(Icons.headphones, 'Part 1: Listening', '$examQuestionsPerPart questions. Each recording can be played twice, like in the real exam.'),
            _Row(Icons.chrome_reader_mode_outlined, 'Part 2: Reading', '$examQuestionsPerPart questions: pictures, replies and gaps to fill.'),
            if (level >= 3)
              const _Row(Icons.edit_outlined, 'Part 3: Writing',
                  '$examWritingQuestions questions: pick the missing character from its pinyin. In the real exam you write it by hand.'),
            _Row(Icons.timer_outlined, '${time.inMinutes} minutes', 'The clock keeps running. Unanswered questions score nothing.'),
            _Row(Icons.emoji_events_outlined, 'Scored out of $max',
                'Each part is worth 100 points. $pass is a pass, the same as the real HSK $level.'),
            ValueListenableBuilder<bool>(
              valueListenable: Speech.instance.available,
              builder: (context, ok, _) => ok
                  ? const SizedBox.shrink()
                  : const _Row(Icons.volume_off, 'No Chinese voice found',
                      'The listening part will show the words instead of playing them.'),
            ),
            if (best != null) ...[
              const SizedBox(height: 8),
              Text('Your best so far: $best / $max${best >= pass ? ' (pass)' : ''}',
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size(260, 52)),
                icon: const Icon(Icons.play_arrow),
                label: const Text('START THE EXAM', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => ExamScreen(progress: progress, questions: buildExam(level: level), level: level, time: time),
                )),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Row(this.icon, this.title, this.text);
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(text),
      );
}

/// The exam itself: one question at a time, no feedback until the end.
class ExamScreen extends StatefulWidget {
  final Progress progress;
  final List<ExamQuestion> questions;
  final Duration time;
  final int level;
  const ExamScreen({super.key, required this.progress, required this.questions, this.time = examTime, this.level = 1});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _index = 0;
  late final List<int?> _answers = List.filled(widget.questions.length, null);
  final Map<int, int> _plays = {};
  late Duration _left = widget.time;
  Timer? _timer;
  bool _finished = false;
  int _earnedXp = 0;

  ExamQuestion get _q => widget.questions[_index];
  bool get _voice => Speech.instance.available.value;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished) return;
      setState(() => _left -= const Duration(seconds: 1));
      if (_left <= Duration.zero) _finish();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlay());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _autoPlay() {
    if (_q.speak != null && _voice && (_plays[_index] ?? 0) == 0) _play();
  }

  void _play() {
    if (_q.speak == null || (_plays[_index] ?? 0) >= 2) return;
    setState(() => _plays[_index] = (_plays[_index] ?? 0) + 1);
    Speech.instance.say(_q.speak!);
  }

  void _next() {
    if (_index + 1 >= widget.questions.length) {
      _finish();
      return;
    }
    setState(() => _index++);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlay());
  }

  int _right(ExamPart part) {
    var n = 0;
    for (final (i, q) in widget.questions.indexed) {
      if (q.part == part && _answers[i] == q.correct) n++;
    }
    return n;
  }

  /// The parts in this exam, in order.
  List<ExamPart> get _parts => [for (final p in ExamPart.values) if (widget.questions.any((q) => q.part == p)) p];
  int _score(ExamPart p) => partScore(_right(p), widget.questions.where((q) => q.part == p).length);
  int get _total => _parts.fold(0, (a, p) => a + _score(p));
  int get _max => examMaxFor(widget.level);
  int get _pass => examPassFor(widget.level);

  Future<void> _finish() async {
    if (_finished) return;
    _timer?.cancel();
    final total = _total;
    _earnedXp = 10 + total ~/ 10;
    setState(() => _finished = true);
    await widget.progress.finishExam(total, _earnedXp,
        level: widget.level, passed: total >= _pass, fullMarks: total == _max);
  }

  Future<void> _quit() async {
    if (_finished) {
      Navigator.pop(context);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Stop the exam?'),
        content: const Text("Your answers so far won't be scored."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep going')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Stop')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent || _finished) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final digits = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3];
    final i = digits.indexOf(k);
    if (i >= 0 && i < _q.options.length) {
      setState(() => _answers[_index] = i);
      return KeyEventResult.handled;
    }
    if ((k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) && _answers[_index] != null) {
      _next();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.keyR) {
      _play();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mm = _left.inMinutes.toString().padLeft(2, '0');
    final ss = (_left.inSeconds % 60).toString().padLeft(2, '0');
    final hurry = _left.inSeconds <= 60;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _quit),
          title: Text(_finished
              ? 'Exam results'
              : '${partName(_q.part)} · ${_index + 1} of ${widget.questions.length}'),
          actions: [
            if (!_finished)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: hurry ? 20 : 17,
                    fontWeight: FontWeight.bold,
                    color: hurry ? _red : scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  child: Row(children: [
                    Icon(Icons.timer_outlined, color: hurry ? _red : scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('$mm:$ss'),
                  ]),
                ),
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _finished ? _results(scheme) : _question(scheme),
          ),
        ),
      ),
    );
  }

  Widget _question(ColorScheme scheme) {
    final q = _q;
    final listening = q.part == ExamPart.listening;
    final showText = !listening || !_voice; // without a voice, read the listening text instead
    final plays = _plays[_index] ?? 0;
    return Column(children: [
      LinearProgressIndicator(value: (_index + 1) / widget.questions.length, minHeight: 4),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                  position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim), child: child),
            ),
            layoutBuilder: (current, previous) =>
                Stack(alignment: Alignment.topCenter, fit: StackFit.passthrough, children: [...previous, ?current]),
            child: Column(
              key: ValueKey(_index),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(q.instruction, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (listening && _voice)
                  Center(
                    child: Column(children: [
                      PressBounce(
                        enabled: plays < 2,
                        child: IconButton.filled(
                          iconSize: 48,
                          onPressed: plays < 2 ? _play : null,
                          icon: const Icon(Icons.volume_up),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(plays >= 2 ? 'Played twice' : 'Play (${2 - plays} left) · R',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ]),
                  ),
                if (q.picture != null) ...[
                  const SizedBox(height: 8),
                  Center(child: PopIn(child: Text(q.picture!, style: const TextStyle(fontSize: 96)))),
                ],
                // In a picture check, the reading part shows the word next to the picture.
                if (q.gapPinyin != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                      child: Text('Missing: ${q.gapPinyin}', style: TextStyle(fontSize: 18, color: scheme.onPrimaryContainer)),
                    ),
                  ),
                if (showText && q.text != null && !(listening && q.trueFalse && _voice)) ...[
                  const SizedBox(height: 12),
                  Center(child: Text(q.text!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34))),
                  if (Settings.instance.showPinyin && q.textPinyin != null && q.textPinyin!.isNotEmpty)
                    Center(
                      child: Text(q.textPinyin!,
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: scheme.onSurfaceVariant)),
                    ),
                ],
                const SizedBox(height: 24),
                if (q.options.every((o) => o.picture != null))
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (final (i, o) in q.options.indexed)
                      Padding(padding: const EdgeInsets.all(8), child: _pictureOption(scheme, i, o)),
                  ])
                else if (q.trueFalse)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (final (i, o) in q.options.indexed)
                      Padding(padding: const EdgeInsets.all(8), child: _tfOption(scheme, i, o)),
                  ])
                else
                  for (final (i, o) in q.options.indexed) _textOption(scheme, i, o),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 280,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: _answers[_index] == null ? null : _next,
            child: Text(_index + 1 == widget.questions.length ? 'FINISH' : 'NEXT',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ]);
  }

  Color _border(ColorScheme scheme, int i) => _answers[_index] == i ? scheme.primary : scheme.outlineVariant;
  Color? _fill(ColorScheme scheme, int i) =>
      _answers[_index] == i ? scheme.primaryContainer.withValues(alpha: 0.6) : null;

  Widget _box(ColorScheme scheme, int i, Widget child, {double? width}) => AnimatedScale(
        scale: _answers[_index] == i ? 1.05 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: width,
          child: Material(
            color: _fill(scheme, i) ?? scheme.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _border(scheme, i), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _answers[_index] = i),
              child: child,
            ),
          ),
        ),
      );

  Widget _pictureOption(ColorScheme scheme, int i, ExamOption o) => _box(
        scheme,
        i,
        width: 130,
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(o.picture!, style: const TextStyle(fontSize: 56)),
            Text(String.fromCharCode(65 + i), style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
        ),
      );

  Widget _tfOption(ColorScheme scheme, int i, ExamOption o) => _box(
        scheme,
        i,
        width: 150,
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Text(o.label, style: TextStyle(fontSize: 40, color: i == 0 ? _green : _red, fontWeight: FontWeight.bold)),
            Text(o.pinyin ?? '', style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
        ),
      );

  Widget _textOption(ColorScheme scheme, int i, ExamOption o) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _box(
          scheme,
          i,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Text('${String.fromCharCode(65 + i)}  ', style: TextStyle(fontSize: 18, color: scheme.onSurfaceVariant)),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.label, style: const TextStyle(fontSize: 24)),
                  if (Settings.instance.showPinyin && o.pinyin != null && o.pinyin!.isNotEmpty)
                    Text(o.pinyin!, style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant)),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget _results(ColorScheme scheme) {
    final total = _total, passed = total >= _pass;
    final wrong = [
      for (final (i, q) in widget.questions.indexed)
        if (_answers[i] != q.correct) (i, q),
    ];
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(24), children: [
        Center(child: PopIn(child: Text(passed ? '🏆' : '💪', style: const TextStyle(fontSize: 72)))),
        const SizedBox(height: 8),
        Center(
          child: CountUp(
            value: total,
            suffix: ' / $_max',
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: passed ? _green : scheme.onSurface),
          ),
        ),
        Text(
          passed
              ? 'Pass! The real HSK ${widget.level} pass mark is $_pass.'
              : 'Not a pass yet: $_pass is the pass mark. Keep going!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        Wrap(alignment: WrapAlignment.center, spacing: 24, runSpacing: 12, children: [
          for (final p in _parts) _ScoreBar(label: partName(p), score: _score(p)),
        ]),
        const SizedBox(height: 12),
        Text('+$_earnedXp XP', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
        if (wrong.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Answers to check (${wrong.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final (i, q) in wrong)
            Card(
              child: ListTile(
                leading: Text(q.picture ?? switch (q.part) { ExamPart.listening => '🎧', ExamPart.reading => '📖', ExamPart.writing => '✏️' },
                    style: const TextStyle(fontSize: 28)),
                title: Text(q.text ?? ''),
                subtitle: Text('${q.textPinyin ?? ''}\n'
                    'Right answer: ${_describe(q, q.correct)}'
                    '${_answers[i] == null ? ' · not answered' : ' · you chose ${_describe(q, _answers[i]!)}'}'),
                isThreeLine: true,
                trailing: q.speak != null && _voice
                    ? IconButton(icon: const Icon(Icons.volume_up), onPressed: () => Speech.instance.say(q.speak!))
                    : null,
              ),
            ),
        ],
        const SizedBox(height: 24),
        Center(
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size(260, 52)),
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
      if (passed) const Positioned.fill(child: Confetti()),
    ]);
  }

  String _describe(ExamQuestion q, int i) {
    final o = q.options[i];
    if (q.trueFalse) return i == 0 ? '✓ matches' : "✗ doesn't match";
    return o.picture ?? o.label;
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label: $score / 100', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          AnimatedBar(value: score / 100, color: score >= 60 ? _green : Colors.orange),
        ]),
      );
}
