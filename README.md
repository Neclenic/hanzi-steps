# Hanzi Steps 汉字

A first prototype of a beginner Chinese learning app. It runs on Windows and Mac
(and in a web browser), and the same code can later become a phone app.

## What's inside

- **The full HSK 1 course**: all 150 words of HSK 1 (the classic level 1 word list of
  the official Chinese exam) in 14 themed units, after a starter unit on the four tones.
  Every lesson ends with original example sentences that only use words you already know.
- **HSK 2 and HSK 3 courses** in the same lesson style: about 150 new words for HSK 2 and
  300 for HSK 3, continuing straight on from HSK 1. Switch level with the HSK 1 / 2 / 3 buttons
  on the home screen. The first lesson of each level is always open.
- **Daily goal and reminders**: pick 10, 20, 30 or 50 XP a day. The ring at the top of the home
  screen fills as you earn XP, with bars for the last 7 days. Tap it to change the goal or turn
  on a daily reminder at the time you choose. If you've already reached the goal, that day's
  reminder is skipped. (On Windows, the app plans the next week of reminders each time it opens,
  so open it at least once a week.)
- **Mini exam**: a 15-minute timed test in the style of the real HSK 1 exam, with a listening
  part and a reading part (true or false, pick the picture, pick the reply, fill the gap).
  It is scored out of 200 like the real exam, and 120 is a pass.
- **Speaking practice**: say a syllable or a word, and the app listens and checks your tones,
  drawing the pitch of your voice next to the shape it should have. It only checks tones, not
  the sounds themselves. On a Mac the app asks for the microphone the first time.
- **Small animations**: lessons bounce, wrong answers shake, the current lesson pulses,
  numbers count up, and confetti falls when you finish.
- **Lesson types**: "new word" cards, tone cards with a pitch drawing,
  multiple-choice questions, a tap-to-match game, and sentence building
  (tap word tiles in the right order to make sentences like 我是学生).
- **Spaced review**: every word you learn gets a review date. A word you remember comes back
  after 1, 2, 4, 7, 15 and then 30 days; a word you forget comes back the same day. The
  Review button (bottom right) shows how many words are due, and the HSK 1 card at the top
  shows how many words you've learned and how many are well remembered.
- **Settings** (gear icon): hide pinyin in questions to practise reading, choose slow or
  normal speech, test the voice, or reset your progress.
- **Mistakes come back**: anything you get wrong is asked again at the end.
- **Progress is saved** on your computer: finished lessons, XP and a daily streak.
- **Sound**: words and tones are read aloud by your computer's built-in Chinese voice,
  with speaker buttons and "listen and choose" questions.
- **Keyboard friendly**: press 1–4 to pick an answer (1–9 to add sentence tiles, Backspace
  to undo), Enter to check or continue, R to hear it again, Esc to leave.

## Sound

The app uses the Chinese voice that comes with your computer, so no internet is needed.
If the app says "no Chinese voice found", add one and restart the app:

- **Windows:** Settings → Time & language → Speech → Manage voices → Add voices →
  "Chinese (Simplified, China)".
- **Mac:** System Settings → Accessibility → Spoken Content → System voice →
  Manage Voices → Chinese (China mainland), then download a voice such as Tingting.
- **Browser (`flutter run -d chrome`):** Chrome usually has a Chinese voice already.

## Stories

The **Stories** card on the home screen opens 13 short original stories, grouped by HSK level: everyday scenes plus
retellings of two classic fables (守株待兔 and 画蛇添足). Each story is labelled with its level,
worked out automatically from its words ("HSK 1", "HSK 2", "HSK 3", with a "+" when it needs a few extra words),
and shows how many of its words you already know. While reading you can tap any word for its
pinyin, meaning and sound and add it to your review list, switch pinyin on or off, hear a
paragraph or the whole story, and show the English. Each story ends with a few questions.

Stories live in `lib/data/stories.dart`. Write each paragraph with spaces between words; any
word that isn't a course word goes in `storyExtras` (the tests check this).

## Writing characters

Lessons end by writing one or two of their new characters: watch the stroke order, then
trace each stroke with your mouse, finger or pen. The app checks the order and direction of
every stroke and, after two misses, highlights where the stroke starts and which way it goes.
The pen icon at the top of the home screen opens **Writing practice**, where you can write any
character from your finished lessons, with or without the outline.

Stroke data comes from the free Make Me a Hanzi / Hanzi Writer project and is used under the
Arphic Public License (see `assets/strokes/ARPHICPL.TXT`).

## Installing without Flutter

Once this code is on GitHub, the workflow in `.github/workflows/build.yml` builds the apps
automatically: a Windows installer (`HanziSteps-Windows-Setup.exe`), a Windows zip, and a Mac
app (`HanziSteps-Mac.zip`). Pushing a version tag such as `v1.0.0` puts them on the
repository's Releases page.

The Mac app isn't signed with a paid Apple developer account, so the first time, right-click
it and choose **Open**, then confirm. Windows may show a "Windows protected your PC" notice
for the same reason: click **More info → Run anyway**.

## How to run it from the code

You only need to do steps 1 and 2 once.

1. **Install Flutter** (the free toolkit the app is built with). Follow the guide for
   your computer at https://docs.flutter.dev/get-started/install and choose
   "Desktop" when it asks what you want to build.
   - On Windows this also asks you to install *Visual Studio* (the free
     "Community" edition, with "Desktop development with C++" ticked).
   - On Mac it asks you to install *Xcode* from the App Store.
2. Open a terminal (Windows: "PowerShell"; Mac: "Terminal") and check it worked:
   ```
   flutter doctor
   ```
   Green ticks next to "Windows" or "macOS" mean you're ready.
3. Go into this folder and start the app:
   ```
   cd path/to/hanzi_steps
   flutter run -d windows      # on Windows
   flutter run -d macos        # on Mac
   ```
   The first start takes a few minutes. After that it's quick.

**Shortcut if Visual Studio or Xcode is a hassle:** with just Flutter and Google
Chrome installed, `flutter run -d chrome` opens the same app in a browser window.

## Where things are

| What | File |
|---|---|
| All lesson content (words, pinyin, meanings) | `lib/data/course.dart` (HSK 1), `lib/data/hsk2.dart`, `lib/data/hsk3.dart` |
| Daily goal reminders | `lib/logic/reminders.dart` |
| Mini exam questions and screen | `lib/data/exam.dart`, `lib/logic/exam.dart`, `lib/screens/exam_screen.dart` |
| Speaking practice (microphone, pitch, tones) | `lib/logic/recorder.dart`, `lib/logic/pitch.dart`, `lib/screens/speaking_screen.dart` |
| Small animations | `lib/widgets/anim.dart` |
| How questions are made from the words | `lib/logic/exercises.dart` |
| Saving XP, streak, finished lessons and tricky words | `lib/logic/progress.dart` |
| Saved settings (pinyin, speech speed) | `lib/logic/settings.dart` |
| Settings screen | `lib/screens/settings_screen.dart` |
| Stroke data and stroke checking | `lib/logic/strokes.dart`, `assets/strokes/` |
| The writing box | `lib/widgets/character_writer.dart` |
| Writing practice page | `lib/screens/writing_screen.dart` |
| Reading Chinese aloud | `lib/logic/speech.dart` |
| The lesson path (home screen) | `lib/screens/home_screen.dart` |
| The lesson and quiz screens | `lib/screens/lesson_screen.dart` |

To add words, copy a `Word('你好', 'nǐ hǎo', 'hello')` line in `course.dart` and change it.
Questions for new words are created automatically. To add a sentence, add a
`Sentence(['我', '是', '学生'], 'wǒ shì xuésheng', 'I am a student.')` line to a lesson;
each tile must be a word taught in that lesson or earlier (the tests check this).

## Checks

`flutter test` plays through every lesson automatically and checks that no question
has duplicate answers, that HSK 1 has exactly 150 words, that every sentence can be built
from words already taught, and that review works. It also checks the daily goal, builds and
plays through mini exams, and checks the tone detector on made-up voice recordings.

## Not in this version yet

Accounts and phone versions. Speaking practice checks tones only, not whole pronunciation.
