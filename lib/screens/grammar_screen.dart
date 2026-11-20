import 'package:flutter/material.dart';

import '../data/course.dart';
import '../data/grammar.dart';
import '../logic/progress.dart';
import '../widgets/anim.dart';
import 'lesson_screen.dart' show GrammarCard;

/// Every grammar tip in one place, grouped by HSK level.
class GrammarScreen extends StatelessWidget {
  final Progress progress;
  const GrammarScreen({super.key, required this.progress});

  static (Unit, Lesson)? _where(String lessonId) {
    for (final u in course) {
      for (final l in u.lessons) {
        if (l.id == lessonId) return (u, l);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar tips')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Each tip also appears in its lesson. A tick means you have done that lesson.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            for (final level in levels) ...[
              if (grammarTips.any((t) => _where(t.lessonId)?.$1.level == level))
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text('HSK $level', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              for (final (i, tip) in grammarTips.where((t) => _where(t.lessonId)?.$1.level == level).indexed)
                FadeSlideIn(
                  delay: Duration(milliseconds: 40 * i),
                  child: Card(
                    child: ListTile(
                      leading: progress.isDone(_where(tip.lessonId)!.$2)
                          ? const Icon(Icons.check_circle, color: Color(0xFF2E9E5B))
                          : Icon(Icons.lightbulb_outline, color: scheme.primary),
                      title: Text(tip.title),
                      subtitle: Text('${tip.pattern}  ·  lesson "${_where(tip.lessonId)!.$2.title}"'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          body: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: GrammarCard(tip: tip)),
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
            ],
          ]),
        ),
      ),
    );
  }
}
