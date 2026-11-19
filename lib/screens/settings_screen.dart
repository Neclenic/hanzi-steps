import 'package:flutter/material.dart';

import '../logic/progress.dart';
import '../logic/settings.dart';
import '../logic/speech.dart';

class SettingsScreen extends StatelessWidget {
  final Progress progress;
  const SettingsScreen({super.key, required this.progress});

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Start over?'),
        content: const Text('This clears your XP, streak, finished lessons and practice history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      await progress.reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress reset.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Settings.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
              const _Heading('Reading'),
              SwitchListTile(
                title: const Text('Show pinyin in questions'),
                subtitle: const Text(
                    'Turn off to practise reading the characters on their own. New-word cards always show pinyin.'),
                value: settings.showPinyin,
                onChanged: (v) => settings.showPinyin = v,
              ),
              const SizedBox(height: 16),
              const _Heading('Sound'),
              ValueListenableBuilder<bool>(
                valueListenable: Speech.instance.available,
                builder: (context, ok, _) => ok
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ListTile(
                          title: const Text('Speech speed'),
                          trailing: SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 0, label: Text('Slow')),
                              ButtonSegment(value: 1, label: Text('Normal')),
                            ],
                            selected: {settings.speechSpeed},
                            onSelectionChanged: (v) => settings.speechSpeed = v.first,
                          ),
                        ),
                        ListTile(
                          title: const Text('Test the voice'),
                          subtitle: const Text('你好，我是你的中文老师。'),
                          trailing: const Icon(Icons.volume_up),
                          onTap: () => Speech.instance.say('你好，我是你的中文老师。'),
                        ),
                      ])
                    : const ListTile(
                        leading: Icon(Icons.volume_off),
                        title: Text('No Chinese voice found on this computer'),
                        subtitle: Text('See the note on the home screen for how to add one.'),
                      ),
              ),
              const SizedBox(height: 16),
              const _Heading('Progress'),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset progress'),
                subtitle: const Text('Start the course again from the beginning.'),
                onTap: () => _reset(context),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(text,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      );
}
