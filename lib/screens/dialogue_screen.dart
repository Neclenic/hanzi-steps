import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/course.dart';
import '../data/dialogues.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../logic/word_lookup.dart';
import '../widgets/anim.dart';
import '../widgets/word_sheet.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart' show SpeakButton;
import 'speaking_screen.dart' show SayItButton;

/// The HSK level a dialogue needs: the highest level of its words.
int dialogueLevel(Dialogue d) {
  var level = 1;
  for (final l in d.lines) {
    for (final t in l.zh.split(' ')) {
      level = max(level, levelOfWord(t) ?? 1);
    }
  }
  return level;
}

/// The list of conversations, grouped by HSK level.
class DialoguesScreen extends StatelessWidget {
  final Progress progress;
  const DialoguesScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Dialogues')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text('Short everyday conversations. Listen to the other person, then pick the right reply, '
                  'and say it yourself if you like.',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              for (final level in levels) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Text('HSK $level', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                for (final (i, d) in dialogues.where((d) => dialogueLevel(d) == level).indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: 50 * i),
                    child: PressBounce(
                      child: Card(
                        child: ListTile(
                          leading: Text(d.scene, style: const TextStyle(fontSize: 32)),
                          title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('With ${d.other}'),
                          trailing: progress.dialoguesDone.contains(d.id)
                              ? const Icon(Icons.check_circle, color: quizGreen)
                              : const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DialogueScreen(dialogue: d, progress: progress),
                          )),
                        ),
                      ),
                    ),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Plays one conversation: the other person's lines appear and are read aloud,
/// and on your turn you choose what to say.
class DialogueScreen extends StatefulWidget {
  final Dialogue dialogue;
  final Progress progress;
  const DialogueScreen({super.key, required this.dialogue, required this.progress});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final _random = Random();
  final _scroll = ScrollController();
  bool _started = false;
  int _shown = 0; // how many lines are in the chat so far
  List<(String, String)> _options = const [];
  int? _wrongPick;
  int _mistakes = 0; // wrong picks this line
  int _firstTry = 0;
  bool _answered = false; // your line has been picked correctly, waiting for Continue
  bool _english = false;
  bool _finished = false;
  int _xp = 0;

  List<DialogueLine> get _lines => widget.dialogue.lines;
  int get _yourLines => _lines.where((l) => l.isYours).length;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _started = true);
    _advance();
  }

  /// Shows the next line. The other person's lines are shown one after another;
  /// on your line, the choices appear.
  Future<void> _advance() async {
    while (_shown < _lines.length && !_lines[_shown].isYours) {
      final line = _lines[_shown];
      setState(() => _shown++);
      _scrollDown();
      Speech.instance.say(line.hanzi);
      // Give time to hear the line before the next one appears.
      await Future<void>.delayed(Duration(milliseconds: Speech.instance.available.value ? 600 + 180 * line.hanzi.length : 500));
      if (!mounted) return;
    }
    if (_shown >= _lines.length) {
      await _finish();
      return;
    }
    final line = _lines[_shown];
    final opts = [(line.zh, line.pinyin), ...line.wrong]..shuffle(_random);
    setState(() {
      _options = opts;
      _wrongPick = null;
      _mistakes = 0;
      _answered = false;
    });
    _scrollDown();
  }

  void _pick(int i) {
    if (_answered || _finished || i >= _options.length) return;
    final line = _lines[_shown];
    if (_options[i].$1 == line.zh) {
      if (_mistakes == 0) _firstTry++;
      setState(() {
        _answered = true;
        _shown++;
      });
      Speech.instance.say(line.hanzi);
      _scrollDown();
    } else {
      setState(() {
        _wrongPick = i;
        _mistakes++;
      });
    }
  }

  void _continue() {
    setState(() {
      _answered = false;
      _options = const [];
    });
    _advance();
  }

  Future<void> _finish() async {
    _xp = 5 + 2 * _firstTry;
    await widget.progress.finishDialogue(widget.dialogue.id, _xp);
    if (mounted) setState(() => _finished = true);
  }

  void _restart() {
    setState(() {
      _shown = 0;
      _firstTry = 0;
      _finished = false;
      _options = const [];
      _answered = false;
    });
    _start();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final d = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3].indexOf(k);
    if (d >= 0) {
      _pick(d);
      return KeyEventResult.handled;
    }
    if ((k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter)) {
      if (!_started) {
        _start();
      } else if (_answered) {
        _continue();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dialogue;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(d.title),
          actions: [
            if (_started && !_finished)
              TextButton.icon(
                onPressed: () => setState(() => _english = !_english),
                icon: Icon(_english ? Icons.visibility_off : Icons.translate),
                label: Text(_english ? 'Hide English' : 'English'),
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _finished
                ? RoundResults(
                    title: 'Conversation done!',
                    right: _firstTry,
                    total: _yourLines,
                    xp: _xp,
                    note: 'Replies you picked right the first time.',
                    onAgain: _restart,
                  )
                : !_started
                    ? _intro(d)
                    : Column(children: [
                        Expanded(
                          child: ListView(controller: _scroll, padding: const EdgeInsets.all(16), children: [
                            for (var i = 0; i < _shown; i++) _bubble(_lines[i], i),
                          ]),
                        ),
                        _bottom(),
                      ]),
          ),
        ),
      ),
    );
  }

  Widget _intro(Dialogue d) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        PopIn(child: Text(d.scene, style: const TextStyle(fontSize: 80))),
        const SizedBox(height: 12),
        Text(d.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text('HSK ${dialogueLevel(d)} · with ${d.other}', style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        Card(
          child: ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('Your part'), subtitle: Text(d.goal)),
        ),
        const SizedBox(height: 8),
        Text('Tip: tap any word in the conversation to see what it means, or to save it to My words.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        SizedBox(
          width: 240,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: quizGreen),
            onPressed: _start,
            child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _bubble(DialogueLine line, int i) {
    final scheme = Theme.of(context).colorScheme;
    final mine = line.isYours;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? quizGreen.withValues(alpha: 0.15) : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          // Tap a word to see what it means and save it to My words.
          Flexible(
            child: Wrap(children: [
              for (final t in line.zh.split(' '))
                if (lookupWord(t) case final w?)
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => showWordSheet(context, widget.progress, w),
                    child: Text(t, style: const TextStyle(fontSize: 22)),
                  )
                else
                  Text(t, style: const TextStyle(fontSize: 22)),
            ]),
          ),
          SpeakButton(line.hanzi, size: 32),
        ]),
        if (Settings.instance.showPinyin) Text(line.pinyin, style: TextStyle(color: scheme.primary)),
        if (_english) Text(line.en, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      ]),
    );
    return FadeSlideIn(
      key: ValueKey('line$i'),
      from: Offset(mine ? 0.2 : -0.2, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!mine) ...[Text(widget.dialogue.scene, style: const TextStyle(fontSize: 26)), const SizedBox(width: 8)],
            Flexible(child: bubble),
            if (mine) ...[const SizedBox(width: 8), const Text('🙂', style: TextStyle(fontSize: 26))],
          ],
        ),
      ),
    );
  }

  Widget _bottom() {
    final scheme = Theme.of(context).colorScheme;
    if (_answered) {
      final line = _lines[_shown - 1];
      return Container(
        color: quizGreen.withValues(alpha: 0.12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Icon(Icons.check_circle, color: quizGreen),
            const SizedBox(width: 8),
            Expanded(child: Text('"${line.en}"', style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
          SayItButton(key: ValueKey('say$_shown'), pinyin: line.pinyin, progress: widget.progress),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: quizGreen),
              onPressed: _continue,
              child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      );
    }
    if (_options.isEmpty) return const SizedBox(height: 16);
    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(_wrongPick == null ? 'Your turn. What do you say?' : "That doesn't fit. Try another one.",
            style: TextStyle(fontWeight: FontWeight.bold, color: _wrongPick == null ? null : quizRed)),
        const SizedBox(height: 8),
        for (final (i, o) in _options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnswerTile(
              key: ValueKey('opt$_shown-$i'),
              number: i + 1,
              selected: _wrongPick == i,
              checked: _wrongPick == i,
              isCorrect: false,
              onTap: () => _pick(i),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.$1.replaceAll(' ', ''), style: const TextStyle(fontSize: 19)),
                if (Settings.instance.showPinyin) Text(o.$2, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
      ]),
    );
  }
}
