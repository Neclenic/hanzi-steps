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
