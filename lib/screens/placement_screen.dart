import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/course.dart';
import '../logic/placement.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';

/// A short quiz that finds out how much of a course you already know,
/// so you can skip those lessons.
class PlacementScreen extends StatefulWidget {
  final Progress progress;
  const PlacementScreen({super.key, required this.progress});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

enum _Stage { intro, quiz, result }

class _PlacementScreenState extends State<PlacementScreen> {
  _Stage _stage = _Stage.intro;
  int _level = Settings.instance.level;
  late List<PlacementStep> _steps;
  int _step = 0; // the step being asked now
  int _passed = 0; // steps known so far
  List<PlacementQuestion> _qs = [];
  int _q = 0;
  int _rightInStep = 0;
  int? _tapped;

  void _start() {
    setState(() {
      _steps = placementSteps(_level);
      _step = 0;
      _passed = 0;
      _stage = _Stage.quiz;
      _newStep();
    });
  }

  void _newStep() {
    _qs = placementQuestions(_steps[_step], _level);
    _q = 0;
    _rightInStep = 0;
    _tapped = null;
  }

  Future<void> _answer(int? i) async {
    if (_tapped != null) return;
    final q = _qs[_q];
    final right = i != null && q.options[i] == q.word;
    setState(() => _tapped = i ?? -1);
    if (right) _rightInStep++;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _tapped = null;
      if (_q + 1 < _qs.length) {
        _q++;
        return;
      }
      if (!stepPassed(_rightInStep, _qs.length)) {
        _stage = _Stage.result;
        return;
      }
      _passed++;
      if (_step + 1 >= _steps.length) {
        _stage = _Stage.result;
        return;
      }
      _step++;
      _newStep();
    });
  }

  Future<void> _skip(List<Lesson> lessons) async {
    await widget.progress.skipLessons(lessons);
    Settings.instance.level = _level;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent || _stage != _Stage.quiz) return KeyEventResult.ignored;
        final n = int.tryParse(e.character ?? '');
        if (n == 0) {
          _answer(null);
          return KeyEventResult.handled;
        }
        if (n != null && n >= 1 && n <= _qs[_q].options.length) {
          _answer(n - 1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Placement test')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: switch (_stage) {
              _Stage.intro => _intro(context),
              _Stage.quiz => _quiz(context),
              _Stage.result => _result(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(32), children: [
      const Center(child: PopIn(child: Text('🧭', style: TextStyle(fontSize: 72)))),
      const SizedBox(height: 12),
      const Text('Already know some Chinese?',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(
        'Answer a few questions about words from the course, two units at a time. The test stops as soon as '
        'you meet words you don\'t know yet, and then you can skip the lessons before that point.\n\n'
        'There is no pinyin, and it\'s fine to say "I don\'t know". Guessing only makes the lessons too hard.',
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      const SizedBox(height: 24),
      Center(
        child: SegmentedButton<int>(
          segments: [for (final l in levels) ButtonSegment(value: l, label: Text('HSK $l'))],
          selected: {_level},
          onSelectionChanged: (v) => setState(() => _level = v.first),
        ),
      ),
      const SizedBox(height: 8),
      Text('Which course to test', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 24),
      Center(
        child: SizedBox(
          width: 240,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: quizGreen),
            onPressed: _start,
            child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ]);
  }

  Widget _quiz(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _qs[_q];
    final unitNames = _steps[_step].units.map((u) => u.title).join(' and ');
    return Column(children: [
      LinearProgressIndicator(value: (_step + _q / _qs.length) / _steps.length, minHeight: 6),
      Expanded(
        child: ListView(key: ValueKey('$_step-$_q'), padding: const EdgeInsets.all(24), children: [
          Text('HSK $_level · part ${_step + 1} of ${_steps.length}: $unitNames',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(q.askMeaning ? 'What does this mean?' : 'Which one means "${q.word.meaning}"?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (q.askMeaning) Center(child: PopIn(child: Text(q.word.hanzi, style: const TextStyle(fontSize: 56)))),
          const SizedBox(height: 16),
          for (final (i, o) in q.options.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerTile(
                number: i + 1,
                selected: _tapped == i,
                checked: false,
                isCorrect: false,
                onTap: () => _answer(i),
                child: Text(q.askMeaning ? o.meaning : o.hanzi, style: TextStyle(fontSize: q.askMeaning ? 17 : 28)),
              ),
            ),
          Center(
            child: TextButton(
              onPressed: () => _answer(null),
              child: const Text('I don\'t know (0)'),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _result(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final skip = lessonsToSkip(_level, _passed);
    final allKnown = _passed == _steps.length;
    final lastUnit = _passed == 0 ? null : _steps[_passed - 1].units.last;
    final next = lessonsOf(_level).where((l) => !skip.contains(l) && !widget.progress.isDone(l)).firstOrNull;
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(32), children: [
        Center(child: PopIn(child: Text(_passed == 0 ? '🌱' : (allKnown ? '🏆' : '🎯'), style: const TextStyle(fontSize: 72)))),
        const SizedBox(height: 12),
        Text(
          _passed == 0
              ? 'Start from the beginning'
              : allKnown
                  ? 'You know all of HSK $_level!'
                  : 'You know HSK $_level up to "${lastUnit!.title}"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _passed == 0
              ? 'The first lessons are the right place for you. They go quickly, and every word you learn will count.'
              : 'You can skip ${skip.length} lessons. Their words go on your review list and come back over the next '
                  'two weeks, so anything you\'ve forgotten gets refreshed.'
                  '${next == null ? '' : '\n\nYou would start at "${next.title}".'}',
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        if (_passed > 0) ...[
          Center(
            child: SizedBox(
              width: 280,
              height: 52,
              child: FilledButton(
                key: const ValueKey('skipLessons'),
                style: FilledButton.styleFrom(backgroundColor: quizGreen),
                onPressed: () => _skip(skip),
                child: Text('SKIP ${skip.length} LESSONS', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Center(
          child: TextButton(
            onPressed: () async {
              await widget.progress.setPlacementSeen();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(_passed > 0 ? 'No thanks, keep all lessons' : 'OK, let\'s start'),
          ),
        ),
        if (allKnown && _level < levels.last)
          Center(
            child: TextButton(
              onPressed: () async {
                await widget.progress.skipLessons(skip);
                setState(() {
                  _level++;
                  _stage = _Stage.intro;
                });
              },
              child: Text('Skip these and test HSK ${_level + 1} too'),
            ),
          ),
      ]),
      if (allKnown) const Positioned.fill(child: IgnorePointer(child: Confetti())),
    ]);
  }
}
