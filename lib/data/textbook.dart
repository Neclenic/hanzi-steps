// Textbook-style units, laid out like a Chinese school textbook (课本).
//
// Each lesson (课) is a short rhyme (儿歌), a character list (识字) or a short text (课文),
// with its new characters (生字) and exercises (练习). Each unit ends with a review corner
// (语文园地): a radical family, a "my discovery" note, and something to learn by heart.
//
// All lessons are written fresh for this app. The poems in the review corners are Tang
// dynasty poems (over 1,200 years old), and the sayings are traditional; both are free to use.
//
// Text is written with spaces between words, like the stories. Pinyin has one syllable per
// character, separated by spaces, with no punctuation. The tests check that they line up and
// that every word can be looked up.

enum TbKind { rhyme, characters, text }

extension TbKindName on TbKind {
  String get zh => switch (this) { TbKind.rhyme => '儿歌', TbKind.characters => '识字', TbKind.text => '课文' };
  String get en => switch (this) { TbKind.rhyme => 'Rhyme', TbKind.characters => 'Characters', TbKind.text => 'Text' };
}

/// A line of Chinese with pinyin for each character and an English translation.
class TbLine {
  final String zh; // words separated by spaces
  final String py; // one syllable per character, separated by spaces
  final String en;
  const TbLine(this.zh, this.py, this.en);

  List<String> get tokens => zh.split(' ').where((t) => t.isNotEmpty).toList();
  String get text => tokens.join();
  List<String> get syllables => py.split(' ').where((t) => t.isNotEmpty).toList();
}

const tbPunctuation = {'，', '。', '？', '！', '：', '、', '“', '”'};

/// A new character (生字), drawn in a 田字格 square.
class TbChar {
  final String char;
  final String pinyin;
  final String meaning;
  final String? radical; // its radical (部首), when it has a clear one
  final List<String> words; // words made with it (组词)
  final bool write; // true: learn to write it (会写); false: learn to read it (会认)
  const TbChar(this.char, this.pinyin, this.meaning, {this.radical, this.words = const [], this.write = false});
}

/// Pick the word that fills the gap (＿) in a sentence.
class TbFill {
  final String zh; // words separated by spaces, with ＿ for the gap
  final List<String> options; // the first one is right
  final String en;
  const TbFill(this.zh, this.options, this.en);
}

/// A question with three answers; the first is right.
class TbAsk {
  final String zh;
  final String en;
  final List<String> options;
  const TbAsk(this.zh, this.en, this.options);
}

/// Put the words in order to make a sentence (连词成句).
class TbOrder {
  final String zh; // the sentence, words separated by spaces
  final String en;
  const TbOrder(this.zh, this.en);
}

/// Something to say out loud (说一说).
class TbSpeak {
  final String en; // the task
  final TbLine model; // an example answer
  const TbSpeak(this.en, this.model);
}

class TbLesson {
  final String id;
  final int number; // counts through both books, like a real textbook
  final TbKind kind;
  final String title;
  final String titlePy;
  final String titleEn;
  final List<TbLine> lines;
  final List<TbChar> chars;
  final String? note; // a short teaching note under the text
  final List<TbFill> fills;
  final List<TbAsk> asks;
  final List<TbOrder> orders;
  final TbSpeak speak;
  const TbLesson({
    required this.id,
    required this.number,
    required this.kind,
    required this.title,
    required this.titlePy,
    required this.titleEn,
    required this.lines,
    required this.chars,
    this.note,
    this.fills = const [],
    this.asks = const [],
    this.orders = const [],
    required this.speak,
  });
}

/// A radical and some characters that have it (识字加油站).
class TbRadical {
  final String radical;
  final String meaning;
  final String note;
  final List<(String, String, String)> chars; // character, pinyin, meaning
  const TbRadical(this.radical, this.meaning, this.note, this.chars);
}

/// A poem or saying to learn by heart (日积月累).
class TbPoem {
  final String title;
  final String titlePy;
  final String titleEn;
  final String? author; // e.g. "唐 · 李白 (Lǐ Bái)"
  final List<TbLine> lines; // one character per token
  final String? note;
  const TbPoem(this.title, this.titlePy, this.titleEn, this.lines, {this.author, this.note});

  bool get isSaying => author == null;
}

/// The review corner at the end of each unit (语文园地).
class TbCorner {
  final String id;
  final TbRadical radical;
  final List<(String, String)> discoveries; // 我的发现: what to look at, and what it shows
  final List<TbPoem> poems;
  const TbCorner(this.id, this.radical, this.discoveries, this.poems);
}

class TbUnit {
  final int book; // 1 or 2
  final int number; // 1–6, counting through both books
  final String title;
  final String titleEn;
  final int colorValue;
  final List<TbLesson> lessons;
  final TbCorner corner;
  const TbUnit(this.book, this.number, this.title, this.titleEn, this.colorValue, this.lessons, this.corner);
}

/// The books: 第一册 matches HSK 1, 第二册 HSK 2 and 第三册 HSK 3.
const tbBooks = <int, (String, String)>{
  1: ('第一册', 'Book 1 · about HSK 1'),
  2: ('第二册', 'Book 2 · about HSK 2'),
  3: ('第三册', 'Book 3 · about HSK 3'),
};

/// Words the textbook uses that the course doesn't teach (or uses in another sense).
/// These win over course words with the same characters.
const textbookExtras = <String, (String, String)>{
  '手': ('shǒu', 'hand'),
  '拉': ('lā', 'to pull, to hold'),
  '山': ('shān', 'mountain, hill'),
  '口': ('kǒu', 'mouth; (counts the people in a family)'),
  '早': ('zǎo', 'early; good morning'),
  '声': ('shēng', 'a sound; (counts things said)'),
  '红': ('hóng', 'red'),
  '白': ('bái', 'white'),
  '蓝': ('lán', 'blue'),
  '绿': ('lǜ', 'green'),
  '黄': ('huáng', 'yellow'),
  '花': ('huā', 'flower'),
  '开': ('kāi', 'to open; (flowers) to bloom'),
  '前': ('qián', 'front, ahead'),
  '右': ('yòu', 'right (side)'),
  '亮': ('liàng', 'bright, light'),
  '起': ('qǐ', 'to get up; to lift'),
  '早饭': ('zǎofàn', 'breakfast'),
  '好看': ('hǎokàn', 'good-looking, nice to see'),
  '好喝': ('hǎohē', 'tasty (to drink)'),
  '排': ('pái', 'to put in a row'),
  '棒': ('bàng', 'great, excellent'),
  '三百': ('sānbǎi', 'three hundred'),
  '一百': ('yìbǎi', 'one hundred'),
  '叶': ('yè', 'leaf'),
  '叶子': ('yèzi', 'leaf'),
  '春天': ('chūntiān', 'spring'),
  '夏天': ('xiàtiān', 'summer'),
  '秋天': ('qiūtiān', 'autumn'),
  '冬天': ('dōngtiān', 'winter'),
  '四季': ('sìjì', 'the four seasons'),
  '春节': ('Chūnjié', 'Spring Festival, Chinese New Year'),
  '中秋节': ('Zhōngqiūjié', 'Mid-Autumn Festival'),
  '背': ('bēi', 'to carry on your back'),
  '反义词': ('fǎnyìcí', 'opposite (word)'),
  '足球': ('zúqiú', 'football'),
  '打': ('dǎ', 'to hit; to play (ball games played with the hands)'),
  '踢': ('tī', 'to kick'),
  '她们': ('tāmen', 'they (women)'),
  '国': ('guó', 'country'),
  // words made with the new characters (组词)
  '三月': ('Sānyuè', 'March'),
  '九月': ('Jiǔyuè', 'September'),
  '十月': ('Shíyuè', 'October'),
  '走路': ('zǒu lù', 'to walk'),
  '门口': ('ménkǒu', 'doorway, entrance'),
  '女人': ('nǚrén', 'woman'),
  '回家': ('huí jiā', 'to go home'),
  '大学': ('dàxué', 'university'),
  '吃饭': ('chī fàn', 'to have a meal'),
  '红茶': ('hóngchá', 'black tea (literally "red tea")'),
  '绿茶': ('lǜchá', 'green tea'),
  '下雪': ('xià xuě', 'to snow'),
  '不错': ('búcuò', 'not bad, pretty good'),
  '书店': ('shūdiàn', 'bookshop'),
  '钱包': ('qiánbāo', 'wallet, purse'),
  '书包': ('shūbāo', 'school bag'),
  '汽车': ('qìchē', 'car'),
  // Book 3
  '上下': ('shàngxià', 'up and down'),
  '东边': ('dōngbian', 'the east side'),
  '做饭': ('zuò fàn', 'to cook'),
  '停': ('tíng', 'to stop'),
  '停车': ('tíng chē', 'to park'),
  '出来': ('chūlái', 'to come out'),
  '前后': ('qiánhòu', 'front and back'),
  '十八': ('shíbā', 'eighteen'),
  '南方': ('nánfāng', 'the south'),
  '可是': ('kěshì', 'but'),
  '吃药': ('chī yào', 'to take medicine'),
  '唱': ('chàng', 'to sing'),
  '嘴': ('zuǐ', 'mouth'),
  '回来': ('huílái', 'to come back'),
  '圆': ('yuán', 'round'),
  '大树': ('dà shù', 'big tree'),
  '大自然': ('dàzìrán', 'nature'),
  '天天': ('tiāntiān', 'every day'),
  '头': ('tóu', 'head'),
  '头疼': ('tóuténg', 'headache'),
  '好听': ('hǎotīng', 'nice to listen to'),
  '安全': ('ānquán', 'safe; safety'),
  '小鱼': ('xiǎo yú', 'little fish'),
  '小鸟': ('xiǎo niǎo', 'little bird'),
  '左右': ('zuǒyòu', 'left and right'),
  '床': ('chuáng', 'bed'),
  '手心': ('shǒuxīn', 'palm of the hand'),
  '手背': ('shǒubèi', 'back of the hand'),
  '搬家': ('bān jiā', 'to move house'),
  '新年': ('xīnnián', 'new year'),
  '明年': ('míngnián', 'next year'),
  '星星': ('xīngxing', 'star'),
  '有用': ('yǒuyòng', 'useful'),
  '森林': ('sēnlín', 'forest'),
  '棵': ('kē', '(counts trees and plants)'),
  '楼上': ('lóushàng', 'upstairs'),
  '楼下': ('lóuxià', 'downstairs'),
  '歌': ('gē', 'song'),
  '没': ('méi', 'not (done)'),
  '洗手': ('xǐ shǒu', 'to wash your hands'),
  '洗脸': ('xǐ liǎn', 'to wash your face'),
  '病': ('bìng', 'illness'),
  '白云': ('báiyún', 'white cloud'),
  '看病': ('kàn bìng', 'to see a doctor'),
  '睡': ('shuì', 'to sleep'),
  '窗户': ('chuānghu', 'window'),
  '竹子': ('zhúzi', 'bamboo'),
  '第二': ('dì-èr', 'second; next'),
  '红灯': ('hóngdēng', 'red light'),
  '绿灯': ('lǜdēng', 'green light'),
  '黄灯': ('huángdēng', 'yellow light'),
  '美': ('měi', 'beautiful'),
  '行': ('xíng', 'to go; OK'),
  '街': ('jiē', 'street'),
  '衣裳': ('yīshang', 'clothes'),
  '记住': ('jìzhù', 'to remember'),
  '雨': ('yǔ', 'rain'),
  '飞': ('fēi', 'to fly'),
  '首': ('shǒu', '(counts songs and poems)'),
  '马路': ('mǎlù', 'road, street'),
  '黑': ('hēi', 'black'),
  '离开': ('líkāi', 'to leave'),
};

const _r = TbKind.rhyme;
const _c = TbKind.characters;
const _t = TbKind.text;
typedef _L = TbLine;
typedef _C = TbChar;

const tbUnits = <TbUnit>[
  // ======================= 第一册 Book 1 =======================
  TbUnit(1, 1, '我和我的家', 'Me and my family', 0xFFE4572E, [
    TbLesson(
      id: 'tb-1',
      number: 1,
      kind: _r,
      title: '数一数',
      titlePy: 'Shǔ yi shǔ',
      titleEn: "Let's count",
      lines: [
        _L('一 二 三 ， 去 爬山 ，', 'yī èr sān qù pá shān', "One, two, three, let's climb a hill,"),
        _L('四 五 六 ， 看 小 狗 ，', 'sì wǔ liù kàn xiǎo gǒu', 'four, five, six, look at the puppy,'),
        _L('七 八 九 ， 一起 走 ，', 'qī bā jiǔ yì qǐ zǒu', 'seven, eight, nine, off we go together,'),
        _L('十 个 朋友 手 拉 手 。', 'shí gè péng you shǒu lā shǒu', 'ten friends, hand in hand.'),
      ],
      note: 'Chinese children learn numbers with counting rhymes like this one. 六, 狗, 九, 走 and 手 all rhyme.',
      chars: [
        _C('三', 'sān', 'three', radical: '一', words: ['三月'], write: true),
        _C('山', 'shān', 'mountain', radical: '山', words: ['爬山'], write: true),
        _C('手', 'shǒu', 'hand', radical: '手', words: ['手机', '手表'], write: true),
        _C('走', 'zǒu', 'to walk, to go', radical: '走', words: ['走路']),
        _C('九', 'jiǔ', 'nine', words: ['九月']),
        _C('十', 'shí', 'ten', radical: '十', words: ['十月'], write: true),
      ],
      fills: [
        TbFill('一 二 ＿ ， 去 爬山 。', ['三', '山', '手'], "One, two, three, let's climb a hill."),
        TbFill('七 八 九 ， 一起 ＿ 。', ['走', '手', '九'], 'Seven, eight, nine, off we go together.'),
      ],
      asks: [TbAsk('几 个 朋友 手 拉 手 ？', 'How many friends hold hands?', ['十 个', '三 个', '九 个'])],
      orders: [TbOrder('十 个 朋友 手 拉 手 。', 'Ten friends, hand in hand.')],
      speak: TbSpeak('Count from one to ten.', _L('一 二 三 四 五 六 七 八 九 十', 'yī èr sān sì wǔ liù qī bā jiǔ shí', 'One to ten.')),
    ),
    TbLesson(
      id: 'tb-2',
      number: 2,
      kind: _c,
      title: '家',
      titlePy: 'Jiā',
      titleEn: 'Family',
      lines: [
        _L('爸爸 妈妈 ， 儿子 女儿 ，', 'bà ba mā ma ér zi nǚ ér', 'Dad and Mum, son and daughter,'),
        _L('一 家 四 口 ， 都 在 家 里 。', 'yì jiā sì kǒu dōu zài jiā lǐ', 'a family of four, all at home.'),
        _L('我 爱 爸爸 ， 我 爱 妈妈 ，', 'wǒ ài bà ba wǒ ài mā ma', 'I love Dad, I love Mum,'),
        _L('我 爱 我 的 家 。', 'wǒ ài wǒ de jiā', 'I love my family.'),
      ],
      note: '口 means "mouth". It also counts the people in a family: 一家四口 is "a family of four mouths".',
      chars: [
        _C('爸', 'bà', 'dad', radical: '父', words: ['爸爸']),
        _C('妈', 'mā', 'mum', radical: '女', words: ['妈妈']),
        _C('儿', 'ér', 'son, child', words: ['儿子', '女儿']),
        _C('女', 'nǚ', 'woman, female', radical: '女', words: ['女儿', '女人'], write: true),
        _C('口', 'kǒu', 'mouth', radical: '口', words: ['门口'], write: true),
        _C('家', 'jiā', 'home, family', radical: '宀', words: ['大家', '回家'], write: true),
        _C('爱', 'ài', 'to love', words: ['爱好', '可爱']),
      ],
      fills: [
        TbFill('一 家 四 ＿ 。', ['口', '家', '女'], 'A family of four.'),
        TbFill('我 ＿ 我 的 家 。', ['爱', '爸', '儿'], 'I love my family.'),
      ],
      asks: [TbAsk('这 一 家 有 几 口 人 ？', 'How many people are in this family?', ['四 口', '三 口', '十 口'])],
      orders: [TbOrder('我 爱 我 的 家 。', 'I love my family.')],
      speak: TbSpeak('Say who is in your family.', _L('我 家 有 爸爸 ， 妈妈 和 我 。', 'wǒ jiā yǒu bà ba mā ma hé wǒ', 'In my family there are Dad, Mum and me.')),
    ),
    TbLesson(
      id: 'tb-3',
      number: 3,
      kind: _t,
      title: '我的朋友',
      titlePy: 'Wǒ de péngyou',
      titleEn: 'My friend',
      lines: [
        _L('我 有 一 个 好 朋友 ， 她 叫 王丽 。', 'wǒ yǒu yí gè hǎo péng you tā jiào Wáng Lì', 'I have a good friend. Her name is Wang Li.'),
        _L('王丽 是 中国 人 ， 她 是 我 的 同学 。', 'Wáng Lì shì Zhōng guó rén tā shì wǒ de tóng xué', 'Wang Li is Chinese. She is my classmate.'),
        _L('她 喜欢 猫 ， 我 喜欢 狗 。', 'tā xǐ huan māo wǒ xǐ huan gǒu', 'She likes cats, and I like dogs.'),
        _L('我们 都 喜欢 看 书 。', 'wǒ men dōu xǐ huan kàn shū', 'We both like reading.'),
      ],
      note: '一 is said yí before a fourth tone, so 一个 is yí gè. Textbooks write the changed tone.',
      chars: [
        _C('朋', 'péng', 'friend', radical: '月', words: ['朋友']),
        _C('友', 'yǒu', 'friend', radical: '又', words: ['朋友'], write: true),
        _C('叫', 'jiào', 'to be called; to call', radical: '口', write: true),
        _C('国', 'guó', 'country', radical: '囗', words: ['中国', '国家']),
        _C('学', 'xué', 'to study', radical: '子', words: ['学生', '同学', '学校'], write: true),
        _C('喜', 'xǐ', 'happy; to like', words: ['喜欢']),
      ],
      fills: [
        TbFill('她 ＿ 王丽 。', ['叫', '是', '有'], 'Her name is Wang Li.'),
        TbFill('王丽 是 我 的 ＿ 。', ['同学', '老师', '妈妈'], 'Wang Li is my classmate.'),
      ],
      asks: [
        TbAsk('王丽 喜欢 什么 ？', 'What does Wang Li like?', ['猫', '狗', '书']),
        TbAsk('王丽 是 哪 国 人 ？', 'Which country is Wang Li from?', ['中国', '北京', '学校']),
      ],
      orders: [TbOrder('我们 都 喜欢 看 书 。', 'We both like reading.')],
      speak: TbSpeak('Talk about a friend: their name and what they like.',
          _L('我 的 朋友 叫 小明 ， 他 喜欢 狗 。', 'wǒ de péng you jiào Xiǎo Míng tā xǐ huan gǒu', 'My friend is called Xiaoming. He likes dogs.')),
    ),
  ], TbCorner('tb-c1', TbRadical('女', 'woman', 'Many words for women and family have 女 on the left.', [
    ('妈', 'mā', 'mum'),
    ('姐', 'jiě', 'older sister'),
    ('妹', 'mèi', 'younger sister'),
    ('她', 'tā', 'she'),
    ('好', 'hǎo', 'good'),
    ('奶', 'nǎi', 'milk; grandma'),
  ]), [
    ('女 + 子 = 好', 'A woman and her child: "good".'),
    ('人 → 从 → 众', 'One person 人, a person following another 从 "to follow", three people 众 "a crowd".'),
  ], [
    TbPoem('咏鹅', 'Yǒng é', 'Ode to the goose', author: '唐 · 骆宾王 (Luò Bīnwáng)', [
      _L('鹅 ， 鹅 ， 鹅 ，', 'é é é', 'Goose, goose, goose,'),
      _L('曲 项 向 天 歌 。', 'qū xiàng xiàng tiān gē', 'bending its neck, it sings to the sky.'),
      _L('白 毛 浮 绿 水 ，', 'bái máo fú lǜ shuǐ', 'White feathers float on green water,'),
      _L('红 掌 拨 清 波 。', 'hóng zhǎng bō qīng bō', 'red feet push the clear waves.'),
    ], note: 'Often the first poem Chinese children learn. The poet is said to have written it at seven.'),
    TbPoem('家和万事兴', 'Jiā hé wàn shì xīng', 'A saying', [
      _L('家 和 万 事 兴', 'jiā hé wàn shì xīng', 'When the family is at peace, everything goes well.'),
    ]),
  ])),

  TbUnit(1, 2, '你好，谢谢', 'Manners and meals', 0xFF2E86AB, [
    TbLesson(
      id: 'tb-4',
      number: 4,
      kind: _r,
      title: '说声好',
      titlePy: 'Shuō shēng hǎo',
      titleEn: 'Say hello',
      lines: [
        _L('老师 早 ， 同学 早 ，', 'lǎo shī zǎo tóng xué zǎo', 'Good morning, teacher! Good morning, classmates!'),
        _L('见面 先 说 一 声 好 。', 'jiàn miàn xiān shuō yì shēng hǎo', 'When we meet, first we say hello.'),
        _L('借 了 东西 说 谢谢 ，', 'jiè le dōng xi shuō xiè xie', 'When we borrow something, we say thank you,'),
        _L('做 错 事情 说 对不起 ，', 'zuò cuò shì qing shuō duì bu qǐ', 'when we do something wrong, we say sorry,'),
        _L('大家 都 说 我 真 好 。', 'dà jiā dōu shuō wǒ zhēn hǎo', 'and everyone says how good I am.'),
      ],
      note: '早 on its own is a quick "good morning". 早 and 好 rhyme.',
      chars: [
        _C('早', 'zǎo', 'early; morning', radical: '日', words: ['早上', '早饭'], write: true),
        _C('老', 'lǎo', 'old', radical: '老', words: ['老师']),
        _C('师', 'shī', 'teacher', words: ['老师']),
        _C('见', 'jiàn', 'to see, to meet', radical: '见', words: ['再见', '看见', '见面'], write: true),
        _C('说', 'shuō', 'to speak, to say', radical: '讠', words: ['说话'], write: true),
        _C('谢', 'xiè', 'to thank', radical: '讠', words: ['谢谢']),
      ],
      fills: [
        TbFill('借 了 东西 说 ＿ 。', ['谢谢', '对不起', '再见'], 'When we borrow something, we say thank you.'),
        TbFill('做 错 事情 说 ＿ 。', ['对不起', '谢谢', '你好'], 'When we do something wrong, we say sorry.'),
      ],
      orders: [TbOrder('见面 先 说 一 声 好 。', 'When we meet, first we say hello.')],
      speak: TbSpeak('Greet your teacher in the morning.', _L('老师 早 ！', 'lǎo shī zǎo', 'Good morning, teacher!')),
    ),
    TbLesson(
      id: 'tb-5',
      number: 5,
      kind: _c,
      title: '水果',
      titlePy: 'Shuǐguǒ',
      titleEn: 'Fruit',
      lines: [
        _L('苹果 红 ， 西瓜 大 ，', 'píng guǒ hóng xī guā dà', 'Apples are red, watermelons are big,'),
        _L('香蕉 长 ， 葡萄 小 ，', 'xiāng jiāo cháng pú tao xiǎo', 'bananas are long, grapes are small.'),
        _L('水果 好吃 我 都 要 ，', 'shuǐ guǒ hǎo chī wǒ dōu yào', 'Fruit is tasty, I want them all,'),
        _L('吃 了 水果 身体 好 。', 'chī le shuǐ guǒ shēn tǐ hǎo', 'eating fruit keeps you healthy.'),
      ],
      note: 'In a list like this, a describing word can follow the thing directly: 苹果红 "apples, red". '
          'In an ordinary sentence you add 很: 苹果很红.',
      chars: [
        _C('苹', 'píng', '(in 苹果, apple)', radical: '艹', words: ['苹果']),
        _C('果', 'guǒ', 'fruit', radical: '木', words: ['水果', '苹果']),
        _C('瓜', 'guā', 'melon', radical: '瓜', words: ['西瓜']),
        _C('大', 'dà', 'big', radical: '大', words: ['大家', '大学'], write: true),
        _C('小', 'xiǎo', 'small', radical: '小', words: ['小姐', '小时'], write: true),
        _C('吃', 'chī', 'to eat', radical: '口', words: ['好吃', '吃饭'], write: true),
      ],
      fills: [
        TbFill('西瓜 ＿ ， 葡萄 小 。', ['大', '小', '长'], 'Watermelons are big, grapes are small.'),
        TbFill('香蕉 ＿ 。', ['长', '大', '红'], 'Bananas are long.'),
      ],
      asks: [TbAsk('“ 大 ” 的 反义词 是 什么 ？', 'What is the opposite of 大?', ['小', '长', '红'])],
      orders: [TbOrder('吃 了 水果 身体 好 。', 'Eating fruit keeps you healthy.')],
      speak: TbSpeak('Say which fruit you like.', _L('我 喜欢 吃 苹果 。', 'wǒ xǐ huan chī píng guǒ', 'I like eating apples.')),
    ),
    TbLesson(
      id: 'tb-6',
      number: 6,
      kind: _t,
      title: '在饭馆',
      titlePy: 'Zài fànguǎn',
      titleEn: 'At the restaurant',
      lines: [
        _L('服务员 ： 你们 好 ！ 请 坐 。 你们 想 吃 什么 ？', 'fú wù yuán nǐ men hǎo qǐng zuò nǐ men xiǎng chī shén me',
            'Waiter: Hello! Please sit down. What would you like to eat?'),
        _L('爸爸 ： 我们 要 米饭 和 鱼 。', 'bà ba wǒ men yào mǐ fàn hé yú', 'Dad: We would like rice and fish.'),
        _L('服务员 ： 想 喝 什么 ？', 'fú wù yuán xiǎng hē shén me', 'Waiter: What would you like to drink?'),
        _L('妈妈 ： 一 杯 茶 ， 一 杯 牛奶 。', 'mā ma yì bēi chá yì bēi niú nǎi', 'Mum: A cup of tea and a glass of milk.'),
        _L('我 ： 我 想 喝 水 。', 'wǒ wǒ xiǎng hē shuǐ', 'Me: I would like water.'),
        _L('服务员 ： 好 的 ， 请 等 一下 。', 'fú wù yuán hǎo de qǐng děng yí xià', 'Waiter: OK, one moment please.'),
      ],
      note: '想 "would like" is softer than 要 "want". Both are fine for ordering.',
      chars: [
        _C('饭', 'fàn', 'cooked rice; meal', radical: '饣', words: ['米饭', '饭馆']),
        _C('喝', 'hē', 'to drink', radical: '口', words: ['好喝']),
        _C('茶', 'chá', 'tea', radical: '艹', words: ['红茶', '绿茶'], write: true),
        _C('坐', 'zuò', 'to sit; to travel by', radical: '土', write: true),
        _C('想', 'xiǎng', 'to want, to think', radical: '心'),
        _C('鱼', 'yú', 'fish', radical: '鱼'),
      ],
      fills: [
        TbFill('请 ＿ 。', ['坐', '吃', '喝'], 'Please sit down.'),
        TbFill('一 杯 ＿ 。', ['茶', '鱼', '米饭'], 'A cup of tea.'),
      ],
      asks: [
        TbAsk('爸爸 要 什么 ？', 'What does Dad order?', ['米饭 和 鱼', '茶', '牛奶']),
        TbAsk('“ 我 ” 想 喝 什么 ？', 'What do I want to drink?', ['水', '茶', '牛奶']),
      ],
      orders: [TbOrder('你们 想 吃 什么 ？', 'What would you like to eat?')],
      speak: TbSpeak('Order a drink.', _L('我 想 喝 一 杯 茶 。', 'wǒ xiǎng hē yì bēi chá', 'I would like a cup of tea.')),
    ),
  ], TbCorner('tb-c2', TbRadical('口', 'mouth', 'Words for eating, drinking and speaking often have 口.', [
    ('吃', 'chī', 'to eat'),
    ('喝', 'hē', 'to drink'),
    ('叫', 'jiào', 'to call'),
    ('吗', 'ma', '(question word)'),
    ('呢', 'ne', '(and you?)'),
    ('唱', 'chàng', 'to sing'),
  ]), [
    ('木 → 林 → 森', 'One tree 木, two trees 林 "woods", three trees 森 "forest".'),
    ('手 + 目 = 看', 'A hand held over an eye: "to look".'),
  ], [
    TbPoem('春晓', 'Chūn xiǎo', 'Spring morning', author: '唐 · 孟浩然 (Mèng Hàorán)', [
      _L('春 眠 不 觉 晓 ，', 'chūn mián bù jué xiǎo', 'Sleeping in spring, I miss the dawn;'),
      _L('处 处 闻 啼 鸟 。', 'chù chù wén tí niǎo', 'everywhere I hear the birds sing.'),
      _L('夜 来 风 雨 声 ，', 'yè lái fēng yǔ shēng', 'In the night came the sound of wind and rain;'),
      _L('花 落 知 多 少 。', 'huā luò zhī duō shǎo', 'who knows how many flowers fell?'),
    ]),
    TbPoem('民以食为天', 'Mín yǐ shí wéi tiān', 'A saying', [
      _L('民 以 食 为 天', 'mín yǐ shí wéi tiān', 'For the people, food comes first.'),
    ], note: 'Word for word: "the people take food as heaven".'),
  ])),

  TbUnit(1, 3, '出门', 'Out and about', 0xFF2E9E5B, [
    TbLesson(
      id: 'tb-7',
      number: 7,
      kind: _c,
      title: '天气',
      titlePy: 'Tiānqì',
      titleEn: 'Weather',
      lines: [
        _L('天气 冷 ， 天气 热 ，', 'tiān qì lěng tiān qì rè', 'Cold weather, hot weather,'),
        _L('下雨 了 ， 下 雪 了 。', 'xià yǔ le xià xuě le', "it's raining, it's snowing."),
        _L('冷 了 多 穿 衣服 ，', 'lěng le duō chuān yī fu', "When it's cold, wear more clothes;"),
        _L('热 了 多 喝 水 。', 'rè le duō hē shuǐ', "when it's hot, drink more water."),
      ],
      note: '了 at the end can mean "now it is…": 下雨了 "it has started to rain".',
      chars: [
        _C('冷', 'lěng', 'cold', radical: '冫'),
        _C('热', 'rè', 'hot', radical: '灬', words: ['热情']),
        _C('雨', 'yǔ', 'rain', radical: '雨', words: ['下雨'], write: true),
        _C('雪', 'xuě', 'snow', radical: '雨', words: ['下雪']),
        _C('衣', 'yī', 'clothes', radical: '衣', words: ['衣服'], write: true),
        _C('多', 'duō', 'many, more', radical: '夕', words: ['多少'], write: true),
      ],
      fills: [
        TbFill('冷 了 多 穿 ＿ 。', ['衣服', '水', '雪'], "When it's cold, wear more clothes."),
        TbFill('热 了 多 喝 ＿ 。', ['水', '衣服', '雨'], "When it's hot, drink more water."),
      ],
      asks: [TbAsk('“ 冷 ” 的 反义词 是 什么 ？', 'What is the opposite of 冷?', ['热', '雪', '多'])],
      orders: [TbOrder('冷 了 多 穿 衣服 。', "When it's cold, wear more clothes.")],
      speak: TbSpeak('Say what the weather is like today.', _L('今天 天气 很 冷 。', 'jīn tiān tiān qì hěn lěng', 'It is cold today.')),
    ),
    TbLesson(
      id: 'tb-8',
      number: 8,
      kind: _r,
      title: '我的一天',
      titlePy: 'Wǒ de yì tiān',
      titleEn: 'My day',
      lines: [
        _L('天 亮 了 ， 起床 了 ，', 'tiān liàng le qǐ chuáng le', "It's light, time to get up,"),
        _L('吃 了 早饭 去 学校 。', 'chī le zǎo fàn qù xué xiào', 'have breakfast, off to school.'),
        _L('上午 读 书 写 汉字 ，', 'shàng wǔ dú shū xiě Hàn zì', 'In the morning, read and write characters;'),
        _L('下午 回 家 和 狗 跑 。', 'xià wǔ huí jiā hé gǒu pǎo', 'in the afternoon, home to run with the dog.'),
        _L('晚上 九 点 睡觉 了 ，', 'wǎn shang jiǔ diǎn shuì jiào le', 'At nine in the evening, off to bed;'),
        _L('明天 还 要 起 得 早 。', 'míng tiān hái yào qǐ de zǎo', 'tomorrow I must get up early again.'),
      ],
      note: '校, 跑 and 早 rhyme (-ao).',
      chars: [
        _C('起', 'qǐ', 'to get up', radical: '走', words: ['起床', '一起']),
        _C('床', 'chuáng', 'bed', radical: '广', words: ['起床']),
        _C('上', 'shàng', 'up, on; first', words: ['上午', '上班'], write: true),
        _C('午', 'wǔ', 'noon', words: ['中午', '下午'], write: true),
        _C('回', 'huí', 'to go back', radical: '囗', words: ['回家'], write: true),
        _C('睡', 'shuì', 'to sleep', radical: '目', words: ['睡觉']),
      ],
      fills: [
        TbFill('吃 了 早饭 去 ＿ 。', ['学校', '医院', '商店'], 'Have breakfast, off to school.'),
        TbFill('晚上 九 点 ＿ 了 。', ['睡觉', '起床', '早饭'], 'At nine in the evening, off to bed.'),
      ],
      asks: [TbAsk('晚上 几 点 睡觉 ？', 'What time is bedtime?', ['九 点', '七 点', '十 点'])],
      orders: [TbOrder('下午 回 家 和 狗 跑 。', 'In the afternoon, home to run with the dog.')],
      speak: TbSpeak('Say what time you get up.', _L('我 早上 七 点 起床 。', 'wǒ zǎo shang qī diǎn qǐ chuáng', 'I get up at seven in the morning.')),
    ),
    TbLesson(
      id: 'tb-9',
      number: 9,
      kind: _t,
      title: '去北京',
      titlePy: 'Qù Běijīng',
      titleEn: 'Going to Beijing',
      lines: [
        _L('明天 是 星期六 。', 'míng tiān shì xīng qī liù', 'Tomorrow is Saturday.'),
        _L('爸爸 说 ： “ 我们 坐 飞机 去 北京 。 ”', 'bà ba shuō wǒ men zuò fēi jī qù Běi jīng', 'Dad says, "We are flying to Beijing."'),
        _L('我 很 高兴 。 北京 有 很 多 好吃 的 ， 也 有 很 多 好看 的 。',
            'wǒ hěn gāo xìng Běi jīng yǒu hěn duō hǎo chī de yě yǒu hěn duō hǎo kàn de',
            "I'm very happy. Beijing has lots of good food, and lots to see."),
        _L('我 想 在 北京 买 东西 ， 送 给 我 的 朋友 。', 'wǒ xiǎng zài Běi jīng mǎi dōng xi sòng gěi wǒ de péng you',
            'I want to buy things in Beijing for my friends.'),
      ],
      note: '坐飞机 is "to travel by plane": you 坐 "sit" in a plane, a taxi or a train.',
      chars: [
        _C('北', 'běi', 'north', words: ['北京'], write: true),
        _C('京', 'jīng', 'capital city', radical: '亠', words: ['北京']),
        _C('飞', 'fēi', 'to fly', radical: '飞', words: ['飞机']),
        _C('机', 'jī', 'machine', radical: '木', words: ['飞机', '手机', '机场'], write: true),
        _C('星', 'xīng', 'star', radical: '日', words: ['星期']),
        _C('期', 'qī', 'period of time', radical: '月', words: ['星期']),
      ],
      fills: [
        TbFill('我们 坐 ＿ 去 北京 。', ['飞机', '出租车', '学校'], 'We are flying to Beijing.'),
        TbFill('明天 是 ＿ 。', ['星期六', '北京', '飞机'], 'Tomorrow is Saturday.'),
      ],
      asks: [TbAsk('他们 怎么 去 北京 ？', 'How are they going to Beijing?', ['坐 飞机', '坐 出租车', '坐 火车'])],
      orders: [TbOrder('我 想 在 北京 买 东西 。', 'I want to buy things in Beijing.')],
      speak: TbSpeak('Say where you want to go, and how.', _L('我 想 坐 飞机 去 中国 。', 'wǒ xiǎng zuò fēi jī qù Zhōng guó', 'I want to fly to China.')),
    ),
  ], TbCorner('tb-c3', TbRadical('氵', 'water', '氵 is three drops of water. Words about water often have it. '
      '汉 (first the name of a river) and 没 (first "to sink") have it too.', [
    ('河', 'hé', 'river'),
    ('洗', 'xǐ', 'to wash'),
    ('游', 'yóu', 'to swim'),
    ('泳', 'yǒng', 'to swim'),
    ('汉', 'hàn', 'Chinese (in 汉语)'),
    ('没', 'méi', 'not have'),
  ]), [
    ('日 + 月 = 明', 'The sun and the moon together: "bright".'),
    ('小 + 大 = 尖', 'Small on top of big: "pointed".'),
    ('不 + 正 = 歪', 'Not straight: "crooked".'),
  ], [
    TbPoem('静夜思', 'Jìng yè sī', 'Quiet night thoughts', author: '唐 · 李白 (Lǐ Bái)', [
      _L('床 前 明 月 光 ，', 'chuáng qián míng yuè guāng', 'Moonlight shines in front of my bed;'),
      _L('疑 是 地 上 霜 。', 'yí shì dì shàng shuāng', 'I wonder if it is frost on the ground.'),
      _L('举 头 望 明 月 ，', 'jǔ tóu wàng míng yuè', 'I raise my head and look at the bright moon,'),
      _L('低 头 思 故 乡 。', 'dī tóu sī gù xiāng', 'I lower my head and think of home.'),
    ], note: 'Probably the best-known poem in China. Almost everyone can say it by heart.'),
  ])),

  // ======================= 第二册 Book 2 =======================
  TbUnit(2, 4, '学校', 'At school', 0xFF7B2CBF, [
    TbLesson(
      id: 'tb-10',
      number: 10,
      kind: _c,
      title: '教室里',
      titlePy: 'Jiàoshì li',
      titleEn: 'In the classroom',
      lines: [
        _L('走 进 教室 看 一 看 ，', 'zǒu jìn jiào shì kàn yi kàn', 'Walk into the classroom and have a look:'),
        _L('桌子 椅子 排 得 好 。', 'zhuō zi yǐ zi pái de hǎo', 'the desks and chairs stand in neat rows.'),
        _L('黑板 上 写 新 汉字 ，', 'hēi bǎn shàng xiě xīn Hàn zì', 'New characters are written on the blackboard,'),
        _L('我 的 铅笔 准备 好 。', 'wǒ de qiān bǐ zhǔn bèi hǎo', 'and my pencil is ready.'),
      ],
      note: '看一看 means "have a look". A verb, then 一, then the verb again makes it light and casual.',
      chars: [
        _C('室', 'shì', 'room', radical: '宀', words: ['教室', '办公室'], write: true),
        _C('桌', 'zhuō', 'table, desk', radical: '木', words: ['桌子']),
        _C('椅', 'yǐ', 'chair', radical: '木', words: ['椅子']),
        _C('板', 'bǎn', 'board', radical: '木', words: ['黑板']),
        _C('笔', 'bǐ', 'pen, brush', radical: '⺮', words: ['铅笔', '笔记本'], write: true),
        _C('黑', 'hēi', 'black', words: ['黑色', '黑板']),
      ],
      fills: [
        TbFill('桌子 ＿ 排 得 好 。', ['椅子', '铅笔', '汉字'], 'The desks and chairs stand in neat rows.'),
        TbFill('黑板 上 写 新 ＿ 。', ['汉字', '桌子', '铅笔'], 'New characters are written on the blackboard.'),
      ],
      asks: [TbAsk('黑板 上 有 什么 ？', 'What is on the blackboard?', ['新 汉字', '铅笔', '椅子'])],
      orders: [TbOrder('走 进 教室 看 一 看 。', 'Walk into the classroom and have a look.')],
      speak: TbSpeak('Name three things in your room.',
          _L('我 的 房间 里 有 桌子 ， 椅子 和 电脑 。', 'wǒ de fáng jiān lǐ yǒu zhuō zi yǐ zi hé diàn nǎo', 'In my room there is a desk, a chair and a computer.')),
    ),
    TbLesson(
      id: 'tb-11',
      number: 11,
      kind: _t,
      title: '考试',
      titlePy: 'Kǎoshì',
      titleEn: 'The test',
      lines: [
        _L('今天 上午 有 汉语 考试 。', 'jīn tiān shàng wǔ yǒu Hàn yǔ kǎo shì', 'There is a Chinese test this morning.'),
        _L('题 不 难 ， 小明 都 会 。', 'tí bù nán Xiǎo Míng dōu huì', "The questions aren't hard. Xiaoming can do them all."),
        _L('他 写 得 很 快 ， 也 没有 错 。', 'tā xiě de hěn kuài yě méi yǒu cuò', 'He writes fast, and makes no mistakes.'),
        _L('老师 说 ： “ 小明 ， 你 真 棒 ！ ”', 'lǎo shī shuō Xiǎo Míng nǐ zhēn bàng', 'The teacher says, "Xiaoming, well done!"'),
        _L('小明 笑 着 说 ： “ 因为 我 每 天 都 学习 。 ”', 'Xiǎo Míng xiào zhe shuō yīn wèi wǒ měi tiān dōu xué xí',
            'Xiaoming smiles and says, "That\'s because I study every day."'),
      ],
      note: '写得很快 "writes fast": 得 joins a verb to how well it is done.',
      chars: [
        _C('考', 'kǎo', 'to test', radical: '耂', words: ['考试']),
        _C('试', 'shì', 'to try', radical: '讠', words: ['考试']),
        _C('题', 'tí', 'question, problem', radical: '页', words: ['问题']),
        _C('快', 'kuài', 'fast', radical: '忄', words: ['快乐'], write: true),
        _C('错', 'cuò', 'wrong', radical: '钅', words: ['不错']),
        _C('笑', 'xiào', 'to smile, to laugh', radical: '⺮', write: true),
      ],
      fills: [
        TbFill('他 写 得 很 ＿ 。', ['快', '笑', '题'], 'He writes fast.'),
        TbFill('今天 上午 有 汉语 ＿ 。', ['考试', '老师', '学校'], 'There is a Chinese test this morning.'),
      ],
      asks: [
        TbAsk('“ 快 ” 的 反义词 是 什么 ？', 'What is the opposite of 快?', ['慢', '错', '笑']),
        TbAsk('小明 为什么 都 会 ？', 'Why can Xiaoming do every question?', ['他 每 天 都 学习', '题 很 多', '他 写 得 很 快']),
      ],
      orders: [TbOrder('我 每 天 都 学习 汉语 。', 'I study Chinese every day.')],
      speak: TbSpeak('Say how often you study Chinese.', _L('我 每 天 都 学习 汉语 。', 'wǒ měi tiān dōu xué xí Hàn yǔ', 'I study Chinese every day.')),
    ),
    TbLesson(
      id: 'tb-12',
      number: 12,
      kind: _r,
      title: '一起来运动',
      titlePy: 'Yìqǐ lái yùndòng',
      titleEn: "Let's do sport together",
      lines: [
        _L('你 跑步 ， 我 游泳 ，', 'nǐ pǎo bù wǒ yóu yǒng', 'You go running, I go swimming,'),
        _L('大家 一起 来 运动 。', 'dà jiā yì qǐ lái yùn dòng', "let's all do sport together."),
        _L('打篮球 ， 踢足球 ，', 'dǎ lán qiú tī zú qiú', 'Play basketball, play football,'),
        _L('身体 好 了 不 生病 。', 'shēn tǐ hǎo le bù shēng bìng', "a strong body doesn't get ill."),
      ],
      note: '"Play" is 打 for ball games played with the hands (打篮球) and 踢 "kick" for football (踢足球).',
      chars: [
        _C('跑', 'pǎo', 'to run', radical: '⻊', words: ['跑步']),
        _C('游', 'yóu', 'to swim; to travel', radical: '氵', words: ['游泳', '旅游']),
        _C('运', 'yùn', 'to move', radical: '辶', words: ['运动']),
        _C('动', 'dòng', 'to move', radical: '力', words: ['运动'], write: true),
        _C('球', 'qiú', 'ball', radical: '王', words: ['打篮球', '踢足球']),
        _C('体', 'tǐ', 'body', radical: '亻', words: ['身体'], write: true),
      ],
      fills: [
        TbFill('大家 一起 来 ＿ 。', ['运动', '跑步', '生病'], "Let's all do sport together."),
        TbFill('身体 好 了 不 ＿ 。', ['生病', '运动', '游泳'], "A strong body doesn't get ill."),
      ],
      asks: [TbAsk('足球 是 打 还是 踢 ？', 'Do you 打 or 踢 a football?', ['踢', '打', '跑'])],
      orders: [TbOrder('大家 一起 来 运动 。', "Let's all do sport together.")],
      speak: TbSpeak('Say which sport you like.', _L('我 喜欢 游泳 。', 'wǒ xǐ huan yóu yǒng', 'I like swimming.')),
    ),
  ], TbCorner('tb-c4', TbRadical('讠', 'speech', '讠 comes from 言 "speech". Words about speaking and language have it.', [
    ('说', 'shuō', 'to speak'),
    ('话', 'huà', 'words, speech'),
    ('语', 'yǔ', 'language'),
    ('请', 'qǐng', 'please'),
    ('谁', 'shéi', 'who'),
    ('课', 'kè', 'lesson'),
  ]), [
    ('大 ↔ 小 · 多 ↔ 少 · 冷 ↔ 热', 'Many words come in opposite pairs (反义词).'),
    ('快 ↔ 慢 · 对 ↔ 错 · 远 ↔ 近', 'Learning them in pairs makes both easier to remember.'),
  ], [
    TbPoem('学而时习之', 'Xué ér shí xí zhī', 'From the Analects of Confucius', author: '《论语》 (Lúnyǔ)', [
      _L('学 而 时 习 之 ，', 'xué ér shí xí zhī', 'To learn something and practise it often:'),
      _L('不 亦 说 乎 ？', 'bú yì yuè hū', 'is that not a joy?'),
    ], note: 'Here 说 is read yuè. It is an old way of writing 悦 "happy".'),
    TbPoem('活到老，学到老', 'Huó dào lǎo, xué dào lǎo', 'A saying', [
      _L('活 到 老 ， 学 到 老', 'huó dào lǎo xué dào lǎo', 'Keep learning as long as you live.'),
    ]),
  ])),

  TbUnit(2, 5, '买东西', 'Shopping and finding the way', 0xFFF18F01, [
    TbLesson(
      id: 'tb-13',
      number: 13,
      kind: _c,
      title: '颜色',
      titlePy: 'Yánsè',
      titleEn: 'Colours',
      lines: [
        _L('天 是 蓝 的 ， 云 是 白 的 ，', 'tiān shì lán de yún shì bái de', 'The sky is blue, the clouds are white,'),
        _L('花 是 红 的 ， 草 是 绿 的 。', 'huā shì hóng de cǎo shì lǜ de', 'the flowers are red, the grass is green.'),
        _L('我 喜欢 绿 的 ， 你 呢 ？', 'wǒ xǐ huan lǜ de nǐ ne', 'I like green. What about you?'),
      ],
      note: '是…的 here means "is a … one": 云是白的 "the clouds are white ones".',
      chars: [
        _C('云', 'yún', 'cloud', write: true),
        _C('白', 'bái', 'white', radical: '白', words: ['白色'], write: true),
        _C('红', 'hóng', 'red', radical: '纟', words: ['红色', '红茶']),
        _C('草', 'cǎo', 'grass', radical: '艹'),
        _C('绿', 'lǜ', 'green', radical: '纟', words: ['绿色', '绿茶']),
        _C('花', 'huā', 'flower', radical: '艹', words: ['花园']),
      ],
      fills: [
        TbFill('草 是 ＿ 的 。', ['绿', '红', '白'], 'The grass is green.'),
        TbFill('云 是 ＿ 的 。', ['白', '绿', '红'], 'The clouds are white.'),
      ],
      asks: [TbAsk('“ 我 ” 喜欢 什么 颜色 ？', 'Which colour do I like?', ['绿 的', '红 的', '白 的'])],
      orders: [TbOrder('花 是 红 的 。', 'The flowers are red.')],
      speak: TbSpeak('Say your favourite colour.', _L('我 喜欢 红色 。', 'wǒ xǐ huan hóng sè', 'I like red.')),
    ),
    TbLesson(
      id: 'tb-14',
      number: 14,
      kind: _t,
      title: '买衣服',
      titlePy: 'Mǎi yīfu',
      titleEn: 'Buying clothes',
      lines: [
        _L('星期天 ， 我 和 妈妈 去 商店 买 衣服 。', 'xīng qī tiān wǒ hé mā ma qù shāng diàn mǎi yī fu', 'On Sunday, Mum and I went to a shop to buy clothes.'),
        _L('我 看见 一 件 红色 的 衣服 ， 非常 漂亮 。', 'wǒ kàn jiàn yí jiàn hóng sè de yī fu fēi cháng piào liang', 'I saw a red top. It was really pretty.'),
        _L('我 问 服务员 ： “ 这 件 衣服 多少 钱 ？ ”', 'wǒ wèn fú wù yuán zhè jiàn yī fu duō shao qián', 'I asked the shop assistant, "How much is this?"'),
        _L('服务员 说 ： “ 三百 块 。 ”', 'fú wù yuán shuō sān bǎi kuài', 'The assistant said, "Three hundred yuan."'),
        _L('妈妈 说 ： “ 太 贵 了 ！ 有 便宜 的 吗 ？ ”', 'mā ma shuō tài guì le yǒu pián yi de ma', 'Mum said, "That\'s too expensive! Do you have a cheaper one?"'),
        _L('服务员 说 ： “ 有 ， 这 件 白色 的 一百 块 。 ”', 'fú wù yuán shuō yǒu zhè jiàn bái sè de yì bǎi kuài', 'The assistant said, "Yes, this white one is a hundred."'),
        _L('我 穿 了 一下 ， 很 好看 。 我们 就 买 了 白色 的 。', 'wǒ chuān le yí xià hěn hǎo kàn wǒ men jiù mǎi le bái sè de',
            'I tried it on and it looked nice. So we bought the white one.'),
      ],
      note: '件 is the counting word for clothes: 一件衣服 "one piece of clothing".',
      chars: [
        _C('买', 'mǎi', 'to buy', write: true),
        _C('件', 'jiàn', '(counts clothes)', radical: '亻', write: true),
        _C('贵', 'guì', 'expensive', radical: '贝'),
        _C('钱', 'qián', 'money', radical: '钅', words: ['钱包']),
        _C('店', 'diàn', 'shop', radical: '广', words: ['商店', '书店']),
        _C('便', 'pián', '(in 便宜, cheap)', radical: '亻', words: ['便宜']),
      ],
      fills: [
        TbFill('这 件 衣服 多少 ＿ ？', ['钱', '件', '贵'], 'How much is this piece of clothing?'),
        TbFill('太 ＿ 了 ！', ['贵', '便宜', '漂亮'], "That's too expensive!"),
      ],
      asks: [
        TbAsk('“ 贵 ” 的 反义词 是 什么 ？', 'What is the opposite of 贵?', ['便宜', '漂亮', '好看']),
        TbAsk('她们 买 了 什么 颜色 的 衣服 ？', 'What colour did they buy?', ['白色', '红色', '黑色']),
      ],
      orders: [TbOrder('这 件 衣服 多少 钱 ？', 'How much is this?')],
      speak: TbSpeak('Ask how much something costs.', _L('这 个 多少 钱 ？', 'zhè ge duō shao qián', 'How much is this?')),
    ),
    TbLesson(
      id: 'tb-15',
      number: 15,
      kind: _r,
      title: '怎么走',
      titlePy: 'Zěnme zǒu',
      titleEn: 'Which way?',
      lines: [
        _L('请 问 火车站 怎么 走 ？', 'qǐng wèn huǒ chē zhàn zěn me zǒu', 'Excuse me, how do I get to the train station?'),
        _L('往 前 走 ， 往 右 走 ，', 'wǎng qián zǒu wǎng yòu zǒu', 'Go straight on, then turn right,'),
        _L('十 分钟 ， 就 到 了 ，', 'shí fēn zhōng jiù dào le', "ten minutes and you're there."),
        _L('谢谢 你 ， 好 朋友 ！', 'xiè xie nǐ hǎo péng you', 'Thank you, my friend!'),
      ],
      note: '请问 "may I ask" is the polite way to start a question to a stranger. 走 and 友 rhyme.',
      chars: [
        _C('问', 'wèn', 'to ask', radical: '门', words: ['问题'], write: true),
        _C('前', 'qián', 'front', words: ['前面']),
        _C('右', 'yòu', 'right (side)', radical: '口', words: ['右边'], write: true),
        _C('到', 'dào', 'to arrive', radical: '刂', words: ['迟到']),
        _C('站', 'zhàn', 'station; to stand', radical: '立', words: ['火车站']),
        _C('钟', 'zhōng', 'clock', radical: '钅', words: ['分钟']),
      ],
      fills: [
        TbFill('往 前 走 ， 往 ＿ 走 。', ['右', '到', '问'], 'Go straight on, then turn right.'),
        TbFill('十 分钟 ， 就 ＿ 了 。', ['到', '走', '站'], "Ten minutes and you're there."),
      ],
      asks: [TbAsk('去 火车站 要 几 分钟 ？', 'How many minutes is it to the station?', ['十 分钟', '五 分钟', '九 分钟'])],
      orders: [TbOrder('请 问 火车站 怎么 走 ？', 'Excuse me, how do I get to the train station?')],
      speak: TbSpeak('Ask the way to the airport.', _L('请 问 机场 怎么 走 ？', 'qǐng wèn jī chǎng zěn me zǒu', 'Excuse me, how do I get to the airport?')),
    ),
  ], TbCorner('tb-c5', TbRadical('钅', 'metal', '钅 comes from 金 "metal, gold". 错 first meant "to inlay with gold".', [
    ('钱', 'qián', 'money'),
    ('铅', 'qiān', 'lead (in 铅笔, pencil)'),
    ('银', 'yín', 'silver (in 银行, bank)'),
    ('钟', 'zhōng', 'clock'),
    ('错', 'cuò', 'wrong'),
    ('铁', 'tiě', 'iron (in 地铁, underground)'),
  ]), [
    ('一个人 · 一本书 · 一杯茶', 'Different things take different counting words.'),
    ('一件衣服 · 一张票 · 一只猫', '件 is for clothes, 张 for flat things like tickets, 只 for animals.'),
  ], [
    TbPoem('一寸光阴一寸金', 'Yí cùn guāngyīn yí cùn jīn', 'A saying', [
      _L('一 寸 光 阴 一 寸 金', 'yí cùn guāng yīn yí cùn jīn', 'An inch of time is worth an inch of gold.'),
    ], note: 'Time is precious, so use it well.'),
    TbPoem('货比三家', 'Huò bǐ sān jiā', 'A saying', [
      _L('货 比 三 家', 'huò bǐ sān jiā', 'Compare the goods in three shops before you buy.'),
    ]),
  ])),

  TbUnit(2, 6, '节日和旅游', 'Seasons, birthdays and trips', 0xFFD7263D, [
    TbLesson(
      id: 'tb-16',
      number: 16,
      kind: _c,
      title: '四季',
      titlePy: 'Sì jì',
      titleEn: 'The four seasons',
      lines: [
        _L('春天 花 开 ， 夏天 很 热 ，', 'chūn tiān huā kāi xià tiān hěn rè', 'In spring the flowers bloom, summer is hot,'),
        _L('秋天 叶 黄 ， 冬天 下 雪 。', 'qiū tiān yè huáng dōng tiān xià xuě', 'in autumn the leaves turn yellow, in winter it snows.'),
        _L('一 年 四季 ， 我 都 喜欢 。', 'yì nián sì jì wǒ dōu xǐ huan', 'I love all four seasons of the year.'),
      ],
      note: 'Add 天 to a season to say it in everyday speech: 春天 "spring", 冬天 "winter".',
      chars: [
        _C('春', 'chūn', 'spring', radical: '日', words: ['春天', '春节'], write: true),
        _C('夏', 'xià', 'summer', words: ['夏天']),
        _C('秋', 'qiū', 'autumn', radical: '禾', words: ['秋天', '中秋节']),
        _C('冬', 'dōng', 'winter', words: ['冬天'], write: true),
        _C('叶', 'yè', 'leaf', radical: '口', words: ['叶子']),
        _C('季', 'jì', 'season', words: ['季节', '四季']),
      ],
      fills: [
        TbFill('冬天 下 ＿ 。', ['雪', '雨', '花'], 'In winter it snows.'),
        TbFill('春天 ＿ 开 。', ['花', '叶', '雪'], 'In spring the flowers bloom.'),
      ],
      asks: [TbAsk('一 年 有 几 个 季节 ？', 'How many seasons are there in a year?', ['四 个', '三 个', '十 个'])],
      orders: [TbOrder('一 年 四季 ， 我 都 喜欢 。', 'I love all four seasons of the year.')],
      speak: TbSpeak('Say which season you like.', _L('我 喜欢 秋天 。', 'wǒ xǐ huan qiū tiān', 'I like autumn.')),
    ),
    TbLesson(
      id: 'tb-17',
      number: 17,
      kind: _t,
      title: '生日',
      titlePy: 'Shēngrì',
      titleEn: 'My birthday',
      lines: [
        _L('今天 是 我 的 生日 。', 'jīn tiān shì wǒ de shēng rì', 'Today is my birthday.'),
        _L('早上 ， 妈妈 给 我 做 了 面条 。', 'zǎo shang mā ma gěi wǒ zuò le miàn tiáo', 'In the morning, Mum made me noodles.'),
        _L('妈妈 说 ： “ 在 中国 ， 生日 要 吃 面条 。 ”', 'mā ma shuō zài Zhōng guó shēng rì yào chī miàn tiáo', 'Mum says, "In China, you eat noodles on your birthday."'),
        _L('晚上 ， 我 的 朋友 都 来 了 。', 'wǎn shang wǒ de péng you dōu lái le', 'In the evening, all my friends came.'),
        _L('他们 唱歌 ， 跳舞 ， 还 送 给 我 很 多 礼物 。', 'tā men chàng gē tiào wǔ hái sòng gěi wǒ hěn duō lǐ wù',
            'They sang and danced, and gave me lots of presents.'),
        _L('大家 一起 说 ： “ 祝 你 生日 快乐 ！ ”', 'dà jiā yì qǐ shuō zhù nǐ shēng rì kuài lè', 'Together they said, "Happy birthday!"'),
        _L('我 觉得 今天 是 最 快乐 的 一 天 。', 'wǒ jué de jīn tiān shì zuì kuài lè de yì tiān', 'I think today was the happiest day.'),
      ],
      note: 'Long noodles stand for a long life, so birthday noodles are a wish for a long life.',
      chars: [
        _C('生', 'shēng', 'to be born; life', words: ['生日', '学生', '医生'], write: true),
        _C('日', 'rì', 'sun; day', radical: '日', words: ['生日'], write: true),
        _C('面', 'miàn', 'noodles; face', radical: '面', words: ['面条', '见面']),
        _C('唱', 'chàng', 'to sing', radical: '口', words: ['唱歌']),
        _C('歌', 'gē', 'song', radical: '欠', words: ['唱歌']),
        _C('礼', 'lǐ', 'gift; manners', radical: '礻', words: ['礼物']),
      ],
      fills: [
        TbFill('妈妈 给 我 做 了 ＿ 。', ['面条', '米饭', '礼物'], 'Mum made me noodles.'),
        TbFill('祝 你 生日 ＿ ！', ['快乐', '高兴', '漂亮'], 'Happy birthday!'),
      ],
      asks: [TbAsk('在 中国 ， 生日 要 吃 什么 ？', 'In China, what do you eat on your birthday?', ['面条', '米饭', '鱼'])],
      orders: [TbOrder('祝 你 生日 快乐 ！', 'Happy birthday!')],
      speak: TbSpeak('Wish someone a happy birthday.', _L('祝 你 生日 快乐 ！', 'zhù nǐ shēng rì kuài lè', 'Happy birthday!')),
    ),
    TbLesson(
      id: 'tb-18',
      number: 18,
      kind: _r,
      title: '去旅游',
      titlePy: 'Qù lǚyóu',
      titleEn: 'Off on a trip',
      lines: [
        _L('背 起 包 ， 去 旅游 ，', 'bēi qǐ bāo qù lǚ yóu', 'Bag on my back, off on a trip,'),
        _L('坐 上 火车 一起 走 。', 'zuò shàng huǒ chē yì qǐ zǒu', 'onto the train, and off we go.'),
        _L('看 大 山 ， 看 黄河 ，', 'kàn dà shān kàn Huáng Hé', 'See the high mountains, see the Yellow River:'),
        _L('好看 的 地方 真 多 ！', 'hǎo kàn de dì fang zhēn duō', 'there are so many beautiful places!'),
      ],
      note: '黄河, the Yellow River, is called the "mother river" of China. 河 and 多 rhyme.',
      chars: [
        _C('包', 'bāo', 'bag', radical: '勹', words: ['面包', '书包']),
        _C('旅', 'lǚ', 'to travel', radical: '方', words: ['旅游']),
        _C('火', 'huǒ', 'fire', radical: '火', words: ['火车'], write: true),
        _C('车', 'chē', 'vehicle', radical: '车', words: ['火车', '出租车', '汽车'], write: true),
        _C('河', 'hé', 'river', radical: '氵', words: ['黄河']),
        _C('地', 'dì', 'ground, place', radical: '土', words: ['地方', '地图']),
      ],
      fills: [
        TbFill('坐 上 ＿ 一起 走 。', ['火车', '飞机', '黄河'], 'Onto the train, and off we go.'),
        TbFill('好看 的 地方 真 ＿ ！', ['多', '少', '小'], 'There are so many beautiful places!'),
      ],
      asks: [TbAsk('他们 坐 什么 去 旅游 ？', 'How do they travel?', ['坐 火车', '坐 飞机', '坐 出租车'])],
      orders: [TbOrder('背 起 包 ， 去 旅游 。', 'Bag on my back, off on a trip.')],
      speak: TbSpeak('Say where you want to travel.', _L('我 想 去 北京 旅游 。', 'wǒ xiǎng qù Běi jīng lǚ yóu', 'I want to travel to Beijing.')),
    ),
  ], TbCorner('tb-c6', TbRadical('艹', 'grass', '艹 is grass on top. Plants, and things made from plants, have it.', [
    ('草', 'cǎo', 'grass'),
    ('花', 'huā', 'flower'),
    ('茶', 'chá', 'tea'),
    ('菜', 'cài', 'vegetables; dish'),
    ('苹', 'píng', '(in 苹果, apple)'),
    ('药', 'yào', 'medicine'),
  ]), [
    ('春天 · 夏天 · 秋天 · 冬天', 'Add 天 to a season to say it in everyday speech.'),
    ('桌子 · 椅子 · 杯子 · 叶子', '子 at the end often just marks a thing. It is said lightly: zi.'),
  ], [
    TbPoem('登鹳雀楼', 'Dēng Guànquè Lóu', 'Climbing Stork Tower', author: '唐 · 王之涣 (Wáng Zhīhuàn)', [
      _L('白 日 依 山 尽 ，', 'bái rì yī shān jìn', 'The white sun sinks behind the mountains,'),
      _L('黄 河 入 海 流 。', 'Huáng Hé rù hǎi liú', 'the Yellow River flows into the sea.'),
      _L('欲 穷 千 里 目 ，', 'yù qióng qiān lǐ mù', 'To see a thousand miles further,'),
      _L('更 上 一 层 楼 。', 'gèng shàng yì céng lóu', 'climb one more floor.'),
    ], note: 'The last two lines are often said to mean "aim higher".'),
    TbPoem('读万卷书，行万里路', 'Dú wàn juàn shū, xíng wàn lǐ lù', 'A saying', [
      _L('读 万 卷 书 ， 行 万 里 路', 'dú wàn juàn shū xíng wàn lǐ lù', 'Read ten thousand books, travel ten thousand miles.'),
    ]),
  ])),

  // ---------------- 第三册 · Book 3 (about HSK 3) ----------------

  TbUnit(3, 7, '城市生活', 'Life in the city', 0xFF00897B, [
    TbLesson(
      id: 'tb-19',
      number: 19,
      kind: _c,
      title: '城市',
      titlePy: 'Chéngshì',
      titleEn: 'The city',
      lines: [
        _L('城市 里 有 很 多 高 楼 ，', 'chéng shì lǐ yǒu hěn duō gāo lóu', 'The city has lots of tall buildings,'),
        _L('街 上 有 汽车 ， 地铁 ， 公共汽车 。', 'jiē shang yǒu qì chē dì tiě gōng gòng qì chē', 'and in the streets there are cars, the underground and buses.'),
        _L('银行 ， 超市 ， 图书馆 ，', 'yín háng chāo shì tú shū guǎn', 'Banks, supermarkets, libraries,'),
        _L('公园 里 有 花 也 有 树 。', 'gōng yuán lǐ yǒu huā yě yǒu shù', 'and the park has flowers and trees.'),
      ],
      note: '公共汽车 is the full word for "bus". People often just say 公交车 gōngjiāochē.',
      chars: [
        _C('城', 'chéng', 'city; city wall', radical: '土', words: ['城市']),
        _C('市', 'shì', 'market; city', words: ['城市', '超市'], write: true),
        _C('楼', 'lóu', 'building; floor', radical: '木', words: ['楼上', '楼下']),
        _C('街', 'jiē', 'street', radical: '彳'),
        _C('铁', 'tiě', 'iron', radical: '钅', words: ['地铁']),
        _C('银', 'yín', 'silver', radical: '钅', words: ['银行']),
        _C('园', 'yuán', 'garden, park', radical: '囗', words: ['公园', '花园'], write: true),
      ],
      fills: [
        TbFill('城市 里 有 很 多 高 ＿ 。', ['楼', '山', '河'], 'The city has lots of tall buildings.'),
        TbFill('＿ 里 有 花 也 有 树 。', ['公园', '银行', '超市'], 'The park has flowers and trees.'),
      ],
      asks: [TbAsk('街 上 有 什么 ？', 'What is in the streets?', ['汽车', '花', '树'])],
      orders: [TbOrder('公园 里 有 花 也 有 树 。', 'The park has flowers and trees.')],
      speak: TbSpeak('Say where you live.', _L('我 住 在 一 个 大 城市 。', 'wǒ zhù zài yí gè dà chéng shì', 'I live in a big city.')),
    ),
    TbLesson(
      id: 'tb-20',
      number: 20,
      kind: _t,
      title: '搬家',
      titlePy: 'Bān jiā',
      titleEn: 'Moving house',
      lines: [
        _L('上 个 月 ， 我们 家 搬 到 了 城市 的 东边 。', 'shàng ge yuè wǒ men jiā bān dào le chéng shì de dōng biān', 'Last month, my family moved to the east of the city.'),
        _L('新 家 在 十八 楼 ， 从 窗户 能 看见 一 条 河 。', 'xīn jiā zài shí bā lóu cóng chuāng hu néng kàn jiàn yì tiáo hé', 'Our new flat is on the 18th floor. From the window you can see a river.'),
        _L('附近 有 一 个 超市 ， 还 有 一 个 公园 。', 'fù jìn yǒu yí gè chāo shì hái yǒu yí gè gōng yuán', 'Nearby there is a supermarket and a park.'),
        _L('可是 学校 离 新 家 比较 远 ，', 'kě shì xué xiào lí xīn jiā bǐ jiào yuǎn', 'But school is quite far from the new flat,'),
        _L('我 每 天 要 坐 二十 分钟 地铁 。', 'wǒ měi tiān yào zuò èr shí fēn zhōng dì tiě', 'so every day I ride the underground for twenty minutes.'),
        _L('我 很 想 以前 的 邻居 ， 但是 我 也 喜欢 新 家 。', 'wǒ hěn xiǎng yǐ qián de lín jū dàn shì wǒ yě xǐ huan xīn jiā', 'I miss our old neighbours, but I like the new flat too.'),
      ],
      note: '离 says how far one place is from another: 学校离家很远 "school is far from home". 想 can also mean "to miss" someone.',
      chars: [
        _C('搬', 'bān', 'to move (things)', radical: '扌', words: ['搬家']),
        _C('新', 'xīn', 'new', radical: '斤', words: ['新年'], write: true),
        _C('窗', 'chuāng', 'window', radical: '穴', words: ['窗户']),
        _C('附', 'fù', 'near; to attach', radical: '阝', words: ['附近']),
        _C('近', 'jìn', 'near', radical: '辶', words: ['附近', '最近'], write: true),
        _C('离', 'lí', 'away from', words: ['离开']),
        _C('远', 'yuǎn', 'far', radical: '辶', write: true),
      ],
      fills: [
        TbFill('上 个 月 ， 我们 家 ＿ 到 了 城市 的 东边 。', ['搬', '走', '跑'], 'Last month, my family moved to the east of the city.'),
        TbFill('学校 ＿ 新 家 比较 远 。', ['离', '从', '在'], 'School is quite far from the new flat.'),
      ],
      asks: [TbAsk('“ 我 ” 每 天 怎么 去 学校 ？', 'How do I get to school every day?', ['坐 地铁', '坐 出租车', '走路'])],
      orders: [TbOrder('附近 有 一 个 超市 。', 'There is a supermarket nearby.')],
      speak: TbSpeak('Say that your home is close to school.', _L('我 家 离 学校 很 近 。', 'wǒ jiā lí xué xiào hěn jìn', 'My home is close to school.')),
    ),
    TbLesson(
      id: 'tb-21',
      number: 21,
      kind: _r,
      title: '过马路',
      titlePy: 'Guò mǎlù',
      titleEn: 'Crossing the road',
      lines: [
        _L('红灯 停 ， 绿灯 行 ，', 'hóng dēng tíng lǜ dēng xíng', 'Red light, stop. Green light, go.'),
        _L('黄灯 亮 了 等 一 等 。', 'huáng dēng liàng le děng yi děng', 'When the yellow light is on, wait a moment.'),
        _L('过 马路 ， 看 左右 ，', 'guò mǎ lù kàn zuǒ yòu', 'Crossing the road, look left and right.'),
        _L('安全 第一 要 记住 。', 'ān quán dì yī yào jì zhù', 'Safety first: remember that!'),
      ],
      note: '行 xíng here means "to go", as in old writing. In 银行 "bank" the same character is said háng.',
      chars: [
        _C('灯', 'dēng', 'lamp, light', radical: '火', words: ['红灯', '绿灯'], write: true),
        _C('停', 'tíng', 'to stop', radical: '亻', words: ['停车']),
        _C('等', 'děng', 'to wait', radical: '⺮'),
        _C('马', 'mǎ', 'horse', radical: '马', words: ['马路', '马上'], write: true),
        _C('路', 'lù', 'road', radical: '⻊', words: ['马路', '走路']),
        _C('安', 'ān', 'safe, calm', radical: '宀', words: ['安全']),
        _C('全', 'quán', 'whole; safe', words: ['安全']),
      ],
      fills: [
        TbFill('红灯 ＿ ， 绿灯 行 。', ['停', '走', '跑'], 'Red light, stop. Green light, go.'),
        TbFill('过 马路 ， 看 ＿ 。', ['左右', '上下', '前后'], 'Crossing the road, look left and right.'),
      ],
      asks: [TbAsk('黄灯 亮 了 要 怎么样 ？', 'What should you do when the yellow light is on?', ['等 一 等', '快 跑', '过 马路'])],
      orders: [TbOrder('红灯 停 ， 绿灯 行 。', 'Red light, stop. Green light, go.')],
      speak: TbSpeak('Remind a friend to be careful.', _L('安全 第一 ！', 'ān quán dì yī', 'Safety first!')),
    ),
  ], TbCorner('tb-c7', TbRadical('辶', 'walking', '辶 is a foot on the move. Words about going, coming and distance have it.', [
    ('这', 'zhè', 'this'),
    ('还', 'hái', 'still'),
    ('进', 'jìn', 'to enter'),
    ('远', 'yuǎn', 'far'),
    ('近', 'jìn', 'near'),
    ('送', 'sòng', 'to give; to see off'),
  ]), [
    ('近 ↔ 远 · 新 ↔ 旧', 'Opposites: near and far, new and old (旧 jiù).'),
    ('马 → 吗 · 妈 · 骂', '马 mǎ gives its sound to 吗 ma, 妈 mā and 骂 mà "to scold".'),
  ], [
    TbPoem('悯农', 'Mǐn nóng', 'Pity the farmers', author: '唐 · 李绅 (Lǐ Shēn)', [
      _L('锄 禾 日 当 午 ，', 'chú hé rì dāng wǔ', 'Hoeing the crops under the midday sun,'),
      _L('汗 滴 禾 下 土 。', 'hàn dī hé xià tǔ', 'sweat drips onto the soil below.'),
      _L('谁 知 盘 中 餐 ，', 'shéi zhī pán zhōng cān', 'Who knows that in the food on our plates,'),
      _L('粒 粒 皆 辛 苦 。', 'lì lì jiē xīn kǔ', 'every single grain is hard work?'),
    ], note: 'Children learn this poem to remember not to waste food.'),
    TbPoem('千里之行，始于足下', 'Qiān lǐ zhī xíng, shǐ yú zú xià', 'A saying', [
      _L('千 里 之 行 ， 始 于 足 下', 'qiān lǐ zhī xíng shǐ yú zú xià', 'A journey of a thousand miles begins with a single step.'),
    ]),
  ])),

  TbUnit(3, 8, '身体和健康', 'Body and health', 0xFF7B61FF, [
    TbLesson(
      id: 'tb-22',
      number: 22,
      kind: _c,
      title: '身体',
      titlePy: 'Shēntǐ',
      titleEn: 'My body',
      lines: [
        _L('我 有 一 张 脸 ， 两 只 眼睛 ，', 'wǒ yǒu yì zhāng liǎn liǎng zhī yǎn jing', 'I have one face, two eyes,'),
        _L('一 个 鼻子 ， 一 张 嘴 。', 'yí gè bí zi yì zhāng zuǐ', 'one nose and one mouth.'),
        _L('两 只 耳朵 听 声音 ，', 'liǎng zhī ěr duo tīng shēng yīn', 'Two ears to hear sounds,'),
        _L('两 只 手 ， 两 条 腿 ， 我 的 身体 真 有用 ！', 'liǎng zhī shǒu liǎng tiáo tuǐ wǒ de shēn tǐ zhēn yǒu yòng', 'two hands, two legs. My body is so useful!'),
      ],
      note: 'Each part has its own counting word: 一张脸, 一只眼睛, 一条腿. Look at the Counting words page for more.',
      chars: [
        _C('脸', 'liǎn', 'face', radical: '月', words: ['洗脸']),
        _C('眼', 'yǎn', 'eye', radical: '目', words: ['眼睛']),
        _C('鼻', 'bí', 'nose', radical: '鼻', words: ['鼻子']),
        _C('嘴', 'zuǐ', 'mouth', radical: '口'),
        _C('耳', 'ěr', 'ear', radical: '耳', words: ['耳朵'], write: true),
        _C('腿', 'tuǐ', 'leg', radical: '月'),
        _C('身', 'shēn', 'body', radical: '身', words: ['身体'], write: true),
      ],
      fills: [
        TbFill('两 只 ＿ 听 声音 。', ['耳朵', '眼睛', '鼻子'], 'Two ears to hear sounds.'),
        TbFill('我 有 两 条 ＿ 。', ['腿', '嘴', '脸'], 'I have two legs.'),
      ],
      asks: [TbAsk('我们 用 什么 听 声音 ？', 'What do we hear with?', ['耳朵', '眼睛', '嘴'])],
      orders: [TbOrder('我 的 身体 真 有用 ！', 'My body is so useful!')],
      speak: TbSpeak('Point to your eyes and say what they are.', _L('这 是 我 的 眼睛 。', 'zhè shì wǒ de yǎn jing', 'These are my eyes.')),
    ),
    TbLesson(
      id: 'tb-23',
      number: 23,
      kind: _t,
      title: '感冒了',
      titlePy: 'Gǎnmào le',
      titleEn: 'I caught a cold',
      lines: [
        _L('昨天 晚上 下 大 雨 ， 我 没 带 伞 。', 'zuó tiān wǎn shang xià dà yǔ wǒ méi dài sǎn', 'Last night it rained hard, and I didn\'t take an umbrella.'),
        _L('今天 早上 ， 我 头 疼 ， 还 发烧 了 。', 'jīn tiān zǎo shang wǒ tóu téng hái fā shāo le', 'This morning I had a headache and a fever.'),
        _L('妈妈 带 我 去 医院 看 医生 。', 'mā ma dài wǒ qù yī yuàn kàn yī shēng', 'Mum took me to the hospital to see a doctor.'),
        _L('医生 说 ： “ 你 感冒 了 ， 要 多 喝 水 ， 多 休息 。 ”', 'yī shēng shuō nǐ gǎn mào le yào duō hē shuǐ duō xiū xi',
            'The doctor said, "You\'ve caught a cold. Drink lots of water and rest a lot."'),
        _L('我 吃 了 药 ， 睡 了 一 天 。', 'wǒ chī le yào shuì le yì tiān', 'I took some medicine and slept all day.'),
        _L('第二 天 ， 我 的 病 就 好 了 。', 'dì èr tiān wǒ de bìng jiù hǎo le', 'The next day, I was better.'),
      ],
      note: 'In Chinese you "eat" medicine: 吃药. "To see a doctor" is 看医生 or 看病.',
      chars: [
        _C('感', 'gǎn', 'to feel', radical: '心', words: ['感冒']),
        _C('冒', 'mào', 'to give off; (in 感冒, a cold)', words: ['感冒']),
        _C('疼', 'téng', 'to hurt, sore', radical: '疒', words: ['头疼']),
        _C('烧', 'shāo', 'to burn; fever', radical: '火', words: ['发烧']),
        _C('医', 'yī', 'doctor; medicine', words: ['医生', '医院'], write: true),
        _C('药', 'yào', 'medicine', radical: '艹', words: ['吃药']),
        _C('病', 'bìng', 'illness', radical: '疒', words: ['生病', '看病'], write: true),
      ],
      fills: [
        TbFill('你 感冒 了 ， 要 多 ＿ 。', ['休息', '跑步', '工作'], 'You\'ve caught a cold. Rest a lot.'),
        TbFill('我 吃 了 ＿ ， 睡 了 一 天 。', ['药', '面条', '蛋糕'], 'I took some medicine and slept all day.'),
      ],
      asks: [TbAsk('“ 我 ” 为什么 感冒 了 ？', 'Why did I catch a cold?', ['没 带 伞', '没 吃 饭', '没 睡觉'])],
      orders: [TbOrder('妈妈 带 我 去 医院 。', 'Mum took me to the hospital.')],
      speak: TbSpeak('Tell the doctor your head hurts.', _L('我 头 疼 。', 'wǒ tóu téng', 'I have a headache.')),
    ),
    TbLesson(
      id: 'tb-24',
      number: 24,
      kind: _r,
      title: '洗手歌',
      titlePy: 'Xǐ shǒu gē',
      titleEn: 'The hand-washing song',
      lines: [
        _L('吃饭 以前 先 洗手 ，', 'chī fàn yǐ qián xiān xǐ shǒu', 'Before you eat, wash your hands first,'),
        _L('手心 手背 洗 一 洗 。', 'shǒu xīn shǒu bèi xǐ yi xǐ', 'palms and backs, give them a wash.'),
        _L('刷牙 洗脸 天天 做 ，', 'shuā yá xǐ liǎn tiān tiān zuò', 'Brush your teeth and wash your face every day,'),
        _L('干净 健康 不 生病 。', 'gān jìng jiàn kāng bù shēng bìng', 'stay clean and healthy and you won\'t get ill.'),
      ],
      note: 'Saying a verb twice with 一 in the middle, like 洗一洗, makes it short and gentle: "give it a wash".',
      chars: [
        _C('洗', 'xǐ', 'to wash', radical: '氵', words: ['洗手', '洗脸']),
        _C('刷', 'shuā', 'to brush', radical: '刂', words: ['刷牙']),
        _C('牙', 'yá', 'tooth', radical: '牙', words: ['刷牙'], write: true),
        _C('干', 'gān', 'dry', words: ['干净'], write: true),
        _C('净', 'jìng', 'clean', radical: '冫', words: ['干净']),
        _C('健', 'jiàn', 'healthy', radical: '亻', words: ['健康']),
        _C('康', 'kāng', 'healthy', radical: '广', words: ['健康']),
      ],
      fills: [
        TbFill('吃饭 以前 先 ＿ 。', ['洗手', '睡觉', '跑步'], 'Before you eat, wash your hands first.'),
        TbFill('＿ 洗脸 天天 做 。', ['刷牙', '唱歌', '爬山'], 'Brush your teeth and wash your face every day.'),
      ],
      asks: [TbAsk('吃饭 以前 要 做 什么 ？', 'What should you do before eating?', ['洗手', '刷牙', '睡觉'])],
      orders: [TbOrder('吃饭 以前 先 洗手 。', 'Before you eat, wash your hands first.')],
      speak: TbSpeak('Say you\'re going to wash your hands.', _L('我 去 洗手 。', 'wǒ qù xǐ shǒu', 'I\'m going to wash my hands.')),
    ),
  ], TbCorner('tb-c8', TbRadical('疒', 'illness', '疒 is a sickbed. Words about being ill or in pain have it.', [
    ('病', 'bìng', 'illness'),
    ('疼', 'téng', 'to hurt'),
    ('痛', 'tòng', 'pain'),
    ('瘦', 'shòu', 'thin'),
    ('痒', 'yǎng', 'itchy'),
    ('疯', 'fēng', 'mad, crazy'),
  ]), [
    ('头疼 · 牙疼 · 肚子疼', 'Put 疼 after a body part to say it hurts.'),
    ('胖 ↔ 瘦 · 干净 ↔ 脏', 'Opposites: fat and thin, clean and dirty (脏 zāng).'),
  ], [
    TbPoem('江雪', 'Jiāng xuě', 'River snow', author: '唐 · 柳宗元 (Liǔ Zōngyuán)', [
      _L('千 山 鸟 飞 绝 ，', 'qiān shān niǎo fēi jué', 'Over a thousand mountains, no bird flies;'),
      _L('万 径 人 踪 灭 。', 'wàn jìng rén zōng miè', 'on ten thousand paths, not a footprint.'),
      _L('孤 舟 蓑 笠 翁 ，', 'gū zhōu suō lì wēng', 'In a lone boat, an old man in a straw cape and hat'),
      _L('独 钓 寒 江 雪 。', 'dú diào hán jiāng xuě', 'fishes alone in the snow on the cold river.'),
    ], note: 'A whole snowy world in twenty characters, and one small person in the middle of it.'),
    TbPoem('三人行，必有我师', 'Sān rén xíng, bì yǒu wǒ shī', 'A saying of Confucius', [
      _L('三 人 行 ， 必 有 我 师', 'sān rén xíng bì yǒu wǒ shī', 'When three people walk together, one of them can be my teacher.'),
    ]),
  ])),

  TbUnit(3, 9, '大自然', 'Nature', 0xFF3BB273, [
    TbLesson(
      id: 'tb-25',
      number: 25,
      kind: _c,
      title: '大自然',
      titlePy: 'Dà zìrán',
      titleEn: 'Nature',
      lines: [
        _L('山 上 有 大 森林 ， 树 上 有 小鸟 。', 'shān shang yǒu dà sēn lín shù shang yǒu xiǎo niǎo', 'On the mountain is a big forest. In the trees are little birds.'),
        _L('河 里 有 小鱼 ， 天 上 有 白云 。', 'hé lǐ yǒu xiǎo yú tiān shàng yǒu bái yún', 'In the river are little fish. In the sky are white clouds.'),
        _L('太阳 出来 了 ， 月亮 回家 了 。', 'tài yáng chū lái le yuè liang huí jiā le', 'The sun has come out, and the moon has gone home.'),
        _L('大自然 真 美 ！', 'dà zì rán zhēn měi', 'Nature is so beautiful!'),
      ],
      note: '木 is one tree, 林 two trees "woods", 森 three trees: 森林 is a big forest.',
      chars: [
        _C('自', 'zì', 'self; nature', words: ['自己', '自行车'], write: true),
        _C('然', 'rán', 'so, like that', radical: '灬', words: ['然后']),
        _C('森', 'sēn', 'forest', radical: '木', words: ['森林']),
        _C('林', 'lín', 'woods', radical: '木', words: ['森林'], write: true),
        _C('树', 'shù', 'tree', radical: '木', words: ['大树']),
        _C('鸟', 'niǎo', 'bird', radical: '鸟', words: ['小鸟'], write: true),
        _C('阳', 'yáng', 'sun', radical: '阝', words: ['太阳']),
      ],
      fills: [
        TbFill('树 上 有 ＿ 。', ['小鸟', '小鱼', '白云'], 'In the trees are little birds.'),
        TbFill('＿ 出来 了 ， 月亮 回家 了 。', ['太阳', '星星', '小鸟'], 'The sun has come out, and the moon has gone home.'),
      ],
      asks: [TbAsk('河 里 有 什么 ？', 'What is in the river?', ['小鱼', '小鸟', '白云'])],
      orders: [TbOrder('大自然 真 美 ！', 'Nature is so beautiful!')],
      speak: TbSpeak('Say what you can see in the sky.', _L('天 上 有 太阳 。', 'tiān shàng yǒu tài yáng', 'The sun is in the sky.')),
    ),
    TbLesson(
      id: 'tb-26',
      number: 26,
      kind: _t,
      title: '小鸟和大树',
      titlePy: 'Xiǎo niǎo hé dà shù',
      titleEn: 'The little bird and the big tree',
      lines: [
        _L('一 棵 大树 上 住 着 一 只 小鸟 。', 'yì kē dà shù shang zhù zhe yì zhī xiǎo niǎo', 'A little bird lived in a big tree.'),
        _L('小鸟 每 天 给 大树 唱歌 ， 大树 很 高兴 。', 'xiǎo niǎo měi tiān gěi dà shù chàng gē dà shù hěn gāo xìng', 'Every day the bird sang to the tree, and the tree was happy.'),
        _L('冬天 到 了 ， 小鸟 要 飞 到 南方 去 。', 'dōng tiān dào le xiǎo niǎo yào fēi dào nán fāng qù', 'Winter came, and the bird had to fly south.'),
        _L('大树 说 ： “ 明年 春天 ， 你 还 回来 给 我 唱歌 吗 ？ ”', 'dà shù shuō míng nián chūn tiān nǐ hái huí lái gěi wǒ chàng gē ma',
            'The tree said, "Next spring, will you come back and sing to me?"'),
        _L('小鸟 说 ： “ 一定 ！ 你 等 着 我 。 ”', 'xiǎo niǎo shuō yí dìng nǐ děng zhe wǒ', 'The bird said, "I promise! Wait for me."'),
        _L('第二 年 春天 ， 小鸟 飞 回来 了 。', 'dì èr nián chūn tiān xiǎo niǎo fēi huí lái le', 'The next spring, the bird flew back.'),
        _L('它 站 在 大树 上 ， 唱 了 一 首 最 好听 的 歌 。', 'tā zhàn zài dà shù shang chàng le yì shǒu zuì hǎo tīng de gē',
            'It stood in the big tree and sang its loveliest song.'),
      ],
      note: '着 after a verb shows something going on: 住着 "living", 等着我 "be waiting for me".',
      chars: [
        _C('棵', 'kē', '(counts trees)', radical: '木'),
        _C('南', 'nán', 'south', words: ['南方'], write: true),
        _C('方', 'fāng', 'direction; square', radical: '方', words: ['南方', '地方'], write: true),
        _C('年', 'nián', 'year', words: ['明年', '新年'], write: true),
        _C('定', 'dìng', 'to fix, sure', radical: '宀', words: ['一定']),
        _C('首', 'shǒu', '(counts songs and poems)', radical: '首'),
      ],
      fills: [
        TbFill('冬天 到 了 ， 小鸟 要 飞 到 ＿ 去 。', ['南方', '北京', '学校'], 'Winter came, and the bird had to fly south.'),
        TbFill('小鸟 每 天 给 大树 ＿ 。', ['唱歌', '跳舞', '做饭'], 'Every day the bird sang to the tree.'),
      ],
      asks: [TbAsk('小鸟 什么 时候 飞 回来 了 ？', 'When did the little bird fly back?', ['第二 年 春天', '冬天', '第二 天'])],
      orders: [TbOrder('小鸟 飞 回来 了 。', 'The little bird flew back.')],
      speak: TbSpeak('Ask a friend to wait for you.', _L('你 等 着 我 。', 'nǐ děng zhe wǒ', 'Wait for me.')),
    ),
    TbLesson(
      id: 'tb-27',
      number: 27,
      kind: _r,
      title: '熊猫',
      titlePy: 'Xióngmāo',
      titleEn: 'The panda',
      lines: [
        _L('大 熊猫 ， 圆 又 胖 ，', 'dà xióng māo yuán yòu pàng', 'Big panda, round and fat,'),
        _L('黑 眼睛 ， 白 衣裳 。', 'hēi yǎn jing bái yī shang', 'black eyes and a white coat.'),
        _L('爱 吃 竹子 爱 睡觉 ，', 'ài chī zhú zi ài shuì jiào', 'It loves eating bamboo and loves sleeping,'),
        _L('大家 都 说 它 漂亮 。', 'dà jiā dōu shuō tā piào liang', 'and everyone says it\'s beautiful.'),
      ],
      note: '衣裳 is an older, friendly word for 衣服 "clothes". It rhymes with 胖 and 亮.',
      chars: [
        _C('熊', 'xióng', 'bear', radical: '灬', words: ['熊猫']),
        _C('猫', 'māo', 'cat', radical: '犭', words: ['熊猫']),
        _C('圆', 'yuán', 'round', radical: '囗'),
        _C('胖', 'pàng', 'fat', radical: '月'),
        _C('竹', 'zhú', 'bamboo', radical: '⺮', words: ['竹子'], write: true),
        _C('亮', 'liàng', 'bright', radical: '亠', words: ['漂亮', '月亮']),
      ],
      fills: [
        TbFill('大 熊猫 爱 吃 ＿ 。', ['竹子', '面包', '蛋糕'], 'Big pandas love eating bamboo.'),
        TbFill('黑 眼睛 ， ＿ 衣裳 。', ['白', '红', '绿'], 'Black eyes and a white coat.'),
      ],
      asks: [TbAsk('熊猫 爱 做 什么 ？', 'What do pandas love doing?', ['睡觉', '游泳', '唱歌'])],
      orders: [TbOrder('大家 都 说 它 漂亮 。', 'Everyone says it\'s beautiful.')],
      speak: TbSpeak('Say that you like pandas.', _L('我 喜欢 大 熊猫 。', 'wǒ xǐ huan dà xióng māo', 'I like giant pandas.')),
    ),
  ], TbCorner('tb-c9', TbRadical('木', 'tree, wood', '木 is a tree. Trees, and things made of wood, have it.', [
    ('树', 'shù', 'tree'),
    ('林', 'lín', 'woods'),
    ('森', 'sēn', 'forest'),
    ('桌', 'zhuō', 'table'),
    ('椅', 'yǐ', 'chair'),
    ('杯', 'bēi', 'cup'),
  ]), [
    ('木 → 林 → 森', 'One tree 木, two trees 林 "woods", three trees 森 "forest".'),
    ('鸟 → 鸡 · 鸭', '鸟 "bird" is part of many birds: 鸡 jī "chicken", 鸭 yā "duck".'),
  ], [
    TbPoem('赋得古原草送别', 'Fù dé gǔ yuán cǎo sòng bié', 'Grass on the old plain (first four lines)', author: '唐 · 白居易 (Bái Jūyì)', [
      _L('离 离 原 上 草 ，', 'lí lí yuán shàng cǎo', 'Thick grows the grass on the plain;'),
      _L('一 岁 一 枯 荣 。', 'yí suì yì kū róng', 'each year it withers, then grows green.'),
      _L('野 火 烧 不 尽 ，', 'yě huǒ shāo bú jìn', 'Wildfire can\'t burn it all away:'),
      _L('春 风 吹 又 生 。', 'chūn fēng chuī yòu shēng', 'the spring wind blows, and it grows again.'),
    ], note: 'Bai Juyi is said to have written it at sixteen. The grass that always grows back stands for never giving up.'),
    TbPoem('有志者事竟成', 'Yǒu zhì zhě shì jìng chéng', 'A saying', [
      _L('有 志 者 事 竟 成', 'yǒu zhì zhě shì jìng chéng', 'Where there\'s a will, there\'s a way.'),
    ]),
  ])),
];

List<TbUnit> tbUnitsOf(int book) => [for (final u in tbUnits) if (u.book == book) u];
List<TbLesson> get tbLessons => [for (final u in tbUnits) ...u.lessons];
TbUnit tbUnitOf(TbLesson l) => tbUnits.firstWhere((u) => u.lessons.contains(l));
