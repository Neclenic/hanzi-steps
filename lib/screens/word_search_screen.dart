import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/word_lookup.dart';
import '../widgets/word_sheet.dart';

/// Look up any word in the course by characters, pinyin or English.
class WordSearchScreen extends StatefulWidget {
  final Progress progress;
  final String initialQuery;
  const WordSearchScreen({super.key, required this.progress, this.initialQuery = ''});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  late final _query = TextEditingController(text: widget.initialQuery);

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _query.text.trim();
    final results = q.isEmpty ? courseWords : searchWords(q);
    return Scaffold(
      appBar: AppBar(title: const Text('Word search')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                key: const ValueKey('searchInput'),
                controller: _query,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _query.clear),
                  hintText: 'Characters, pinyin or English: 好, hao3, good',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  q.isEmpty
                      ? 'All ${courseWords.length} words in the course'
                      : results.isEmpty
                          ? 'No course word matches "$q".'
                          : '${results.length} ${results.length == 1 ? 'word' : 'words'}',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                itemCount: results.length,
                itemBuilder: (context, i) => WordRow(word: results[i], progress: widget.progress),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// One word in a list: characters, pinyin, meaning and HSK level. Tap for details.
class WordRow extends StatelessWidget {
  final Word word;
  final Progress progress;
  final Widget? trailing;
  const WordRow({super.key, required this.word, required this.progress, this.trailing});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final level = levelOfWord(word.hanzi);
    return ListTile(
      onTap: () => showWordSheet(context, progress, word),
      leading: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64),
        child: Text(word.hanzi, style: const TextStyle(fontSize: 26)),
      ),
      title: Text(word.pinyin, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
      subtitle: Text(word.meaning, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing ??
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (level != null)
              Text('HSK $level', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
            MyWordButton(hanzi: word.hanzi, progress: progress, compact: true),
          ]),
    );
  }
}
