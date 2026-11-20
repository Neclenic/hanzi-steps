import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/exercises.dart';
import '../logic/panda.dart';
import '../logic/progress.dart';
import '../screens/lesson_screen.dart';
import 'anim.dart';

/// The pet panda, drawn in code so it can breathe, blink and change its face.
class PandaView extends StatefulWidget {
  final PandaMood mood;
  final int stage; // 0 to 4: accessories appear as it grows
  final double size;
  const PandaView({super.key, required this.mood, required this.stage, this.size = 120});

  @override
  State<PandaView> createState() => _PandaViewState();
}

class _PandaViewState extends State<PandaView> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final AnimationController _hop = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loops = loopingAnimations && !MediaQuery.disableAnimationsOf(context);
    if (loops && widget.mood != PandaMood.asleep) {
      if (!_idle.isAnimating) _idle.repeat();
    } else {
      _idle.stop();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _hop.forward(from: 0),
        child: AnimatedBuilder(
          animation: Listenable.merge([_idle, _hop]),
          builder: (context, _) {
            final t = _idle.value;
            final hop = sin(_hop.value * pi) * 0.12;
            final breathe = 1 + 0.025 * sin(t * 2 * pi * 2);
            final blink = t > 0.6 && t < 0.64; // a quick blink every few seconds
            return Transform.translate(
              offset: Offset(0, -hop * widget.size),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 1.05,
                child: CustomPaint(
                  painter: PandaPainter(mood: widget.mood, stage: widget.stage, breathe: breathe, blink: blink),
                ),
              ),
            );
          },
        ),
      );
}

class PandaPainter extends CustomPainter {
  final PandaMood mood;
  final int stage;
  final double breathe;
  final bool blink;
  PandaPainter({required this.mood, required this.stage, this.breathe = 1, this.blink = false});

  static const _black = Color(0xFF2B2B2B);
  static const _white = Color(0xFFFFFFFF);
  static const _line = Color(0xFFBDBDBD);

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100; // the panda is drawn on a 100 × 105 grid
    Offset p(double x, double y) => Offset(x * u, y * u);
    final black = Paint()..color = _black;
    final white = Paint()..color = _white;
    final outline = Paint()
      ..color = _line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * u;
    void oval(Offset c, double rx, double ry, Paint paint, {double angle = 0}) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2 * u, height: ry * 2 * u), paint);
      canvas.restore();
    }

    final sad = mood == PandaMood.sad || mood == PandaMood.hungry;
    final asleep = mood == PandaMood.asleep;

    // Shadow.
    oval(p(50, 101), 30, 4, Paint()..color = Colors.black.withValues(alpha: 0.08));

    // Body, breathing in and out.
    canvas.save();
    canvas.translate(50 * u, 100 * u);
    canvas.scale(1, breathe);
    canvas.translate(-50 * u, -100 * u);
    oval(p(34, 95), 11, 7, black); // feet
    oval(p(66, 95), 11, 7, black);
    oval(p(50, 73), 29, 25, white);
    oval(p(50, 73), 29, 25, outline);
    // Arms: down when sad, up and waving a little when happy.
    final armUp = mood == PandaMood.happy ? -0.5 : 0.0;
    oval(p(25, 70), 8, 14, black, angle: 0.5 + armUp);
    oval(p(75, 70), 8, 14, black, angle: -0.5 - armUp);
    if (stage >= 3) {
      // A red scarf.
      final scarf = Paint()..color = const Color(0xFFD7263D);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30 * u, 57 * u, 40 * u, 7 * u), Radius.circular(3.5 * u)), scarf);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(56 * u, 60 * u, 7 * u, 15 * u), Radius.circular(3 * u)), scarf);
    }
    if (stage >= 2) {
      // A bamboo stick held in the right arm.
      final green = Paint()..color = const Color(0xFF6AA84F);
      final dark = Paint()
        ..color = const Color(0xFF3D7A2A)
        ..strokeWidth = 1 * u;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(79 * u, 42 * u, 6 * u, 46 * u), Radius.circular(3 * u)), green);
      for (final y in [55.0, 70.0]) {
        canvas.drawLine(p(79, y), p(85, y), dark);
      }
      oval(p(90, 46), 7, 2.6, green, angle: -0.5);
    }
    canvas.restore();

    // Ears and head.
    oval(p(27, 15), 9, 9, black);
    oval(p(73, 15), 9, 9, black);
    oval(p(50, 37), 28, 25, white);
    oval(p(50, 37), 28, 25, outline);
    if (stage >= 1 && stage < 4) {
      // A little bamboo leaf on one ear.
      oval(p(77, 7), 6, 2.4, Paint()..color = const Color(0xFF6AA84F), angle: -0.7);
    }

    // Eye patches droop when the panda is sad.
    final droop = sad ? 0.25 : 0.0;
    oval(p(38.5, 37), 8, 10.5, black, angle: -0.6 - droop);
    oval(p(61.5, 37), 8, 10.5, black, angle: 0.6 + droop);

    // Eyes.
    final eyeWhite = Paint()..color = _white;
    final pupil = Paint()..color = _black;
    final stroke = Paint()
      ..color = _white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8 * u;
    for (final x in [39.5, 60.5]) {
      if (asleep || blink) {
        // Closed eyes: a little curve.
        final path = Path()
          ..moveTo((x - 3.5) * u, 37 * u)
          ..quadraticBezierTo(x * u, 39.5 * u, (x + 3.5) * u, 37 * u);
        canvas.drawPath(path, stroke);
      } else if (mood == PandaMood.happy) {
        // Smiling eyes: ^ ^
        final path = Path()
          ..moveTo((x - 3.5) * u, 38.5 * u)
          ..quadraticBezierTo(x * u, 33 * u, (x + 3.5) * u, 38.5 * u);
        canvas.drawPath(path, stroke);
      } else {
        canvas.drawCircle(p(x, 36.5), 3.6 * u, eyeWhite);
        canvas.drawCircle(p(x, sad ? 38 : 36.8), 2 * u, pupil);
        canvas.drawCircle(p(x + 0.8, sad ? 37.2 : 36), 0.7 * u, eyeWhite);
      }
    }
    if (mood == PandaMood.sad) {
      // A tear.
      final tear = Path()
        ..moveTo(38 * u, 45 * u)
        ..quadraticBezierTo(35.5 * u, 50 * u, 38 * u, 51 * u)
        ..quadraticBezierTo(40.5 * u, 50 * u, 38 * u, 45 * u);
      canvas.drawPath(tear, Paint()..color = const Color(0xFF64B5F6));
    }

    // Cheeks.
    if (mood == PandaMood.happy || mood == PandaMood.content) {
      final blush = Paint()..color = const Color(0xFFF8A5B5).withValues(alpha: 0.7);
      oval(p(31, 47), 4, 2.5, blush);
      oval(p(69, 47), 4, 2.5, blush);
    }

    // Nose and mouth.
    oval(p(50, 46), 3.5, 2.4, black);
    final mouth = Paint()
      ..color = _black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4 * u;
    final m = Path()..moveTo(44 * u, 51.5 * u);
    switch (mood) {
      case PandaMood.happy:
        m.quadraticBezierTo(50 * u, 58 * u, 56 * u, 51.5 * u);
      case PandaMood.content:
      case PandaMood.asleep:
        m
          ..moveTo(46 * u, 51 * u)
          ..quadraticBezierTo(50 * u, 54.5 * u, 54 * u, 51 * u);
      case PandaMood.hungry:
        m
          ..moveTo(46.5 * u, 53 * u)
          ..lineTo(53.5 * u, 53 * u);
      case PandaMood.sad:
        m
          ..moveTo(45 * u, 55 * u)
          ..quadraticBezierTo(50 * u, 50 * u, 55 * u, 55 * u);
    }
    canvas.drawPath(m, mouth);

    if (stage >= 4) {
      // A graduation cap.
      final cap = Paint()..color = _black;
      final top = Path()
        ..moveTo(50 * u, 2 * u)
        ..lineTo(76 * u, 9 * u)
        ..lineTo(50 * u, 16 * u)
        ..lineTo(24 * u, 9 * u)
        ..close();
      canvas.drawRect(Rect.fromLTWH(38 * u, 10 * u, 24 * u, 8 * u), cap);
      canvas.drawPath(top, cap);
      canvas.drawLine(p(76, 9), p(78, 20), Paint()
        ..color = const Color(0xFFF4C430)
        ..strokeWidth = 1.2 * u);
      canvas.drawCircle(p(78, 21), 1.6 * u, Paint()..color = const Color(0xFFF4C430));
    }
    if (asleep) {
      final tp = TextPainter(
        text: TextSpan(text: 'z z', style: TextStyle(fontSize: 9 * u, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p(74, 22));
    }
  }

  @override
  bool shouldRepaint(PandaPainter old) =>
      old.mood != mood || old.stage != stage || old.breathe != breathe || old.blink != blink;
}

/// The panda on the home screen: it grows with your XP and its mood shows how your reviews are going.
class PandaCard extends StatelessWidget {
  final Progress progress;
  const PandaCard({super.key, required this.progress});

  Future<void> _rename(BuildContext context) async {
    final c = TextEditingController(text: progress.pandaName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name your panda'),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 16,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) await progress.setPandaName(name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final xp = progress.xp;
    final stage = pandaStageFor(xp);
    final mood = pandaMoodOf(progress);
    final due = progress.dueWords.length;
    final next = stage + 1 < pandaStages.length ? pandaStages[stage + 1] : null;
    final from = pandaStages[stage].xp;
    final canFeed = due > 0 && progress.wordsToPractice().length >= 2;
    return Card(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          PandaView(mood: mood, stage: stage, size: 76.0 + 9 * stage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: InkWell(
                    onTap: () => _rename(context),
                    child: Text(progress.pandaName,
                        overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 6),
                Text(pandaStages[stage].name, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ]),
              const SizedBox(height: 6),
              // A speech bubble.
              FadeSlideIn(
                key: ValueKey(mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(pandaSays(mood, name: progress.pandaName, due: due, daysAway: progress.daysAway)),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AnimatedBar(
                      value: next == null ? 1 : (xp - from) / (next.xp - from),
                      color: const Color(0xFF6AA84F),
                      height: 6,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next == null ? 'Fully grown!' : '${next.xp - xp} XP until ${next.name.toLowerCase()}',
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  ]),
                ),
                if (canFeed) ...[
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LessonScreen(lesson: practiceLesson(progress.wordsToPractice()), progress: progress),
                    )),
                    icon: const Text('🎋'),
                    label: const Text('Feed'),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
