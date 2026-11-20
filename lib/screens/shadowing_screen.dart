import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/pitch.dart';
import '../logic/progress.dart';
import '../logic/recorder.dart';
import '../logic/settings.dart';
import '../logic/shadowing.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'speaking_screen.dart';

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

Map<String, VoiceLine>? _lines;

/// Xiaoxiao's pitch lines, loaded once (see tool/make_pitch.dart).
Future<Map<String, VoiceLine>> loadVoiceLines() async {
  if (_lines != null) return _lines!;
  try {
    final j = jsonDecode(await rootBundle.loadString('assets/voice/pitch.json')) as Map<String, dynamic>;
    _lines = {for (final e in j.entries) e.key: VoiceLine.fromJson(e.value as Map<String, dynamic>)};
  } catch (e) {
    debugPrint('No pitch lines: $e');
    _lines = {};
  }
  return _lines!;
}

/// Shadowing: pick a set of sentences to repeat after Xiaoxiao.
class ShadowingScreen extends StatelessWidget {
  final Progress progress;
  const ShadowingScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Shadowing 跟读')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(
              'Shadowing is how many interpreters train. Xiaoxiao says a sentence, and you say it straight after her, '
              'copying her rhythm and the rise and fall of her voice. Then you see your tone line next to hers.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text('Tip: use headphones, so the microphone only hears you.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            for (final (i, set) in ShadowSet.values.indexed)
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * i),
                child: PressBounce(
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                          [Icons.menu_book_outlined, Icons.forum_outlined, Icons.luggage_outlined][i],
                          color: scheme.primary),
                      title: Text(set.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(set.subtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ShadowRoundScreen(
                          progress: progress,
                          title: set.title,
                          items: shadowRound(set, done: progress.completed),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text('Shadowed so far: ${progress.count('shadowed')} sentences',
                textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

enum _Stage { ready, listening, recording, checking, done }

/// One round: for each sentence, listen, repeat, and compare.
class ShadowRoundScreen extends StatefulWidget {
  final Progress progress;
  final String title;
  final List<ShadowItem> items;
  const ShadowRoundScreen({super.key, required this.progress, required this.title, required this.items});

  @override
  State<ShadowRoundScreen> createState() => _ShadowRoundScreenState();
}

class _ShadowRoundScreenState extends State<ShadowRoundScreen> {
  final _rec = VoiceRecorder();
  final _focus = FocusNode();
  Map<String, VoiceLine> _her = const {};
  int _i = 0;
  _Stage _stage = _Stage.ready;
  SpeakCheck? _check;
  String? _problem;
  Timer? _autoStop;
  final _best = <int, int>{}; // best score for each sentence
  bool _finished = false;
  int _xp = 0;

  ShadowItem get _item => widget.items[_i];
  VoiceLine? get _line => _her[clipName(_item.hanzi)];

  @override
  void initState() {
    super.initState();
    loadVoiceLines().then((v) {
      if (mounted) setState(() => _her = v);
    });
  }

  @override
  void dispose() {
    _autoStop?.cancel();
    Speech.instance.stop();
    _rec.dispose();
    _focus.dispose();
    super.dispose();
  }

  Duration get _herLength => _line?.length ?? Duration(milliseconds: 400 + 330 * _item.syllables);

  Future<void> _go() async {
    if (_stage == _Stage.recording) return _stop();
    if (_stage != _Stage.ready && _stage != _Stage.done) return;
    setState(() {
      _stage = _Stage.listening;
      _check = null;
      _problem = null;
    });
    await Speech.instance.sayAndWait(_item.hanzi, _herLength);
    if (!mounted) return;
    final ok = await _rec.start();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _stage = _Stage.ready;
        _problem = kIsWeb
            ? 'No microphone, or the browser blocked it. Allow the microphone for this page and try again.'
            : 'No microphone found, or the app may not use it. Check your microphone and its privacy settings.';
      });
      return;
    }
    setState(() => _stage = _Stage.recording);
    // Give a little more time than Xiaoxiao took.
    _autoStop = Timer(_herLength * 1.4 + const Duration(milliseconds: 1000), _stop);
  }

  Future<void> _stop() async {
    _autoStop?.cancel();
    if (_stage != _Stage.recording) return;
    setState(() => _stage = _Stage.checking);
    final samples = await _rec.stop();
    final prefs = await SharedPreferences.getInstance();
    final check = checkRecording(samples, _item.pinyin, ref: prefs.getDouble('voicePitch'));
    var checked = 0, right = 0;
    for (var i = 0; i < check.heard.length; i++) {
      if (check.heard[i] == null) continue;
      checked++;
      if (check.syllableOk(i)) right++;
      await widget.progress.recordTone(check.expected[i], check.syllableOk(i));
    }
    if (check.problem == null) {
      final score = shadowScore(right, checked);
      _best[_i] = max(_best[_i] ?? 0, score);
    }
    if (!mounted) return;
    setState(() {
      _check = check;
      _problem = check.problem;
      _stage = _Stage.done;
    });
  }

  Future<void> _next() async {
    _autoStop?.cancel();
    if (_stage == _Stage.recording) await _rec.stop();
    await Speech.instance.stop();
    if (_i + 1 < widget.items.length) {
      setState(() {
        _i++;
        _stage = _Stage.ready;
        _check = null;
        _problem = null;
      });
      return;
    }
    final tried = _best.length;
    _xp = 5 + 2 * _best.values.where((s) => s >= 80).length;
    await widget.progress.bump('shadowed', tried);
    await widget.progress.addXp(_xp);
    if (mounted) setState(() => _finished = true);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.space) {
      _go();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter && _stage == _Stage.done) {
      _next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_finished) {
      final good = _best.values.where((s) => s >= 80).length;
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: RoundResults(
          title: 'Shadowing done!',
          right: good,
          total: widget.items.length,
          xp: _xp,
          note: 'Sentences with 80 or more for tones. Try the same set again tomorrow: shadowing works best little and often.',
          onAgain: () => Navigator.of(context).pop(),
        ),
      );
    }
    final item = _item;
    final check = _check;
    final score = check == null || check.problem != null
        ? null
        : shadowScore([for (var i = 0; i < check.heard.length; i++) if (check.heard[i] != null && check.syllableOk(i)) i].length,
            check.heard.where((h) => h != null).length);
    final chars = shadowChars(item.hanzi, item.pinyin);
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} · ${_i + 1} of ${widget.items.length}')),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              LinearProgressIndicator(value: (_i + (_stage == _Stage.done ? 1 : 0)) / widget.items.length),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Text(item.hanzi,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: switch (item.hanzi.characters.length) { <= 4 => 48, <= 9 => 36, _ => 28 })),
                    if (Settings.instance.showPinyin)
                      Text(item.pinyin, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: scheme.primary)),
                    Text(item.meaning, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: ShadowChart(
                        her: _line?.syllables ?? const [],
                        mine: check,
                        labels: chars,
                        herColor: scheme.outline,
                        ok: _green,
                        bad: _red,
                        grid: scheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(alignment: WrapAlignment.center, spacing: 16, children: [
                      _Legend(color: scheme.outline, text: 'Xiaoxiao'),
                      if (check != null && check.problem == null) const _Legend(color: _green, text: 'You (red: tone to work on)'),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _bigButton()),
              const SizedBox(height: 8),
              Text(
                switch (_stage) {
                  _Stage.ready => 'Press the button (or Space). Listen, then repeat straight away.',
                  _Stage.listening => 'Listen…',
                  _Stage.recording => 'Now you! Say it like Xiaoxiao.',
                  _Stage.checking => 'Checking your tones…',
                  _Stage.done => _problem ?? 'Tones: $score / 100. ${score! >= 80 ? 'Great shadowing!' : 'Listen to her line and try again.'}',
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _stage == _Stage.done ? FontWeight.bold : FontWeight.normal,
                  color: _stage == _Stage.done && _problem == null ? (score! >= 80 ? _green : _red) : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton.icon(
                  onPressed: _stage == _Stage.ready || _stage == _Stage.done ? () => Speech.instance.say(item.hanzi) : null,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Hear it again'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _stage == _Stage.listening || _stage == _Stage.checking ? null : _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_stage == _Stage.done ? 'Next (Enter)' : 'Skip'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _bigButton() {
    final recording = _stage == _Stage.recording;
    final busy = _stage == _Stage.listening || _stage == _Stage.checking;
    final button = ValueListenableBuilder<double>(
      valueListenable: _rec.level,
      builder: (context, lvl, child) =>
          AnimatedScale(scale: 1 + (recording ? lvl * 0.25 : 0), duration: const Duration(milliseconds: 90), child: child),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: recording ? _red : _green,
          minimumSize: const Size(240, 56),
        ),
        onPressed: busy ? null : _go,
        icon: Icon(recording ? Icons.stop_rounded : (_stage == _Stage.listening ? Icons.hearing : Icons.play_arrow)),
        label: Text(
          recording ? 'Stop' : (_stage == _Stage.done ? 'Try again' : 'Listen and repeat'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
    return recording ? PulseRing(color: _red, size: 64, child: button) : button;
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 18, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ]);
}

/// The characters to write under each syllable: no punctuation, and no 儿 that is only an "r".
List<String> shadowChars(String hanzi, String pinyin) {
  var chars = hanzi.characters.where((c) => RegExp(r'[一-鿿]').hasMatch(c)).toList();
  if (chars.length > tonesOf(pinyin).length) {
    chars = [for (final (j, c) in chars.indexed) if (c != '儿' || j == 0) c];
  }
  return chars;
}

/// Xiaoxiao's pitch line and yours, one column per syllable.
class ShadowChart extends StatelessWidget {
  final List<List<double>> her;
  final SpeakCheck? mine;
  final List<String> labels;
  final Color herColor, ok, bad, grid;
  const ShadowChart({
    super.key,
    required this.her,
    required this.mine,
    required this.labels,
    required this.herColor,
    required this.ok,
    required this.bad,
    required this.grid,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
        painter: _ShadowPainter(her, mine, labels, herColor, ok, bad, grid, Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class _ShadowPainter extends CustomPainter {
  final List<List<double>> her;
  final SpeakCheck? mine;
  final List<String> labels;
  final Color herColor, ok, bad, grid, text;
  _ShadowPainter(this.her, this.mine, this.labels, this.herColor, this.ok, this.bad, this.grid, this.text);

  static const _range = 9.0; // semitones above and below the usual pitch

  @override
  void paint(Canvas canvas, Size size) {
    final n = max(her.length, max(labels.length, mine?.expected.length ?? 0));
    if (n == 0) return;
    const labelH = 20.0;
    final h = size.height - labelH;
    const gap = 8.0;
    final w = (size.width - gap * (n - 1)) / n;
    double y(double st) => h / 2 - st.clamp(-_range, _range) / _range * (h / 2 - 6);
    canvas.drawLine(Offset(0, y(0)), Offset(size.width, y(0)), Paint()..color = grid);

    void line(List<double> st, double left, Paint paint) {
      if (st.length < 2) return;
      final path = Path();
      for (var k = 0; k < st.length; k++) {
        final p = Offset(left + k / (st.length - 1) * w, y(st[k]));
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < n; i++) {
      final left = i * (w + gap);
      if (i < her.length) {
        line(her[i], left, Paint()
          ..color = herColor.withValues(alpha: 0.55)
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
      }
      final m = mine;
      if (m != null && m.problem == null && i < m.contours.length) {
        final tone = i < m.expected.length ? m.expected[i] : 0;
        line(m.contours[i].semitones, left, Paint()
          ..color = tone == 0 ? grid : (m.syllableOk(i) ? ok : bad)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
      }
      if (i < labels.length) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: TextStyle(fontSize: 14, color: text)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(left + w / 2 - tp.width / 2, h + 2));
      }
    }
  }

  @override
  bool shouldRepaint(_ShadowPainter old) => old.her != her || old.mine != mine || old.labels != labels;
}
