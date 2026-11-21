import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/topics.dart';
import '../logic/progress.dart';
import '../logic/recorder.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import 'lesson_screen.dart' show SpeakButton;

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// Speak on a topic: the list of topics, easiest first.
class TopicsScreen extends StatelessWidget {
  final Progress progress;
  const TopicsScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levels = {for (final t in speakTopics) t.level}.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Speak on a topic 说一说')),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(
                'Answer a question out loud for up to a minute, like the speaking part of the HSKK exam. '
                'Then listen to yourself, and to how Xiaoxiao answers it.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              for (final level in levels) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text('HSK $level level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                for (final (i, t) in speakTopics.where((t) => t.level == level).indexed)
                  FadeSlideIn(
                    delay: Duration(milliseconds: 40 * i),
                    child: PressBounce(
                      child: Card(
                        child: ListTile(
                          leading: Text(t.scene, style: const TextStyle(fontSize: 30)),
                          title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(t.question),
                          trailing: progress.count('topic_${t.id}') > 0
                              ? const Icon(Icons.check_circle, color: _green)
                              : const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TopicScreen(progress: progress, topic: t),
                          )),
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              Text('Topics answered so far: ${progress.count('topicsSpoken')}',
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The longest answer that is recorded.
const topicMaxSeconds = 60;

/// One topic: think, speak, then compare with the model answer.
class TopicScreen extends StatefulWidget {
  final Progress progress;
  final SpeakTopic topic;
  const TopicScreen({super.key, required this.progress, required this.topic});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final _rec = VoiceRecorder();
  bool _recording = false;
  bool _busy = false;
  String? _problem;
  int _elapsed = 0;
  Timer? _ticker;
  Uint8List? _answer;
  double _spoke = 0;
  bool _showModel = false;
  final Set<int> _checked = {};
  int _xp = 0;

  SpeakTopic get _t => widget.topic;

  @override
  void dispose() {
    _ticker?.cancel();
    Speech.instance.stop();
    _rec.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    if (_recording) return _stop();
    await Speech.instance.stop();
    setState(() {
      _busy = true;
      _problem = null;
    });
    final ok = await _rec.start();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _problem = kIsWeb
            ? 'No microphone, or the browser blocked it. Allow the microphone for this page and try again.'
            : 'No microphone found, or the app may not use it. Check your microphone and its privacy settings.';
      });
      return;
    }
    setState(() {
      _busy = false;
      _recording = true;
      _elapsed = 0;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= topicMaxSeconds) _stop();
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    if (!_recording) return;
    setState(() {
      _recording = false;
      _busy = true;
    });
    final samples = await _rec.stop();
    final spoke = spokenSeconds(samples);
    final first = _answer == null;
    if (spoke < 2) {
      setState(() {
        _busy = false;
        _problem = 'I could hardly hear you. Move closer to the microphone and try again.';
      });
      return;
    }
    if (first) {
      _xp = 5 + (spoke >= 30 ? 5 : 0);
      await widget.progress.bump('topicsSpoken');
      await widget.progress.bump('topic_${_t.id}');
      await widget.progress.bump('topicSeconds', spoke.round());
      await widget.progress.addXp(_xp);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _answer = toWav(samples);
      _spoke = spoke;
      if (spoke >= 30) _checked.add(0);
    });
  }

  String _clock(num s) => '${s ~/ 60}:${(s % 60).round().toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answer = _answer;
    return Scaffold(
      appBar: AppBar(title: Text(_t.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(_t.scene, style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Flexible(child: Text(_t.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26))),
                    SpeakButton(_t.question, size: 36),
                  ]),
                  if (Settings.instance.showPinyin)
                    Text(_t.questionPinyin, textAlign: TextAlign.center, style: TextStyle(color: scheme.primary)),
                  Text(_t.questionEn, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Useful words', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final w in _t.words)
                ActionChip(
                  label: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(w.zh, style: const TextStyle(fontSize: 18)),
                    Text('${w.pinyin} · ${w.en}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                  ]),
                  onPressed: () => Speech.instance.say(w.zh),
                ),
            ]),
            const SizedBox(height: 20),
            Center(child: _recordButton()),
            const SizedBox(height: 8),
            Text(
              _recording
                  ? 'Speak now… ${_clock(_elapsed)} of ${_clock(topicMaxSeconds)}. Press Stop when you have finished.'
                  : _busy
                      ? 'One moment…'
                      : _problem ??
                          (answer == null
                              ? 'Think for a moment, then press the button and answer in Chinese. Aim for 30 seconds or more.'
                              : 'You spoke for about ${_clock(_spoke)}.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: _problem != null ? _red : null, fontSize: 15),
            ),
            if (answer != null) ...[
              const SizedBox(height: 12),
              Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 8, children: [
                FilledButton.tonalIcon(
                  onPressed: () => Speech.instance.playBytes(answer),
                  icon: const Icon(Icons.person),
                  label: const Text('Play my answer'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() => _showModel = true);
                    Speech.instance.say(_t.model);
                  },
                  icon: const Icon(Icons.record_voice_over),
                  label: const Text("Play Xiaoxiao's answer"),
                ),
                TextButton(onPressed: () => Speech.instance.stop(), child: const Text('Stop')),
              ]),
              if (_xp > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: PopIn(
                    child: Text('+$_xp XP', textAlign: TextAlign.center, style: const TextStyle(color: _green, fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Check yourself', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final (i, c) in topicChecks.indexed)
                CheckboxListTile(
                  dense: true,
                  value: _checked.contains(i),
                  onChanged: (v) => setState(() => v == true ? _checked.add(i) : _checked.remove(i)),
                  title: Text(c),
                ),
            ],
            const SizedBox(height: 8),
            if (!_showModel)
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showModel = true),
                  icon: const Icon(Icons.visibility),
                  label: Text(answer == null ? 'Peek at a model answer' : 'Show the model answer'),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Expanded(child: Text('Model answer', style: TextStyle(fontWeight: FontWeight.bold))),
                      SpeakButton(_t.model, size: 32),
                    ]),
                    const SizedBox(height: 6),
                    Text(_t.model, style: const TextStyle(fontSize: 20, height: 1.5)),
                    if (Settings.instance.showPinyin) ...[
                      const SizedBox(height: 6),
                      Text(_t.modelPinyin, style: TextStyle(color: scheme.primary)),
                    ],
                    const SizedBox(height: 6),
                    Text(_t.modelEn, style: TextStyle(color: scheme.onSurfaceVariant)),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _recordButton() {
    final button = ValueListenableBuilder<double>(
      valueListenable: _rec.level,
      builder: (context, lvl, child) =>
          AnimatedScale(scale: 1 + (_recording ? lvl * 0.2 : 0), duration: const Duration(milliseconds: 90), child: child),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: _recording ? _red : _green, minimumSize: const Size(240, 56)),
        onPressed: _busy ? null : _start,
        icon: Icon(_recording ? Icons.stop_rounded : Icons.mic),
        label: Text(
          _recording ? 'Stop' : (_answer == null ? 'Start speaking' : 'Answer again'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
    return _recording ? PulseRing(color: _red, size: 64, child: button) : button;
  }
}
