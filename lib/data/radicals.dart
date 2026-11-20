// Radicals (部首): the parts characters are built from that hint at their meaning.

class Radical {
  final String form; // as it looks inside a character, e.g. 氵
  final String name; // its everyday Chinese name, e.g. 三点水
  final String namePinyin;
  final String meaning;
  final String note;
  final List<(String, String, String)> chars; // character, pinyin, meaning
  const Radical(this.form, this.name, this.namePinyin, this.meaning, this.note, this.chars);
}

const radicals = <Radical>[
  Radical('亻', '单人旁', 'dānrénpáng', 'person', 'A standing person 人, squeezed onto the left side.', [
    ('你', 'nǐ', 'you'), ('他', 'tā', 'he'), ('们', 'men', '(plural)'), ('做', 'zuò', 'to do, to make'),
    ('住', 'zhù', 'to live'), ('休', 'xiū', 'to rest (a person by a tree)'), ('体', 'tǐ', 'body'), ('作', 'zuò', 'to work'),
  ]),
  Radical('氵', '三点水', 'sāndiǎnshuǐ', 'water', 'Three drops of water: rivers, washing, swimming.', [
    ('河', 'hé', 'river'), ('洗', 'xǐ', 'to wash'), ('游', 'yóu', 'to swim'), ('泳', 'yǒng', 'to swim'),
    ('汉', 'hàn', 'Chinese (first a river)'), ('没', 'méi', 'not have (first "to sink")'), ('酒', 'jiǔ', 'alcohol, wine'), ('海', 'hǎi', 'sea'),
  ]),
  Radical('口', '口字旁', 'kǒuzìpáng', 'mouth', 'Eating, drinking, speaking, and the little words at the end of sentences.', [
    ('吃', 'chī', 'to eat'), ('喝', 'hē', 'to drink'), ('叫', 'jiào', 'to call'), ('吗', 'ma', '(question word)'),
    ('呢', 'ne', '(and you?)'), ('唱', 'chàng', 'to sing'), ('哪', 'nǎ', 'which'), ('吧', 'ba', '(suggestion word)'),
  ]),
  Radical('女', '女字旁', 'nǚzìpáng', 'woman', 'Women and family members.', [
    ('妈', 'mā', 'mum'), ('姐', 'jiě', 'older sister'), ('妹', 'mèi', 'younger sister'), ('她', 'tā', 'she'),
    ('好', 'hǎo', 'good'), ('奶', 'nǎi', 'milk; grandma'), ('姓', 'xìng', 'family name'),
  ]),
  Radical('木', '木字旁', 'mùzìpáng', 'tree, wood', 'Trees and things made of wood.', [
    ('树', 'shù', 'tree'), ('桌', 'zhuō', 'table'), ('椅', 'yǐ', 'chair'), ('杯', 'bēi', 'cup'),
    ('机', 'jī', 'machine'), ('林', 'lín', 'woods'), ('校', 'xiào', 'school'),
  ]),
  Radical('艹', '草字头', 'cǎozìtóu', 'grass, plants', 'Grass on top: plants, and things made from plants.', [
    ('草', 'cǎo', 'grass'), ('花', 'huā', 'flower'), ('茶', 'chá', 'tea'), ('菜', 'cài', 'vegetables; dish'),
    ('苹', 'píng', '(in 苹果, apple)'), ('药', 'yào', 'medicine'), ('节', 'jié', 'festival'),
  ]),
  Radical('讠', '言字旁', 'yánzìpáng', 'speech', 'From 言 "words". Speaking and language.', [
    ('说', 'shuō', 'to speak'), ('话', 'huà', 'words, speech'), ('语', 'yǔ', 'language'), ('请', 'qǐng', 'please'),
    ('谁', 'shéi', 'who'), ('课', 'kè', 'lesson'), ('认', 'rèn', 'to recognise'), ('识', 'shí', 'to know'),
  ]),
  Radical('扌', '提手旁', 'tíshǒupáng', 'hand', 'From 手 "hand". Things you do with your hands.', [
    ('打', 'dǎ', 'to hit; to make (a call)'), ('找', 'zhǎo', 'to look for'), ('拿', 'ná', 'to hold, to take'),
    ('把', 'bǎ', 'to hold; (puts the object first)'), ('接', 'jiē', 'to meet, to pick up'), ('换', 'huàn', 'to change'),
    ('搬', 'bān', 'to move (things)'),
  ]),
  Radical('日', '日字旁', 'rìzìpáng', 'sun, day', 'Light, time and the weather.', [
    ('明', 'míng', 'bright'), ('早', 'zǎo', 'early'), ('晚', 'wǎn', 'late, evening'), ('时', 'shí', 'time'),
    ('昨', 'zuó', 'yesterday'), ('晴', 'qíng', 'sunny'), ('星', 'xīng', 'star'), ('春', 'chūn', 'spring'),
  ]),
  Radical('月', '月字旁', 'yuèzìpáng', 'moon; flesh', 'Two different old parts look like 月: the moon, and 肉 "flesh". '
      'That is why parts of the body have it.', [
    ('朋', 'péng', 'friend'), ('期', 'qī', 'period of time'), ('脸', 'liǎn', 'face'), ('脚', 'jiǎo', 'foot'),
    ('腿', 'tuǐ', 'leg'), ('胖', 'pàng', 'fat'), ('服', 'fú', 'clothes (in 衣服)'),
  ]),
  Radical('忄', '竖心旁', 'shùxīnpáng', 'heart, feelings', 'A standing heart 心. Feelings and states of mind. '
      'At the bottom of a character it stays 心, as in 想 and 您.', [
    ('忙', 'máng', 'busy'), ('快', 'kuài', 'fast; happy'), ('慢', 'màn', 'slow'), ('情', 'qíng', 'feeling'),
    ('怕', 'pà', 'to be afraid'), ('想', 'xiǎng', 'to think, to want'), ('您', 'nín', 'you (polite)'), ('意', 'yì', 'meaning, idea'),
  ]),
  Radical('辶', '走之旁', 'zǒuzhīpáng', 'walking', 'A foot on the move. Going, coming and distance.', [
    ('这', 'zhè', 'this'), ('还', 'hái', 'still'), ('进', 'jìn', 'to enter'), ('远', 'yuǎn', 'far'),
    ('近', 'jìn', 'near'), ('送', 'sòng', 'to give; to see off'), ('道', 'dào', 'road, way'), ('过', 'guò', 'to pass'),
  ]),
  Radical('⻊', '足字旁', 'zúzìpáng', 'foot', 'From 足 "foot". Running, jumping, kicking.', [
    ('跑', 'pǎo', 'to run'), ('跳', 'tiào', 'to jump'), ('踢', 'tī', 'to kick'), ('路', 'lù', 'road'), ('跟', 'gēn', 'with; to follow'),
  ]),
  Radical('饣', '食字旁', 'shízìpáng', 'food', 'From 食 "food". Eating and being hungry or full.', [
    ('饭', 'fàn', 'meal, rice'), ('饿', 'è', 'hungry'), ('饱', 'bǎo', 'full'), ('馆', 'guǎn', 'building (in 饭馆, restaurant)'),
  ]),
  Radical('钅', '金字旁', 'jīnzìpáng', 'metal, gold', 'From 金 "metal, gold". Money and things made of metal.', [
    ('钱', 'qián', 'money'), ('铅', 'qiān', 'lead (in 铅笔, pencil)'), ('银', 'yín', 'silver'), ('钟', 'zhōng', 'clock'),
    ('错', 'cuò', 'wrong (first "to inlay gold")'), ('铁', 'tiě', 'iron'),
  ]),
  Radical('纟', '绞丝旁', 'jiǎosīpáng', 'silk, thread', 'A twist of silk. Colours (from dyeing silk) and things that join or link.', [
    ('红', 'hóng', 'red'), ('绿', 'lǜ', 'green'), ('给', 'gěi', 'to give'), ('经', 'jīng', 'to pass through'),
    ('级', 'jí', 'grade, level'), ('结', 'jié', 'to tie'),
  ]),
  Radical('宀', '宝盖头', 'bǎogàitóu', 'roof', 'A roof on top. Houses, rooms and being safe at home.', [
    ('家', 'jiā', 'home'), ('室', 'shì', 'room'), ('字', 'zì', 'character'), ('安', 'ān', 'safe, calm'),
    ('客', 'kè', 'guest'), ('宾', 'bīn', 'guest (in 宾馆, hotel)'),
  ]),
  Radical('门', '门字框', 'ménzìkuàng', 'door', 'A doorway around the rest of the character.', [
    ('问', 'wèn', 'to ask (a mouth at the door)'), ('间', 'jiān', 'room; between'), ('闻', 'wén', 'to hear (in 新闻, news)'),
    ('们', 'men', '(plural)'),
  ]),
  Radical('目', '目字旁', 'mùzìpáng', 'eye', 'An eye on its side. Looking and sleeping.', [
    ('睡', 'shuì', 'to sleep'), ('看', 'kàn', 'to look (a hand over the eye)'), ('眼', 'yǎn', 'eye'), ('睛', 'jīng', 'eyeball'),
  ]),
  Radical('雨', '雨字头', 'yǔzìtóu', 'rain', 'Rain on top. Weather.', [
    ('雪', 'xuě', 'snow'), ('零', 'líng', 'zero (first "drizzle")'), ('需', 'xū', 'to need'), ('雷', 'léi', 'thunder'),
  ]),
  Radical('灬', '四点底', 'sìdiǎndǐ', 'fire', 'Four dots at the bottom are flames, from 火 "fire".', [
    ('热', 'rè', 'hot'), ('点', 'diǎn', 'dot; o\'clock'), ('照', 'zhào', 'to shine; photo'), ('熊', 'xióng', 'bear'),
    ('然', 'rán', 'so, like that'), ('黑', 'hēi', 'black (soot)'),
  ]),
  Radical('车', '车字旁', 'chēzìpáng', 'vehicle', 'A cart seen from above.', [
    ('辆', 'liàng', '(counts vehicles)'), ('轻', 'qīng', 'light (not heavy)'), ('较', 'jiào', 'rather (in 比较)'),
  ]),
  Radical('礻', '示字旁', 'shìzìpáng', 'spirits, rites', 'From 示 "an altar". Wishes, blessings and manners.', [
    ('礼', 'lǐ', 'gift; manners'), ('祝', 'zhù', 'to wish'), ('视', 'shì', 'to look at (in 电视)'), ('福', 'fú', 'good fortune'),
  ]),
  Radical('衤', '衣字旁', 'yīzìpáng', 'clothes', 'From 衣 "clothes". Looks like 礻 with one more dot.', [
    ('衬', 'chèn', 'lining (in 衬衫, shirt)'), ('衫', 'shān', 'shirt'), ('裤', 'kù', 'trousers'), ('裙', 'qún', 'skirt'),
  ]),
];

/// Simple characters with none of the radicals above, used as wrong answers in the quiz.
const plainChars = ['大', '小', '上', '下', '十', '天', '不', '也', '年', '生', '出', '文', '少', '太', '千', '万', '东', '北', '九'];
