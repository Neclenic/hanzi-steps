import 'dart:math';

import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/strokes.dart';
import '../widgets/anim.dart';
import '../widgets/character_writer.dart';
import '../widgets/quiz_parts.dart';

/// Picks [n] characters to write from memory: from learned words, trickiest first,
/// each with the word it comes from. Only characters with stroke data.
List<(String, Word)> pickMemoryChars(List<Word> learned, bool Function(String) hasStrokes, {int n = 5, Random? random}) {
  final r = random ?? Random();
  final words = learned.isEmpty ? allLessons.firstWhere((l) => l.words.isNotEmpty).words : learned;
  final seen = <String>{};
  final all = [
    for (final w in [...words]..shuffle(r))
      for (final c in w.hanzi.split(''))
        if (hasStrokes(c) && seen.add(c)) (c, w),
  ];
  return all.take(n).toList();
}

/// 默写: see the meaning and sound, then write the character with no outline to trace.
class MemoryWritingScreen extends StatefulWidget {
  final Progress progress;
  const MemoryWritingScreen({super.key, required this.progress});

  @override
  State<MemoryWritingScreen> createState() => _MemoryWritingScreenState();
}

class _MemoryWritingScreenState extends State<MemoryWritingScreen> {
  List<(String, Word)> _chars = [];
  bool _loaded = false;
  int _i = 0;
  int? _mistakes; // set when the current character is finished
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    StrokeLibrary.instance.load().then((_) {
      if (mounted) _start();
    });
  }

  void _start() => setState(() {
        _chars = pickMemoryChars(widget.progress.learnedWords, StrokeLibrary.instance.has);
        _loaded = true;
        _i = 0;
        _mistakes = null;
        _right = 0;
        _done = false;
        _say();
      });

  void _say() {
    if (_chars.isNotEmpty) Speech.instance.say(_chars[_i].$2.hanzi);
  }

  Future<void> _finished(int mistakes) async {
    final good = mistakes <= 1;
    setState(() {
      _mistakes = mistakes;
      if (good) _right++;
    });
    if (good) await widget.progress.bump('memoryRight');
  }

  Future<void> _next() async {
    if (_i + 1 >= _chars.length) {
      final xp = 5 + 2 * _right;
      await widget.progress.addXp(xp);
      setState(() {
        _xp = xp;
        _done = true;
      });
      return;
    }
    setState(() {
      _i++;
      _mistakes = null;
    });
    _say();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_done || _chars.isEmpty ? 'Write from memory' : 'Write from memory · ${_i + 1} of ${_chars.length}')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _done
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: RoundResults(
                      title: '默写完成！ Well done!',
                      right: _right,
                      total: _chars.length,
                      xp: _xp,
                      note: 'A character counts as right when you write it with at most one slip.',
                      onAgain: _start,
                    ),
                  ),
                )
              : _body(scheme),
    );
  }

  Widget _body(ColorScheme scheme) {
    final (c, w) = _chars[_i];
    final gapped = w.hanzi.replaceAll(c, '□');
    final finished = _mistakes != null;
    return Column(children: [
      LinearProgressIndicator(value: _i / _chars.length),
      Expanded(
        child: ListView(key: ValueKey(_i), padding: const EdgeInsets.all(16), children: [
          const Text('默写 · Write the missing character, with no outline to trace',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          PopIn(
            child: Column(children: [
              Text(finished ? w.hanzi : gapped, style: const TextStyle(fontSize: 40)),
              Text(w.pinyin, style: TextStyle(fontSize: 22, color: scheme.primary)),
              Text(w.meaning, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
              IconButton(tooltip: 'Hear it again', onPressed: _say, icon: const Icon(Icons.volume_up)),
            ]),
          ),
          Center(
            child: CharacterWriter(
              key: ValueKey('mem-$_i-$c'),
              char: c,
              showOutline: false,
              watchFirst: false,
              size: 280,
              onComplete: _finished,
            ),
          ),
          if (!finished)
            Text('Stuck? After two misses a hint shows where the stroke starts.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.outline)),
        ]),
      ),
      if (finished)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Text(
                _mistakes == 0 ? '🎉 Perfect, from memory!' : (_mistakes! <= 1 ? '👍 Right, with one slip.' : 'Done, with $_mistakes slips. Try it again later.'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _mistakes! <= 1 ? quizGreen : scheme.error),
              ),
            ),
            FilledButton(onPressed: _next, child: Text(_i + 1 >= _chars.length ? 'FINISH' : 'NEXT')),
          ]),
        ),
    ]);
  }
}
