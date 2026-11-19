import 'dart:math';
import 'dart:typed_data';

/// Pitch tracking and tone checking for speaking practice.
///
/// This listens to *how your voice goes up and down*, which is what makes a
/// Mandarin tone. It doesn't check the consonants and vowels (so it can't
/// tell 妈 mā from 八 bā), only the tones.

const sampleRate = 16000;
const _frame = 640; // 40 ms window
const _hop = 160; // a pitch reading every 10 ms
const minHz = 70.0;
const maxHz = 500.0;

/// One pitch reading. [hz] is null when the sound isn't voiced (silence, "s", "sh"…).
class PitchPoint {
  final double time; // seconds
  final double? hz;
  final double energy; // loudness, 0 to 1
  const PitchPoint(this.time, this.hz, this.energy);
}

/// Turns raw 16-bit little-endian PCM bytes into samples from -1 to 1.
Float64List pcm16ToSamples(Uint8List bytes) {
  final n = bytes.length ~/ 2;
  final out = Float64List(n);
  final data = ByteData.sublistView(bytes);
  for (var i = 0; i < n; i++) {
    out[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return out;
}

/// Finds the pitch every 10 ms with the YIN method.
List<PitchPoint> trackPitch(List<double> samples, {int rate = sampleRate}) {
  final points = <PitchPoint>[];
  final minLag = (rate / maxHz).floor();
  final maxLag = (rate / minHz).ceil();
  final window = max(_frame, maxLag * 2);
  if (samples.length < window) return points;
  // Loudness relative to the loudest part, so quiet microphones still work.
  final energies = <double>[];
  for (var start = 0; start + window <= samples.length; start += _hop) {
    var e = 0.0;
    for (var i = start; i < start + window; i++) {
      e += samples[i] * samples[i];
    }
    energies.add(sqrt(e / window));
  }
  final loudest = energies.fold<double>(0, max);
  final d = Float64List(maxLag + 2);
  var f = 0;
  for (var start = 0; start + window <= samples.length; start += _hop, f++) {
    final energy = loudest == 0 ? 0.0 : energies[f] / loudest;
    final t = (start + window / 2) / rate;
    if (energy < 0.12 || energies[f] < 0.004) {
      points.add(PitchPoint(t, null, energy));
      continue;
    }
    // Difference function and its cumulative mean normalised form.
    final w = window - maxLag;
    for (var lag = 1; lag <= maxLag; lag++) {
      var sum = 0.0;
      for (var i = 0; i < w; i++) {
        final diff = samples[start + i] - samples[start + i + lag];
        sum += diff * diff;
      }
      d[lag] = sum;
    }
    var running = 0.0;
    d[0] = 1;
    for (var lag = 1; lag <= maxLag; lag++) {
      running += d[lag];
      d[lag] = running == 0 ? 1 : d[lag] * lag / running;
    }
    int? best;
    for (var lag = minLag; lag <= maxLag; lag++) {
      if (d[lag] < 0.15) {
        while (lag + 1 <= maxLag && d[lag + 1] < d[lag]) {
          lag++;
        }
        best = lag;
        break;
      }
    }
    if (best == null) {
      // No clear dip: take the deepest one if it is still quite clear.
      var lag = minLag;
      for (var l = minLag; l <= maxLag; l++) {
        if (d[l] < d[lag]) lag = l;
      }
      if (d[lag] < 0.35) best = lag;
    }
    if (best == null) {
      points.add(PitchPoint(t, null, energy));
      continue;
    }
    // Parabolic interpolation for a finer reading.
    var lag = best.toDouble();
    if (best > 1 && best < maxLag) {
      final a = d[best - 1], b = d[best], c = d[best + 1];
      final den = a - 2 * b + c;
      if (den.abs() > 1e-12) lag = best + 0.5 * (a - c) / den;
    }
    points.add(PitchPoint(t, rate / lag, energy));
  }
  return _cleanUp(points);
}

/// Removes single-frame glitches and octave jumps.
List<PitchPoint> _cleanUp(List<PitchPoint> p) {
  final out = [...p];
  for (var i = 0; i < p.length; i++) {
    final hz = p[i].hz;
    if (hz == null) continue;
    // Median of the neighbours.
    final near = [for (var j = max(0, i - 3); j <= min(p.length - 1, i + 3); j++) ?p[j].hz]..sort();
    if (near.length < 3) {
      out[i] = PitchPoint(p[i].time, null, p[i].energy);
      continue;
    }
    final med = near[near.length ~/ 2];
    var v = hz;
    if (v > med * 1.7) v /= 2; // octave too high
    if (v < med / 1.7) v *= 2; // octave too low
    if ((12 * log(v / med) / ln2).abs() > 4) v = med; // a glitch
    out[i] = PitchPoint(p[i].time, v, p[i].energy);
  }
  return out;
}

/// A stretch of voice that should be one syllable, as semitones over time.
class SyllableContour {
  final List<double> times;
  final List<double> semitones; // relative to the speaker's usual pitch
  const SyllableContour(this.times, this.semitones);
}

/// Semitones between two frequencies.
double semitonesBetween(double hz, double ref) => 12 * log(hz / ref) / ln2;

/// Median of the voiced pitch readings, used as the speaker's reference pitch.
double? medianPitch(List<PitchPoint> p) {
  final v = [for (final x in p) ?x.hz]..sort();
  if (v.isEmpty) return null;
  return v[v.length ~/ 2];
}

/// Splits the voiced parts of a recording into [count] syllables.
List<SyllableContour> splitSyllables(List<PitchPoint> p, int count, double ref) {
  // Voiced runs, allowing short gaps (a consonant like "x" or "sh").
  final runs = <List<PitchPoint>>[];
  var cur = <PitchPoint>[];
  var gap = 0;
  for (final x in p) {
    if (x.hz != null) {
      if (gap > 0 && gap <= 2 && cur.isNotEmpty) {
        // tiny drop-out inside a vowel: keep going
      } else if (gap > 2 && cur.isNotEmpty) {
        runs.add(cur);
        cur = [];
      }
      cur.add(x);
      gap = 0;
    } else {
      gap++;
    }
  }
  if (cur.isNotEmpty) runs.add(cur);
  // Ignore very short bits (clicks, breaths): under 60 ms.
  runs.removeWhere((r) => r.length < 6);
  if (runs.isEmpty || count <= 0) return [];

  List<List<PitchPoint>> parts;
  if (runs.length == count) {
    parts = runs;
  } else if (runs.length > count) {
    // Too many pieces: join the ones with the smallest gaps between them.
    parts = [...runs];
    while (parts.length > count) {
      var best = 0;
      var bestGap = double.infinity;
      for (var i = 0; i < parts.length - 1; i++) {
        final g = parts[i + 1].first.time - parts[i].last.time;
        if (g < bestGap) {
          bestGap = g;
          best = i;
        }
      }
      parts[best] = [...parts[best], ...parts[best + 1]];
      parts.removeAt(best + 1);
    }
  } else {
    // Too few pieces (syllables run together): split the voiced time evenly,
    // cutting at the quietest moments near each even split.
    final voiced = [for (final r in runs) ...r];
    parts = [];
    final per = voiced.length / count;
    var start = 0;
    for (var k = 1; k <= count; k++) {
      var end = k == count ? voiced.length : (per * k).round();
      if (k < count) {
        final lo = max(start + 3, end - (per * 0.25).round()), hi = min(voiced.length - 3, end + (per * 0.25).round());
        var q = end;
        for (var i = lo; i < hi; i++) {
          if (voiced[i].energy < voiced[q].energy) q = i;
        }
        end = q;
      }
      if (end > start) parts.add(voiced.sublist(start, end));
      start = end;
    }
  }
  return [
    for (final r in parts)
      SyllableContour([for (final x in r) x.time], _smooth([for (final x in r) semitonesBetween(x.hz!, ref)])),
  ];
}

List<double> _smooth(List<double> v) {
  if (v.length < 5) return v;
  return [
    for (var i = 0; i < v.length; i++)
      () {
        final w = [for (var j = max(0, i - 2); j <= min(v.length - 1, i + 2); j++) v[j]];
        return w.reduce((a, b) => a + b) / w.length;
      }(),
  ];
}

/// What the app heard for one syllable.
class ToneGuess {
  final int tone; // 1–4
  final String why; // a short description, e.g. "rose by 4 semitones"
  const ToneGuess(this.tone, this.why);
}

/// Guesses which tone a syllable was said with, from the shape of its pitch.
/// [st] is in semitones relative to the speaker's usual pitch.
ToneGuess classifyTone(List<double> st) {
  if (st.length < 4) return const ToneGuess(0, 'too short to hear');
  // Leave out the first and last bits, where consonants bend the pitch.
  final cut = (st.length * 0.12).floor();
  final v = st.sublist(cut, st.length - cut);
  final n = v.length;
  double avg(Iterable<double> x) => x.reduce((a, b) => a + b) / x.length;
  final q = max(1, (n * 0.25).round());
  final start = avg(v.take(q));
  final end = avg(v.skip(n - q));
  var minI = 0, maxI = 0;
  for (var i = 0; i < n; i++) {
    if (v[i] < v[minI]) minI = i;
    if (v[i] > v[maxI]) maxI = i;
  }
  final low = v[minI], high = v[maxI];
  final minPos = minI / max(1, n - 1);
  final rise = end - start;
  final range = high - low;
  final level = avg(v);

  // Third tone: dips down and comes back up, or stays low and creaky.
  if (minPos > 0.25 && minPos < 0.8 && start - low > 1.2 && end - low > 1.5 && range > 2) {
    return ToneGuess(3, 'dipped ${(start - low).toStringAsFixed(0)} and rose ${(end - low).toStringAsFixed(0)} semitones');
  }
  // Second tone: rises (it may dip a little at the very start).
  if (rise > 1.8 || (end - low > 2.5 && minPos <= 0.35)) {
    return ToneGuess(2, 'rose by ${(end - min(start, low)).toStringAsFixed(0)} semitones');
  }
  // Fourth tone: falls clearly.
  if (rise < -2.5) return ToneGuess(4, 'fell by ${(-rise).toStringAsFixed(0)} semitones');
  // Fairly flat: first tone if it's high or mid, third tone if it's low.
  if (range < 3) {
    if (level < -2.5) return ToneGuess(3, 'stayed low');
    return const ToneGuess(1, 'stayed level');
  }
  if (rise < -1.5) return ToneGuess(4, 'fell by ${(-rise).toStringAsFixed(0)} semitones');
  return ToneGuess(rise > 0 ? 2 : 1, rise > 0 ? 'rose a little' : 'stayed fairly level');
}

// ---------- Pinyin ----------

const _toneMarks = {
  'ā': 1, 'á': 2, 'ǎ': 3, 'à': 4,
  'ē': 1, 'é': 2, 'ě': 3, 'è': 4,
  'ī': 1, 'í': 2, 'ǐ': 3, 'ì': 4,
  'ō': 1, 'ó': 2, 'ǒ': 3, 'ò': 4,
  'ū': 1, 'ú': 2, 'ǔ': 3, 'ù': 4,
  'ǖ': 1, 'ǘ': 2, 'ǚ': 3, 'ǜ': 4,
};
const _plainVowels = 'aeiouüv';

bool _isVowel(String c) => _toneMarks.containsKey(c) || _plainVowels.contains(c);

/// The tone of each syllable in a pinyin word, e.g. "xièxie" → [4, 0], where 0
/// is the light (neutral) tone. Each group of vowels is one syllable.
List<int> tonesOf(String pinyin) {
  final s = pinyin.toLowerCase();
  final tones = <int>[];
  var inVowels = false;
  var tone = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (_isVowel(c)) {
      if (!inVowels) {
        inVowels = true;
        tone = 0;
      }
      tone = _toneMarks[c] ?? tone;
    } else {
      if (inVowels) tones.add(tone);
      inVowels = false;
    }
  }
  if (inVowels) tones.add(tone);
  return tones;
}

/// The tones as they are actually said: two third tones in a row become
/// second + third (你好 nǐ hǎo is said ní hǎo).
List<int> spokenTones(List<int> written) {
  final t = [...written];
  for (var i = t.length - 2; i >= 0; i--) {
    if (t[i] == 3 && t[i + 1] == 3) t[i] = 2;
  }
  return t;
}
