import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'settings.dart';

/// Reads Chinese aloud using the voice built into the computer
/// (Windows, Mac and web browsers all have one, though Windows may need
/// the Chinese language pack installed — see the README).
class Speech {
  Speech._();
  static final Speech instance = Speech._();

  FlutterTts? _tts;
  bool _ready = false;

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
      final tts = FlutterTts();
      final ok = await _pickChineseVoice(tts);
      await tts.setSpeechRate(rate);
      await tts.awaitSpeakCompletion(false);
      _tts = tts;
      available.value = ok;
      if (!ok) {
        // Browsers sometimes load their voice list a moment after start-up.
        Future.delayed(const Duration(milliseconds: 1500), () async {
          try {
            available.value = await _pickChineseVoice(tts);
          } catch (_) {}
        });
      }
    } catch (e) {
      // No speech support on this platform (or in tests): the app still works silently.
      debugPrint('Speech unavailable: $e');
      available.value = false;
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
    final tts = _tts;
    if (tts == null || !available.value) return;
    try {
      await tts.stop();
      await tts.setSpeechRate(slow ? (kIsWeb ? 0.6 : 0.3) : rate);
      await tts.speak(hanzi);
    } catch (e) {
      debugPrint('Speech failed: $e');
    }
  }
}
