import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/course.dart';
import '../logic/pinyin_input.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart' show SpeakButton;

/// Words for a typing round: learned words first (the trickiest ones more often),
/// or the first lessons' words for a beginner.
List<Word> typingWords(Progress progress, {int n = 10, Random? random}) {
  final r = random ?? Random();
  var pool = {for (final w in progress.learnedWords) w.hanzi: w}.values.toList();
  if (pool.length < n) {
    pool = [
      ...pool,
      for (final l in lessonsOf(1).where((l) => l.words.isNotEmpty).take(3))
        for (final w in l.words)
          if (!pool.any((p) => p.hanzi == w.hanzi)) w,
    ];
  }
  final trouble = {for (final (w, t) in progress.troubleWords) w.hanzi: t};
  pool.shuffle(r);
  pool.sort((a, b) => (trouble[b.hanzi] ?? 0).compareTo(trouble[a.hanzi] ?? 0));
  final tricky = pool.take(n ~/ 2).toList();
  final rest = pool.skip(n ~/ 2).toList()..shuffle(r);
  return ([...tricky, ...rest.take(n - tricky.length)]..shuffle(r));
}

/// Hear a word (or see it, without a Chinese voice) and type it in pinyin with tones.
class TypingScreen extends StatefulWidget {
  final Progress progress;
  final List<Word>? words;
  const TypingScreen({super.key, required this.progress, this.words});

  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  late List<Word> _words = widget.words ?? typingWords(widget.progress);
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _pageFocus = FocusNode(); // takes Enter once the answer is checked
  int _i = 0;
  TypedCheck? _check;
  int _right = 0;
  bool _done = false;
  int _xp = 0;
  bool _showHanzi = false;

  Word get _w => _words[_i];
  bool get _listening => Speech.instance.available.value;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    _play();
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _pageFocus.dispose();
    super.dispose();
  }

  void _play() {
    if (!_listening) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_done) Speech.instance.say(_w.hanzi);
    });
  }

  Future<void> _press() async {
    if (_check == null) {
      if (_input.text.trim().isEmpty) return;
      final c = checkTyped(_input.text, _w);
      setState(() {
        _check = c;
        if (c.ok) _right++;
      });
      _pageFocus.requestFocus();
      Speech.instance.say(_w.hanzi);
      await widget.progress.recordAnswer(_w.hanzi, c.ok);
      if (c.ok) await widget.progress.bump('typedRight');
      // When every syllable has a typed tone, remember how each tone went.
      if (c.lettersOk && c.typed.length == c.expected.length) {
        for (var i = 0; i < c.expected.length; i++) {
          await widget.progress.recordTone(c.expected[i], c.expected[i] == c.typed[i]);
        }
      }
      return;
    }
    if (_i + 1 >= _words.length) {
      _xp = 5 + _right;
      await widget.progress.addXp(_xp);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _i++;
      _check = null;
      _showHanzi = false;
      _input.clear();
    });
    _focus.requestFocus();
    _play();
  }

  void _again() {
    setState(() {
      _words = typingWords(widget.progress);
      _i = 0;
      _check = null;
      _right = 0;
      _done = false;
      _input.clear();
    });
    _play();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = _check;
    final preview = numberedToMarked(_input.text);
    return Focus(
      focusNode: _pageFocus,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent &&
            _check != null &&
            !_done &&
            (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          _press();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? 'Type the pinyin' : 'Type the pinyin · ${_i + 1} of ${_words.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Typing round done!',
                    right: _right,
                    total: _words.length,
                    xp: _xp,
                    note: 'Words you get wrong come back more often.',
                    onAgain: _again,
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Text(
                              _listening ? 'Type what you hear, with tones' : 'Type this word in pinyin, with tones',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            if (_listening) Center(child: SpeakButton(_w.hanzi, size: 88, filled: true)),
                            if (!_listening || _showHanzi || c != null)
                              Center(
                                child: PopIn(
                                  key: ValueKey('h$_i'),
                                  child: Column(
                                    children: [
                                      Text(_w.hanzi, style: const TextStyle(fontSize: 56)),
                                      if (c != null || !_listening)
                                        Text(_w.meaning, style: TextStyle(color: scheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: TextButton(
                                  onPressed: () => setState(() => _showHanzi = true),
                                  child: const Text('Show the characters'),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextField(
                              key: const ValueKey('pinyinInput'),
                              controller: _input,
                              focusNode: _focus,
                              autofocus: true,
                              enabled: c == null,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(fontSize: 22),
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'e.g. ni3hao3',
                                suffixIcon: _input.text.isEmpty
                                    ? null
                                    : Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Center(
                                          widthFactor: 1,
                                          child: Text(preview, style: TextStyle(fontSize: 20, color: scheme.primary)),
                                        ),
                                      ),
                              ),
                              onSubmitted: (_) => _press(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type a tone number after each syllable: ni3hao3 becomes nǐhǎo. Use v for ü (nv3 = nǚ). '
                              'Light tones need no number. Tone marks work too.',
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      QuizBottomBar(
                        checked: c != null,
                        right: c?.ok ?? false,
                        canPress: c != null || _input.text.trim().isNotEmpty,
                        correctAnswer: _w.pinyin,
                        explain: c == null
                            ? null
                            : c.ok
                            ? '${_w.hanzi} ${_w.pinyin}: ${_w.meaning}'
                            : c.lettersOk
                            ? 'The sounds are right. Check the tones: ${_toneHint(c)}.'
                            : 'You typed "${preview.isEmpty ? _input.text : preview}". The word means "${_w.meaning}".',
                        onPressed: _press,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _toneHint(TypedCheck c) => [for (final t in c.expected) t == 0 ? 'light' : '$t'].join(' + ');
}
