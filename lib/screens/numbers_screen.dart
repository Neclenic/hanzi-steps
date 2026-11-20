import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/numbers.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';
import 'lesson_screen.dart' show SpeakButton;

const _kindInfo = {
  NumberKind.price: ('💴', 'Prices', 'How much is it?'),
  NumberKind.phone: ('📱', 'Phone numbers', 'Type the number you hear'),
  NumberKind.date: ('📅', 'Dates', 'Days, months and weekdays'),
  NumberKind.time: ('🕒', 'Clock times', 'Morning, afternoon and evening'),
};

/// Pick what to practise: prices, phone numbers, dates, clock times, or a mix.
class NumbersScreen extends StatelessWidget {
  final Progress progress;
  const NumbersScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    void open(NumberKind? kind) => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NumberRoundScreen(progress: progress, kind: kind),
        ));
    return Scaffold(
      appBar: AppBar(title: const Text('Numbers in real life')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(
              'Prices, phone numbers, dates and times come up all the time, and they go by fast. '
              'Each round has 10 questions.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            for (final (i, k) in NumberKind.values.indexed)
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * i),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => open(k),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_kindInfo[k]!.$1, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_kindInfo[k]!.$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(numberTips[k]!, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                          ]),
                        ),
                        const Icon(Icons.chevron_right),
                      ]),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Center(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: quizGreen),
                onPressed: () => open(null),
                icon: const Icon(Icons.shuffle),
                label: const Text('MIX OF EVERYTHING'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

enum NumberAsk { listen, read, write, type }

class NumberQuestion {
  final LifeNumber answer;
  final NumberAsk ask;
  final List<LifeNumber> options; // empty for typing questions
  const NumberQuestion(this.answer, this.ask, this.options);
}

/// A round of number questions. Listening questions need a Chinese voice;
/// phone numbers are typed as digits.
List<NumberQuestion> buildNumberRound(NumberKind? kind, {int n = 10, bool voice = false, Random? random}) {
  final r = random ?? Random();
  final out = <NumberQuestion>[];
  final seen = <String>{};
  while (out.length < n) {
    final k = kind ?? NumberKind.values[out.length % NumberKind.values.length];
    final a = randomLifeNumber(k, r);
    if (!seen.add(a.figures)) continue;
    if (k == NumberKind.phone) {
      out.add(NumberQuestion(a, NumberAsk.type, const []));
      continue;
    }
    final asks = [if (voice) NumberAsk.listen, if (voice) NumberAsk.listen, NumberAsk.read, NumberAsk.write];
    final opts = [a, ...numberDistractors(a, r)]..shuffle(r);
    out.add(NumberQuestion(a, asks[r.nextInt(asks.length)], opts));
  }
  if (kind == null) out.shuffle(r);
  return out;
}

class NumberRoundScreen extends StatefulWidget {
  final Progress progress;
  final NumberKind? kind; // null: a mix of everything
  final List<NumberQuestion>? questions;
  const NumberRoundScreen({super.key, required this.progress, this.kind, this.questions});

  @override
  State<NumberRoundScreen> createState() => _NumberRoundScreenState();
}

class _NumberRoundScreenState extends State<NumberRoundScreen> {
  late List<NumberQuestion> _qs = widget.questions ?? _build();
  int _i = 0;
  int? _picked;
  bool _checked = false;
  int _right = 0;
  bool _done = false;
  int _xp = 0;
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _pageFocus = FocusNode();

  List<NumberQuestion> _build() => buildNumberRound(widget.kind, voice: Speech.instance.available.value);

  NumberQuestion get _q => _qs[_i];
  bool get _voice => Speech.instance.available.value;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (_q.ask == NumberAsk.type ? _inputFocus : _pageFocus).requestFocus();
    });
    _play();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _pageFocus.dispose();
    super.dispose();
  }

  void _play() {
    final q = _q;
    if (!_voice || !(q.ask == NumberAsk.listen || q.ask == NumberAsk.type)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_done) Speech.instance.say(q.answer.speak);
    });
  }

  bool get _isRight => _q.ask == NumberAsk.type
      ? _input.text.replaceAll(RegExp(r'\D'), '') == _q.answer.figures.replaceAll(' ', '')
      : _picked != null && _q.options[_picked!] == _q.answer;

  bool get _canPress => _checked || (_q.ask == NumberAsk.type ? _input.text.trim().isNotEmpty : _picked != null);

  Future<void> _press() async {
    if (!_canPress || _done) return;
    if (!_checked) {
      final right = _isRight;
      setState(() {
        _checked = true;
        if (right) _right++;
      });
      _pageFocus.requestFocus();
      Speech.instance.say(_q.answer.speak);
      if (right) await widget.progress.bump('numbersRight');
      return;
    }
    if (_i + 1 >= _qs.length) {
      _xp = 5 + _right;
      await widget.progress.addXp(_xp);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _i++;
      _picked = null;
      _checked = false;
      _input.clear();
    });
    (_q.ask == NumberAsk.type ? _inputFocus : _pageFocus).requestFocus();
    _play();
  }

  void _again() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (_q.ask == NumberAsk.type ? _inputFocus : _pageFocus).requestFocus();
    });
    setState(() {
      _qs = _build();
      _i = 0;
      _picked = null;
      _checked = false;
      _right = 0;
      _done = false;
      _input.clear();
    });
    _play();
  }

  String get _title => widget.kind == null ? 'Numbers' : _kindInfo[widget.kind]!.$2;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _pageFocus,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent || _done) return KeyEventResult.ignored;
        final k = e.logicalKey;
        if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
          _press();
          return KeyEventResult.handled;
        }
        final n = int.tryParse(e.character ?? '');
        if (!_checked && _q.ask != NumberAsk.type && n != null && n >= 1 && n <= _q.options.length) {
          setState(() => _picked = n - 1);
          return KeyEventResult.handled;
        }
        if (k == LogicalKeyboardKey.keyR && _q.ask != NumberAsk.type) {
          Speech.instance.say(_q.answer.speak);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_done ? _title : '$_title · ${_i + 1} of ${_qs.length}')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _done
                ? RoundResults(
                    title: 'Numbers round done!',
                    right: _right,
                    total: _qs.length,
                    xp: _xp,
                    onAgain: _again,
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(
                        key: ValueKey(_i),
                        padding: const EdgeInsets.all(24),
                        children: [_question(context)],
                      ),
                    ),
                    QuizBottomBar(
                      checked: _checked,
                      right: _checked && _isRight,
                      canPress: _canPress,
                      correctAnswer: _q.ask == NumberAsk.write ? _q.answer.hanzi : _q.answer.figures,
                      explain: '${_q.answer.hanzi} (${_q.answer.pinyin}) = ${_q.answer.figures}',
                      onPressed: _press,
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  Widget _question(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _q;
    final a = q.answer;
    final showPinyin = Settings.instance.showPinyin;
    Widget heading(String t) => Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
    switch (q.ask) {
      case NumberAsk.type:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          heading(_voice ? 'Type the phone number you hear' : 'Type this phone number in digits'),
          const SizedBox(height: 20),
          if (_voice)
            Center(child: SpeakButton(a.speak, size: 88, filled: true))
          else
            Center(child: Text(a.pinyin, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: scheme.primary))),
          if (_checked) ...[
            const SizedBox(height: 12),
            Center(child: PopIn(child: Text(a.hanzi, style: const TextStyle(fontSize: 26)))),
          ],
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('digitsInput'),
            controller: _input,
            focusNode: _inputFocus,
            enabled: !_checked,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
            style: const TextStyle(fontSize: 26, letterSpacing: 2),
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Type the 11 digits'),
            onSubmitted: (_) => _press(),
          ),
          const SizedBox(height: 8),
          Text('Remember: 幺 yāo is 1 in phone numbers.', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]);
      case NumberAsk.listen:
      case NumberAsk.read:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          heading(q.ask == NumberAsk.listen ? 'Listen. Which one did you hear?' : 'What does this say?'),
          const SizedBox(height: 20),
          if (q.ask == NumberAsk.listen)
            Center(child: SpeakButton(a.speak, size: 88, filled: true))
          else
            Center(
              child: PopIn(
                child: Column(children: [
                  Text(a.hanzi, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36)),
                  if (showPinyin) Text(a.pinyin, style: TextStyle(fontSize: 16, color: scheme.primary)),
                ]),
              ),
            ),
          const SizedBox(height: 24),
          ..._options((o) => Text(o.figures, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
        ]);
      case NumberAsk.write:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          heading('How do you say this in Chinese?'),
          const SizedBox(height: 20),
          Center(child: PopIn(child: Text(a.figures, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 24),
          ..._options((o) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.hanzi, style: const TextStyle(fontSize: 24)),
                if (showPinyin) Text(o.pinyin, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ])),
        ]);
    }
  }

  List<Widget> _options(Widget Function(LifeNumber) label) => [
        for (final (i, o) in _q.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnswerTile(
              number: i + 1,
              selected: _picked == i,
              checked: _checked,
              isCorrect: o == _q.answer,
              onTap: () {
                setState(() => _picked = i);
                if (_q.ask == NumberAsk.write) Speech.instance.say(o.speak);
              },
              child: label(o),
            ),
          ),
      ];
}
