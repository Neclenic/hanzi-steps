import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_steps/data/course.dart';
import 'package:hanzi_steps/data/dialogues.dart';
import 'package:hanzi_steps/data/grammar.dart';
import 'package:hanzi_steps/data/reading.dart';
import 'package:hanzi_steps/data/stories.dart';
import 'package:hanzi_steps/data/synonyms.dart';
import 'package:hanzi_steps/data/topics.dart';
import 'package:hanzi_steps/logic/badges.dart';
import 'package:hanzi_steps/logic/pitch.dart';
import 'package:hanzi_steps/logic/progress.dart';
import 'package:hanzi_steps/logic/recorder.dart';
import 'package:hanzi_steps/logic/settings.dart';
import 'package:hanzi_steps/logic/speech.dart';
import 'package:hanzi_steps/logic/story_words.dart';
import 'package:hanzi_steps/screens/dialogue_screen.dart';
import 'package:hanzi_steps/screens/reading_screen.dart';
import 'package:hanzi_steps/screens/synonyms_screen.dart';
import 'package:hanzi_steps/screens/topics_screen.dart';
import 'package:hanzi_steps/widgets/anim.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Progress> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  Speech.instance.available.value = false;
  await Settings.instance.load();
  return Progress.load();
}

/// Characters said as a syllable of their own (儿 at the end of 一点儿 is only an "r").
int _syllables(String zh) {
  final chars = zh.replaceAll(RegExp(r'[^一-鿿]'), '');
  return chars.replaceAll(RegExp(r'(?<=[点哪这那玩会])儿'), '').runes.length;
}

void main() {
  setUp(() => loopingAnimations = false);

  group('speak on a topic', () {
    test('every topic has a question, useful words and a model answer with matching pinyin', () {
      expect(speakTopics.length, greaterThanOrEqualTo(10));
      expect(speakTopics.map((t) => t.id).toSet(), hasLength(speakTopics.length));
      expect(speakTopics.map((t) => t.level).toSet(), containsAll([3, 4, 5]));
      for (final t in speakTopics) {
        expect(tonesOf(t.questionPinyin), hasLength(_syllables(t.question)), reason: t.question);
        expect(tonesOf(t.modelPinyin), hasLength(_syllables(t.model)), reason: t.id);
        expect(t.words.length, greaterThanOrEqualTo(4), reason: t.id);
        for (final w in t.words) {
          expect(tonesOf(w.pinyin), hasLength(_syllables(w.zh)), reason: w.zh);
        }
        expect(t.modelEn.trim(), isNotEmpty);
      }
    });

    test('a recording becomes a WAV file, and only the loud parts count as speaking', () {
      final silence = List<double>.filled(sampleRate, 0);
      final tone = [for (var i = 0; i < sampleRate * 2; i++) 0.5 * sin(2 * pi * 220 * i / sampleRate)];
      final wav = toWav([...silence, ...tone]);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(wav.length, 44 + 2 * (silence.length + tone.length));
      expect(spokenSeconds(silence), 0);
      expect(spokenSeconds([...silence, ...tone]), closeTo(2, 0.1));
    });

    testWidgets('the list opens a topic, and the model answer can be read before speaking', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2400));
      await tester.pumpWidget(MaterialApp(home: TopicsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('HSK 3 level'), findsOneWidget);
      expect(find.text('HSK 5 level'), findsOneWidget);
      final t = speakTopics.first;
      await tester.tap(find.text(t.title));
      await tester.pumpAndSettle();
      expect(find.text(t.question), findsOneWidget);
      expect(find.text('Start speaking'), findsOneWidget);
      expect(find.text(t.words.first.zh), findsOneWidget);
      await tester.tap(find.text('Peek at a model answer'));
      await tester.pumpAndSettle();
      expect(find.text(t.model), findsOneWidget);
      expect(find.text(t.modelEn), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('role-play out loud', () {
    testWidgets('your lines ask you to speak, with the Chinese as a hint', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      final d = dialogues.first;
      await tester.pumpWidget(MaterialApp(home: DialogueScreen(dialogue: d, progress: progress)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Role-play out loud'));
      for (final line in d.lines.where((l) => l.isYours)) {
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Your turn. Say it in Chinese:'), findsOneWidget);
        expect(find.text('"${line.en}"'), findsOneWidget);
        await tester.tap(find.text('Show the Chinese'));
        await tester.pump();
        expect(find.text(line.hanzi), findsWidgets);
        await tester.tap(find.text('SKIP'));
      }
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Conversation done!'), findsOneWidget);
      expect(progress.dialoguesDone, contains(d.id));
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('HSK 4 part 2', () {
    test('the course now teaches nearly every HSK 4 word, with grammar tips', () {
      final h4 = [for (final l in allLessons) if (l.id.startsWith('h4-')) ...l.words];
      expect(h4.length, greaterThanOrEqualTo(550));
      final tips = grammarTips.where((t) => t.lessonId.startsWith('h4-'));
      expect(tips.length, greaterThanOrEqualTo(10));
    });
  });

  group('similar words', () {
    test('every pair has two words, a tip, and sentences where only one word fits', () {
      expect(synonymPairs.length, greaterThanOrEqualTo(25));
      expect(synonymPairs.map((p) => p.id).toSet(), hasLength(synonymPairs.length));
      for (final p in synonymPairs) {
        expect(p.words, hasLength(2), reason: p.id);
        expect(synonymPairById(p.id), same(p));
        for (final w in p.words) {
          expect(tonesOf(w.pinyin), hasLength(_syllables(w.zh)), reason: w.zh);
        }
        for (var i = 0; i < p.words.length; i++) {
          expect(p.examples.where((e) => e.answer == i).length, greaterThanOrEqualTo(2), reason: '${p.id} ${p.words[i].zh}');
        }
        for (final e in p.examples) {
          final word = p.words[e.answer].zh;
          expect(word.allMatches(e.zh).length, 1, reason: '${e.zh} has $word once');
          expect(p.gap(e), contains('＿＿'));
          expect(p.gap(e), isNot(contains(word)), reason: e.zh);
          expect(tonesOf(e.pinyin), hasLength(_syllables(e.zh)), reason: e.zh);
          expect(e.en.trim(), isNotEmpty);
        }
      }
    });

    test('a drill has ten different sentences and never the same pair twice in a row', () async {
      final progress = await _fresh();
      for (var seed = 0; seed < 30; seed++) {
        final qs = buildSynonymDrill(progress, random: Random(seed));
        expect(qs, hasLength(10));
        expect(qs.map((q) => q.example).toSet(), hasLength(10));
        for (var i = 1; i < qs.length; i++) {
          expect(qs[i].pair, isNot(same(qs[i - 1].pair)));
        }
      }
      final one = buildSynonymDrill(progress, only: synonymPairs.first, random: Random(1));
      expect(one.map((q) => q.example).toSet(), synonymPairs.first.examples.toSet());
    });

    testWidgets('answer a drill question and see the explanation', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      await tester.pumpWidget(MaterialApp(home: SynonymsScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text(synonymPairs.first.title), findsOneWidget);
      final pair = synonymPairs.first;
      final qs = buildSynonymDrill(progress, only: pair, random: Random(2));
      await tester.pumpWidget(MaterialApp(home: SynonymDrill(progress: progress, pair: pair, questions: qs)));
      await tester.pumpAndSettle();
      expect(find.text(pair.gap(qs.first.example)), findsOneWidget);
      // Pick the wrong word first.
      final wrong = pair.words[1 - qs.first.example.answer].zh;
      await tester.tap(find.text(wrong));
      await tester.pump();
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(find.text(pair.tip), findsOneWidget);
      expect(find.text(qs.first.example.zh), findsOneWidget, reason: 'the whole sentence shows once checked');
      expect(progress.synonymStats[pair.id], (0, 1));
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('reading practice', () {
    test('every word of every article can be tapped, and the extras are new words', () {
      expect(readingArticles.length, greaterThanOrEqualTo(8));
      expect(readingArticles.map((a) => a.id).toSet(), hasLength(readingArticles.length));
      expect(readingArticles.map((a) => a.level).toSet(), containsAll([4, 5]));
      for (final a in readingArticles) {
        expect(readingArticleById(a.id), same(a));
        expect(a.paragraphs.length, greaterThanOrEqualTo(3), reason: a.id);
        for (final p in a.paragraphs) {
          for (final t in p.tokens) {
            final known = storyPunctuation.contains(t) || lookupStoryWord(t) != null;
            expect(known, isTrue, reason: '"$t" in ${a.id} is not in the course or readingExtras');
          }
          expect(p.en.trim(), isNotEmpty);
        }
      }
      for (final k in readingExtras.keys) {
        expect(wordFor(k), isNull, reason: '$k is already a course word');
        expect(storyExtras.containsKey(k), isFalse, reason: '$k is already a story extra');
        expect(tonesOf(readingExtras[k]!.$1), hasLength(_syllables(k)), reason: k);
      }
    });

    test('every article has three questions with three different options', () {
      final places = <int>[];
      for (final a in readingArticles) {
        expect(a.questions, hasLength(3), reason: a.id);
        for (final q in a.questions) {
          expect(q.options, hasLength(3), reason: q.zh);
          expect(q.options.toSet(), hasLength(3), reason: q.zh);
          expect(q.correct, inInclusiveRange(0, 2));
          places.add(q.correct);
        }
      }
      for (var i = 0; i < 3; i++) {
        expect(places.where((p) => p == i).length, greaterThanOrEqualTo(places.length ~/ 5), reason: 'answer ${'ABC'[i]}');
      }
    });

    testWidgets('read an article, answer its questions, and it counts as reading, not a story', (tester) async {
      final progress = await _fresh();
      await tester.binding.setSurfaceSize(const Size(900, 2400));
      await tester.pumpWidget(MaterialApp(home: ReadingScreen(progress: progress)));
      await tester.pumpAndSettle();
      expect(find.text('HSK 4 level'), findsOneWidget);
      expect(find.text('HSK 5 level'), findsOneWidget);
      final a = readingArticles.first;
      await tester.tap(find.text(a.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ANSWER THE QUESTIONS'));
      await tester.pumpAndSettle();
      for (final q in a.questions) {
        await tester.tap(find.text(q.options[q.correct]));
        await tester.pumpAndSettle();
        await tester.tap(find.text('RIGHT! CONTINUE'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Article finished!'), findsOneWidget);
      expect(progress.readingDone, {a.id});
      expect(progress.readingBest(a.id), 3);
      expect(progress.storiesRead, isEmpty);
      await tester.binding.setSurfaceSize(null);
    });
  });

  test('new badges come from the new activities', () async {
    final p = await _fresh();
    expect(earnedBadges(p), isNot(contains('synonyms30')));
    await p.bump('synonymRight', 30);
    for (final a in readingArticles) {
      await p.finishReading(a.id, 3, 20);
    }
    for (final t in speakTopics.take(5)) {
      await p.bump('topic_${t.id}');
    }
    await p.bump('roleplayGood', 20);
    expect(earnedBadges(p), containsAll(['synonyms30', 'reading', 'topics5', 'roleplay20']));
  });
}
