import 'package:flutter/material.dart';

import '../data/course.dart';
import '../logic/progress.dart';
import '../logic/speech.dart';
import '../logic/weekly_report.dart';
import '../widgets/anim.dart';
import '../widgets/tone_shape.dart';

/// A summary of the last 7 days next to the 7 days before.
class WeeklyReportScreen extends StatefulWidget {
  final Progress progress;
  const WeeklyReportScreen({super.key, required this.progress});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  @override
  void initState() {
    super.initState();
    widget.progress.setReportSeen();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Weekly report')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [WeeklyReportView(progress: widget.progress)]),
          ),
        ),
      );
}

/// The report itself, also shown on the Stats page.
class WeeklyReportView extends StatelessWidget {
  final Progress progress;
  const WeeklyReportView({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = WeeklyReport.of(progress);
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 6));
    String d(DateTime t) => '${t.day}/${t.month}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Your week: ${d(from)} to ${d(now)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text('Compared with the 7 days before.', style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, c) {
        final perRow = c.maxWidth >= 480 ? 4 : 2;
        final w = (c.maxWidth - 8 * (perRow - 1)) / perRow;
        Widget tile(String emoji, String label, int value, int before, {String unit = ''}) =>
            SizedBox(width: w, child: _Tile(emoji: emoji, label: label, value: value, before: before, unit: unit));
        return Wrap(spacing: 8, runSpacing: 8, children: [
          tile('⚡', 'XP earned', r.now.xp, r.before.xp),
          tile('⏱️', 'Time in the app', r.now.minutes, r.before.minutes, unit: ' min'),
          tile('🌱', 'New words', r.now.newWords, r.before.newWords),
          tile('📅', 'Days practised', r.now.activeDays, r.before.activeDays, unit: ' of 7'),
        ]);
      }),
      const SizedBox(height: 12),
      Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Text('🔥', style: TextStyle(fontSize: 26)),
          title: Text(r.streak == 0 ? 'No streak right now' : '${r.streak}-day streak'),
          subtitle: Text(r.now.activeDays == 7 ? 'You practised every day this week. 太棒了!' : 'Practise a little every day to build it up.'),
        ),
      ),
      const SizedBox(height: 8),
      Card(
        margin: EdgeInsets.zero,
        child: r.weakestTone == null
            ? const ListTile(
                leading: Text('🎤', style: TextStyle(fontSize: 26)),
                title: Text('Weakest tone'),
                subtitle: Text('Do some speaking or tone practice to find out which tone needs work.'),
              )
            : ListTile(
                leading: ToneShape(tone: r.weakestTone!.$1, size: 36, color: scheme.primary),
                title: Text('Weakest tone: ${r.weakestTone!.$1 <= tones.length ? tones[r.weakestTone!.$1 - 1].name.toLowerCase() : 'tone ${r.weakestTone!.$1}'}'),
                subtitle: Text('${r.weakestTone!.$2} of ${r.weakestTone!.$3} right so far. The Tone pairs drill helps.'),
              ),
      ),
      const SizedBox(height: 8),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Trickiest words', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (r.tricky.isEmpty)
              Text('None yet. Words you get wrong will show here.', style: TextStyle(color: scheme.onSurfaceVariant))
            else
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (w, _) in r.tricky)
                  ActionChip(
                    label: Text('${w.hanzi} ${w.pinyin} · ${w.meaning}'),
                    onPressed: () => Speech.instance.say(w.hanzi),
                  ),
              ]),
          ]),
        ),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final String emoji, label, unit;
  final int value, before;
  const _Tile({required this.emoji, required this.label, required this.value, required this.before, this.unit = ''});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final diff = value - before;
    final up = diff > 0;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            AnimatedCount(value: value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Row(children: [
            if (diff != 0) Icon(up ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: up ? const Color(0xFF2E9E5B) : scheme.outline),
            Flexible(
              child: Text(
                diff == 0 ? 'same as last week' : '${diff.abs()} ${up ? 'more' : 'less'} than last week',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
