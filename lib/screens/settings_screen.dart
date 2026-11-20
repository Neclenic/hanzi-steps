import 'package:flutter/material.dart';

import '../logic/progress.dart';
import '../logic/reminders.dart';
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
              const _Heading('Daily goal'),
              GoalPicker(progress: progress),
              ReminderSettings(progress: progress),
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

/// Choose how much XP a day to aim for.
class GoalPicker extends StatelessWidget {
  final Progress progress;
  const GoalPicker({super.key, required this.progress});

  static const goals = [(10, 'Relaxed'), (20, 'Steady'), (30, 'Serious'), (50, 'Intense')];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: progress,
        builder: (context, _) => ListTile(
          title: const Text('XP a day'),
          subtitle: Text('${goals.firstWhere((g) => g.$1 == progress.dailyGoal, orElse: () => goals[1]).$2}: '
              'about ${(progress.dailyGoal / 10).ceil()} ${progress.dailyGoal <= 10 ? 'lesson' : 'lessons'} a day'),
          trailing: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [for (final g in goals) ButtonSegment(value: g.$1, label: Text('${g.$1}'))],
            selected: {progress.dailyGoal},
            onSelectionChanged: (v) async {
              await progress.setDailyGoal(v.first);
              await refreshReminders(progress);
            },
          ),
        ),
      );
}

/// Turn the daily reminder on or off and pick its time.
class ReminderSettings extends StatelessWidget {
  final Progress progress;
  const ReminderSettings({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final s = Settings.instance;
    if (!Reminders.supported) {
      return const ListTile(
        leading: Icon(Icons.notifications_off_outlined),
        title: Text('Daily reminder'),
        subtitle: Text('Reminders work in the Windows and Mac apps, not in a web browser.'),
      );
    }
    final time = TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute);
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => Column(children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Daily reminder'),
          subtitle: Text(s.reminderOn
              ? 'Every day at ${time.format(context)}, unless you have already reached your goal'
              : 'Get a nudge to keep your streak going'),
          value: s.reminderOn,
          onChanged: (v) async {
            if (v) await Reminders.instance.requestPermission();
            s.reminderOn = v;
            await refreshReminders(progress);
          },
        ),
        if (s.reminderOn) ...[
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Reminder time'),
            trailing: OutlinedButton(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: time);
                if (t == null) return;
                s.setReminderTime(t.hour, t.minute);
                await refreshReminders(progress);
              },
              child: Text(time.format(context)),
            ),
          ),
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Send a test reminder now'),
            trailing: const Icon(Icons.send_outlined),
            onTap: () async {
              final ok = await Reminders.instance.showTest();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Notifications seem to be blocked. Check the notification settings of your computer.'),
                ));
              }
            },
          ),
        ],
      ]),
    );
  }
}
