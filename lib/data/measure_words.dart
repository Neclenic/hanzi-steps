// Counting words (量词): in Chinese you can't say "one book", only "one 本 book" (一本书).
// Each counting word goes with a family of things.

class MeasureWord {
  final String char;
  final String pinyin;
  final String use; // what it counts, in English
  final List<String> nouns; // course words it goes with
  const MeasureWord(this.char, this.pinyin, this.use, this.nouns);
}

const measureWords = <MeasureWord>[
  MeasureWord('个', 'gè', 'the everyday one: people and many other things', ['人', '苹果', '问题', '朋友', '星期']),
  MeasureWord('本', 'běn', 'books and things bound like books', ['书', '字典', '笔记本']),
  MeasureWord('张', 'zhāng', 'flat things: tickets, tables, photos, beds, maps', ['票', '桌子', '照片', '床', '地图']),
  MeasureWord('件', 'jiàn', 'clothes for the top half, and matters or presents', ['衣服', '衬衫', '事情', '礼物']),
  MeasureWord('只', 'zhī', 'most animals, and one of a pair (a hand)', ['猫', '狗', '鸟', '熊猫', '手']),
  MeasureWord('杯', 'bēi', 'a cup or glass of a drink', ['茶', '咖啡', '水', '牛奶', '果汁']),
  MeasureWord('条', 'tiáo', 'long, thin things: fish, rivers, trousers, roads', ['鱼', '河', '裤子', '裙子', '路']),
  MeasureWord('辆', 'liàng', 'vehicles with wheels', ['自行车', '出租车', '公共汽车']),
  MeasureWord('双', 'shuāng', 'pairs: shoes, chopsticks, eyes', ['鞋', '筷子', '眼睛']),
  MeasureWord('位', 'wèi', 'people, said politely', ['老师', '客人', '医生', '先生']),
  MeasureWord('碗', 'wǎn', 'a bowl of food', ['米饭', '面条']),
  MeasureWord('瓶', 'píng', 'a bottle of something', ['水', '啤酒', '果汁', '牛奶']),
  MeasureWord('家', 'jiā', 'shops, companies and other businesses', ['饭馆', '商店', '公司', '银行', '超市', '医院']),
  MeasureWord('块', 'kuài', 'pieces and lumps: cake, bread, watches', ['蛋糕', '面包', '手表']),
];

/// All counting words that go with [noun]. 个 is left out: people use it with almost
/// anything in casual speech, so it is never offered as a wrong answer.
Set<String> measuresFor(String noun) => {
      for (final m in measureWords)
        if (m.nouns.contains(noun)) m.char,
    };

const measureTip = 'Chinese puts a counting word between the number and the thing: 一本书 "one 本 book". '
    'Use 两 (not 二) for "two": 两本书. 这 and 那 take one too: 这本书 "this book". '
    'When you don\'t know the right one, 个 is understood almost everywhere.';
