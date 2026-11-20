import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/char_stories.dart';
import '../data/textbook.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../logic/strokes.dart';
import '../logic/textbook.dart';
import '../widgets/anim.dart';
import '../widgets/char_story_card.dart';
import '../widgets/character_writer.dart';
import '../widgets/quiz_parts.dart';
import '../widgets/word_sheet.dart';

const _gridRed = Color(0xFFD7263D);

/// The textbook (课本): two books of units, each with three lessons and a review corner.
class TextbookScreen extends StatefulWidget {
  final Progress progress;
  const TextbookScreen({super.key, required this.progress});

  @override
  State<TextbookScreen> createState() => _TextbookScreenState();
}

class _TextbookScreenState extends State<TextbookScreen> {
  // Start in Book 2 once Book 1 is all done.
  late int _book = tbUnitsOf(1).every((u) => _unitDone(u)) ? 2 : 1;

  bool _unitDone(TbUnit u) {
    final done = widget.progress.textbookDone;
    return u.lessons.every((l) => done.contains(l.id)) && done.contains(u.corner.id);
  }

  void _push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: widget.progress,
      builder: (context, _) {
        final done = widget.progress.textbookDone;
        final units = tbUnitsOf(_book);
        final total = units.fold(0, (n, u) => n + u.lessons.length + 1);
        final finished = units.fold(0, (n, u) => n + u.lessons.where((l) => done.contains(l.id)).length + (done.contains(u.corner.id) ? 1 : 0));
        final (bookZh, bookEn) = tbBooks[_book]!;
        return Scaffold(
          appBar: AppBar(title: const Text('Textbook · 课本')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
                Text(
                  'Lessons laid out like a Chinese school textbook: rhymes, character lists and short texts, '
                  'each with new characters to read and write. Every unit ends with a review corner and a famous poem or saying.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SegmentedButton<int>(
                    segments: [
                      for (final b in tbBooks.keys) ButtonSegment(value: b, label: Text('${tbBooks[b]!.$1} · Book $b')),
                    ],
                    selected: {_book},
                    onSelectionChanged: (s) => setState(() => _book = s.first),
                  ),
                ),
                const SizedBox(height: 12),
                _Cover(zh: bookZh, en: bookEn, done: finished, total: total),
                for (final (i, u) in units.indexed)
                  FadeSlideIn(
                    key: ValueKey('${_book}_${u.number}'),
                    delay: Duration(milliseconds: 60 * i),
                    child: _UnitCard(
                      unit: u,
                      done: done,
                      onLesson: (l) => _push(TbLessonScreen(progress: widget.progress, lesson: l)),
                      onCorner: () => _push(TbCornerScreen(progress: widget.progress, unit: u)),
                    ),
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  final String zh, en;
  final int done, total;
  const _Cover({required this.zh, required this.en, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFFD7263D), Color(0xFFF18F01)]),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('汉语', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 6)),
          Text(zh, style: const TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 4),
          Text(en, style: const TextStyle(color: Colors.white70)),
        ]),
        const Spacer(),
        Column(children: [
          Text('$done / $total', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('done', style: TextStyle(color: Colors.white70)),
        ]),
      ]),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final TbUnit unit;
  final Set<String> done;
  final void Function(TbLesson) onLesson;
  final VoidCallback onCorner;
  const _UnitCard({required this.unit, required this.done, required this.onLesson, required this.onCorner});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(unit.colorValue);
    Widget check(bool d) => d ? const Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.chevron_right, color: scheme.outline);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: color,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            Text(tbUnitLabel(unit), style: const TextStyle(color: Colors.white70)),
            const SizedBox(width: 10),
            Text(unit.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Expanded(child: Text(unit.titleEn, style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis)),
          ]),
        ),
        for (final l in unit.lessons)
          ListTile(
            onTap: () => onLesson(l),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              foregroundColor: color,
              child: Text('${l.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Row(children: [
              Text(l.title, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              _KindTag(l.kind),
            ]),
            subtitle: Text('${l.titlePy} · ${l.titleEn}'),
            trailing: check(done.contains(l.id)),
          ),
        ListTile(
          onTap: onCorner,
          tileColor: color.withValues(alpha: 0.06),
          leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: const Text('🌱')),
          title: Text(tbCornerLabel(unit), style: const TextStyle(fontSize: 18)),
          subtitle: Text('Review corner · radical ${unit.corner.radical.radical} · ${unit.corner.poems.first.title}'),
          trailing: check(done.contains(unit.corner.id)),
        ),
      ]),
    );
  }
}

class _KindTag extends StatelessWidget {
  final TbKind kind;
  const _KindTag(this.kind);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(border: Border.all(color: scheme.outline), borderRadius: BorderRadius.circular(6)),
      child: Text('${kind.zh} ${kind.en}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
    );
  }
}

// ---------------- Pieces of a textbook page ----------------

/// A 田字格 square: the grid Chinese children write characters in.
class TianZiGe extends StatelessWidget {
  final String char;
  final double size;
  final Color? color;
  const TianZiGe(this.char, {super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _GridPainter(color ?? _gridRed),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: Text(char, style: TextStyle(fontSize: size * 0.68, height: 1.15))),
        ),
      );
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, border);
    final dash = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    void dashed(Offset a, Offset b) {
      final d = b - a;
      final n = (d.distance / 6).floor();
      for (var i = 0; i < n; i += 2) {
        canvas.drawLine(a + d * (i / n), a + d * ((i + 1) / n), dash);
      }
    }

    dashed(Offset(size.width / 2, 0), Offset(size.width / 2, size.height));
    dashed(Offset(0, size.height / 2), Offset(size.width, size.height / 2));
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

/// A line of Chinese with the pinyin of each character above it. Words can be tapped.
class RubyLine extends StatelessWidget {
  final TbLine line;
  final bool pinyin;
  final double size;
  final bool center;
  final void Function(String token)? onWord;
  const RubyLine(this.line, {super.key, this.pinyin = true, this.size = 26, this.center = false, this.onWord});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pyStyle = TextStyle(fontSize: size * 0.48, color: scheme.primary, height: 1.1);
    final hzStyle = TextStyle(fontSize: size, height: 1.25);
    Widget cell(String ch, String? py) => SizedBox(
          width: size * 1.25 + (py != null && py.length > 4 ? (py.length - 4) * size * 0.2 : 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (pinyin) Text(py ?? '', style: pyStyle, maxLines: 1, softWrap: false),
            Text(ch, style: hzStyle),
          ]),
        );
    // Punctuation sticks to its word: closing marks (，。” …) to the word before, an opening “ to
    // the word after. So a line never starts with a comma or a closing quote.
    final groups = <List<RubyWord>>[];
    var openNext = false;
    for (final w in rubyWords(line)) {
      final isPunct = w.$2.isEmpty;
      if (isPunct && w.$1 != '“' && groups.isNotEmpty && !openNext) {
        groups.last.add(w);
      } else if (openNext) {
        groups.last.add(w);
        openNext = isPunct && w.$1 == '“';
      } else {
        groups.add([w]);
        openNext = isPunct && w.$1 == '“';
      }
    }
    Widget punct(String t) =>
        SizedBox(width: size * 0.9, child: Column(children: [if (pinyin) Text('', style: pyStyle), Text(t, style: hzStyle)]));
    Widget word(String t, List<String> py) => InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onWord == null ? null : () => onWord!(t),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < t.length; i++) cell(t[i], py[i]),
          ]),
        );
    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 6,
      children: [
        for (final g in groups)
          if (g.length == 1)
            (g.first.$2.isEmpty ? punct(g.first.$1) : word(g.first.$1, g.first.$2))
          else
            Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final (t, py) in g) py.isEmpty ? punct(t) : word(t, py),
            ]),
      ],
    );
  }
}

/// Opens the sheet for a word in a textbook text.
void showTbWord(BuildContext context, Progress progress, String token) {
  final w = tbWord(token);
  if (w == null) return;
  Speech.instance.say(token);
  showWordSheet(context, progress, w);
}

class _Section extends StatelessWidget {
  final String zh, en;
  final String? sub;
  const _Section(this.zh, this.en, {this.sub});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 22, color: _gridRed),
          const SizedBox(width: 8),
          Text(zh, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(en, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
        ]),
        if (sub != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(sub!, style: TextStyle(color: scheme.onSurfaceVariant))),
      ]),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('💡 '), Expanded(child: Text(text))]),
      );
}

Widget _speakButton(String text, {String tooltip = 'Listen'}) => ValueListenableBuilder<bool>(
      valueListenable: Speech.instance.available,
      builder: (context, ok, _) => ok
          ? IconButton(icon: const Icon(Icons.volume_up), tooltip: tooltip, onPressed: () => Speech.instance.say(text))
          : const SizedBox.shrink(),
    );

// ---------------- A lesson ----------------

class TbLessonScreen extends StatefulWidget {
  final Progress progress;
  final TbLesson lesson;
  const TbLessonScreen({super.key, required this.progress, required this.lesson});

  @override
  State<TbLessonScreen> createState() => _TbLessonScreenState();
}

class _TbLessonScreenState extends State<TbLessonScreen> {
  bool _pinyin = Settings.instance.showPinyin;
  bool _english = false;

  TbLesson get _l => widget.lesson;

  void _exercises() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TbQuizScreen(
          title: '第${_l.number}课 · 练习',
          build: () => buildTbExercises(_l),
          note: 'Lesson ${_l.number} is done. Read the text aloud once more to remember it.',
          onFinish: (right, total) async {
            final xp = 10 + right;
            await widget.progress.finishTextbook(_l.id, xp);
            return xp;
          },
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unit = tbUnitOf(_l);
    final centered = _l.kind != TbKind.text;
    final done = widget.progress.textbookDone.contains(_l.id);
    return Scaffold(
      appBar: AppBar(title: Text('第${_l.number}课 · ${_l.titleEn}')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: quizGreen,
        foregroundColor: Colors.white,
        onPressed: _exercises,
        icon: const Icon(Icons.edit_note),
        label: Text(done ? 'DO THE EXERCISES AGAIN' : 'DO THE EXERCISES'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
            Row(children: [
              Text('${tbUnitLabel(unit)} · ${unit.title}', style: TextStyle(color: scheme.onSurfaceVariant)),
              const Spacer(),
              _KindTag(_l.kind),
            ]),
            const SizedBox(height: 8),
            // The page: title and text, on paper.
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Color.alphaBlend(const Color(0xFFFFF4D6).withValues(alpha: 0.5), scheme.surface),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(children: [
                Text('${_l.number}', style: TextStyle(color: Color(unit.colorValue), fontWeight: FontWeight.bold, fontSize: 18)),
                if (_pinyin) Text(_l.titlePy, style: TextStyle(color: scheme.primary, fontSize: 16)),
                Text(_l.title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                Text(_l.titleEn, style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 4, children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: Speech.instance.available,
                    builder: (context, ok, _) => ok
                        ? FilledButton.tonalIcon(
                            onPressed: () => Speech.instance.say(_l.lines.map((x) => x.text).join()),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Listen to it all'),
                          )
                        : const SizedBox.shrink(),
                  ),
                  FilterChip(label: const Text('Pinyin'), selected: _pinyin, onSelected: (v) => setState(() => _pinyin = v)),
                  FilterChip(label: const Text('English'), selected: _english, onSelected: (v) => setState(() => _english = v)),
                ]),
                const SizedBox(height: 12),
                for (final line in _l.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            RubyLine(line,
                                pinyin: _pinyin, center: centered, onWord: (t) => showTbWord(context, widget.progress, t)),
                            if (_english)
                              Text(line.en, style: TextStyle(color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      _speakButton(line.text, tooltip: 'Listen to this line'),
                    ]),
                  ),
                Text('Tap a word to see what it means.', style: TextStyle(fontSize: 12, color: scheme.outline)),
              ]),
            ),
            if (_l.note != null) _Tip(_l.note!),
            const _Section('生字', 'New characters',
                sub: 'Tap a character to hear it, see how it is built and write it. ✏️ marks the ones to learn to write.'),
            Wrap(spacing: 14, runSpacing: 14, children: [
              for (final c in _l.chars) _CharBox(c, onTap: () => showTbChar(context, widget.progress, c)),
            ]),
            const _Section('说一说', 'Say it'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_l.speak.en, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(child: RubyLine(_l.speak.model, pinyin: _pinyin, size: 22)),
                    _speakButton(_l.speak.model.text),
                  ]),
                  Text('${_l.speak.model.en} Now you try.', style: TextStyle(color: scheme.onSurfaceVariant)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _CharBox extends StatelessWidget {
  final TbChar c;
  final VoidCallback onTap;
  const _CharBox(this.c, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 22, child: Text(c.pinyin, style: TextStyle(color: scheme.primary, fontSize: 15))),
          TianZiGe(c.char, size: 68),
          const SizedBox(height: 2),
          Text(c.write ? '✏️ write' : 'read', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// Everything about one new character: sound, meaning, radical, strokes, words, and writing it.
Future<void> showTbChar(BuildContext context, Progress progress, TbChar c) {
  Speech.instance.say(c.char);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TbCharSheet(c, progress),
  );
}

class _TbCharSheet extends StatefulWidget {
  final TbChar c;
  final Progress progress;
  const _TbCharSheet(this.c, this.progress);

  @override
  State<_TbCharSheet> createState() => _TbCharSheetState();
}

class _TbCharSheetState extends State<_TbCharSheet> {
  bool _loaded = StrokeLibrary.instance.has('一');
  String? _written;

  @override
  void initState() {
    super.initState();
    if (!_loaded) {
      StrokeLibrary.instance.load().then((_) {
        if (mounted) setState(() => _loaded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = widget.c;
    final strokes = _loaded ? StrokeLibrary.instance.get(c.char)?.count : null;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TianZiGe(c.char, size: 110),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(c.pinyin, style: TextStyle(fontSize: 26, color: scheme.primary, fontWeight: FontWeight.w600)),
                  _speakButton(c.char),
                ]),
                Text(c.meaning, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 6),
                if (c.radical != null) Text('部首 radical: ${c.radical}', style: TextStyle(color: scheme.onSurfaceVariant)),
                if (strokes != null) Text('笔画 strokes: $strokes', style: TextStyle(color: scheme.onSurfaceVariant)),
                Text(c.write ? '会写 · learn to write it' : '会认 · learn to read it', style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
          ]),
          if (c.words.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('组词 · Words with it', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final w in c.words)
                if (tbWord(w) case final word?)
                  ActionChip(
                    label: Text('$w ${word.pinyin} · ${word.meaning}'),
                    onPressed: () => showTbWord(context, widget.progress, w),
                  ),
            ]),
          ],
          for (final s in storiesFor(c.char)) ...[const SizedBox(height: 12), SizedBox(width: double.infinity, child: CharStoryCard(s))],
          if (_loaded && StrokeLibrary.instance.has(c.char)) ...[
            const SizedBox(height: 16),
            const Text('写一写 · Write it', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(
              child: CharacterWriter(
                char: c.char,
                size: 240,
                onComplete: (m) => setState(() => _written = m == 0 ? 'Perfect! No mistakes.' : 'Done, with $m slip${m == 1 ? '' : 's'}.'),
              ),
            ),
            if (_written != null) Center(child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(_written!))),
          ],
        ]),
      ),
    );
  }
}

// ---------------- The review corner ----------------

class TbCornerScreen extends StatefulWidget {
  final Progress progress;
  final TbUnit unit;
  const TbCornerScreen({super.key, required this.progress, required this.unit});

  @override
  State<TbCornerScreen> createState() => _TbCornerScreenState();
}

class _TbCornerScreenState extends State<TbCornerScreen> {
  bool _pinyin = Settings.instance.showPinyin;
  bool _english = true;

  TbUnit get _u => widget.unit;

  void _review() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TbQuizScreen(
          title: '${tbCornerLabel(_u)} · 字词句运用',
          build: () => buildTbReview(_u),
          note: 'Unit ${_u.number} review is done.',
          onFinish: (right, total) async {
            final xp = 10 + right;
            await widget.progress.finishTextbook(_u.corner.id, xp);
            return xp;
          },
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rad = _u.corner.radical;
    final done = widget.progress.textbookDone.contains(_u.corner.id);
    return Scaffold(
      appBar: AppBar(title: Text('${tbCornerLabel(_u)} · Review corner')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: quizGreen,
        foregroundColor: Colors.white,
        onPressed: _review,
        icon: const Icon(Icons.edit_note),
        label: Text(done ? 'DO THE REVIEW AGAIN' : 'DO THE REVIEW'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 100), children: [
            Text('${tbUnitLabel(_u)} · ${_u.title} · ${_u.titleEn}', style: TextStyle(color: scheme.onSurfaceVariant)),
            const _Section('识字加油站', 'Radical corner'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    TianZiGe(rad.radical, size: 72),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('"${rad.meaning}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(rad.note),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    for (final (ch, py, meaning) in rad.chars)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Speech.instance.say(ch),
                        child: SizedBox(
                          width: 82,
                          child: Column(children: [
                            Text(py, style: TextStyle(color: scheme.primary)),
                            TianZiGe(ch, size: 56),
                            Text(meaning, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11), maxLines: 2),
                          ]),
                        ),
                      ),
                  ]),
                ]),
              ),
            ),
            const _Section('我的发现', 'My discovery'),
            for (final (look, shows) in _u.corner.discoveries)
              Card(
                child: ListTile(
                  title: Text(look, style: const TextStyle(fontSize: 26)),
                  subtitle: Text(shows),
                  onTap: () => Speech.instance.say(look.replaceAll(RegExp(r'[^一-鿿]'), '')),
                ),
              ),
            _Section('日积月累', 'Learn by heart', sub: 'Read it a few times, then try to say it without looking.'),
            Wrap(spacing: 8, children: [
              FilterChip(label: const Text('Pinyin'), selected: _pinyin, onSelected: (v) => setState(() => _pinyin = v)),
              FilterChip(label: const Text('English'), selected: _english, onSelected: (v) => setState(() => _english = v)),
            ]),
            for (final p in _u.corner.poems)
              Card(
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(children: [
                          if (_pinyin) Text(p.titlePy, style: TextStyle(color: scheme.primary)),
                          Text(p.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(p.author ?? p.titleEn, style: TextStyle(color: scheme.onSurfaceVariant)),
                        ]),
                      ),
                      SizedBox(width: 48, child: _speakButton(p.lines.map((x) => x.text).join())),
                    ]),
                    const SizedBox(height: 10),
                    for (final line in p.lines) ...[
                      RubyLine(line, pinyin: _pinyin, center: true, size: 28),
                      if (_english)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(line.en, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                        ),
                    ],
                    if (p.note != null) _Tip(p.note!),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ---------------- Exercises ----------------

/// A round of textbook exercises (练习).
class TbQuizScreen extends StatefulWidget {
  final String title;
  final List<TbQuestion> Function() build;
  final Future<int> Function(int right, int total) onFinish; // returns the XP earned
  final String? note;
  final void Function(TbQuestion q, bool right)? onAnswer; // called after each check
  const TbQuizScreen({super.key, required this.title, required this.build, required this.onFinish, this.note, this.onAnswer});

  @override
  State<TbQuizScreen> createState() => _TbQuizScreenState();
}

class _TbQuizScreenState extends State<TbQuizScreen> {
  late List<TbQuestion> _qs = widget.build();
  int _i = 0;
  int? _picked;
  List<int> _built = [];
  bool _checked = false;
  bool _wasRight = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;

  TbQuestion get _q => _qs[_i];

  bool get _canCheck => switch (_q) {
        TbChoice _ => _picked != null,
        TbBuild b => _built.length == b.bank.length,
      };

  bool get _isRight => switch (_q) {
        TbChoice c => _picked == c.correct,
        TbBuild b => b.isRight([for (final i in _built) b.bank[i]]),
      };

  Future<void> _press() async {
    if (_done) return;
    if (!_checked) {
      if (!_canCheck) return;
      final right = _isRight;
      setState(() {
        _checked = true;
        _wasRight = right;
        if (right) _right++;
      });
      final q = _q;
      widget.onAnswer?.call(q, right);
      Speech.instance.say(switch (q) {
        TbChoice c => c.speak ?? '',
        TbBuild b => b.answer.join(),
      });
      return;
    }
    if (_i + 1 >= _qs.length) {
      final xp = await widget.onFinish(_right, _qs.length);
      if (!mounted) return;
      setState(() {
        _xp = xp;
        _done = true;
      });
      return;
    }
    setState(() {
      _i++;
      _picked = null;
      _built = [];
      _checked = false;
    });
  }

  void _again() => setState(() {
        _qs = widget.build();
        _i = 0;
        _picked = null;
        _built = [];
        _checked = false;
        _right = 0;
        _done = false;
      });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent || _done) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _press();
          return KeyEventResult.handled;
        }
        final n = int.tryParse(e.character ?? '');
        final q = _q;
        if (!_checked && n != null && q is TbChoice && n >= 1 && n <= q.options.length) {
          setState(() => _picked = n - 1);
          return KeyEventResult.handled;
        }
        if (!_checked && q is TbBuild && e.logicalKey == LogicalKeyboardKey.backspace && _built.isNotEmpty) {
          setState(() => _built.removeLast());
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? widget.title : '${widget.title} · ${_i + 1} of ${_qs.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _done
                ? RoundResults(title: '练习完成！ Well done!', right: _right, total: _qs.length, xp: _xp, note: widget.note, onAgain: _again)
                : Column(children: [
                    LinearProgressIndicator(value: _i / _qs.length),
                    Expanded(
                      child: ListView(
                        key: ValueKey(_i),
                        padding: const EdgeInsets.all(24),
                        children: [switch (_q) { TbChoice c => _choice(c), TbBuild b => _build(b) }],
                      ),
                    ),
                    QuizBottomBar(
                      checked: _checked,
                      right: _wasRight,
                      canPress: _checked || _canCheck,
                      correctAnswer: switch (_q) {
                        TbChoice c => c.options[c.correct],
                        TbBuild b => b.answer.join() + b.end,
                      },
                      explain: switch (_q) {
                        TbChoice c => c.explain,
                        TbBuild b => b.en,
                      },
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  Widget _heading(String text) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _choice(TbChoice c) {
    final scheme = Theme.of(context).colorScheme;
    final big = c.prompt.length <= 2 || c.promptIsPinyin;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading(c.heading),
      const SizedBox(height: 20),
      PopIn(
        child: Column(children: [
          if (c.promptIsPinyin)
            Text(c.prompt, style: TextStyle(fontSize: 44, color: scheme.primary, fontWeight: FontWeight.w600))
          else if (big)
            TianZiGe(c.prompt, size: 110)
          else
            Text(c.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30)),
          if (c.promptSub != null) ...[
            const SizedBox(height: 6),
            Text(c.promptSub!, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ]),
      ),
      const SizedBox(height: 28),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
        for (final (i, o) in c.options.indexed)
          SizedBox(
            width: c.bigOptions ? 120 : 300,
            child: AnswerTile(
              number: i + 1,
              selected: _picked == i,
              checked: _checked,
              isCorrect: i == c.correct,
              onTap: () => setState(() => _picked = i),
              child: Text(o, textAlign: TextAlign.center, style: TextStyle(fontSize: c.bigOptions ? 44 : 22)),
            ),
          ),
      ]),
    ]);
  }

  Widget _build(TbBuild b) {
    final scheme = Theme.of(context).colorScheme;
    Widget tile(String text, {bool ghost = false, VoidCallback? onTap}) {
      final py = Settings.instance.showPinyin ? tbWord(text.replaceAll(RegExp('[，。？！]'), ''))?.pinyin : null;
      return Opacity(
        opacity: ghost ? 0.25 : 1,
        child: Material(
          color: scheme.surface,
          shape: RoundedRectangleBorder(side: BorderSide(color: scheme.outlineVariant, width: 2), borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ghost || _checked ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(text, style: const TextStyle(fontSize: 26)),
                if (py != null) Text(py, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading('连词成句 · Put the words in order'),
      const SizedBox(height: 12),
      Text('"${b.en}"', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 20),
      Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outlineVariant, width: 2))),
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.end, children: [
          for (final i in _built) tile(b.bank[i], onTap: () => setState(() => _built.remove(i))),
          if (_built.length == b.bank.length && b.end.isNotEmpty) Text(b.end, style: const TextStyle(fontSize: 26)),
        ]),
      ),
      const SizedBox(height: 24),
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
        for (final (i, t) in b.bank.indexed)
          _built.contains(i) ? tile(t, ghost: true) : tile(t, onTap: () => setState(() => _built.add(i))),
      ]),
      const SizedBox(height: 12),
      Text('Tap the words in order. Tap a word above to take it back.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.outline)),
    ]);
  }
}
