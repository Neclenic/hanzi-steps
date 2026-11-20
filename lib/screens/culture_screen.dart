import 'package:flutter/material.dart';

import '../data/course.dart';
import '../data/culture.dart';
import '../logic/progress.dart';
import '../widgets/anim.dart';
import 'lesson_screen.dart' show CultureCard;

(Unit, Lesson)? _where(String lessonId) {
  for (final u in course) {
    for (final l in u.lessons) {
      if (l.id == lessonId) return (u, l);
    }
  }
  return null;
}

/// Every culture note in one place, grouped by HSK level.
class CultureScreen extends StatelessWidget {
  final Progress progress;
  const CultureScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Culture notes')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Festivals, food, names and good manners. Each note also appears in its lesson.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            for (final level in levels) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text('HSK $level', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              for (final (i, note) in cultureNotes.where((n) => _where(n.lessonId)?.$1.level == level).indexed)
                FadeSlideIn(
                  delay: Duration(milliseconds: 40 * i),
                  child: Card(
                    child: ListTile(
                      leading: Text(note.emoji, style: const TextStyle(fontSize: 28)),
                      title: Text(note.title),
                      subtitle: Text('Lesson "${_where(note.lessonId)!.$2.title}"'),
                      trailing: progress.isDone(_where(note.lessonId)!.$2)
                          ? const Icon(Icons.check_circle, color: Color(0xFF2E9E5B))
                          : const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          body: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: CultureCard(note: note)),
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
