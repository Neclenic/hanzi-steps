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
- **Mini exams for HSK 1, 2 and 3**: timed tests in the style of the real HSK exams, with a
  listening part and a reading part (true or false, pick the picture, pick the reply, fill the gap).
  HSK 1 and 2 are scored out of 200 (120 is a pass). HSK 3 adds a writing part where you pick the
  missing character, and is scored out of 300 (180 is a pass). The Mini exam card opens the exam
  for the level you have selected.
- **Speaking practice**: say a syllable or a word, and the app listens and checks your tones,
  drawing the pitch of your voice next to the shape it should have. It only checks tones, not
  the sounds themselves. On a Mac the app asks for the microphone the first time.
- **Tone pairs**: practise the 20 two-syllable tone combinations (like mā-má or nǐ-hǎo). A grid
  shows how often you get each pair right; tap a pair for example words. The tone quiz plays a word
  and you pick its pair (pairs you miss come up more often), and "Say them" lets you speak them.
- **Character stories**: new-word cards and the writing page show how a character is built
  from parts, with a memory hint, e.g. 口 mouth + 马 horse = 吗.
- **Grammar tips**: 33 short cards inside lessons (吗, 的, 了, measure words and more), each with
  examples that only use words you know. The Grammar card on the home screen lists them all.
- **Dialogues**: 9 short conversations (a café, buying fruit, asking the way, at the doctor…).
  Listen to the other person, pick your reply from three, then say it aloud if you like.
- **Type pinyin**: hear a word and type it in pinyin. Type tones as numbers (ni3hao3) and they
  turn into marks as you type (nǐhǎo). Light tones can be left out.
- **Numbers in real life**: prices (三块五 = ¥3.50), phone numbers (typed as digits, with 幺 yāo for 1),
  dates (十一月二十号，星期五) and clock times (下午两点半). Listen and pick, read and pick, or pick the Chinese
  for a price or time. Wrong answers are numbers that are easy to mix up, like 4 and 10 or 7 and 1.
- **Look-alike characters**: 24 groups such as 人/入/八, 大/太/天, 己/已, 买/卖 and 在/再, each with a tip on how
  to tell them apart and a drill that asks the groups you miss more often.
- **Dictation**: hear a sentence from your finished lessons, then build it from word tiles or type it in
  pinyin (tones optional), with a "Slowly" button.
- **Word search**: look up any course word by characters, pinyin (with or without tones) or English, and see
  where it's taught, how its characters are built, and which look-alikes to watch out for.
- **My words**: tap ☆ on a word in a story, a dialogue or word search to save it, then practise only those.
- **Placement test**: answers a few questions per two units and stops at the first part you don't know yet,
  then offers to skip those lessons. Their words come back in reviews over the next two weeks.
- **Culture notes**: 36 "Did you know?" cards inside lessons, on festivals, food, names and good manners,
  plus a Culture page listing them all.
- **Pet panda**: grows from a baby panda to a panda master as you earn XP. It's happy when you reach your
  daily goal and gets hungry (and then sad) when reviews pile up. The "Feed" button starts a review.
  Tap its name to rename it.
- **Badges**: 31 badges, from "First steps" to a 30-day streak. A banner slides in when you earn one.
- **Stats & badges page**: XP for the last 14 days, how often you get each tone right, the
  tone pairs and words you miss most (with a button to practise those words), and your badges.
- **Quick games**: Speed match (match characters and meanings against the clock) and Falling
  characters (catch the one that matches the meaning before it reaches the bottom; 3 lives).
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
| Tone pairs | `lib/logic/tone_pairs.dart`, `lib/screens/tone_pairs_screen.dart` |
| Character stories | `lib/data/char_stories.dart`, `lib/widgets/char_story_card.dart` |
| Grammar tips | `lib/data/grammar.dart`, `lib/screens/grammar_screen.dart` |
| Dialogues | `lib/data/dialogues.dart`, `lib/screens/dialogue_screen.dart` |
| Typing pinyin | `lib/logic/pinyin_input.dart`, `lib/screens/typing_screen.dart` |
| Badges | `lib/logic/badges.dart`, `lib/widgets/badge_watcher.dart` |
| Stats page | `lib/screens/stats_screen.dart` |
| Quick games | `lib/screens/games_screen.dart` |
| Shared quiz pieces (answer tiles, bottom bar, results) | `lib/widgets/quiz_parts.dart` |
| Numbers in real life | `lib/logic/numbers.dart`, `lib/screens/numbers_screen.dart` |
| Look-alike characters | `lib/data/look_alikes.dart`, `lib/screens/look_alikes_screen.dart` |
| Dictation | `lib/screens/dictation_screen.dart` |
| Word search, word details and My words | `lib/logic/word_lookup.dart`, `lib/widgets/word_sheet.dart`, `lib/screens/word_search_screen.dart`, `lib/screens/my_words_screen.dart` |
| Placement test | `lib/logic/placement.dart`, `lib/screens/placement_screen.dart` |
| Culture notes | `lib/data/culture.dart`, `lib/screens/culture_screen.dart` |
| Pet panda | `lib/logic/panda.dart`, `lib/widgets/panda.dart` |
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
plays through mini exams for all three levels, and checks the tone detector on made-up voice
recordings. It also checks that grammar examples and dialogues only use words already taught,
that typed pinyin is marked right or wrong correctly, and plays through each game. It also checks how numbers
are written and said, that look-alike examples and culture notes fit their lessons, the placement test,
word search, My words and the panda's moods.

## Not in this version yet

Accounts and phone versions. Speaking practice checks tones only, not whole pronunciation.
