import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/strokes.dart';
import '../widgets/character_writer.dart';

/// Practise writing any character from the lessons you have finished.
class WritingScreen extends StatefulWidget {
  final Progress progress;
  const WritingScreen({super.key, required this.progress});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  List<(String, Word)> _chars = [];
  int? _current;
  bool _outline = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    StrokeLibrary.instance.load().then((_) {
      if (!mounted) return;
      // Characters from finished lessons; if none yet, the first lesson's as a taste.
      var words = widget.progress.learnedWords;
      if (words.isEmpty) words = allLessons.firstWhere((l) => l.words.isNotEmpty).words;
      final seen = <String>{};
      setState(() {
        _chars = [
          for (final w in words)
            for (final c in w.hanzi.split(''))
              if (StrokeLibrary.instance.has(c) && seen.add(c)) (c, w),
        ];
        _loaded = true;
      });
    });
  }

  void _open(int i) {
    setState(() => _current = i);
    Speech.instance.say(_chars[i].$1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cur = _current;
    return Scaffold(
      appBar: AppBar(
        title: Text(cur == null ? 'Writing practice' : 'Write ${_chars[cur].$1}'),
        leading: cur == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _current = null)),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : cur == null
              ? _grid(scheme)
              : _writer(cur, scheme),
    );
  }

  Widget _grid(ColorScheme scheme) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(
              widget.progress.learnedWords.isEmpty
                  ? 'Finish lessons to unlock their characters here. Here are the first ones to try.'
                  : 'Characters from the lessons you have finished. Pick one to write.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final (i, (c, w)) in _chars.indexed)
                Tooltip(
                  message: '${w.hanzi} · ${w.pinyin} · ${w.meaning}',
                  child: Material(
                    color: scheme.surface,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: scheme.outlineVariant, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _open(i),
                      child: SizedBox(width: 64, height: 64, child: Center(child: Text(c, style: const TextStyle(fontSize: 32)))),
                    ),
                  ),
                ),
            ]),
          ]),
        ),
      );

  Widget _writer(int i, ColorScheme scheme) {
    final (c, w) = _chars[i];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(children: [
          Text(w.hanzi.length > 1 ? '$c from ${w.hanzi}' : c, style: const TextStyle(fontSize: 20)),
          Text('${w.pinyin} · ${w.meaning}', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          CharacterWriter(key: ValueKey('$c-$_outline'), char: c, showOutline: _outline, watchFirst: _outline),
          const SizedBox(height: 8),
          SizedBox(
            width: 340,
            child: SwitchListTile(
              title: const Text('Show outline'),
              subtitle: const Text('Turn off to write from memory'),
              value: _outline,
              onChanged: (v) => setState(() => _outline = v),
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton.icon(
              onPressed: i > 0 ? () => _open(i - 1) : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: i + 1 < _chars.length ? () => _open(i + 1) : null,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
            ),
          ]),
        ]),
      ),
    );
  }
}
