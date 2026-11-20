import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/pinyin_chart.dart';
import 'package:hanzi_steps/data/survival.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/pinyin_input.dart';
import 'package:hanzi_steps/logic/pinyin_quiz.dart';
import 'package:hanzi_steps/logic/pitch.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/survival_quiz.dart';
import 'package:hanzi_steps/logic/textbook.dart';
import 'package:hanzi_steps/main.dart';
import 'package:hanzi_steps/screens/home_screen.dart';
import 'package:hanzi_steps/screens/pinyin_chart_screen.dart';
import 'package:hanzi_steps/screens/settings_screen.dart';
import 'package:hanzi_steps/screens/survival_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  Speech.instance.available.value = false;
  await Settings.instance.load();
  Settings.instance.level = 1;
  return Progress.load();
}

void main() {
  setUp(() => loopingAnimations = false);

  group('Pinyin chart', () {
    test('has every syllable, each with four tones and at least one character', () {
      expect(pinyinChart.length, greaterThan(390));
      for (final MapEntry(key: syl, value: tones) in pinyinChart.entries) {
        expect(tones, hasLength(4), reason: syl);
        expect(tones.any((t) => t != null), isTrue, reason: syl);
        for (final t in tones) {
          if (t != null) expect(t.$1.runes, hasLength(1), reason: '$syl ${t.$1}');
        }
      }
      for (final s in ['ma', 'zhuang', 'lv', 'nve', 'er', 'shei', 'yu', 'wo']) {
        expect(pinyinChart, contains(s));
      }
      expect(pinyinChart['ma']!.map((t) => t?.$1), ['妈', '麻', '马', '骂']);
    });

    test('a character is never used for two syllables or tones', () {
      final seen = <String, String>{};
      for (final MapEntry(key: syl, value: tones) in pinyinChart.entries) {
        for (final (i, t) in tones.indexed) {
          if (t == null) continue;
          expect(seen[t.$1], isNull, reason: '${t.$1} in $syl${i + 1} and ${seen[t.$1]}');
          seen[t.$1] = '$syl${i + 1}';
        }
      }
    });

    test('groups by initial, with every syllable in exactly one group', () {
      expect(initialOf('zhuang'), 'zh');
      expect(initialOf('zuo'), 'z');
      expect(initialOf('ai'), '');
      expect(initialOf('yue'), 'y');
      final groups = chartByInitial();
      expect(groups.first.$1, 'b');
      expect(groups.last.$1, '');
      final all = [for (final g in groups) ...g.$2];
      expect(all, hasLength(pinyinChart.length));
      expect(all.toSet(), pinyinChart.keys.toSet());
      for (final i in pinyinInitials) {
        expect(initialTips, contains(i));
      }
    });

    test('search accepts ü, v and tone marks', () {
      expect(searchSyllables('lü'), containsAll(['lv', 'lve']));
      expect(searchSyllables('lv'), containsAll(['lv', 'lve']));
      expect(searchSyllables('zhōng'), ['zhong']);
      expect(searchSyllables('zh').every((s) => s.startsWith('zh')), isTrue);
      expect(searchSyllables('xyz'), isEmpty);
      expect(searchSyllables(''), hasLength(pinyinChart.length));
      expect(showSyllable('nve'), 'nüe');
    });

    test('the tone quiz asks about course characters, with the right tone marked', () {
      final qs = buildToneQuiz(random: Random(3));
      expect(qs, hasLength(8));
      expect(qs.map((q) => q.prompt).toSet(), hasLength(8));
      for (final q in qs) {
        expect(q.options, hasLength(4));
        expect(q.promptSub, isNotEmpty);
        final tones = pinyinChart[q.tag]!;
        expect(tones[q.correct]!.$1, q.prompt);
        expect(q.options[q.correct], markSyllable(q.tag!, q.correct + 1));
      }
    });
  });

  group('Survival phrases', () {
    test('six packs with unique ids and enough phrases', () {
      expect(phrasePacks, hasLength(6));
      expect(phrasePacks.map((p) => p.id).toSet(), hasLength(6));
      for (final p in phrasePacks) {
        expect(p.phrases.length, greaterThanOrEqualTo(9), reason: p.id);
        expect(p.phrases.where((x) => x.hear), isNotEmpty, reason: '${p.id} has lines you will hear');
        expect(phrasePackById(p.id), same(p));
      }
    });

    test('the pinyin has one syllable for each character', () {
      for (final pack in phrasePacks) {
        for (final p in pack.phrases) {
          // 儿 at the end of 哪儿, 这儿, 一点儿… is only an "r" sound.
          final chars = p.hanzi.replaceAll(RegExp(r'[，。？！]'), '').replaceAll('儿', '');
          expect(tonesOf(p.pinyin), hasLength(chars.runes.length), reason: '${p.hanzi} ${p.pinyin}');
          expect(p.zh.replaceAll(' ', ''), p.hanzi);
        }
      }
    });

    test('the quiz checks meaning, how to say it and word order', () {
      for (final pack in phrasePacks) {
        final qs = buildPhraseQuiz(pack, random: Random(pack.id.length));
        expect(qs, hasLength(8), reason: pack.id);
        for (final q in qs) {
          switch (q) {
            case TbChoice c:
              expect(c.options.toSet(), hasLength(c.options.length), reason: '${pack.id}: ${c.prompt}');
              final phrase = pack.phrases.firstWhere((p) => p.hanzi == c.prompt || p.en == c.prompt);
              expect(c.options[c.correct], anyOf(phrase.hanzi, phrase.en));
            case TbBuild b:
              expect(pack.phrases.map((p) => p.hanzi), contains(b.answer.join() + b.end));
              expect(b.isRight(b.answer), isTrue);
          }
        }
      }
      // Over a few rounds every kind of question turns up.
      final kinds = <Type>{};
      final headings = <String>{};
      for (var s = 0; s < 6; s++) {
        for (final q in buildPhraseQuiz(phrasePacks[s], random: Random(s))) {
          kinds.add(q.runtimeType);
          if (q is TbChoice) headings.add(q.heading);
        }
      }
      expect(kinds, containsAll([TbChoice, TbBuild]));
      expect(headings, hasLength(3));
    });

    test('the traveller badge needs every pack', () async {
      final progress = await _fresh();
      final b = badgeById('traveller');
      expect(b.earned(progress), isFalse);
      for (final p in phrasePacks) {
        await progress.bump('phrases_${p.id}');
      }
      expect(b.earned(progress), isTrue);
    });
  });

  group('Screens', () {
    testWidgets('pinyin chart: tap a syllable to see its four tones, and search', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: PinyinChartScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('ba'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ma');
      await tester.pumpAndSettle();
      expect(find.text('ba'), findsNothing);
      await tester.tap(find.widgetWithText(ActionChip, 'ma'));
      await tester.pumpAndSettle();
      for (final s in ['mā', 'má', 'mǎ', 'mà', '妈', '麻', '马', '骂']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('horse'), findsOneWidget);
    });

    testWidgets('pinyin chart: the tone quiz opens from the chart', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: PinyinChartScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TONE QUIZ'));
      await tester.pumpAndSettle();
      expect(find.text('声调 · Tone quiz · 1 of 8'), findsOneWidget);
      expect(find.textContaining('Which tone is it?'), findsOneWidget);
    });

    testWidgets('survival phrases: open a pack, see what you say and what you hear', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2400));
      await tester.pumpWidget(MaterialApp(home: SurvivalScreen(progress: progress)));
      await tester.pumpAndSettle();
      for (final p in phrasePacks) {
        expect(find.text(p.title), findsOneWidget);
      }
      await tester.tap(find.text('Taxi'));
      await tester.pumpAndSettle();
      expect(find.text('师傅，我去机场。'), findsOneWidget);
      expect(find.text("You'll hear"), findsNWidgets(2));
      await tester.tap(find.text('Say them'));
      await tester.pumpAndSettle();
      expect(find.text('Say it · Taxi'), findsOneWidget);
    });

    testWidgets('home has tiles for the pinyin chart and survival phrases', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2200));
      await tester.pumpWidget(MaterialApp(home: HomeScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pinyin chart'));
      await tester.pumpAndSettle();
      expect(find.text('Pinyin chart 拼音表'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Survival phrases'));
      await tester.pumpAndSettle();
      expect(find.text('Survival phrases'), findsWidgets);
    });

    testWidgets('dark mode switch in Settings changes the whole app', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      await tester.pumpWidget(HanziStepsApp(progress: progress));
      await tester.pumpAndSettle();
      ThemeMode mode() => tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
      expect(mode(), ThemeMode.system);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(MaterialPageRoute(builder: (_) => SettingsScreen(progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(mode(), ThemeMode.dark);
      expect(Theme.of(tester.element(find.text('Colours'))).brightness, Brightness.dark);
      expect(Settings.instance.themeChoice, 2);
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(mode(), ThemeMode.light);
      Settings.instance.themeChoice = 0;
    });
  });
}
