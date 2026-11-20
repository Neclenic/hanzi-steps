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

  /// Say some Chinese text out loud. Safe to call even if there's no voice.
  /// [slow] reads it slowly whatever the speed setting is.
  Future<void> say(String hanzi, {bool slow = false}) async {
    if (!available.value) return;
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
