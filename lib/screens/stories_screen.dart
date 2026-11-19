import 'package:flutter/material.dart';

import '../data/stories.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../logic/story_words.dart';

const _green = Color(0xFF2E9E5B);
const _red = Color(0xFFD7263D);

/// The list of stories, with their level and how many of their words you know.
class StoriesScreen extends StatelessWidget {
  final Progress progress;
  const StoriesScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final learned = progress.learnedWords.map((w) => w.hanzi).toSet();
        final read = progress.storiesRead;
        return Scaffold(
          appBar: AppBar(title: const Text('Stories')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(
                  'Short stories using the words you are learning. Tap any word to see what it means.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final s in stories) _StoryCard(story: s, learned: learned, read: read.contains(s.id), progress: progress),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final Set<String> learned;
  final bool read;
  final Progress progress;
  const _StoryCard({required this.story, required this.learned, required this.read, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final level = levelOf(story);
    final known = (knownShare(story, learned) * 100).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StoryReaderScreen(story: story, progress: progress),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(story.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Flexible(child: Text(story.titleEn, style: TextStyle(color: scheme.onSurfaceVariant))),
                ]),
                const SizedBox(height: 4),
                Text(story.blurb, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _Chip(level.label, scheme.primaryContainer, scheme.onPrimaryContainer),
                  if (level.newWords.isNotEmpty)
                    _Chip('${level.newWords.length} new ${level.newWords.length == 1 ? 'word' : 'words'}',
                        scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
                  _Chip('You know $known%', scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
                ]),
              ]),
            ),
            if (read) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: _green)),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Chip(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
      );
}

// ---------------- Reading ----------------

class StoryReaderScreen extends StatefulWidget {
  final Story story;
  final Progress progress;
  const StoryReaderScreen({super.key, required this.story, required this.progress});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  late bool _pinyin = Settings.instance.showPinyin;
  final Set<int> _showEnglish = {};

  void _tapWord(String token) {
    final w = lookupStoryWord(token);
    if (w == null) return;
    Speech.instance.say(w.hanzi);
    showModalBottomSheet<void>(
      context: context,
      builder: (c) => _WordSheet(word: w, progress: widget.progress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.story;
    final learned = widget.progress.learnedWords.map((w) => w.hanzi).toSet();
    return Scaffold(
      appBar: AppBar(
        title: Text('${s.title}  ·  ${s.titleEn}'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: Speech.instance.available,
            builder: (context, ok, _) => ok
                ? IconButton(
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Read the whole story aloud',
                    onPressed: () => Speech.instance.say(s.paragraphs.map((p) => p.text).join('')),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('Pinyin'),
              selected: _pinyin,
              onSelected: (v) => setState(() => _pinyin = v),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), children: [
            Text('Tap a word for its meaning. Underlined words are new.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            for (final (i, p) in s.paragraphs.indexed) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Wrap(runSpacing: 10, children: [
                    for (final g in _groups(p.tokens)) _group(g, learned, scheme),
                  ]),
                ),
                Column(children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: Speech.instance.available,
                    builder: (context, ok, _) => ok
                        ? IconButton(
                            icon: const Icon(Icons.volume_up_outlined, size: 20),
                            tooltip: 'Listen',
                            onPressed: () => Speech.instance.say(p.text),
                          )
                        : const SizedBox.shrink(),
                  ),
                  IconButton(
                    icon: Icon(Icons.translate, size: 20, color: _showEnglish.contains(i) ? scheme.primary : null),
                    tooltip: 'Show English',
                    onPressed: () => setState(() => _showEnglish.contains(i) ? _showEnglish.remove(i) : _showEnglish.add(i)),
                  ),
                ]),
              ]),
              if (_showEnglish.contains(i))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(p.en, style: TextStyle(fontStyle: FontStyle.italic, color: scheme.onSurfaceVariant)),
                ),
              const SizedBox(height: 22),
            ],
            const SizedBox(height: 8),
            Center(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size(260, 52)),
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => StoryQuizScreen(story: s, progress: widget.progress),
                )),
                icon: const Icon(Icons.quiz),
                label: const Text('ANSWER THE QUESTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// Keeps punctuation with the word next to it, so a line never starts with "，" or "。"
  /// and an opening quote stays with the word it opens.
  List<List<String>> _groups(List<String> tokens) {
    final out = <List<String>>[];
    var pendingOpen = <String>[];
    for (final t in tokens) {
      if (t == '“') {
        pendingOpen.add(t);
      } else if (storyPunctuation.contains(t) && out.isNotEmpty && pendingOpen.isEmpty) {
        out.last.add(t);
      } else {
        out.add([...pendingOpen, t]);
        pendingOpen = [];
      }
    }
    if (pendingOpen.isNotEmpty) out.add(pendingOpen);
    return out;
  }

  Widget _group(List<String> g, Set<String> learned, ColorScheme scheme) =>
      Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final t in g) _token(t, learned, scheme),
      ]);

  Widget _token(String t, Set<String> learned, ColorScheme scheme) {
    final w = lookupStoryWord(t);
    if (w == null) {
      // Punctuation.
      return Text(t, style: const TextStyle(fontSize: 26));
    }
    final isNew = !learned.contains(t);
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _tapWord(t),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_pinyin) Text(w.pinyin, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          Text(
            t,
            style: TextStyle(
              fontSize: 26,
              decoration: isNew ? TextDecoration.underline : null,
              decorationColor: Colors.orange,
              decorationThickness: 2,
            ),
          ),
        ]),
      ),
    );
  }
}

class _WordSheet extends StatefulWidget {
  final StoryWord word;
  final Progress progress;
  const _WordSheet({required this.word, required this.progress});

  @override
  State<_WordSheet> createState() => _WordSheetState();
}

class _WordSheetState extends State<_WordSheet> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = widget.word;
    final course = w.courseWord;
    final inReview = course != null && widget.progress.isInReview(course);
    final learned = course != null && widget.progress.learnedWords.contains(course);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(w.hanzi, style: const TextStyle(fontSize: 44)),
          const SizedBox(width: 12),
          ValueListenableBuilder<bool>(
            valueListenable: Speech.instance.available,
            builder: (context, ok, _) => ok
                ? IconButton(icon: const Icon(Icons.volume_up), onPressed: () => Speech.instance.say(w.hanzi))
                : const SizedBox.shrink(),
          ),
        ]),
        Text(w.pinyin, style: TextStyle(fontSize: 20, color: scheme.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(w.meaning, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          w.isHsk1
              ? 'HSK 1 word'
              : course != null
                  ? 'Bonus word from the course'
                  : 'Not in HSK 1',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        if (course != null) ...[
          const SizedBox(height: 16),
          if (learned || inReview)
            Row(children: [
              const Icon(Icons.check, color: _green),
              const SizedBox(width: 6),
              Text(learned ? 'You learned this word in a lesson' : 'On your review list'),
            ])
          else
            FilledButton.icon(
              onPressed: () async {
                await widget.progress.addToReview(course);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to my review list'),
            ),
        ],
      ]),
    );
  }
}

// ---------------- Questions ----------------

class StoryQuizScreen extends StatefulWidget {
  final Story story;
  final Progress progress;
  const StoryQuizScreen({super.key, required this.story, required this.progress});

  @override
  State<StoryQuizScreen> createState() => _StoryQuizScreenState();
}

class _StoryQuizScreenState extends State<StoryQuizScreen> {
  int _q = 0;
  int? _picked;
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  Future<void> _next() async {
    if (_q + 1 < widget.story.questions.length) {
      setState(() {
        _q++;
        _picked = null;
      });
      return;
    }
    _xp = 5 + _right * 5;
    await widget.progress.finishStory(widget.story.id, _xp);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.story;
    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(padding: const EdgeInsets.all(24), child: _done ? _result(scheme) : _question(scheme)),
        ),
      ),
    );
  }

  Widget _question(ColorScheme scheme) {
    final q = widget.story.questions[_q];
    final answered = _picked != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Question ${_q + 1} of ${widget.story.questions.length}', style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      Text(q.zh.replaceAll(' ', ''), style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 4),
      Text(q.en, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 24),
      for (final (i, o) in q.options.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: answered && i == q.correct
                ? _green.withValues(alpha: 0.12)
                : answered && i == _picked
                    ? _red.withValues(alpha: 0.12)
                    : scheme.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: answered && i == q.correct
                    ? _green
                    : answered && i == _picked
                        ? _red
                        : scheme.outlineVariant,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: answered
                  ? null
                  : () => setState(() {
                        _picked = i;
                        if (i == q.correct) _right++;
                      }),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(o, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),
      const SizedBox(height: 12),
      if (answered)
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _picked == q.correct ? _green : _red,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: _next,
          child: Text(_picked == q.correct ? 'RIGHT! CONTINUE' : 'CONTINUE',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
    ]);
  }

  Widget _result(ColorScheme scheme) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('📖', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 8),
        const Text('Story finished!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$_right of ${widget.story.questions.length} answers right · +$_xp XP',
            style: TextStyle(fontSize: 18, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _green, minimumSize: const Size(240, 52)),
          onPressed: () => Navigator.pop(context),
          child: const Text('BACK TO STORIES', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]);
}
