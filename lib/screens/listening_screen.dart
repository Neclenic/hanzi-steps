import 'package:flutter/material.dart';

import '../data/listening.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import 'lesson_screen.dart' show SpeakButton;

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// Listening at real speed: the list of clips, easiest first.
class ListeningScreen extends StatelessWidget {
  final Progress progress;
  const ListeningScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levels = {for (final c in listenClips) c.level}.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Listening 听力')),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(
                'Real Chinese at real speed, like the listening part of the HSK exam. '
                'Play a clip (twice is fine, as in the exam), answer the questions, then read what was said.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              for (final level in levels) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text('HSK $level level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                for (final (i, clip) in listenClips.where((c) => c.level == level).indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: 40 * i),
                    child: PressBounce(
                      child: Card(
                        child: ListTile(
                          leading: Text(clip.scene, style: const TextStyle(fontSize: 30)),
                          title: Text(clip.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${clip.dialogue ? 'Conversation' : 'Talk'} · ${clip.questions.length} questions'),
                          trailing: progress.listenDone.contains(clip.id)
                              ? Text('${progress.listenBest(clip.id)} / ${clip.questions.length} ✓',
                                  style: const TextStyle(color: _green, fontWeight: FontWeight.bold))
                              : const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ListenClipScreen(progress: progress, clip: clip),
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

/// One clip: listen, answer, then see the words.
class ListenClipScreen extends StatefulWidget {
  final Progress progress;
  final ListenClip clip;
  const ListenClipScreen({super.key, required this.progress, required this.clip});

  @override
  State<ListenClipScreen> createState() => _ListenClipScreenState();
}

class _ListenClipScreenState extends State<ListenClipScreen> {
  late final List<int?> _picked = List.filled(widget.clip.questions.length, null);
  bool _checked = false;
  bool _slower = false;
  int _plays = 0;
  int _xp = 0;

  ListenClip get _clip => widget.clip;
  int get _right => [for (final (i, q) in _clip.questions.indexed) if (_picked[i] == q.correct) i].length;

  @override
  void dispose() {
    Speech.instance.stop();
    super.dispose();
  }

  void _play() {
    setState(() => _plays++);
    Speech.instance.playClip(_clip.audio, rate: _slower ? 0.8 : 1.0, fallback: _clip.text);
  }

  Future<void> _check() async {
    final right = _right;
    _xp = 3 + 2 * right;
    setState(() => _checked = true);
    await widget.progress.finishListening(_clip.id, right, _xp);
  }

  void _again() => setState(() {
        _checked = false;
        _plays = 0;
        _picked.fillRange(0, _picked.length, null);
      });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = _clip.questions.length;
    return Scaffold(
      appBar: AppBar(title: Text(_clip.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(_clip.scene, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 4),
                  Text(
                    _clip.dialogue ? 'A conversation between a woman and a man' : 'Someone talking about their life',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(220, 52)),
                    onPressed: _play,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_plays == 0 ? 'Play' : 'Play again',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                    FilterChip(
                      label: const Text('A bit slower'),
                      selected: _slower,
                      onSelected: (v) => setState(() => _slower = v),
                    ),
                    TextButton.icon(
                      onPressed: () => Speech.instance.stop(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ]),
                  if (_plays > 0)
                    Text('Played $_plays ${_plays == 1 ? 'time' : 'times'}',
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            for (final (i, q) in _clip.questions.indexed) _question(i, q, scheme),
            const SizedBox(height: 12),
            if (!_checked)
              Center(
                child: FilledButton(
                  onPressed: _picked.contains(null) ? null : _check,
                  child: const Text('Check answers'),
                ),
              )
            else ...[
              PopIn(
                child: Text(
                  '$_right / $total right · +$_xp XP',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _right == total ? _green : null),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _right == total
                    ? 'You understood it all at full speed!'
                    : 'Read what was said below, then play it again: it gets easier each time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Center(child: TextButton.icon(onPressed: _again, icon: const Icon(Icons.replay), label: const Text('Try again'))),
              const SizedBox(height: 8),
              const Text('What was said', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (final line in _clip.lines) _TranscriptLine(line: line, dialogue: _clip.dialogue),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _question(int i, ListenQuestion q, ColorScheme scheme) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('${i + 1}. ${q.zh}', style: const TextStyle(fontSize: 20))),
              SpeakButton(q.zh, size: 32),
            ]),
            Text(q.en, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (j, option) in q.options.indexed)
                ChoiceChip(
                  label: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${String.fromCharCode(65 + j)}  $option', style: const TextStyle(fontSize: 18)),
                    if (_checked) Text(q.optionsEn[j], style: const TextStyle(fontSize: 12)),
                  ]),
                  selected: _picked[i] == j,
                  selectedColor: _checked ? (j == q.correct ? _green : _red).withValues(alpha: 0.25) : null,
                  side: _checked && j == q.correct ? const BorderSide(color: _green, width: 2) : null,
                  onSelected: _checked ? null : (_) => setState(() => _picked[i] = j),
                ),
            ]),
          ]),
        ),
      );
}

class _TranscriptLine extends StatelessWidget {
  final ListenLine line;
  final bool dialogue;
  const _TranscriptLine({required this.line, required this.dialogue});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final woman = line.speaker == 'A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (dialogue)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: woman ? const Color(0xFFF8BBD0) : const Color(0xFFBBDEFB),
              child: Text(woman ? '女' : '男', style: const TextStyle(color: Colors.black87)),
            ),
          ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.zh, style: const TextStyle(fontSize: 20)),
            if (Settings.instance.showPinyin) Text(line.pinyin, style: TextStyle(color: scheme.primary)),
            Text(line.en, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ]),
        ),
        SpeakButton(line.zh, size: 32),
      ]),
    );
  }
}
