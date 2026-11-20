import 'progress.dart';

/// How the pet panda grows: one stage for each XP milestone.
class PandaStage {
  final int xp; // XP needed to reach this stage
  final String name;
  const PandaStage(this.xp, this.name);
}

const pandaStages = [
  PandaStage(0, 'Baby panda'),
  PandaStage(150, 'Little panda'),
  PandaStage(600, 'Young panda'),
  PandaStage(1500, 'Grown-up panda'),
  PandaStage(4000, 'Panda master'),
];

/// The stage (0 to 4) for an amount of XP.
int pandaStageFor(int xp) => pandaStages.lastIndexWhere((s) => xp >= s.xp);

enum PandaMood { asleep, happy, content, hungry, sad }

/// The panda's mood comes from how your studying is going:
/// happy when today's goal is reached, hungry when reviews are waiting,
/// and sad when lots of reviews pile up or you've been away for a few days.
PandaMood pandaMood({required int? daysAway, required int due, required bool goalMet}) {
  if (daysAway == null) return PandaMood.asleep;
  if (daysAway >= 3 || due >= 20) return PandaMood.sad;
  if (goalMet && due < 5) return PandaMood.happy;
  if (due >= 5) return PandaMood.hungry;
  return PandaMood.content;
}

PandaMood pandaMoodOf(Progress p) => pandaMood(daysAway: p.daysAway, due: p.dueWords.length, goalMet: p.goalMetToday);

/// What the panda says.
String pandaSays(PandaMood mood, {required String name, required int due, int? daysAway}) => switch (mood) {
      PandaMood.asleep => 'Zzz… Hi, I\'m $name! Finish your first lesson to wake me up.',
      PandaMood.happy => 'Yum, that was a great day! 太好了! Thanks for feeding me.',
      PandaMood.content => 'Hi! Let\'s learn something new today.',
      PandaMood.hungry => 'My tummy is rumbling… $due words are waiting for review. Feed me?',
      PandaMood.sad => daysAway != null && daysAway >= 3
          ? 'I missed you! It\'s been $daysAway days.${due == 0 ? ' Let\'s learn something together.' : ' $due ${due == 1 ? 'word is' : 'words are'} waiting.'}'
          : 'So hungry… $due words are waiting for review. Please feed me!',
    };
