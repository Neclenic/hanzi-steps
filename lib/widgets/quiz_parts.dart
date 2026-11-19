import 'package:flutter/material.dart';

import 'anim.dart';

const quizGreen = Color(0xFF2E9E5B);
const quizRed = Color(0xFFD7263D);

/// One answer to tap. Turns green or red once the answer is checked.
class AnswerTile extends StatelessWidget {
  final Widget child;
  final int number; // shown as a small keyboard hint
  final bool selected;
  final bool checked;
  final bool isCorrect;
  final VoidCallback? onTap;
  const AnswerTile({
    super.key,
    required this.child,
    required this.number,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var border = scheme.outlineVariant;
    Color? bg;
    if (checked && isCorrect) {
      border = quizGreen;
      bg = quizGreen.withValues(alpha: 0.12);
    } else if (checked && selected) {
      border = quizRed;
      bg = quizRed.withValues(alpha: 0.12);
    } else if (selected) {
      border = scheme.primary;
      bg = scheme.primaryContainer.withValues(alpha: 0.5);
    }
    return Shake(
      trigger: checked && selected && !isCorrect ? true : null,
      child: PressBounce(
        child: Material(
          color: bg ?? scheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: checked ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(6)),
                  child: Text('$number', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ),
                const SizedBox(width: 12),
                Expanded(child: child),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// The bar at the bottom of a quiz: a CHECK or CONTINUE button, with "Nice!" or
/// "Not quite" and an explanation once the answer is checked.
class QuizBottomBar extends StatelessWidget {
  final bool checked;
  final bool right;
  final bool canPress;
  final String? correctAnswer; // shown when the answer was wrong
  final String? explain;
  final VoidCallback onPressed;
  final String? label; // overrides CHECK / CONTINUE
  final Widget? extra; // e.g. a "Say it" button under the feedback
  const QuizBottomBar({
    super.key,
    required this.checked,
    required this.right,
    required this.canPress,
    required this.onPressed,
    this.correctAnswer,
    this.explain,
    this.label,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wrong = checked && !right;
    return Container(
      color: checked ? (right ? quizGreen : quizRed).withValues(alpha: 0.12) : null,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (checked) ...[
          FadeSlideIn(
            from: const Offset(0, 0.4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(right ? Icons.check_circle : Icons.cancel, color: right ? quizGreen : quizRed),
                const SizedBox(width: 8),
                Text(right ? 'Nice!' : 'Not quite',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: right ? quizGreen : quizRed)),
              ]),
              if (wrong && correctAnswer != null) ...[
                const SizedBox(height: 4),
                Text('Correct answer: $correctAnswer', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
              if (explain != null) ...[const SizedBox(height: 4), Text(explain!)],
              ?extra,
            ]),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: wrong ? quizRed : quizGreen,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: canPress ? onPressed : null,
            child: Text((label ?? (checked ? 'Continue' : 'Check')).toUpperCase()),
          ),
        ),
      ]),
    );
  }
}

/// The end of a short round: score, XP and a button back.
class RoundResults extends StatelessWidget {
  final String title;
  final int right;
  final int total;
  final int xp;
  final String? note;
  final VoidCallback onAgain;
  const RoundResults({
    super.key,
    required this.title,
    required this.right,
    required this.total,
    required this.xp,
    required this.onAgain,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final great = total > 0 && right * 10 >= total * 8;
    return Stack(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            PopIn(child: Text(great ? '🎉' : '💪', style: const TextStyle(fontSize: 72))),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CountUp(value: right, suffix: ' / $total right', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('+$xp XP', style: TextStyle(fontSize: 18, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
            if (note != null) ...[
              const SizedBox(height: 12),
              Text(note!, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 28),
            Row(mainAxisSize: MainAxisSize.min, children: [
              OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('DONE')),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: quizGreen),
                onPressed: onAgain,
                child: const Text('AGAIN'),
              ),
            ]),
          ]),
        ),
      ),
      if (great) const Positioned.fill(child: Confetti()),
    ]);
  }
}
