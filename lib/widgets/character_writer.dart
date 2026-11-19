import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../logic/strokes.dart';

/// A writing box for one character.
///
/// "Watch" animates the strokes in order. Then the learner draws each stroke with the
/// mouse, finger or pen. A correct stroke fills in; a wrong one flashes red. After two
/// misses on the same stroke the app shows where it starts and which way it goes.
class CharacterWriter extends StatefulWidget {
  final String char;
  final bool showOutline; // faint guide to trace over; off = write from memory
  final bool watchFirst; // play the stroke animation when it opens
  final double size;
  final void Function(int mistakes)? onComplete;
  const CharacterWriter({
    super.key,
    required this.char,
    this.showOutline = true,
    this.watchFirst = true,
    this.size = 300,
    this.onComplete,
  });

  @override
  State<CharacterWriter> createState() => CharacterWriterState();
}

class CharacterWriterState extends State<CharacterWriter> with TickerProviderStateMixin {
  CharStrokes? _data;
  int _done = 0; // strokes finished so far
  int _missesHere = 0; // misses on the current stroke
  int _mistakes = 0;
  List<Offset> _ink = [];
  bool _inkWrong = false;
  String? _message;

  late final AnimationController _watch = AnimationController(vsync: this);
  late final AnimationController _hint =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  bool _loaded = false;

  /// The hint only pulses while it is showing (a constantly running animation wastes power).
  void _updateHint() {
    final want = _missesHere >= 2 && !finished;
    if (want && !_hint.isAnimating) _hint.repeat(reverse: true);
    if (!want && _hint.isAnimating) _hint.stop();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _updateHint();
  }

  bool get finished => _data != null && _done >= _data!.count;
  bool get watching => _watch.isAnimating;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(CharacterWriter old) {
    super.didUpdateWidget(old);
    if (old.char != widget.char) _init();
  }

  Future<void> _init() async {
    await StrokeLibrary.instance.load();
    if (!mounted) return;
    setState(() {
      _data = StrokeLibrary.instance.get(widget.char);
      _loaded = true;
      _done = 0;
      _missesHere = 0;
      _mistakes = 0;
      _ink = [];
      _message = null;
    });
    if (widget.watchFirst) watch();
  }

  /// Play the stroke-order animation.
  void watch() {
    final d = _data;
    if (d == null) return;
    _watch.duration = Duration(milliseconds: 650 * d.count);
    _watch.forward(from: 0).then((_) {
      if (mounted) setState(() {});
    });
    setState(() => _message = null);
  }

  /// Start the character again.
  void restart() {
    _watch.stop();
    _watch.value = 0;
    setState(() {
      _done = 0;
      _missesHere = 0;
      _mistakes = 0;
      _ink = [];
      _message = null;
    });
  }

  Offset _toBox(Offset local) => local * (1024 / widget.size);

  void _panStart(DragStartDetails d) {
    if (finished || _data == null) return;
    _watch.stop();
    _watch.value = 0;
    setState(() {
      _ink = [_toBox(d.localPosition)];
      _inkWrong = false;
    });
  }

  void _panUpdate(DragUpdateDetails d) {
    if (finished || _data == null || _ink.isEmpty) return;
    setState(() => _ink = [..._ink, _toBox(d.localPosition)]);
  }

  void _panEnd(DragEndDetails _) {
    final data = _data;
    if (data == null || finished || _ink.isEmpty) return;
    final drawn = _ink;
    if (strokeMatches(drawn, data.medians[_done])) {
      setState(() {
        _done++;
        _missesHere = 0;
        _ink = [];
        _message = null;
      });
      if (finished) {
        setState(() => _message = _mistakes == 0 ? 'Perfect!' : 'Done!');
        widget.onComplete?.call(_mistakes);
      }
    } else {
      final guess = closestStroke(drawn, data.medians);
      setState(() {
        _mistakes++;
        _missesHere++;
        _inkWrong = true;
        _message = _missesHere >= 2
            ? 'Follow the highlighted stroke, starting at the dot.'
            : guess > _done
                ? 'That looks like a later stroke. Stroke ${_done + 1} comes first.'
                : 'Not quite. Try stroke ${_done + 1} again.';
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _inkWrong) setState(() => _ink = []);
      });
    }
  }

  @override
  void dispose() {
    _watch.dispose();
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = _data;
    if (data == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: _loaded ? Text('No stroke data for ${widget.char}') : const CircularProgressIndicator(),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: finished ? const Color(0xFF2E9E5B) : scheme.outlineVariant, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          // Start the stroke where the finger/mouse went down, not after it has moved a bit.
          dragStartBehavior: DragStartBehavior.down,
          onPanStart: _panStart,
          onPanUpdate: _panUpdate,
          onPanEnd: _panEnd,
          child: AnimatedBuilder(
            animation: Listenable.merge([_watch, _hint]),
            builder: (context, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: _WriterPainter(
                data: data,
                done: _done,
                ink: _ink,
                inkWrong: _inkWrong,
                showOutline: widget.showOutline,
                hint: _missesHere >= 2 && !finished ? _hint.value : null,
                watch: _watch.isAnimating ? _watch.value : null,
                inkColor: finished ? const Color(0xFF2E9E5B) : scheme.onSurface,
                guideColor: scheme.outlineVariant,
                hintColor: Colors.amber.shade700,
                gridColor: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 22,
        child: Text(
          _message ?? (finished ? '' : 'Stroke ${_done + 1} of ${data.count}'),
          style: TextStyle(
            color: _message == null
                ? scheme.onSurfaceVariant
                : finished
                    ? const Color(0xFF2E9E5B)
                    : const Color(0xFFD7263D),
            fontWeight: _message == null ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ),
      Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton.icon(onPressed: watch, icon: const Icon(Icons.play_arrow), label: const Text('Watch')),
        const SizedBox(width: 8),
        TextButton.icon(onPressed: restart, icon: const Icon(Icons.refresh), label: const Text('Start again')),
      ]),
    ]);
  }
}

class _WriterPainter extends CustomPainter {
  final CharStrokes data;
  final int done;
  final List<Offset> ink;
  final bool inkWrong;
  final bool showOutline;
  final double? hint; // 0..1 pulse, or null for no hint
  final double? watch; // 0..1 through the whole animation, or null
  final Color inkColor, guideColor, hintColor, gridColor;

  _WriterPainter({
    required this.data,
    required this.done,
    required this.ink,
    required this.inkWrong,
    required this.showOutline,
    required this.hint,
    required this.watch,
    required this.inkColor,
    required this.guideColor,
    required this.hintColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The practice grid (a cross through the middle, like Chinese exercise books).
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    _dashed(canvas, Offset(size.width / 2, 0), Offset(size.width / 2, size.height), grid);
    _dashed(canvas, Offset(0, size.height / 2), Offset(size.width, size.height / 2), grid);

    canvas.save();
    canvas.scale(size.width / 1024);

    final fill = Paint()..color = inkColor;
    final guide = Paint()..color = guideColor.withValues(alpha: 0.55);

    final w = watch;
    if (w != null) {
      // Animation: strokes appear one after another, drawn along their centre line.
      final pos = w * data.count;
      for (var i = 0; i < data.count; i++) {
        canvas.drawPath(data.outlines[i], guide);
      }
      for (var i = 0; i < data.count; i++) {
        final t = (pos - i).clamp(0.0, 1.0);
        if (t <= 0) break;
        if (t >= 1) {
          canvas.drawPath(data.outlines[i], fill);
        } else {
          _revealStroke(canvas, i, t, fill.color);
        }
      }
      canvas.restore();
      return;
    }

    for (var i = 0; i < data.count; i++) {
      if (i < done) {
        canvas.drawPath(data.outlines[i], fill);
      } else if (showOutline) {
        canvas.drawPath(data.outlines[i], guide);
      }
    }

    final h = hint;
    if (h != null && done < data.count) {
      canvas.drawPath(data.outlines[done], Paint()..color = hintColor.withValues(alpha: 0.25 + 0.45 * h));
      final m = data.medians[done];
      canvas.drawCircle(m.first, 34, Paint()..color = hintColor);
      // An arrow head part-way along shows the direction.
      final a = pointAlong(m, 0.55), b = pointAlong(m, 0.7);
      final dir = b - a;
      if (dir.distance > 0) {
        final u = dir / dir.distance;
        final n = Offset(-u.dy, u.dx);
        final tip = b + u * 20;
        final arrow = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo((b - u * 40 + n * 34).dx, (b - u * 40 + n * 34).dy)
          ..lineTo((b - u * 40 - n * 34).dx, (b - u * 40 - n * 34).dy)
          ..close();
        canvas.drawPath(arrow, Paint()..color = hintColor);
      }
    }

    if (ink.length > 1) {
      final p = Path()..moveTo(ink.first.dx, ink.first.dy);
      for (final o in ink.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = inkWrong ? const Color(0xFFD7263D) : inkColor.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 48
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
    canvas.restore();
  }

  void _revealStroke(Canvas canvas, int i, double t, Color color) {
    final part = partOf(data.medians[i], t);
    if (part.length < 2) return;
    final p = Path()..moveTo(part.first.dx, part.first.dy);
    for (final o in part.skip(1)) {
      p.lineTo(o.dx, o.dy);
    }
    canvas.save();
    canvas.clipPath(data.outlines[i]);
    canvas.drawPath(
        p,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 180
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint p) {
    const dash = 6.0, gap = 6.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    for (var d = 0.0; d < total; d += dash + gap) {
      canvas.drawLine(a + dir * d, a + dir * (d + dash).clamp(0, total), p);
    }
  }

  @override
  bool shouldRepaint(covariant _WriterPainter old) => true;
}
