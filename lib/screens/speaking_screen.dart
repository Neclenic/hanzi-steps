import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/course.dart';
import '../logic/pitch.dart';
import '../logic/progress.dart';
import '../logic/recorder.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/tone_shape.dart';

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// Something to say: characters, pinyin and meaning.
class SpeakItem {
  final String hanzi;
  final String pinyin;
  final String meaning;
  const SpeakItem(this.hanzi, this.pinyin, this.meaning);
}

/// The result of checking one recording.
class SpeakCheck {
  final List<int> expected; // tone of each syllable as it should be said (0 = light tone)
  final List<ToneGuess?> heard; // null for light-tone syllables, which aren't checked
  final List<SyllableContour> contours;
  final String? problem; // set when the recording couldn't be checked
  const SpeakCheck(this.expected, this.heard, this.contours, {this.problem});

  bool syllableOk(int i) {
    final h = heard[i];
    if (h == null) return true;
    final want = expected[i];
    if (h.tone == want) return true;
    // A third tone before another syllable is usually only the low part ("half third tone").
    if (want == 3 && i < expected.length - 1 && contours.length > i) {
      final st = contours[i].semitones;
      final avg = st.reduce((a, b) => a + b) / st.length;
      if (avg < -1 || h.tone == 4) return true;
    }
    return false;
  }

  bool get ok => problem == null && [for (var i = 0; i < heard.length; i++) syllableOk(i)].every((x) => x);
}

/// Checks the tones in a recording of [pinyin]. [ref] is the speaker's usual pitch, if known.
SpeakCheck checkRecording(List<double> samples, String pinyin, {double? ref}) {
  final expected = spokenTones(tonesOf(pinyin));
  final points = trackPitch(samples);
  final voiced = points.where((p) => p.hz != null).length;
  if (voiced < 12) {
    return SpeakCheck(expected, const [], const [],
        problem: "I couldn't hear your voice. Speak a bit louder or move closer to the microphone.");
  }
  final reference = ref ?? medianPitch(points)!;
  final contours = splitSyllables(points, expected.length, reference);
  if (contours.length < expected.length) {
    return SpeakCheck(expected, const [], contours,
        problem: 'I heard ${contours.length} of ${expected.length} syllables. Try saying each one clearly.');
  }
  return SpeakCheck(
    expected,
    [for (var i = 0; i < expected.length; i++) expected[i] == 0 ? null : classifyTone(contours[i].semitones)],
    contours,
  );
}

/// Speaking practice: say a word, and the app checks your tones.
class SpeakingScreen extends StatefulWidget {
  final Progress progress;

  /// A fixed list to practise (for example the words of one tone pair). When it is
  /// set, the "Tones / My words" switch is hidden.
  final List<SpeakItem>? items;
  final String title;
  const SpeakingScreen({super.key, required this.progress, this.items, this.title = 'Speaking practice'});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  final _rec = VoiceRecorder();
  final _random = Random();
  bool _words = false; // false: single syllables (tones), true: words from your lessons
  late List<SpeakItem> _items = widget.items ?? _tonesList();
  int _i = 0;
  bool _recording = false;
  bool _busy = false;
  SpeakCheck? _check;
  String? _micProblem;
  Timer? _autoStop;
  int _rightInARow = 0;

  SpeakItem get _item => _items[_i];

  static List<SpeakItem> _tonesList() => [
        for (final l in allLessons.where((l) => l.kind == LessonKind.tones))
          for (final s in l.syllables)
            if (s.hanzi != null) SpeakItem(s.hanzi!, s.marked, s.meaning ?? ''),
      ];

  List<SpeakItem> _wordList() {
    var words = widget.progress.learnedWords;
    if (words.length < 4) words = lessonsOf(1).where((l) => l.words.isNotEmpty).first.words;
    final list = [
      for (final w in words)
        if (tonesOf(w.pinyin).any((t) => t != 0) && tonesOf(w.pinyin).length <= 3 && !w.pinyin.contains(' '))
          SpeakItem(w.hanzi, w.pinyin, w.meaning),
    ]..shuffle(_random);
    return list;
  }

  @override
  void dispose() {
    _autoStop?.cancel();
    _rec.dispose();
    super.dispose();
  }

  void _setMode(bool words) => setState(() {
        _words = words;
        _items = words ? _wordList() : _tonesList();
        _i = 0;
        _check = null;
      });

  void _next() => setState(() {
        _i = (_i + 1) % _items.length;
        _check = null;
      });

  Future<double?> _voiceRef() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble('voicePitch');
  }

  /// Learns the speaker's usual pitch over time, so "high" and "low" fit their voice.
  Future<void> _learnVoice(List<double> samples) async {
    final hz = medianPitch(trackPitch(samples));
    if (hz == null) return;
    final p = await SharedPreferences.getInstance();
    final old = p.getDouble('voicePitch');
    await p.setDouble('voicePitch', old == null ? hz : old * 0.8 + hz * 0.2);
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (_recording) {
      await _stop();
      return;
    }
    setState(() {
      _busy = true;
      _check = null;
      _micProblem = null;
    });
    final ok = await _rec.start();
    setState(() {
      _busy = false;
      _recording = ok;
      if (!ok) {
        _micProblem = kIsWeb
            ? 'No microphone, or the browser blocked it. Allow the microphone for this page and try again.'
            : 'No microphone found, or the app may not use it. Check your microphone and its privacy settings.';
      }
    });
    if (ok) {
      final syllables = max(1, tonesOf(_item.pinyin).length);
      _autoStop = Timer(Duration(milliseconds: 1400 + 700 * syllables), _stop);
    }
  }

  Future<void> _stop() async {
    _autoStop?.cancel();
    if (!_recording) return;
    setState(() {
      _recording = false;
      _busy = true;
    });
    final samples = await _rec.stop();
    final ref = await _voiceRef();
    final check = checkRecording(samples, _item.pinyin, ref: ref);
    if (check.problem == null) await _learnVoice(samples);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _check = check;
    });
    // Remember how each tone went, for the stats page.
    for (var i = 0; i < check.heard.length; i++) {
      if (check.heard[i] != null) await widget.progress.recordTone(check.expected[i], check.syllableOk(i));
    }
    if (check.ok) {
      _rightInARow++;
      await widget.progress.bump('speakRight');
      await widget.progress.addXp(2);
    } else {
      _rightInARow = 0;
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.space) {
      _toggle();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter && _check != null) {
      _next();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyR) {
      Speech.instance.say(_item.hanzi);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expected = spokenTones(tonesOf(_item.pinyin));
    final check = _check;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              if (widget.items == null) Center(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Tones'), icon: Icon(Icons.show_chart)),
                    ButtonSegment(value: true, label: Text('My words'), icon: Icon(Icons.translate)),
                  ],
                  selected: {_words},
                  onSelectionChanged: (v) => _setMode(v.first),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(a), child: c),
                ),
                child: Card(
                  key: ValueKey('${_words}_$_i'),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      // Smaller for whole sentences, so they fit on one or two lines.
                      Text(_item.hanzi,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: switch (_item.hanzi.characters.length) { <= 3 => 72, <= 6 => 56, _ => 40 })),
                      Text(_item.pinyin, style: TextStyle(fontSize: 28, color: scheme.primary, fontWeight: FontWeight.w600)),
                      Text(_item.meaning, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      Wrap(alignment: WrapAlignment.center, runSpacing: 6, children: [
                        for (final (i, t) in expected.indexed)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(children: [
                              t == 0
                                  ? SizedBox(
                                      width: 36 * 1.3,
                                      height: 36,
                                      child: Center(child: Icon(Icons.circle, size: 8, color: scheme.outline)))
                                  : ToneShape(tone: t, size: 36, color: _toneColor(check, i, scheme)),
                              Text(t == 0 ? 'light' : 'tone $t', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                            ]),
                          ),
                      ]),
                      if (expected.length > 1 && !listEquals(expected, tonesOf(_item.pinyin)))
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('Two third tones in a row: the first is said as a second tone.',
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: Speech.instance.available,
                        builder: (context, ok, _) => ok
                            ? TextButton.icon(
                                onPressed: () => Speech.instance.say(_item.hanzi),
                                icon: const Icon(Icons.volume_up),
                                label: const Text('Listen first (R)'),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _micButton(scheme)),
              const SizedBox(height: 8),
              Text(
                _recording
                    ? 'Listening… say "${_item.pinyin}" now'
                    : _busy
                        ? 'Checking…'
                        : 'Tap the microphone (or press Space) and say the word',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (_micProblem != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: scheme.errorContainer,
                  child: ListTile(leading: const Icon(Icons.mic_off), title: Text(_micProblem!)),
                ),
              ],
              if (check != null) ...[
                const SizedBox(height: 16),
                FadeSlideIn(child: _result(check, scheme)),
              ],
              const SizedBox(height: 24),
              Text(
                'How it works: the app follows how your voice rises and falls, which is what a tone is. '
                'It checks your tones, not the consonants and vowels, so it is a tone coach rather than a full '
                'pronunciation check. A quiet room helps.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Color _toneColor(SpeakCheck? c, int i, ColorScheme scheme) {
    if (c == null || c.problem != null || i >= c.heard.length) return scheme.primary;
    return c.syllableOk(i) ? _green : _red;
  }

  Widget _micButton(ColorScheme scheme) {
    final button = ValueListenableBuilder<double>(
      valueListenable: _rec.level,
      builder: (context, lvl, child) => AnimatedScale(
        scale: 1 + (_recording ? lvl * 0.25 : 0),
        duration: const Duration(milliseconds: 90),
        child: child,
      ),
      child: PressBounce(
        child: SizedBox(
          width: 88,
          height: 88,
          child: IconButton.filled(
            onPressed: _busy ? null : _toggle,
            iconSize: 44,
            style: IconButton.styleFrom(backgroundColor: _recording ? _red : const Color(0xFF3BB273)),
            icon: Icon(_recording ? Icons.stop_rounded : Icons.mic),
            tooltip: _recording ? 'Stop' : 'Record',
          ),
        ),
      ),
    );
    return _recording ? PulseRing(color: _red, size: 88, child: button) : SizedBox(height: 88 * 1.6, child: Center(child: button));
  }

  Widget _result(SpeakCheck c, ColorScheme scheme) {
    if (c.problem != null) {
      return Card(
        child: ListTile(leading: const Icon(Icons.hearing_disabled), title: Text(c.problem!)),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            PopIn(
              child: Icon(c.ok ? Icons.check_circle : Icons.refresh, color: c.ok ? _green : Colors.orange, size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                c.ok
                    ? (_rightInARow >= 3 ? 'Great tones! $_rightInARow in a row. +2 XP' : 'Great tones! +2 XP')
                    : 'Almost. Listen again and copy the shape.',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 140, child: PitchChart(check: c, colorOk: _green, colorBad: _red, grid: scheme.outlineVariant)),
          const SizedBox(height: 4),
          Text('Your voice (solid line) and the tone shape (dashed)',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (var i = 0; i < c.expected.length; i++)
            if (c.heard[i] != null)
              Text(
                c.syllableOk(i)
                    ? '${_syllable(i)}: tone ${c.expected[i]} ✓'
                    : '${_syllable(i)}: should be tone ${c.expected[i]} (${tones[c.expected[i] - 1].howTo.toLowerCase().replaceAll(RegExp(r'\.$'), '')}) '
                        'but your voice ${c.heard[i]!.why}.',
                style: TextStyle(color: c.syllableOk(i) ? _green : scheme.onSurface),
              ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: _toggle, child: const Text('TRY AGAIN')),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _green),
              onPressed: _next,
              child: const Text('NEXT WORD'),
            ),
          ]),
        ]),
      ),
    );
  }

  String _syllable(int i) {
    // One character per syllable: leave out punctuation, and the 儿 of 哪儿 or 一点儿, which is only an "r".
    var chars = _item.hanzi.characters.where((c) => !'，。？！、：；'.contains(c)).toList();
    if (chars.length > tonesOf(_item.pinyin).length) {
      chars = [for (final (j, c) in chars.indexed) if (c != '儿' || j == 0) c];
    }
    return i < chars.length ? chars[i] : 'Syllable ${i + 1}';
  }
}

/// Draws the pitch of each syllable, with the target tone shape behind it.
class PitchChart extends StatelessWidget {
  final SpeakCheck check;
  final Color colorOk, colorBad, grid;
  const PitchChart({super.key, required this.check, required this.colorOk, required this.colorBad, required this.grid});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          size: Size.infinite,
          painter: _PitchPainter(check, t, colorOk, colorBad, grid),
        ),
      );
}

class _PitchPainter extends CustomPainter {
  final SpeakCheck check;
  final double t; // how much of the line is drawn, for the animation
  final Color ok, bad, grid;
  _PitchPainter(this.check, this.t, this.ok, this.bad, this.grid);

  static const _range = 9.0; // semitones above and below the speaker's usual pitch

  @override
  void paint(Canvas canvas, Size size) {
    final n = check.expected.length;
    if (n == 0) return;
    final gap = 12.0;
    final w = (size.width - gap * (n - 1)) / n;
    double y(double st) => size.height / 2 - st.clamp(-_range, _range) / _range * (size.height / 2 - 6);
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, y(0)), Offset(size.width, y(0)), g);
    for (var i = 0; i < n; i++) {
      final left = i * (w + gap);
      final tone = check.expected[i];
      final good = check.syllableOk(i);
      // Target shape: tone levels 1–5 become semitones. It is moved up or down to sit
      // on your voice, because the shape matters, not how high your voice is.
      final mine = i < check.contours.length ? check.contours[i].semitones : const <double>[];
      if (tone > 0) {
        final c = tones[tone - 1].contour;
        double lvlAt(double x) {
          final pos = x * (c.length - 1);
          final a = c[pos.floor()], b = c[min(c.length - 1, pos.floor() + 1)];
          return (a + (b - a) * (pos - pos.floor()) - 3) * 2.6;
        }
        var shift = 0.0;
        if (mine.isNotEmpty) {
          final avgMine = mine.reduce((a, b) => a + b) / mine.length;
          final avgTarget = [for (var k = 0; k <= 20; k++) lvlAt(k / 20)].reduce((a, b) => a + b) / 21;
          shift = avgMine - avgTarget;
        }
        final path = Path();
        for (var k = 0; k <= 20; k++) {
          final x = k / 20;
          final p = Offset(left + x * w, y(lvlAt(x) + shift));
          k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        _dashed(canvas, path, Paint()
          ..color = (good ? ok : bad).withValues(alpha: 0.45)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
      }
      if (i >= check.contours.length) continue;
      final st = check.contours[i].semitones;
      if (st.length < 2) continue;
      final shown = max(2, (st.length * t).round());
      final path = Path();
      for (var k = 0; k < shown; k++) {
        final p = Offset(left + k / (st.length - 1) * w, y(st[k]));
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = tone == 0 ? grid : (good ? ok : bad)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, min(d + 6, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter old) => old.t != t || old.check != check;
}

/// A small "Say it" microphone for practising one line, e.g. in a dialogue.
/// Records, checks the tones, and shows a one-line result.
class SayItButton extends StatefulWidget {
  final String pinyin;
  final Progress progress;
  const SayItButton({super.key, required this.pinyin, required this.progress});

  @override
  State<SayItButton> createState() => _SayItButtonState();
}

class _SayItButtonState extends State<SayItButton> {
  final _rec = VoiceRecorder();
  bool _recording = false;
  bool _busy = false;
  String? _message;
  bool _ok = false;
  Timer? _autoStop;

  @override
  void dispose() {
    _autoStop?.cancel();
    _rec.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (_recording) return _stop();
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await _rec.start();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _recording = ok;
      if (!ok) _message = 'No microphone, or it is blocked.';
    });
    if (ok) {
      final syllables = max(1, tonesOf(widget.pinyin).length);
      _autoStop = Timer(Duration(milliseconds: 1400 + 450 * syllables), _stop);
    }
  }

  Future<void> _stop() async {
    _autoStop?.cancel();
    if (!_recording) return;
    setState(() {
      _recording = false;
      _busy = true;
    });
    final samples = await _rec.stop();
    final prefs = await SharedPreferences.getInstance();
    final check = checkRecording(samples, widget.pinyin, ref: prefs.getDouble('voicePitch'));
    var checked = 0, right = 0;
    for (var i = 0; i < check.heard.length; i++) {
      if (check.heard[i] == null) continue;
      checked++;
      if (check.syllableOk(i)) right++;
      await widget.progress.recordTone(check.expected[i], check.syllableOk(i));
    }
    if (check.ok) await widget.progress.bump('speakRight');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _ok = check.ok;
      _message = check.problem ?? (check.ok ? 'Great tones! $right of $checked right.' : 'Tones: $right of $checked right. Listen and try again.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        ValueListenableBuilder<double>(
          valueListenable: _rec.level,
          builder: (context, lvl, child) =>
              AnimatedScale(scale: 1 + (_recording ? lvl * 0.3 : 0), duration: const Duration(milliseconds: 90), child: child),
          child: IconButton.filled(
            onPressed: _busy ? null : _toggle,
            style: IconButton.styleFrom(backgroundColor: _recording ? _red : const Color(0xFF3BB273)),
            icon: Icon(_recording ? Icons.stop_rounded : Icons.mic),
            tooltip: _recording ? 'Stop' : 'Say it yourself',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _recording ? 'Listening… say it now' : _busy ? 'Checking…' : _message ?? 'Say it yourself (checks your tones)',
            style: TextStyle(color: _message != null && _ok ? _green : scheme.onSurfaceVariant),
          ),
        ),
      ]),
    );
  }
}
