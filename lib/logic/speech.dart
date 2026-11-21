import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'settings.dart';

/// Reads Chinese aloud. Most words and sentences come with recordings of a natural
/// voice (Xiaoxiao, made with Azure neural text-to-speech and shipped in assets/voice).
/// Anything without a recording is read by the voice built into the computer
/// (Windows, Mac and web browsers all have one, though Windows may need
/// the Chinese language pack installed — see the README).
class Speech {
  Speech._();
  static final Speech instance = Speech._();

  FlutterTts? _tts;
  bool _ready = false;
  bool _systemVoice = false;

  /// The recordings that ship with the app, by file name (see [clipName]).
  Set<String> clips = {};
  AudioPlayer? _player;

  /// True when a Mandarin voice was found on this computer.
  final ValueNotifier<bool> available = ValueNotifier(false);

  /// Slower speech is easier to follow for beginners.
  /// In the speech plugin, 0.5 is normal speed on Windows and Mac; in browsers 1.0 is.
  double get rate {
    final slow = Settings.instance.speechSpeed == 0;
    if (kIsWeb) return slow ? 0.7 : 1.0;
    return slow ? 0.35 : 0.5;
  }

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    try {
      final list = await rootBundle.loadString('assets/voice/index.txt');
      clips = list.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toSet();
      if (clips.isNotEmpty) available.value = true;
    } catch (e) {
      debugPrint('No voice recordings: $e');
    }
    try {
      final tts = FlutterTts();
      final ok = await _pickChineseVoice(tts);
      await tts.setSpeechRate(rate);
      await tts.awaitSpeakCompletion(false);
      _tts = tts;
      _systemVoice = ok;
      available.value = ok || clips.isNotEmpty;
      if (!ok) {
        // Browsers sometimes load their voice list a moment after start-up.
        Future.delayed(const Duration(milliseconds: 1500), () async {
          try {
            _systemVoice = await _pickChineseVoice(tts);
            available.value = _systemVoice || clips.isNotEmpty;
          } catch (_) {}
        });
      }
    } catch (e) {
      // No speech support on this platform (or in tests): recordings may still play.
      debugPrint('Speech unavailable: $e');
      available.value = clips.isNotEmpty;
    }
  }

  Future<bool> _pickChineseVoice(FlutterTts tts) async {
    // Prefer an explicit Mainland Mandarin voice, then any Chinese voice.
    final voices = (await tts.getVoices as List?)?.cast<Map>() ?? const [];
    Map? best;
    for (final v in voices) {
      final locale = '${v['locale'] ?? v['lang'] ?? ''}'.toLowerCase().replaceAll('_', '-');
      if (locale == 'zh-cn') {
        best = v;
        break;
      }
      if (best == null && locale.startsWith('zh') && !locale.contains('hk') && !locale.contains('yue')) best = v;
    }
    if (best != null) {
      await tts.setVoice({'name': '${best['name']}', 'locale': '${best['locale'] ?? best['lang']}'});
      return true;
    }
    // Browsers can fetch an online Chinese voice even when none is listed yet.
    // (On Windows and Mac the voice list is reliable, so no voice there means no sound.)
    if (kIsWeb) {
      await tts.setLanguage('zh-CN');
      return true;
    }
    return false;
  }

  /// Plays a long recording such as a listening clip ([name] without .mp3) at [rate]
  /// (1.0 is natural speed). Falls back to reading [fallback] with the computer's voice.
  Future<void> playClip(String name, {double rate = 1.0, String? fallback}) async {
    _sequence++;
    if (clips.contains(name)) {
      try {
        await _tts?.stop();
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setPlaybackRate(rate);
        await player.play(AssetSource('voice/$name.mp3'));
        return;
      } catch (e) {
        debugPrint('Recording failed: $e');
      }
    }
    if (fallback != null && _systemVoice) {
      await _tts?.stop();
      await _tts?.setSpeechRate(kIsWeb ? rate : rate * 0.5);
      await _tts?.speak(fallback);
    }
  }

  /// Stops whatever is being said.
  Future<void> stop() async {
    _sequence++;
    try {
      await _player?.stop();
      await _tts?.stop();
    } catch (_) {}
  }

  /// Says [hanzi] and waits until it has been said (at most [expected] plus a little).
  Future<void> sayAndWait(String hanzi, Duration expected) async {
    if (!available.value) return;
    final done = Completer<void>();
    StreamSubscription<void>? sub;
    if (Settings.instance.naturalVoice && clips.contains(clipName(hanzi))) {
      sub = (_player ??= AudioPlayer()).onPlayerComplete.listen((_) {
        if (!done.isCompleted) done.complete();
      });
    }
    await say(hanzi);
    // The computer's voice gives no reliable "finished" signal, so wait for the expected time.
    final limit = expected * (Settings.instance.speechSpeed == 0 ? 1.25 : 1.05) + const Duration(milliseconds: 300);
    await Future.any([done.future, Future<void>.delayed(limit)]);
    await sub?.cancel();
  }

  int _sequence = 0;

  /// Plays recorded pieces one after another. Saying something else stops it.
  Future<void> _playPieces(List<String> pieces, double rate) async {
    final mine = ++_sequence;
    await _tts?.stop();
    final player = _player ??= AudioPlayer();
    await player.stop();
    await player.setPlaybackRate(rate);
    for (final p in pieces) {
      if (mine != _sequence) return;
      final done = player.onPlayerComplete.first.timeout(const Duration(seconds: 3), onTimeout: () {});
      await player.play(AssetSource('voice/${pieceName(p)}.mp3'));
      await done;
    }
  }

  /// Say some Chinese text out loud. Safe to call even if there's no voice.
  /// [slow] reads it slowly whatever the speed setting is.
  Future<void> say(String hanzi, {bool slow = false}) async {
    if (!available.value) return;
    _sequence++;
    final clip = clipName(hanzi);
    if (Settings.instance.naturalVoice && clips.contains(clip)) {
      try {
        await _tts?.stop();
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setPlaybackRate(slow ? 0.7 : (Settings.instance.speechSpeed == 0 ? 0.85 : 1.0));
        await player.play(AssetSource('voice/$clip.mp3'));
        return;
      } catch (e) {
        debugPrint('Recording failed, using the computer voice: $e');
      }
    }
    // Numbers, prices, dates and times are made up while the app runs, so they are
    // read from short recorded pieces instead (三十五块 + 五, 下午 + 两点 + 半).
    if (Settings.instance.naturalVoice) {
      final pieces = splitIntoPieces(hanzi, (t) => clips.contains(pieceName(t)));
      if (pieces != null && pieces.isNotEmpty) {
        try {
          await _playPieces(pieces, slow ? 0.7 : (Settings.instance.speechSpeed == 0 ? 0.85 : 1.0));
          return;
        } catch (e) {
          debugPrint('Recording failed, using the computer voice: $e');
        }
      }
    }
    final tts = _tts;
    if (tts == null || !_systemVoice) return;
    try {
      await _player?.stop();
      await tts.stop();
      await tts.setSpeechRate(slow ? (kIsWeb ? 0.6 : 0.3) : rate);
      await tts.speak(hanzi);
    } catch (e) {
      debugPrint('Speech failed: $e');
    }
  }
}

/// The file name of the recording of [text]: spaces don't matter, so 我 是 学生 and
/// 我是学生 share one. tool/make_voice.py names the files the same way.
String clipName(String text) =>
    sha1.convert(utf8.encode(text.replaceAll(RegExp(r'\s'), ''))).toString().substring(0, 12);

/// The file name of a short recorded piece used to read numbers (see [splitIntoPieces]).
/// Pieces are recorded with no silence around them, so they join up smoothly.
String pieceName(String text) => 'n-${clipName(text)}';

/// Splits [text] into recorded pieces, taking the longest piece that fits each time and
/// skipping punctuation. Returns null if some part has no piece.
List<String>? splitIntoPieces(String text, bool Function(String) has) {
  final t = text.replaceAll(RegExp(r'[\s，。、？！,.:：]'), '');
  final out = <String>[];
  var i = 0;
  while (i < t.length) {
    var j = t.length < i + 8 ? t.length : i + 8;
    while (j > i && !has(t.substring(i, j))) {
      j--;
    }
    if (j == i) return null;
    out.add(t.substring(i, j));
    i = j;
  }
  return out;
}
