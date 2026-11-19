import 'dart:math';

import 'package:flutter/material.dart';

/// Small reusable animations that make the app feel alive.

/// Turn off the animations that repeat forever (tests set this to false so
/// that "wait until everything has settled" can finish).
bool loopingAnimations = true;

bool _loops(BuildContext context) => loopingAnimations && !MediaQuery.disableAnimationsOf(context);

/// Fades and slides its child in when it first appears, after [delay].
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset from; // starting offset, as a fraction of the child's size
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero, this.from = const Offset(0, 0.25)});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _t,
        child: SlideTransition(position: Tween(begin: widget.from, end: Offset.zero).animate(_t), child: widget.child),
      );
}

/// Shrinks slightly while pressed, then springs back, like a physical button.
class PressBounce extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const PressBounce({super.key, required this.child, this.enabled = true});

  @override
  State<PressBounce> createState() => _PressBounceState();
}

class _PressBounceState extends State<PressBounce> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: widget.enabled ? (_) => setState(() => _down = true) : null,
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// A soft pulsing ring behind its child, used to point at the next lesson.
class PulseRing extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  const PulseRing({super.key, required this.child, required this.color, required this.size});

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loops(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size * 1.6,
        height: widget.size * 1.6,
        child: Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = Curves.easeOut.transform(_c.value);
              return Container(
                width: widget.size * (1 + 0.55 * t),
                height: widget.size * (1 + 0.55 * t),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.35 * (1 - t)),
                ),
              );
            },
          ),
          widget.child,
        ]),
      );
}

/// Gently floats up and down.
class Bob extends StatefulWidget {
  final Widget child;
  const Bob({super.key, required this.child});

  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends State<Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loops(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -5 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: widget.child,
      );
}

/// Shakes sideways once each time [trigger] changes. Used for wrong answers.
class Shake extends StatefulWidget {
  final Widget child;
  final Object? trigger;
  const Shake({super.key, required this.child, this.trigger});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && widget.trigger != null) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(sin(_c.value * pi * 6) * 10 * (1 - _c.value), 0),
          child: child,
        ),
        child: widget.child,
      );
}

/// Pops in with a little overshoot.
class PopIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const PopIn({super.key, required this.child, this.duration = const Duration(milliseconds: 450)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1),
        duration: duration,
        curve: Curves.elasticOut,
        builder: (context, v, child) => Transform.scale(scale: v, child: child),
        child: child,
      );
}

/// Counts up to [value] (e.g. XP earned).
class CountUp extends StatelessWidget {
  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  const CountUp({super.key, required this.value, this.prefix = '', this.suffix = '', this.style});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text('$prefix${v.round()}$suffix', style: style),
      );
}

/// A burst of falling confetti, played once.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
    ..forward();
  final _pieces = List.generate(70, (i) => _Piece(Random(i)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_pieces, _c.value)),
        ),
      );
}

class _Piece {
  final double x, speed, drift, spin, size;
  final Color color;
  _Piece(Random r)
      : x = r.nextDouble(),
        speed = 0.6 + r.nextDouble() * 0.7,
        drift = (r.nextDouble() - 0.5) * 0.3,
        spin = r.nextDouble() * 12,
        size = 6 + r.nextDouble() * 6,
        color = const [
          Color(0xFFE4572E),
          Color(0xFF2E86AB),
          Color(0xFF3BB273),
          Color(0xFFF1C40F),
          Color(0xFF7768AE),
          Color(0xFFD7263D),
        ][r.nextInt(6)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    for (final p in pieces) {
      final y = -20 + (size.height + 40) * (t * p.speed);
      final x = size.width * (p.x + p.drift * t) + sin(t * 10 + p.spin) * 12;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.spin);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        Paint()..color = p.color.withValues(alpha: (1 - t).clamp(0, 1)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Animates a number from its previous value to the new one whenever it changes.
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;
  const AnimatedCount({super.key, required this.value, this.style, this.suffix = ''});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text('${v.round()}$suffix', style: style),
      );
}

/// A progress bar that fills smoothly to [value] (0 to 1).
class AnimatedBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? background;
  const AnimatedBar({super.key, required this.value, this.height = 10, this.color, this.background});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: v,
            minHeight: height,
            color: color,
            backgroundColor: background ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      );
}

/// A ring that fills smoothly to [value] (0 to 1), with [child] in the middle.
class AnimatedRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget? child;
  const AnimatedRing({super.key, required this.value, required this.color, this.size = 56, this.stroke = 6, this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => SizedBox(
          width: size,
          height: size,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: stroke,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: color.withValues(alpha: 0.18),
              ),
            ),
            if (child != null) child,
          ]),
        ),
        child: child,
      );
}
