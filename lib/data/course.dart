// All the learning content for the app lives here.
// To add more words or lessons, add entries to the lists below.

import 'hsk2.dart';
import 'hsk3.dart';
import 'hsk4.dart';
import 'hsk4b.dart';

class Word {
  final String hanzi; // Chinese characters, e.g. 你好
  final String pinyin; // Pronunciation with tone marks, e.g. nǐ hǎo
  final String meaning; // English meaning
  final String? note; // Optional extra tip shown when the word is taught
  final bool hsk; // false for useful extras that are not on the HSK 1 list

  const Word(this.hanzi, this.pinyin, this.meaning, {this.note, this.hsk = true});
}

/// One tone of Mandarin, with a simple description and its pitch shape.
class ToneInfo {
  final int number;
  final String name;
  final String mark; // the accent mark, e.g. ¯
  final String howTo;
  final List<double> contour; // pitch from 1 (low) to 5 (high), left to right
  const ToneInfo(this.number, this.name, this.mark, this.howTo, this.contour);
}

const tones = <ToneInfo>[
  ToneInfo(1, 'First tone', 'ā', 'High and flat, like holding a note when singing.', [5, 5]),
  ToneInfo(2, 'Second tone', 'á', 'Rises up, like asking "Huh?"', [3, 5]),
  ToneInfo(3, 'Third tone', 'ǎ', 'Dips low then comes back up a little.', [2, 1, 4]),
  ToneInfo(4, 'Fourth tone', 'à', 'Falls sharply, like a firm "No!"', [5, 1]),
];

/// A syllable used in the tone drills: shown with its tone mark, and the answer is its tone.
class ToneSyllable {
  final String marked; // e.g. mǎ
  final int tone; // 1–4
  final String? hanzi;
  final String? meaning;
  const ToneSyllable(this.marked, this.tone, {this.hanzi, this.meaning});
}

/// A sentence the learner builds from word tiles.
class Sentence {
  final List<String> tiles; // the sentence split into words, in order
  final String pinyin; // the whole sentence as spoken
  final String meaning; // English translation
  const Sentence(this.tiles, this.pinyin, this.meaning);

  String get hanzi => tiles.join();
}

enum LessonKind { tones, vocab, practice }

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final LessonKind kind;
  final List<Word> words;
  final List<ToneSyllable> syllables;
  final List<Sentence> sentences;
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.words = const [],
    this.syllables = const [],
    this.sentences = const [],
  });
}

class Unit {
  final String title;
  final String description;
  final int colorValue;
  final List<Lesson> lessons;
  final String tag; // small label above the title, e.g. "HSK 1 · Unit 3"
  final int level; // which course this unit belongs to: HSK 1, 2 or 3
  const Unit(this.title, this.description, this.colorValue, this.lessons, {this.tag = '', this.level = 1});
}

// Short names to keep the course list below readable.
typedef W = Word;
typedef S = Sentence;
const _v = LessonKind.vocab;

/// The course: the four tones, then all 150 words of HSK 1 (the classic
/// HSK 2.0 level 1 list) in 14 themed units, then HSK 2 and HSK 3
/// (in hsk2.dart and hsk3.dart).
/// Every example sentence is original and only uses words taught before it.
const course = <Unit>[
  Unit('Sounds of Mandarin', 'Pinyin and the four tones', 0xFFE4572E, tag: 'Start here', [
    Lesson(
      id: 'tones-1',
      title: 'Meet the four tones',
      subtitle: 'mā má mǎ mà',
      kind: LessonKind.tones,
      syllables: [
        ToneSyllable('mā', 1, hanzi: '妈', meaning: 'mother'),
        ToneSyllable('má', 2, hanzi: '麻', meaning: 'hemp'),
        ToneSyllable('mǎ', 3, hanzi: '马', meaning: 'horse'),
        ToneSyllable('mà', 4, hanzi: '骂', meaning: 'to scold'),
      ],
    ),
    Lesson(
      id: 'tones-2',
      title: 'Spot the tone',
      subtitle: 'Read tone marks quickly',
      kind: LessonKind.tones,
      syllables: [
        ToneSyllable('bā', 1, hanzi: '八', meaning: 'eight'),
        ToneSyllable('shū', 1, hanzi: '书', meaning: 'book'),
        ToneSyllable('chá', 2, hanzi: '茶', meaning: 'tea'),
        ToneSyllable('rén', 2, hanzi: '人', meaning: 'person'),
        ToneSyllable('hǎo', 3, hanzi: '好', meaning: 'good'),
        ToneSyllable('shuǐ', 3, hanzi: '水', meaning: 'water'),
        ToneSyllable('shì', 4, hanzi: '是', meaning: 'to be'),
        ToneSyllable('dà', 4, hanzi: '大', meaning: 'big'),
      ],
    ),
  ]),

  // ---------------- HSK 1 ----------------
  Unit('Hello!', 'Greetings and polite words', 0xFF2E86AB, tag: 'HSK 1 · Unit 1', [
    Lesson(id: 'greet-1', title: 'Say hello', subtitle: '你好 · 谢谢 · 再见', kind: _v, words: [
      W('你', 'nǐ', 'you'),
      W('好', 'hǎo', 'good / well'),
      W('我', 'wǒ', 'I / me'),
      W('谢谢', 'xièxie', 'thank you'),
      W('不客气', 'bú kèqi', "you're welcome"),
      W('再见', 'zàijiàn', 'goodbye', note: 'Literally "again see".'),
    ], sentences: [
      S(['你', '好'], 'nǐ hǎo', 'Hello!'),
    ]),
    Lesson(id: 'greet-2', title: 'Be polite', subtitle: '对不起 · 没关系 · 请', kind: _v, words: [
      W('对不起', 'duìbuqǐ', 'sorry'),
      W('没关系', 'méi guānxi', "it's okay / never mind"),
      W('请', 'qǐng', 'please'),
      W('喂', 'wéi', 'hello (on the phone)'),
      W('吗', 'ma', '(turns a sentence into a yes/no question)',
          note: 'Put 吗 at the end of a sentence to make it a yes/no question.'),
    ], sentences: [
      S(['你', '好', '吗'], 'nǐ hǎo ma', 'How are you?'),
    ]),
  ]),
  Unit('Numbers', 'Count from one to ten and beyond', 0xFF3BB273, tag: 'HSK 1 · Unit 2', [
    Lesson(id: 'num-1', title: 'One to five', subtitle: '一 二 三 四 五', kind: _v, words: [
      W('一', 'yī', 'one'),
      W('二', 'èr', 'two'),
      W('三', 'sān', 'three'),
      W('四', 'sì', 'four'),
      W('五', 'wǔ', 'five'),
    ]),
    Lesson(id: 'num-2', title: 'Six to ten', subtitle: '六 七 八 九 十', kind: _v, words: [
      W('六', 'liù', 'six'),
      W('七', 'qī', 'seven'),
      W('八', 'bā', 'eight'),
      W('九', 'jiǔ', 'nine'),
      W('十', 'shí', 'ten', note: 'Bigger numbers are built like blocks: 十五 = 15, 二十 = 20, 二十一 = 21.'),
    ], sentences: [
      S(['十', '五'], 'shíwǔ', 'fifteen'),
      S(['二', '十', '一'], 'èrshíyī', 'twenty-one'),
      S(['九', '十', '八'], 'jiǔshíbā', 'ninety-eight'),
    ]),
  ]),
  Unit('People', 'Who is who', 0xFF7768AE, tag: 'HSK 1 · Unit 3', [
    Lesson(id: 'ppl-1', title: 'He, she, we', subtitle: '他 · 她 · 我们', kind: _v, words: [
      W('是', 'shì', 'to be (am / is / are)'),
      W('他', 'tā', 'he / him'),
      W('她', 'tā', 'she / her', note: 'Sounds the same as 他; only the writing differs.'),
      W('我们', 'wǒmen', 'we / us'),
      W('人', 'rén', 'person'),
      W('中国', 'Zhōngguó', 'China'),
    ], sentences: [
      S(['我', '是', '中国', '人'], 'wǒ shì Zhōngguó rén', 'I am Chinese.'),
      S(['我们', '是', '中国', '人'], 'wǒmen shì Zhōngguó rén', 'We are Chinese.'),
    ]),
    Lesson(id: 'ppl-2', title: 'Jobs and friends', subtitle: '老师 · 学生 · 朋友', kind: _v, words: [
      W('老师', 'lǎoshī', 'teacher'),
      W('学生', 'xuésheng', 'student'),
      W('同学', 'tóngxué', 'classmate'),
      W('朋友', 'péngyou', 'friend'),
      W('医生', 'yīshēng', 'doctor'),
      W('谁', 'shéi', 'who'),
    ], sentences: [
      S(['我', '是', '学生'], 'wǒ shì xuésheng', 'I am a student.'),
      S(['他', '是', '谁'], 'tā shì shéi', 'Who is he?'),
      S(['她', '是', '我', '朋友'], 'tā shì wǒ péngyou', 'She is my friend.'),
      S(['他', '是', '医生'], 'tā shì yīshēng', 'He is a doctor.'),
    ]),
  ]),
  Unit('Nice to meet you', 'Names and introductions', 0xFFC2185B, tag: 'HSK 1 · Unit 4', [
    Lesson(id: 'intro-1', title: "What's your name?", subtitle: '叫 · 名字 · 什么', kind: _v, words: [
      W('叫', 'jiào', 'to be called'),
      W('名字', 'míngzi', 'name'),
      W('什么', 'shénme', 'what'),
      W('不', 'bù', 'not', note: 'Before a fourth-tone word, 不 is said bú, as in 不客气 bú kèqi.'),
      W('很', 'hěn', 'very'),
    ], sentences: [
      S(['你', '叫', '什么', '名字'], 'nǐ jiào shénme míngzi', 'What is your name?'),
      S(['我', '很', '好'], 'wǒ hěn hǎo', 'I am very well.'),
      S(['我', '不', '是', '老师'], 'wǒ bú shì lǎoshī', 'I am not a teacher.'),
    ]),
    Lesson(id: 'intro-2', title: 'Pleased to meet you', subtitle: '认识 · 高兴 · 呢', kind: _v, words: [
      W('认识', 'rènshi', 'to know (a person)'),
      W('高兴', 'gāoxìng', 'happy / glad'),
      W('呢', 'ne', '(asks "and you?")', note: '我很好，你呢？ = I\'m well, and you?'),
      W('的', 'de', "'s (shows belonging)", note: '我的 = my, 你的 = your. With family and friends it is often left out.'),
      W('先生', 'xiānsheng', 'Mr. / sir'),
      W('小姐', 'xiǎojiě', 'Miss / young lady'),
    ], sentences: [
      S(['认识', '你', '很', '高兴'], 'rènshi nǐ hěn gāoxìng', 'Nice to meet you.'),
      S(['我', '很', '好', '你', '呢'], 'wǒ hěn hǎo, nǐ ne', "I'm well, and you?"),
      S(['他', '是', '我', '的', '老师'], 'tā shì wǒ de lǎoshī', 'He is my teacher.'),
    ]),
  ]),
  Unit('Family', 'Talk about the people at home', 0xFF4F6D7A, tag: 'HSK 1 · Unit 5', [
    Lesson(id: 'fam-1', title: 'My family', subtitle: '爸爸 · 妈妈 · 家', kind: _v, words: [
      W('爸爸', 'bàba', 'dad'),
      W('妈妈', 'māma', 'mum'),
      W('儿子', 'érzi', 'son'),
      W('女儿', "nǚ'ér", 'daughter'),
      W('家', 'jiā', 'home / family'),
      W('有', 'yǒu', 'to have / there is'),
      W('个', 'gè', '(counting word)',
          note: 'Goes between a number and a noun: 一个人 = one person. In sentences it is said lightly: ge.'),
    ], sentences: [
      S(['我', '有', '一', '个', '女儿'], "wǒ yǒu yí ge nǚ'ér", 'I have a daughter.'),
      S(['我', '家', '有', '三', '个', '人'], 'wǒ jiā yǒu sān ge rén', 'There are three people in my family.'),
      S(['我', '爸爸', '是', '医生'], 'wǒ bàba shì yīshēng', 'My dad is a doctor.'),
    ]),
    Lesson(id: 'fam-2', title: 'How old?', subtitle: '几 · 岁 · 爱', kind: _v, words: [
      W('没有', 'méiyǒu', "don't have / there isn't"),
      W('几', 'jǐ', 'how many / which (small numbers)'),
      W('岁', 'suì', 'years old'),
      W('爱', 'ài', 'to love'),
      W('和', 'hé', 'and (between nouns)'),
    ], sentences: [
      S(['你', '几', '岁'], 'nǐ jǐ suì', 'How old are you? (to a child)'),
      S(['她', '八', '岁'], 'tā bā suì', 'She is eight years old.'),
      S(['我', '没有', '儿子'], 'wǒ méiyǒu érzi', "I don't have a son."),
      S(['爸爸', '和', '妈妈'], 'bàba hé māma', 'Dad and mum'),
      S(['我', '爱', '你'], 'wǒ ài nǐ', 'I love you.'),
    ]),
  ]),
  Unit('Food and drink', 'Eat, drink and go out', 0xFFE09F3E, tag: 'HSK 1 · Unit 6', [
    Lesson(id: 'food-1', title: 'Eat and drink', subtitle: '吃 · 喝 · 茶', kind: _v, words: [
      W('吃', 'chī', 'to eat'),
      W('喝', 'hē', 'to drink'),
      W('水', 'shuǐ', 'water'),
      W('茶', 'chá', 'tea'),
      W('米饭', 'mǐfàn', 'cooked rice'),
      W('菜', 'cài', 'dish / vegetables'),
    ], sentences: [
      S(['我', '喝', '茶'], 'wǒ hē chá', 'I drink tea.'),
      S(['你', '吃', '米饭', '吗'], 'nǐ chī mǐfàn ma', 'Do you eat rice?'),
      S(['我', '不', '喝', '水'], 'wǒ bù hē shuǐ', "I don't drink water."),
    ]),
    Lesson(id: 'food-2', title: 'Going out to eat', subtitle: '想 · 水果 · 饭馆', kind: _v, words: [
      W('想', 'xiǎng', 'would like to / to think'),
      W('去', 'qù', 'to go'),
      W('苹果', 'píngguǒ', 'apple'),
      W('水果', 'shuǐguǒ', 'fruit'),
      W('饭馆', 'fànguǎn', 'restaurant'),
      W('杯子', 'bēizi', 'cup / glass'),
    ], sentences: [
      S(['我', '想', '吃', '苹果'], 'wǒ xiǎng chī píngguǒ', 'I would like to eat an apple.'),
      S(['我', '想', '去', '饭馆'], 'wǒ xiǎng qù fànguǎn', 'I would like to go to a restaurant.'),
      S(['你', '吃', '水果', '吗'], 'nǐ chī shuǐguǒ ma', 'Do you eat fruit?'),
    ]),
  ]),
  Unit('Shopping', 'Buy things and ask prices', 0xFFD1495B, tag: 'HSK 1 · Unit 7', [
    Lesson(id: 'shop-1', title: 'At the shop', subtitle: '买 · 钱 · 多少', kind: _v, words: [
      W('买', 'mǎi', 'to buy'),
      W('东西', 'dōngxi', 'thing / stuff'),
      W('商店', 'shāngdiàn', 'shop'),
      W('钱', 'qián', 'money'),
      W('块', 'kuài', 'yuan (Chinese money, spoken)'),
      W('多少', 'duōshao', 'how many / how much'),
    ], sentences: [
      S(['多少', '钱'], 'duōshao qián', 'How much is it?'),
      S(['十', '块', '钱'], 'shí kuài qián', 'Ten yuan.'),
      S(['我', '去', '商店', '买', '东西'], 'wǒ qù shāngdiàn mǎi dōngxi', "I'm going to the shop to buy things."),
    ]),
    Lesson(id: 'shop-2', title: 'This one or that one?', subtitle: '这 · 那 · 漂亮', kind: _v, words: [
      W('这', 'zhè', 'this'),
      W('那', 'nà', 'that'),
      W('些', 'xiē', 'some (makes 这/那 plural)', note: '这些 = these, 那些 = those.'),
      W('衣服', 'yīfu', 'clothes'),
      W('漂亮', 'piàoliang', 'pretty / beautiful'),
      W('太', 'tài', 'too / so'),
      W('了', 'le', '(shows a change or something done)', note: '太…了 = "so …!", as in 太好了！= Great!'),
    ], sentences: [
      S(['这', '个', '杯子', '很', '漂亮'], 'zhège bēizi hěn piàoliang', 'This cup is very pretty.'),
      S(['太', '好', '了'], 'tài hǎo le', 'Great!'),
      S(['我', '想', '买', '那', '些', '衣服'], 'wǒ xiǎng mǎi nàxiē yīfu', 'I would like to buy those clothes.'),
    ]),
  ]),
  Unit('Dates', 'Days, months and the week', 0xFF00838F, tag: 'HSK 1 · Unit 8', [
    Lesson(id: 'date-1', title: 'Today and tomorrow', subtitle: '今天 · 明天 · 昨天', kind: _v, words: [
      W('今天', 'jīntiān', 'today'),
      W('明天', 'míngtiān', 'tomorrow'),
      W('昨天', 'zuótiān', 'yesterday'),
      W('年', 'nián', 'year'),
      W('月', 'yuè', 'month', note: 'Months are just numbers: 五月 = month five = May.'),
      W('号', 'hào', 'day of the month'),
    ], sentences: [
      S(['今天', '五', '月', '三', '号'], 'jīntiān wǔ yuè sān hào', 'Today is May 3rd.'),
      S(['明天', '是', '七', '号'], 'míngtiān shì qī hào', 'Tomorrow is the 7th.'),
    ]),
    Lesson(id: 'date-2', title: 'Days of the week', subtitle: '星期一 · 星期天', kind: _v, words: [
      W('星期', 'xīngqī', 'week'),
      W('星期一', 'xīngqīyī', 'Monday', note: 'Monday to Saturday are 星期 + 1 to 6.', hsk: false),
      W('星期六', 'xīngqīliù', 'Saturday', hsk: false),
      W('星期天', 'xīngqītiān', 'Sunday', hsk: false),
    ], sentences: [
      S(['今天', '星期', '几'], 'jīntiān xīngqī jǐ', 'What day is it today?'),
      S(['明天', '是', '星期天'], 'míngtiān shì xīngqītiān', 'Tomorrow is Sunday.'),
      S(['昨天', '是', '星期六'], 'zuótiān shì xīngqīliù', 'Yesterday was Saturday.'),
    ]),
  ]),
  Unit('Telling the time', 'Hours, minutes and times of day', 0xFF5C6BC0, tag: 'HSK 1 · Unit 9', [
    Lesson(id: 'time-1', title: 'What time is it?', subtitle: '现在 · 点 · 分钟', kind: _v, words: [
      W('现在', 'xiànzài', 'now'),
      W('点', 'diǎn', "o'clock"),
      W('分钟', 'fēnzhōng', 'minute'),
      W('时候', 'shíhou', 'time / moment', note: '什么时候 = when (literally "what time").'),
    ], sentences: [
      S(['现在', '几', '点'], 'xiànzài jǐ diǎn', 'What time is it now?'),
      S(['现在', '三', '点'], 'xiànzài sān diǎn', "It's three o'clock now."),
      S(['你', '什么', '时候', '去', '商店'], 'nǐ shénme shíhou qù shāngdiàn', 'When are you going to the shop?'),
    ]),
    Lesson(id: 'time-2', title: 'Morning to afternoon', subtitle: '上午 · 中午 · 下午', kind: _v, words: [
      W('上午', 'shàngwǔ', 'morning'),
      W('中午', 'zhōngwǔ', 'noon / midday'),
      W('下午', 'xiàwǔ', 'afternoon'),
    ], sentences: [
      S(['我', '下午', '去', '商店'], 'wǒ xiàwǔ qù shāngdiàn', "I'm going to the shop in the afternoon."),
      S(['中午', '我', '吃', '米饭'], 'zhōngwǔ wǒ chī mǐfàn', 'At noon I eat rice.'),
    ]),
  ]),
  Unit('Places', 'Where things are', 0xFF6D4C41, tag: 'HSK 1 · Unit 10', [
    Lesson(id: 'place-1', title: 'Where are you?', subtitle: '在 · 哪儿 · 学校', kind: _v, words: [
      W('在', 'zài', 'at / in / to be at'),
      W('哪儿', 'nǎr', 'where'),
      W('哪', 'nǎ', 'which'),
      W('学校', 'xuéxiào', 'school'),
      W('医院', 'yīyuàn', 'hospital'),
      W('北京', 'Běijīng', 'Beijing'),
      W('住', 'zhù', 'to live (somewhere)'),
    ], sentences: [
      S(['你', '在', '哪儿'], 'nǐ zài nǎr', 'Where are you?'),
      S(['我', '住', '在', '北京'], 'wǒ zhù zài Běijīng', 'I live in Beijing.'),
      S(['妈妈', '在', '医院'], 'māma zài yīyuàn', 'Mum is at the hospital.'),
      S(['你', '是', '哪', '个', '学校', '的'], 'nǐ shì nǎge xuéxiào de', 'Which school are you from?'),
    ]),
    Lesson(id: 'place-2', title: 'On, under, behind', subtitle: '上 · 下 · 后面', kind: _v, words: [
      W('上', 'shàng', 'on / above / up'),
      W('下', 'xià', 'under / below / down'),
      W('里', 'lǐ', 'inside'),
      W('前面', 'qiánmiàn', 'in front'),
      W('后面', 'hòumiàn', 'behind'),
      W('桌子', 'zhuōzi', 'table / desk'),
      W('椅子', 'yǐzi', 'chair'),
    ], sentences: [
      S(['杯子', '在', '桌子', '上'], 'bēizi zài zhuōzi shang', 'The cup is on the table.'),
      S(['钱', '在', '杯子', '里'], 'qián zài bēizi li', 'The money is in the cup.'),
      S(['商店', '在', '学校', '后面'], 'shāngdiàn zài xuéxiào hòumiàn', 'The shop is behind the school.'),
      S(['椅子', '在', '桌子', '前面'], 'yǐzi zài zhuōzi qiánmiàn', 'The chair is in front of the table.'),
    ]),
  ]),
  Unit('Getting around', 'Travel, phones and screens', 0xFF0097A7, tag: 'HSK 1 · Unit 11', [
    Lesson(id: 'go-1', title: 'Come and go', subtitle: '来 · 回 · 飞机', kind: _v, words: [
      W('来', 'lái', 'to come'),
      W('回', 'huí', 'to go back / return'),
      W('坐', 'zuò', 'to sit / to travel by'),
      W('出租车', 'chūzūchē', 'taxi'),
      W('飞机', 'fēijī', 'plane'),
      W('开', 'kāi', 'to drive / to open'),
    ], sentences: [
      S(['我', '坐', '飞机', '去', '北京'], 'wǒ zuò fēijī qù Běijīng', "I'm flying to Beijing."),
      S(['我', '明天', '回', '家'], 'wǒ míngtiān huí jiā', "I'm going home tomorrow."),
      S(['他', '开', '出租车'], 'tā kāi chūzūchē', 'He drives a taxi.'),
      S(['你', '来', '我', '家', '吗'], 'nǐ lái wǒ jiā ma', 'Are you coming to my home?'),
    ]),
    Lesson(id: 'go-2', title: 'Phones and screens', subtitle: '电话 · 电脑 · 电影', kind: _v, words: [
      W('打电话', 'dǎ diànhuà', 'to make a phone call'),
      W('电脑', 'diànnǎo', 'computer', note: 'Literally "electric brain".'),
      W('电视', 'diànshì', 'TV'),
      W('电影', 'diànyǐng', 'film / movie'),
      W('看', 'kàn', 'to look / to watch / to read'),
      W('看见', 'kànjiàn', 'to see'),
    ], sentences: [
      S(['我', '想', '看', '电影'], 'wǒ xiǎng kàn diànyǐng', 'I would like to watch a film.'),
      S(['妈妈', '在', '看', '电视'], 'māma zài kàn diànshì', 'Mum is watching TV.'),
      S(['我', '看见', '他', '了'], 'wǒ kànjiàn tā le', 'I saw him.'),
      S(['我', '有', '电脑'], 'wǒ yǒu diànnǎo', 'I have a computer.'),
    ]),
  ]),
  Unit('Work and study', 'Daily life and learning Chinese', 0xFF558B2F, tag: 'HSK 1 · Unit 12', [
    Lesson(id: 'work-1', title: 'A busy day', subtitle: '工作 · 学习 · 睡觉', kind: _v, words: [
      W('工作', 'gōngzuò', 'work / to work'),
      W('学习', 'xuéxí', 'to study'),
      W('做', 'zuò', 'to do / to make'),
      W('睡觉', 'shuìjiào', 'to sleep'),
      W('读', 'dú', 'to read (aloud)'),
      W('写', 'xiě', 'to write'),
      W('字', 'zì', 'character (written word)'),
    ], sentences: [
      S(['你', '做', '什么', '工作'], 'nǐ zuò shénme gōngzuò', 'What work do you do?'),
      S(['我', '在', '学校', '学习'], 'wǒ zài xuéxiào xuéxí', 'I study at school.'),
      S(['我', '想', '睡觉'], 'wǒ xiǎng shuìjiào', 'I would like to sleep.'),
    ]),
    Lesson(id: 'work-2', title: 'I can speak Chinese', subtitle: '会 · 能 · 汉语', kind: _v, words: [
      W('会', 'huì', 'can (know how to)'),
      W('能', 'néng', 'can (be able / allowed to)'),
      W('说', 'shuō', 'to speak / to say'),
      W('听', 'tīng', 'to listen'),
      W('汉语', 'Hànyǔ', 'Chinese (language)'),
      W('书', 'shū', 'book'),
      W('本', 'běn', '(counting word for books)'),
    ], sentences: [
      S(['我', '会', '说', '汉语'], 'wǒ huì shuō Hànyǔ', 'I can speak Chinese.'),
      S(['你', '会', '写', '这', '个', '字', '吗'], 'nǐ huì xiě zhège zì ma', 'Can you write this character?'),
      S(['我', '有', '三', '本', '书'], 'wǒ yǒu sān běn shū', 'I have three books.'),
      S(['我', '能', '看', '电视', '吗'], 'wǒ néng kàn diànshì ma', 'Can I watch TV?'),
    ]),
  ]),
  Unit('Weather and describing', 'Hot, cold, big and small', 0xFFF57C00, tag: 'HSK 1 · Unit 13', [
    Lesson(id: 'wx-1', title: "How's the weather?", subtitle: '天气 · 冷 · 热', kind: _v, words: [
      W('天气', 'tiānqì', 'weather'),
      W('怎么样', 'zěnmeyàng', 'how is it? / how about?'),
      W('冷', 'lěng', 'cold'),
      W('热', 'rè', 'hot'),
      W('下雨', 'xià yǔ', 'to rain'),
    ], sentences: [
      S(['今天', '天气', '怎么样'], 'jīntiān tiānqì zěnmeyàng', "How's the weather today?"),
      S(['今天', '很', '冷'], 'jīntiān hěn lěng', "It's very cold today."),
      S(['明天', '下雨', '吗'], 'míngtiān xià yǔ ma', 'Will it rain tomorrow?'),
      S(['太', '热', '了'], 'tài rè le', "It's so hot!"),
    ]),
    Lesson(id: 'wx-2', title: 'Big and small', subtitle: '大 · 小 · 多 · 少', kind: _v, words: [
      W('大', 'dà', 'big'),
      W('小', 'xiǎo', 'small / little'),
      W('多', 'duō', 'many / much'),
      W('少', 'shǎo', 'few / little (amount)'),
      W('一点儿', 'yìdiǎnr', 'a little / a bit'),
      W('怎么', 'zěnme', 'how'),
    ], sentences: [
      S(['北京', '很', '大'], 'Běijīng hěn dà', 'Beijing is very big.'),
      S(['我', '会', '说', '一点儿', '汉语'], 'wǒ huì shuō yìdiǎnr Hànyǔ', 'I can speak a little Chinese.'),
      S(['这', '个', '字', '怎么', '读'], 'zhège zì zěnme dú', 'How do you read this character?'),
      S(['商店', '里', '人', '很', '多'], 'shāngdiàn li rén hěn duō', 'There are lots of people in the shop.'),
    ]),
  ]),
  Unit('Pets and likes', 'What you like and love', 0xFF8D6E63, tag: 'HSK 1 · Unit 14', [
    Lesson(id: 'like-1', title: 'Cats and dogs', subtitle: '猫 · 狗 · 喜欢 · 都', kind: _v, words: [
      W('猫', 'māo', 'cat'),
      W('狗', 'gǒu', 'dog'),
      W('喜欢', 'xǐhuan', 'to like'),
      W('都', 'dōu', 'all / both'),
    ], sentences: [
      S(['我', '喜欢', '猫'], 'wǒ xǐhuan māo', 'I like cats.'),
      S(['我们', '都', '喜欢', '狗'], 'wǒmen dōu xǐhuan gǒu', 'We all like dogs.'),
      S(['你', '喜欢', '什么'], 'nǐ xǐhuan shénme', 'What do you like?'),
      S(['猫', '在', '椅子', '下'], 'māo zài yǐzi xia', 'The cat is under the chair.'),
    ]),
  ]),

  ...hsk2Units,
  ...hsk3Units,
  ...hsk4Units,
  ...hsk4Part2Units,
];

/// The courses, one per HSK level.
const levels = [1, 2, 3, 4];

/// The words on the official list of one HSK level (not the extras), for counting.
List<Word> hskWordsOf(int level) => [
      for (final u in course)
        if (u.level == level)
          for (final l in u.lessons)
            for (final w in l.words)
              if (w.hsk) w,
    ];

/// The HSK 1 words only, for counting.
List<Word> get hskWords => hskWordsOf(1);

/// The units of one HSK level, in order.
List<Unit> unitsOf(int level) => [for (final u in course) if (u.level == level) u];

/// The lessons of one HSK level, in order.
List<Lesson> lessonsOf(int level) => [for (final u in unitsOf(level)) ...u.lessons];

final Map<String, int> _levelByHanzi = {
  for (final u in course)
    for (final l in u.lessons)
      for (final w in l.words) w.hanzi: u.level,
};

/// Which HSK course teaches this word (1, 2 or 3), or null if no course does.
int? levelOfWord(String hanzi) => _levelByHanzi[hanzi];

/// Every lesson in order, used for unlocking the next lesson.
List<Lesson> get allLessons => [for (final u in course) ...u.lessons];

/// Every vocabulary word in the course, used to pick wrong answer options.
List<Word> get allWords => [for (final l in allLessons) ...l.words];

/// Finds a word by its characters (used to show pinyin on sentence tiles).
Word? wordFor(String hanzi) {
  for (final w in allWords) {
    if (w.hanzi == hanzi) return w;
  }
  return null;
}
