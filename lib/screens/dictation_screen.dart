import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/course.dart';
import '../logic/pinyin_input.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart' show SpeakButton, WordTile;

/// A sentence for dictation, with the lesson it comes from (for extra word tiles).
typedef DictationItem = (Sentence, Lesson);

/// Sentences from finished lessons; a beginner gets the first lessons' sentences.
List<DictationItem> dictationSentences(Progress progress, {int n = 8, Random? random}) {
  final r = random ?? Random();
  final done = [
    for (final l in allLessons)
      if (progress.isDone(l))
        for (final s in l.sentences) (s, l),
  ];
  var pool = done;
  if (pool.length < n) {
    final early = [
      for (final l in lessonsOf(1))
        for (final s in l.sentences) (s, l),
    ];
    pool = [...done, ...early.where((e) => !done.any((d) => d.$1 == e.$1)).take(n * 2)];
  }
  // Recent lessons more often: half from the newest sentences, half from anywhere.
  final recent = pool.reversed.take(n * 2).toList()..shuffle(r);
  final picked = <DictationItem>[...recent.take(n ~/ 2)];
  final rest = pool.where((e) => !picked.contains(e)).toList()..shuffle(r);
  picked.addAll(rest.take(n - picked.length));
  return picked..shuffle(r);
}

enum DictationMode { tiles, pinyin }

/// Hear a sentence, then build it from word tiles or type it in pinyin.
class DictationScreen extends StatefulWidget {
  final Progress progress;
  final List<DictationItem>? items;
  const DictationScreen({super.key, required this.progress, this.items});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  late List<DictationItem> _items = widget.items ?? dictationSentences(widget.progress);
  late List<String> _bank = _makeBank();
  final List<int> _built = [];
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _pageFocus = FocusNode();
  DictationMode _mode = DictationMode.tiles;
  int _i = 0;
  bool _checked = false;
  bool _wasRight = false;
  bool _noTones = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;
  final _random = Random();

  Sentence get _s => _items[_i].$1;
  bool get _voice => Speech.instance.available.value;
  // Without a Chinese voice there is nothing to hear: read the pinyin and build with tiles.
  DictationMode get _activeMode => _voice ? _mode : DictationMode.tiles;

  List<String> _makeBank() {
    final (s, lesson) = _items[_i];
    final extras = lesson.words.map((w) => w.hanzi).where((h) => !s.tiles.contains(h)).toList()..shuffle(_random);
    return [...s.tiles, ...extras.take(2)]..shuffle(_random);
  }

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    _play();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _pageFocus.dispose();
    super.dispose();
  }

  void _play({bool slow = false}) {
    if (!_voice) return;
    final text = _s.hanzi;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_done) Speech.instance.say(text, slow: slow);
    });
  }

  bool get _canPress =>
      _checked || (_activeMode == DictationMode.tiles ? _built.isNotEmpty : _input.text.trim().isNotEmpty);

  Future<void> _press() async {
    if (!_canPress || _done) return;
    if (!_checked) {
      bool right;
      if (_activeMode == DictationMode.tiles) {
        right = [for (final i in _built) _bank[i]].join() == _s.hanzi;
        _noTones = false;
      } else {
        // Tones are optional here: right sounds count, and typed tones must be right.
        final c = checkTyped(_input.text, Word(_s.hanzi, _s.pinyin, _s.meaning));
        _noTones = typedTones(_input.text).every((t) => t == 0);
        right = c.lettersOk && (c.tonesOk || _noTones);
      }
      setState(() {
        _checked = true;
        _wasRight = right;
        if (right) _right++;
      });
      _pageFocus.requestFocus();
      Speech.instance.say(_s.hanzi);
      if (right) await widget.progress.bump('dictationRight');
      return;
    }
    if (_i + 1 >= _items.length) {
      _xp = 5 + 2 * _right;
      await widget.progress.addXp(_xp);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _i++;
      _checked = false;
      _built.clear();
      _input.clear();
      _bank = _makeBank();
    });
    if (_activeMode == DictationMode.pinyin) _inputFocus.requestFocus();
    _play();
  }

  void _again() {
    setState(() {
      _items = dictationSentences(widget.progress);
      _i = 0;
      _checked = false;
      _built.clear();
      _input.clear();
      _bank = _makeBank();
      _right = 0;
      _done = false;
    });
    _play();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent || _done) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _press();
      return KeyEventResult.handled;
    }
    if (_checked || _activeMode != DictationMode.tiles) return KeyEventResult.ignored;
    final n = int.tryParse(e.character ?? '');
    if (n != null && n >= 1 && n <= _bank.length && !_built.contains(n - 1)) {
      setState(() => _built.add(n - 1));
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace && _built.isNotEmpty) {
      setState(() => _built.removeLast());
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
    return Focus(
      focusNode: _pageFocus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? 'Dictation' : 'Dictation · ${_i + 1} of ${_items.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Dictation done!',
                    right: _right,
                    total: _items.length,
                    xp: _xp,
                    note: 'Sentences come from the lessons you have finished.',
                    onAgain: _again,
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(padding: const EdgeInsets.all(24), children: [
                        if (_voice)
                          Center(
                            child: SegmentedButton<DictationMode>(
                              segments: const [
                                ButtonSegment(value: DictationMode.tiles, icon: Icon(Icons.view_module_outlined), label: Text('Word tiles')),
                                ButtonSegment(value: DictationMode.pinyin, icon: Icon(Icons.keyboard_alt_outlined), label: Text('Type pinyin')),
                              ],
                              selected: {_mode},
                              onSelectionChanged: _checked
                                  ? null
                                  : (v) {
                                      setState(() => _mode = v.first);
                                      if (_mode == DictationMode.pinyin) _inputFocus.requestFocus();
                                    },
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          _voice
                              ? (_activeMode == DictationMode.tiles ? 'Listen, then build the sentence' : 'Listen, then type it in pinyin')
                              : 'Read the pinyin, then build the sentence',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (_voice)
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SpeakButton(_s.hanzi, size: 80, filled: true),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () => _play(slow: true),
                              icon: const Icon(Icons.slow_motion_video),
                              label: const Text('Slowly'),
                            ),
                          ])
                        else
                          Center(child: Text(_s.pinyin, style: TextStyle(fontSize: 24, color: scheme.primary))),
                        if (_checked) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: PopIn(
                              child: Column(children: [
                                Text(_s.hanzi, style: const TextStyle(fontSize: 30)),
                                Text(_s.pinyin, style: TextStyle(color: scheme.primary)),
                                Text(_s.meaning, style: TextStyle(color: scheme.onSurfaceVariant)),
                              ]),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (_activeMode == DictationMode.tiles) ..._tiles(scheme) else ..._typing(scheme),
                      ]),
                    ),
                    QuizBottomBar(
                      checked: _checked,
                      right: _wasRight,
                      canPress: _canPress,
                      correctAnswer: _activeMode == DictationMode.tiles ? _s.tiles.join(' ') : _s.pinyin,
                      explain: _checked && _wasRight && _noTones
                          ? 'All the sounds are right. Add tone numbers next time (wo3 = wǒ) to check your tones too.'
                          : null,
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _tiles(ColorScheme scheme) => [
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
            for (final i in _built)
              WordTile(text: _bank[i], onTap: _checked ? null : () => setState(() => _built.remove(i))),
          ]),
        ),
        const SizedBox(height: 24),
        Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
          for (final (i, t) in _bank.indexed)
            _built.contains(i)
                ? WordTile(text: t, ghost: true)
                : WordTile(text: t, number: i + 1, onTap: _checked ? null : () => setState(() => _built.add(i))),
        ]),
      ];

  List<Widget> _typing(ColorScheme scheme) {
    final preview = numberedToMarked(_input.text);
    return [
      TextField(
        key: const ValueKey('dictationInput'),
        controller: _input,
        focusNode: _inputFocus,
        autofocus: true,
        enabled: !_checked,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(fontSize: 22),
        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. wo3 xi3huan mao1'),
        onSubmitted: (_) => _press(),
      ),
      if (_input.text.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(preview, style: TextStyle(fontSize: 18, color: scheme.primary)),
      ],
      const SizedBox(height: 8),
      Text(
        'Spaces don\'t matter. Tone numbers are optional here, but if you type them they must be right.',
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
    ];
  }
}
