import 'package:flutter/material.dart';

import '../data/char_stories.dart';
import 'anim.dart';

/// Shows how a character is built: its parts, an equals sign, the character, and a memory hint.
class CharStoryCard extends StatelessWidget {
  final CharStory story;
  const CharStoryCard(this.story, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget part(CharPart p, int i) => FadeSlideIn(
          delay: Duration(milliseconds: 150 * i),
          from: const Offset(0, 0.4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(p.$1, style: TextStyle(fontSize: 34, color: scheme.primary)),
            Text(p.$2, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ]),
        );
    final sign = TextStyle(fontSize: 24, color: scheme.onSurfaceVariant);
    return Card(
      color: scheme.tertiaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_stories, size: 16, color: scheme.onTertiaryContainer),
            const SizedBox(width: 6),
            Text('Remember ${story.char}', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.onTertiaryContainer)),
          ]),
          if (story.parts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, children: [
              for (final (i, p) in story.parts.indexed) ...[
                if (i > 0) Text('+', style: sign),
                part(p, i),
              ],
              Text('=', style: sign),
              PopIn(child: Text(story.char, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600))),
            ]),
          ],
          const SizedBox(height: 8),
          Text(story.hint, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
