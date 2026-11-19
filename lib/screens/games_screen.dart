import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';
import '../widgets/anim.dart';
import '../widgets/quiz_parts.dart';

/// Words for the games: the ones you've learned, or the first lessons' words to start with.
/// No two words share a meaning, so every match is clear.
List<Word> gameWords(Progress progress) {
  final out = <Word>[];
  final meanings = <String>{}, hanzi = <String>{};
  void add(Word w) {
    if (hanzi.add(w.hanzi) && meanings.add(w.meaning)) out.add(w);
  }

  progress.learnedWords.forEach(add);
  if (out.length < 12) {
    for (final l in lessonsOf(1).where((l) => l.words.isNotEmpty).take(4)) {
      l.words.forEach(add);
    }
  }
  return out;
}

/// XP for a game score: a little for playing, more for scoring, at most 15.
int gameXp(int score) => min(15, 2 + score ~/ 2);

/// Choose a quick game.
class GamesScreen extends StatelessWidget {
  final Progress progress;
  const GamesScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget card(String emoji, String title, String text, String game, Widget Function() screen, int i) => FadeSlideIn(
          delay: Duration(milliseconds: 100 * i),
          child: PressBounce(
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen())),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Bob(child: Text(emoji, style: const TextStyle(fontSize: 48))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(text),
                        const SizedBox(height: 6),
                        Text('Best: ${progress.gameBest(game)}', style: TextStyle(color: scheme.onSurfaceVariant)),
                      ]),
                    ),
                    const Icon(Icons.play_circle_fill, size: 40, color: quizGreen),
                  ]),
                ),
              ),
            ),
          ),
        );
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Quick games')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text('Short games with the words you have learned.', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              card('⚡', 'Speed match', 'Match characters with their meanings. How many can you get in 60 seconds?', 'match',
                  () => SpeedMatchGame(progress: progress), 0),
              card('🌧️', 'Falling characters', 'Characters fall from the sky. Tap the one that matches the meaning before it lands. Three lives.',
                  'fall', () => FallingGame(progress: progress), 1),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The end of a game: score, best score and XP.
class _GameOver extends StatelessWidget {
  final int score;
  final int best;
  final bool newBest;
  final int xp;
  final VoidCallback onAgain;
  const _GameOver({required this.score, required this.best, required this.newBest, required this.xp, required this.onAgain});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(children: [
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          PopIn(child: Text(newBest ? '🏆' : '⭐', style: const TextStyle(fontSize: 72))),
          const SizedBox(height: 8),
          Text(newBest ? 'New best score!' : 'Game over', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CountUp(value: score, suffix: ' points', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          Text('Best: $best', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('+$xp XP', style: TextStyle(fontSize: 18, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('DONE')),
            const SizedBox(width: 12),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: quizGreen), onPressed: onAgain, child: const Text('PLAY AGAIN')),
          ]),
        ]),
      ),
      if (newBest) const Positioned.fill(child: Confetti()),
    ]);
  }
}

// ---------------- Speed match ----------------

class SpeedMatchGame extends StatefulWidget {
  final Progress progress;
  final Duration time;
  const SpeedMatchGame({super.key, required this.progress, this.time = const Duration(seconds: 60)});

  @override
  State<SpeedMatchGame> createState() => _SpeedMatchGameState();
}

class _SpeedMatchGameState extends State<SpeedMatchGame> {
  static const _slots = 5;
  final _random = Random();
  late final List<Word> _pool = gameWords(widget.progress);
  late List<Word> _left, _right;
  int? _pickL, _pickR;
  int _score = 0;
  int _combo = 0;
  int _wrongTick = 0;
  (int, int)? _wrongPair;
  late Duration _timeLeft = widget.time;
  Timer? _timer;
  bool _over = false;
  bool _newBest = false;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final first = ([..._pool]..shuffle(_random)).take(_slots).toList();
    _left = [...first]..shuffle(_random);
    _right = [...first]..shuffle(_random);
    _pickL = _pickR = null;
    _score = 0;
    _combo = 0;
    _over = false;
    _timeLeft = widget.time;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_over) return;
      setState(() => _timeLeft -= const Duration(milliseconds: 100));
      if (_timeLeft <= Duration.zero) _end();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _end() async {
    _timer?.cancel();
    _xp = gameXp(_score);
    _over = true;
    _newBest = await widget.progress.finishGame('match', _score, _xp);
    if (mounted) setState(() {});
  }

  /// A word that isn't on the board, for an empty slot.
  Word _fresh() {
    final on = {..._left.map((w) => w.hanzi)};
    final free = _pool.where((w) => !on.contains(w.hanzi)).toList();
    return free.isEmpty ? _pool[_random.nextInt(_pool.length)] : free[_random.nextInt(free.length)];
  }

  void _tap(bool leftSide, int i) {
    if (_over) return;
    setState(() {
      if (leftSide) {
        _pickL = i;
        Speech.instance.say(_left[i].hanzi);
      } else {
        _pickR = i;
      }
      if (_pickL == null || _pickR == null) return;
      final l = _pickL!, r = _pickR!;
      if (_left[l].hanzi == _right[r].hanzi) {
        _score++;
        _combo++;
        final w = _fresh();
        _left[l] = w;
        _right[r] = w;
      } else {
        _combo = 0;
        _wrongTick++;
        _wrongPair = (l, r);
      }
      _pickL = _pickR = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secs = (_timeLeft.inMilliseconds / 1000).ceil();
    return Scaffold(
      appBar: AppBar(title: const Text('Speed match')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _over
              ? _GameOver(
                  score: _score,
                  best: widget.progress.gameBest('match'),
                  newBest: _newBest,
                  xp: _xp,
                  onAgain: () => setState(_start),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      Icon(Icons.timer_outlined, color: secs <= 10 ? quizRed : scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('$secs s',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secs <= 10 ? quizRed : null)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedBar(
                          value: _timeLeft.inMilliseconds / widget.time.inMilliseconds,
                          color: secs <= 10 ? quizRed : quizGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedCount(value: _score, suffix: ' pts', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    SizedBox(
                      height: 28,
                      child: _combo >= 3
                          ? PopIn(key: ValueKey(_combo), child: Text('🔥 $_combo in a row!', style: const TextStyle(fontWeight: FontWeight.bold)))
                          : null,
                    ),
                    Expanded(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Expanded(child: _column(true, scheme)),
                        const SizedBox(width: 12),
                        Expanded(child: _column(false, scheme)),
                      ]),
                    ),
                  ]),
                ),
        ),
      ),
    );
  }

  Widget _column(bool leftSide, ColorScheme scheme) {
    final words = leftSide ? _left : _right;
    final pick = leftSide ? _pickL : _pickR;
    return Column(children: [
      for (final (i, w) in words.indexed)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Shake(
              trigger: _wrongPair != null && (leftSide ? _wrongPair!.$1 : _wrongPair!.$2) == i ? _wrongTick : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Material(
                  key: ValueKey('${w.hanzi}$leftSide$i'),
                  color: pick == i ? scheme.primaryContainer : scheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: pick == i ? scheme.primary : scheme.outlineVariant, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _tap(leftSide, i),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          leftSide ? w.hanzi : w.meaning,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: leftSide ? 30 : 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

// ---------------- Falling characters ----------------

class _Drop {
  final int id;
  final Word word;
  final int lane;
  double y = 0; // 0 at the top, 1 at the bottom
  _Drop(this.id, this.word, this.lane);
}

class _Pop {
  final double x, y;
  final String text;
  final Color color;
  double age = 0;
  _Pop(this.x, this.y, this.text, this.color);
}

class FallingGame extends StatefulWidget {
  final Progress progress;
  final Random? random;
  const FallingGame({super.key, required this.progress, this.random});

  @override
  State<FallingGame> createState() => _FallingGameState();
}

class _FallingGameState extends State<FallingGame> with SingleTickerProviderStateMixin {
  static const lanes = 4;
  late final Random _random = widget.random ?? Random();
  late final List<Word> _pool = gameWords(widget.progress);
  late final Ticker _ticker = createTicker(_tick);
  final List<_Drop> _drops = [];
  final List<_Pop> _pops = [];
  late Word _target;
  int _nextId = 0;
  int _score = 0;
  int _lives = 3;
  int _sinceTarget = 0;
  double _spawnIn = 0;
  Duration _last = Duration.zero;
  bool _over = false;
  bool _newBest = false;
  int _xp = 0;
  int _hurt = 0; // changes when a life is lost, to shake the hearts

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    _drops.clear();
    _pops.clear();
    _score = 0;
    _lives = 3;
    _over = false;
    _spawnIn = 0.3;
    _last = Duration.zero;
    _newTarget();
    if (!_ticker.isActive) _ticker.start();
  }

  void _newTarget() {
    final old = _drops.isEmpty && _score == 0 ? null : _target.hanzi;
    final others = _pool.where((w) => w.hanzi != old).toList();
    _target = others[_random.nextInt(others.length)];
    _sinceTarget = 2; // make the new target come soon
    if (Speech.instance.available.value) Speech.instance.say(_target.hanzi);
  }

  /// How fast drops fall (screen heights per second) and how often they come; both speed up as you score.
  double get _speed => min(0.42, 0.16 + _score * 0.012);
  double get _gap => max(0.55, 1.3 - _score * 0.03);

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    if (_over) return;
    setState(() {
      for (final d in _drops) {
        d.y += _speed * dt;
      }
      for (final p in _pops) {
        p.age += dt;
      }
      _pops.removeWhere((p) => p.age > 0.8);
      // A drop reached the ground.
      for (final d in _drops.where((d) => d.y >= 1).toList()) {
        _drops.remove(d);
        if (d.word.hanzi == _target.hanzi) {
          _loseLife(d, 'missed');
          if (!_over) _newTarget();
        }
      }
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = _gap;
      }
    });
  }

  void _spawn() {
    final targetOnScreen = _drops.any((d) => d.word.hanzi == _target.hanzi);
    final Word word;
    if (!targetOnScreen && (_sinceTarget >= 2 || _random.nextDouble() < 0.4)) {
      word = _target;
      _sinceTarget = 0;
    } else {
      final others = _pool.where((w) => w.hanzi != _target.hanzi && !_drops.any((d) => d.word.hanzi == w.hanzi)).toList();
      if (others.isEmpty) return;
      word = others[_random.nextInt(others.length)];
      _sinceTarget++;
    }
    // Use a lane whose last drop has moved well down, so drops don't overlap.
    final free = [
      for (var l = 0; l < lanes; l++)
        if (_drops.where((d) => d.lane == l).every((d) => d.y > 0.25)) l,
    ];
    if (free.isEmpty) return;
    _drops.add(_Drop(_nextId++, word, free[_random.nextInt(free.length)]));
  }

  void _loseLife(_Drop d, String why) {
    _lives--;
    _hurt++;
    _pops.add(_Pop((d.lane + 0.5) / lanes, min(d.y, 0.95), why == 'missed' ? 'missed!' : '✗', quizRed));
    if (_lives <= 0) _end();
  }

  Future<void> _end() async {
    _over = true;
    _ticker.stop();
    _xp = gameXp(_score);
    _newBest = await widget.progress.finishGame('fall', _score, _xp);
    if (mounted) setState(() {});
  }

  void _tapDrop(_Drop d) {
    if (_over || !_drops.contains(d)) return;
    setState(() {
      _drops.remove(d);
      if (d.word.hanzi == _target.hanzi) {
        _score++;
        _pops.add(_Pop((d.lane + 0.5) / lanes, d.y, '+1', quizGreen));
        _newTarget();
      } else {
        _loseLife(d, 'wrong');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Falling characters')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _over
              ? _GameOver(
                  score: _score,
                  best: widget.progress.gameBest('fall'),
                  newBest: _newBest,
                  xp: _xp,
                  onAgain: () => setState(_start),
                )
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(children: [
                      Shake(
                        trigger: _hurt == 0 ? null : _hurt,
                        child: Row(children: [
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: AnimatedScale(
                                scale: i < _lives ? 1 : 0.7,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(i < _lives ? Icons.favorite : Icons.favorite_border, color: quizRed),
                              ),
                            ),
                        ]),
                      ),
                      const Spacer(),
                      AnimatedCount(value: _score, suffix: ' pts', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [scheme.primaryContainer.withValues(alpha: 0.35), scheme.surfaceContainerLow],
                            ),
                          ),
                          child: LayoutBuilder(builder: (context, c) => _field(c, scheme)),
                        ),
                      ),
                    ),
                  ),
                  _prompt(scheme),
                ]),
        ),
      ),
    );
  }

  Widget _field(BoxConstraints c, ColorScheme scheme) {
    const tile = 72.0;
    final laneW = c.maxWidth / lanes;
    final travel = c.maxHeight - tile;
    final pinyin = Settings.instance.showPinyin;
    return Stack(children: [
      for (final d in _drops)
        Positioned(
          key: ValueKey(d.id),
          left: d.lane * laneW + (laneW - tile) / 2,
          top: d.y * travel,
          width: tile,
          height: tile,
          child: GestureDetector(
            onTapDown: (_) => _tapDrop(d),
            child: Material(
              elevation: 3,
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: scheme.outlineVariant, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FittedBox(child: Text(d.word.hanzi, style: const TextStyle(fontSize: 30))),
                  if (pinyin)
                    FittedBox(child: Text(d.word.pinyin, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant))),
                ]),
              ),
            ),
          ),
        ),
      for (final p in _pops)
        Positioned(
          left: p.x * c.maxWidth - 40,
          top: p.y * travel - 30 * p.age,
          width: 80,
          child: IgnorePointer(
            child: Opacity(
              opacity: (1 - p.age / 0.8).clamp(0.0, 1.0),
              child: Text(p.text,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: p.color)),
            ),
          ),
        ),
    ]);
  }

  Widget _prompt(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(children: [
          const Text('Catch:', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: a, child: c)),
              child: Text(
                '"${_target.meaning}"',
                key: ValueKey(_target.hanzi),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (Speech.instance.available.value)
            IconButton(
              tooltip: 'Hear it',
              onPressed: () => Speech.instance.say(_target.hanzi),
              icon: const Icon(Icons.volume_up),
            ),
        ]),
      );
}
