import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';

/// Stroke-order data for one character.
///
/// Comes from the free "Make Me a Hanzi" / Hanzi Writer data (Arphic Public
/// License, see assets/strokes/ARPHICPL.TXT). Everything is in a 1024 × 1024
/// box with y pointing down, like the screen.
class CharStrokes {
  final String char;
  final List<Path> outlines; // the filled shape of each stroke, in writing order
  final List<List<Offset>> medians; // the centre line of each stroke, from start to end
  const CharStrokes(this.char, this.outlines, this.medians);

  int get count => outlines.length;
}

class StrokeLibrary {
  StrokeLibrary._();
  static final StrokeLibrary instance = StrokeLibrary._();

  Map<String, dynamic>? _raw;
  final Map<String, CharStrokes> _cache = {};

  Future<void> load() async {
    if (_raw != null) return;
    _raw = jsonDecode(await rootBundle.loadString('assets/strokes/strokes.json')) as Map<String, dynamic>;
  }

  /// For tests: load the data from a JSON string instead of the app bundle.
  void loadFromString(String json) => _raw = jsonDecode(json) as Map<String, dynamic>;

  bool has(String char) => _raw?.containsKey(char) ?? false;

  /// All characters we have data for.
  Iterable<String> get characters => _raw?.keys ?? const [];

  CharStrokes? get(String char) {
    final cached = _cache[char];
    if (cached != null) return cached;
    final d = _raw?[char];
    if (d == null) return null;
    final c = CharStrokes(
      char,
      [for (final s in (d['s'] as List)) parseSvgPath(s as String)],
      [
        for (final m in (d['m'] as List))
          [for (final p in (m as List)) _flip((p as List)[0].toDouble(), p[1].toDouble())],
      ],
    );
    return _cache[char] = c;
  }
}

// The data uses y pointing up with the baseline at 900; flip it to screen space.
Offset _flip(double x, double y) => Offset(x, 900 - y);

/// Reads the simple SVG paths in the data (M, L, Q, C and Z commands).
Path parseSvgPath(String d) {
  final tokens = RegExp(r'[MLQCZ]|-?\d+(?:\.\d+)?').allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  Offset next() {
    final p = _flip(double.parse(tokens[i]), double.parse(tokens[i + 1]));
    i += 2;
    return p;
  }

  while (i < tokens.length) {
    final cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        final p = next();
        path.moveTo(p.dx, p.dy);
      case 'L':
        final p = next();
        path.lineTo(p.dx, p.dy);
      case 'Q':
        final c = next(), p = next();
        path.quadraticBezierTo(c.dx, c.dy, p.dx, p.dy);
      case 'C':
        final c1 = next(), c2 = next(), p = next();
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);
      case 'Z':
        path.close();
    }
  }
  return path;
}

// ---------------- Checking a drawn stroke ----------------

double _length(List<Offset> pts) {
  var total = 0.0;
  for (var i = 1; i < pts.length; i++) {
    total += (pts[i] - pts[i - 1]).distance;
  }
  return total;
}

/// Spreads [n] points evenly along a line made of [pts].
List<Offset> resample(List<Offset> pts, int n) {
  if (pts.length < 2) return List.filled(n, pts.isEmpty ? Offset.zero : pts.first);
  final step = _length(pts) / (n - 1);
  if (step == 0) return List.filled(n, pts.first);
  final out = <Offset>[pts.first];
  var carried = 0.0;
  for (var i = 1; i < pts.length && out.length < n; i++) {
    var a = pts[i - 1];
    final b = pts[i];
    var seg = (b - a).distance;
    while (carried + seg >= step && out.length < n) {
      final t = (step - carried) / seg;
      a = Offset.lerp(a, b, t)!;
      out.add(a);
      seg = (b - a).distance;
      carried = 0;
    }
    carried += seg;
  }
  while (out.length < n) {
    out.add(pts.last);
  }
  return out;
}

/// Does a stroke the learner drew match the expected stroke?
///
/// Both are in the 1024 × 1024 box. It checks that the stroke starts and ends in the
/// right places, follows roughly the same path in the same direction, and is long enough.
/// It is deliberately forgiving, since people draw with a mouse.
bool strokeMatches(List<Offset> drawn, List<Offset> expected) {
  if (drawn.length < 2 || expected.length < 2) return false;
  final expLen = _length(expected);
  final drawnLen = _length(drawn);
  if (drawnLen < 30) return false; // just a click

  final isDot = expLen < 160;
  final startTol = isDot ? 220.0 : 200.0;
  final endTol = isDot ? 220.0 : 200.0;
  if ((drawn.first - expected.first).distance > startTol) return false;
  if ((drawn.last - expected.last).distance > endTol) return false;
  if (!isDot && drawnLen < expLen * 0.35) return false;
  if (drawnLen > expLen * 3 + 500) return false; // wild scribbles

  // Same overall direction.
  final dDir = drawn.last - drawn.first;
  final eDir = expected.last - expected.first;
  if (!isDot && dDir.distance > 0 && eDir.distance > 0) {
    final cos = (dDir.dx * eDir.dx + dDir.dy * eDir.dy) / (dDir.distance * eDir.distance);
    if (cos < 0.3) return false;
  }

  // Similar shape: compare evenly spaced points along both lines.
  const n = 24;
  final a = resample(drawn, n), b = resample(expected, n);
  var sum = 0.0;
  for (var i = 0; i < n; i++) {
    sum += (a[i] - b[i]).distance;
  }
  return sum / n < (isDot ? 200 : 140);
}

/// Which expected stroke is closest to what was drawn (used to say "that was stroke 3").
int closestStroke(List<Offset> drawn, List<List<Offset>> medians) {
  var best = 0;
  var bestScore = double.infinity;
  final a = resample(drawn, 16);
  for (var i = 0; i < medians.length; i++) {
    final b = resample(medians[i], 16);
    var s = 0.0;
    for (var k = 0; k < 16; k++) {
      s += (a[k] - b[k]).distance;
    }
    if (s < bestScore) {
      bestScore = s;
      best = i;
    }
  }
  return best;
}

/// A point partway (t from 0 to 1) along a line.
Offset pointAlong(List<Offset> pts, double t) {
  final total = _length(pts);
  var target = total * t.clamp(0, 1);
  for (var i = 1; i < pts.length; i++) {
    final seg = (pts[i] - pts[i - 1]).distance;
    if (target <= seg && seg > 0) return Offset.lerp(pts[i - 1], pts[i], target / seg)!;
    target -= seg;
  }
  return pts.last;
}

/// The first part (t from 0 to 1) of a line, as a list of points.
List<Offset> partOf(List<Offset> pts, double t) {
  if (t >= 1) return pts;
  final total = _length(pts);
  var target = total * max(0, t);
  final out = <Offset>[pts.first];
  for (var i = 1; i < pts.length; i++) {
    final seg = (pts[i] - pts[i - 1]).distance;
    if (target <= seg) {
      if (seg > 0) out.add(Offset.lerp(pts[i - 1], pts[i], target / seg)!);
      return out;
    }
    out.add(pts[i]);
    target -= seg;
  }
  return out;
}
