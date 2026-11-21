import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'pitch.dart';

/// Records a few seconds from the microphone as raw samples, for speaking practice.
class VoiceRecorder {
  AudioRecorder? _rec;
  StreamSubscription<Uint8List>? _sub;
  final _bytes = BytesBuilder(copy: false);

  /// How loud the microphone is right now, from 0 to 1 (for the level meter).
  final level = ValueNotifier<double>(0);
  bool get recording => _sub != null;

  /// Asks for the microphone. Returns false if it was refused or there is none.
  Future<bool> ask() async {
    try {
      _rec ??= AudioRecorder();
      return await _rec!.hasPermission();
    } catch (e) {
      debugPrint('No microphone: $e');
      return false;
    }
  }

  Future<bool> start() async {
    if (!await ask()) return false;
    _bytes.clear();
    try {
      final stream = await _rec!.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ));
      _sub = stream.listen((chunk) {
        _bytes.add(chunk);
        final s = pcm16ToSamples(chunk);
        if (s.isEmpty) return;
        var e = 0.0;
        for (final x in s) {
          e += x * x;
        }
        level.value = min(1, sqrt(e / s.length) * 6);
      });
      return true;
    } catch (e) {
      debugPrint('Could not start recording: $e');
      return false;
    }
  }

  /// Stops and returns what was recorded.
  Future<Float64List> stop() async {
    try {
      await _rec?.stop();
    } catch (_) {}
    await _sub?.cancel();
    _sub = null;
    level.value = 0;
    return pcm16ToSamples(_bytes.takeBytes());
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    try {
      await _rec?.dispose();
    } catch (_) {}
    level.dispose();
  }
}

/// [samples] (from -1 to 1) as a 16-bit mono WAV file, so a recording can be played back.
Uint8List toWav(List<double> samples, {int rate = sampleRate}) {
  final data = ByteData(44 + samples.length * 2);
  void text(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // plain PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  text(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}

/// Roughly how many seconds of [samples] are speech rather than silence.
double spokenSeconds(List<double> samples, {int rate = sampleRate}) {
  final frame = rate ~/ 50; // 20 ms
  final energies = <double>[];
  for (var i = 0; i + frame <= samples.length; i += frame) {
    var e = 0.0;
    for (var j = i; j < i + frame; j++) {
      e += samples[j] * samples[j];
    }
    energies.add(sqrt(e / frame));
  }
  if (energies.isEmpty) return 0;
  final loudest = energies.reduce(max);
  if (loudest < 0.01) return 0;
  return energies.where((e) => e > max(0.008, loudest * 0.12)).length / 50;
}
