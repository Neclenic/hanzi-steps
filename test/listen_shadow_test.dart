import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/listening.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/pitch.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/shadowing.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/screens/listening_screen.dart';
import 'package:hanzi_steps/screens/shadowing_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  Speech.instance.available.value = false;
  await Settings.instance.load();
  Settings.instance.level = 1;
  return Progress.load();
}

/// The characters of [zh] that are said as a syllable of their own. 儿 at the end of
/// 这儿, 哪儿, 一点儿… is only an "r" sound.
int _syllables(String zh) => zh.replaceAll(RegExp(r'[^一-鿿]'), '').replaceAll('儿', '').runes.length;

void main() {
  setUp(() => loopingAnimations = false);
  final index = File('assets/voice/index.txt').readAsLinesSync().where((l) => l.isNotEmpty).toSet();

  group('listening at real speed', () {
    test('has clips at HSK 3 and 4 level, each with a unique id', () {
      expect(listenClips.length, greaterThanOrEqualTo(10));
      expect(listenClips.map((c) => c.id).toSet(), hasLength(listenClips.length));
      expect(listenClips.map((c) => c.level).toSet(), containsAll([3, 4]));
      for (final c in listenClips) {
        expect(listenClipById(c.id), same(c));
        expect(c.lines.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.lines.map((l) => l.speaker).toSet().difference({'A', 'B'}), isEmpty, reason: c.id);
        if (c.dialogue) {
          expect(c.lines.map((l) => l.speaker).toSet(), {'A', 'B'}, reason: '${c.id} has two speakers');
        } else {
          expect(c.lines.map((l) => l.speaker).toSet(), {'A'}, reason: '${c.id} is one person talking');
        }
      }
    });

    test('every line has one pinyin syllable per character', () {
      for (final c in listenClips) {
        for (final l in c.lines) {
          expect(tonesOf(l.pinyin), hasLength(_syllables(l.zh)), reason: '${l.zh} ${l.pinyin}');
          expect(l.en.trim(), isNotEmpty);
        }
      }
    });

    test('every question has three options, a right answer and English for each option', () {
      for (final c in listenClips) {
        expect(c.questions.length, 3, reason: c.id);
        for (final q in c.questions) {
          expect(q.options, hasLength(3), reason: q.zh);
          expect(q.options.toSet(), hasLength(3), reason: '${q.zh} has three different options');
          expect(q.optionsEn, hasLength(q.options.length), reason: q.zh);
          expect(q.correct, inInclusiveRange(0, q.options.length - 1), reason: q.zh);
        }
      }
    });

    test('the right answers are not always in the same place', () {
      final places = [for (final c in listenClips) for (final q in c.questions) q.correct];
      for (var i = 0; i < 3; i++) {
        expect(places.where((p) => p == i).length, greaterThanOrEqualTo(places.length ~/ 6), reason: 'answer ${'ABC'[i]}');
      }
    });

    test('every clip is recorded whole, and each line and question on its own', () {
      for (final c in listenClips) {
        expect(index, contains(c.audio), reason: 'run python3 tool/make_voice.py to record ${c.id}');
        expect(File('assets/voice/${c.audio}.mp3').lengthSync(), greaterThan(20000), reason: c.id);
        for (final l in c.lines) {
          expect(index, contains(clipName(l.zh)), reason: l.zh);
        }
        for (final q in c.questions) {
          expect(index, contains(clipName(q.zh)), reason: q.zh);
        }
      }
    });

    test('finishing a clip keeps the best score and earns the badge at the end', () async {
      final p = await _fresh();
      await p.finishListening('cafe', 2, 7);
      await p.finishListening('cafe', 1, 5);
      expect(p.listenDone, {'cafe'});
      expect(p.listenBest('cafe'), 2);
      expect(p.xp, 12);
      expect(earnedBadges(p), isNot(contains('listening')));
      for (final c in listenClips) {
        await p.finishListening(c.id, 3, 9);
      }
      expect(earnedBadges(p), contains('listening'));
      expect(p.listenBest('cafe'), 3);
    });

    testWidgets('the list opens, and a clip can be answered and its words read', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2400));
      await tester.pumpWidget(MaterialApp(home: ListeningScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('HSK 3 level'), findsOneWidget);
      expect(find.text('HSK 4 level'), findsOneWidget);
      await tester.tap(find.text('At the café'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Play'));
      await tester.pump();
      expect(find.text('Played 1 time'), findsOneWidget);
      final cafe = listenClipById('cafe')!;
      expect(find.text(cafe.lines.first.zh), findsNothing, reason: 'the words are hidden until you answer');
      // Answer the first two right and the last one wrong.
      for (final (i, q) in cafe.questions.indexed) {
        final pick = i < 2 ? q.correct : (q.correct + 1) % 3;
        await tester.tap(find.text('${'ABC'[pick]}  ${q.options[pick]}'));
        await tester.pump();
      }
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 3 right · +7 XP'), findsOneWidget);
      expect(find.text(cafe.lines.first.zh), findsOneWidget);
      expect(find.text(cafe.questions.first.optionsEn.first), findsOneWidget);
      expect(progress.listenBest('cafe'), 2);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Check answers'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('shadowing', () {
    test('a round has eight different sentences', () {
      for (final set in ShadowSet.values) {
        final round = shadowRound(set, random: Random(1));
        expect(round, hasLength(8), reason: set.name);
        expect(round.map((i) => i.hanzi).toSet(), hasLength(8), reason: set.name);
      }
    });

    test('lesson sentences come from finished lessons once there are enough', () {
      final lessons = courseShadowItems().map((i) => i.hanzi).toSet();
      final first = shadowRound(ShadowSet.lessons, random: Random(2));
      expect(first.every((i) => lessons.contains(i.hanzi)), isTrue);
    });

    test("Xiaoxiao's pitch line and a recording exist for everything that can be shadowed", () {
      final lines = jsonDecode(File('assets/voice/pitch.json').readAsStringSync()) as Map<String, dynamic>;
      final missing = [
        for (final i in allShadowItems())
          if (!lines.containsKey(clipName(i.hanzi)) || !index.contains(clipName(i.hanzi))) i.hanzi,
      ];
      expect(missing, isEmpty, reason: 'run python3 tool/make_voice.py, then dart run tool/make_pitch.dart');
      final line = VoiceLine.fromJson(lines.values.first as Map<String, dynamic>);
      expect(line.length.inMilliseconds, greaterThan(200));
    });

    test('the score is the share of syllables with the right tone', () {
      expect(shadowScore(3, 4), 75);
      expect(shadowScore(0, 0), 0);
      expect(shadowScore(5, 5), 100);
    });

    testWidgets('the shadowing page opens a round of sentences', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: ShadowingScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text(ShadowSet.dialogues.title), findsOneWidget);
      await tester.tap(find.text(ShadowSet.phrases.title));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 of 8'), findsOneWidget);
      expect(find.text('Xiaoxiao'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 of 8'), findsOneWidget);
      // (Tests have no microphone, so the round stops at "Listen…".)
      await tester.tap(find.text('Listen and repeat'));
      await tester.pump();
      expect(find.text('Listen…'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
