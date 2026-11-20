// Characters that are easy to mix up, because they look alike or sound the same.
// Each character comes with an example word, so the drill can ask "which one goes here?".

class LookAlike {
  final String char;
  final String pinyin;
  final String meaning;
  final String example; // a word or phrase that contains [char]
  final String examplePinyin;
  final String exampleMeaning;
  const LookAlike(this.char, this.pinyin, this.meaning, this.example, this.examplePinyin, this.exampleMeaning);

  /// The example with this character left out, e.g. 休息 → ＿息.
  String get gap => example.replaceFirst(char, '＿');
}

class LookAlikeGroup {
  final String id;
  final List<LookAlike> chars;
  final String tip; // how to tell them apart
  const LookAlikeGroup(this.id, this.chars, this.tip);

  String get title => chars.map((c) => c.char).join(' · ');
}

typedef _C = LookAlike;

const lookAlikeGroups = <LookAlikeGroup>[
  LookAlikeGroup('ren-ru', [
    _C('人', 'rén', 'person', '中国人', 'Zhōngguó rén', 'Chinese person'),
    _C('入', 'rù', 'to enter', '进入', 'jìnrù', 'to go in'),
    _C('八', 'bā', 'eight', '八月', 'bā yuè', 'August'),
  ], '人 is a person walking: the left leg is longer. 入 is the other way round: the right stroke is longer and starts higher. '
      'In 八 the two strokes don\'t touch at all.'),
  LookAlikeGroup('da-tai', [
    _C('大', 'dà', 'big', '大家', 'dàjiā', 'everybody'),
    _C('太', 'tài', 'too, very', '太阳', 'tàiyáng', 'the sun'),
    _C('天', 'tiān', 'sky, day', '今天', 'jīntiān', 'today'),
  ], '大 is a person with arms spread wide: big! 太 adds a dot underneath, "even bigger", so too much. '
      '天 adds a line above the person: the sky.'),
  LookAlikeGroup('ji-yi', [
    _C('己', 'jǐ', 'self', '自己', 'zìjǐ', 'oneself'),
    _C('已', 'yǐ', 'already', '已经', 'yǐjīng', 'already'),
  ], 'Look at the top left corner. 己 is wide open. In 已 the stroke goes half way up: it is "already" half closed.'),
  LookAlikeGroup('mai', [
    _C('买', 'mǎi', 'to buy', '买东西', 'mǎi dōngxi', 'to go shopping'),
    _C('卖', 'mài', 'to sell', '卖东西', 'mài dōngxi', 'to sell things'),
  ], '卖 has an extra 十 on top. You need to have more (十) to sell. Listen for the tone too: mǎi dips, mài falls.'),
  LookAlikeGroup('ri-mu', [
    _C('日', 'rì', 'sun, day', '生日', 'shēngrì', 'birthday'),
    _C('目', 'mù', 'eye', '节目', 'jiémù', 'TV programme'),
    _C('白', 'bái', 'white', '白天', 'báitiān', 'daytime'),
  ], '日 has one line inside, 目 (an eye turned upright) has two. 白 is the sun with a ray of light on top.'),
  LookAlikeGroup('tu-shi', [
    _C('土', 'tǔ', 'earth, soil', '土豆', 'tǔdòu', 'potato'),
    _C('士', 'shì', 'scholar', '女士', 'nǚshì', 'Ms, madam'),
  ], 'In 土 the bottom line is longer, like the wide ground. In 士 the top line is longer.'),
  LookAlikeGroup('wei-mo', [
    _C('未', 'wèi', 'not yet', '未来', 'wèilái', 'the future'),
    _C('末', 'mò', 'end, tip', '周末', 'zhōumò', 'weekend'),
  ], 'Both are a tree with an extra line. In 末 the top line is longer: the tip of the tree, the end. '
      'In 未 the top line is short: the tree has not grown yet.'),
  LookAlikeGroup('qian-gan', [
    _C('千', 'qiān', 'thousand', '两千', 'liǎngqiān', 'two thousand'),
    _C('干', 'gān', 'dry', '干净', 'gānjìng', 'clean'),
    _C('于', 'yú', 'at, in', '于是', 'yúshì', 'and so'),
  ], '千 starts with a slanting stroke on top. 干 has a flat line on top and a straight leg. 于 has a hook at the bottom.'),
  LookAlikeGroup('wu-niu', [
    _C('午', 'wǔ', 'noon', '中午', 'zhōngwǔ', 'noon'),
    _C('牛', 'niú', 'cow', '牛奶', 'niúnǎi', 'milk'),
  ], 'In 牛 the middle stroke pokes out at the top, like a horn. In 午 it stays inside.'),
  LookAlikeGroup('wang-yu', [
    _C('王', 'wáng', 'king', '国王', 'guówáng', 'king'),
    _C('玉', 'yù', 'jade', '玉米', 'yùmǐ', 'corn'),
    _C('主', 'zhǔ', 'host, main', '主要', 'zhǔyào', 'main'),
  ], 'They are all 王 with a dot. 玉 has the dot at the bottom right, like a jade bead. 主 has it on top, like a flame.'),
  LookAlikeGroup('men', [
    _C('门', 'mén', 'door', '门口', 'ménkǒu', 'doorway'),
    _C('问', 'wèn', 'to ask', '问题', 'wèntí', 'question'),
    _C('间', 'jiān', 'between, room', '时间', 'shíjiān', 'time'),
    _C('们', 'men', '(plural)', '我们', 'wǒmen', 'we'),
  ], '问 is a mouth 口 at the door: asking. 间 is the sun 日 shining through a gap in the door. '
      '们 has the person 亻 next to the door: people.'),
  LookAlikeGroup('xiu-ti', [
    _C('休', 'xiū', 'to rest', '休息', 'xiūxi', 'to rest'),
    _C('体', 'tǐ', 'body', '身体', 'shēntǐ', 'body, health'),
  ], '休 is a person 亻 leaning on a tree 木: resting. 体 has 本 (with an extra line at the bottom) next to the person.'),
  LookAlikeGroup('zhao-wo', [
    _C('找', 'zhǎo', 'to look for', '找到', 'zhǎodào', 'to find'),
    _C('我', 'wǒ', 'I, me', '我们', 'wǒmen', 'we'),
  ], '找 has the hand 扌 on the left: you use your hand to look for things. 我 has an extra slanting stroke on top of the left side.'),
  LookAlikeGroup('jian-bei', [
    _C('见', 'jiàn', 'to see', '再见', 'zàijiàn', 'goodbye'),
    _C('贝', 'bèi', 'shell', '宝贝', 'bǎobèi', 'darling, treasure'),
  ], '见 is an eye on legs, and the last leg bends out with a hook. 贝 ends with two short legs that don\'t bend.'),
  LookAlikeGroup('he-ke', [
    _C('喝', 'hē', 'to drink', '喝水', 'hē shuǐ', 'to drink water'),
    _C('渴', 'kě', 'thirsty', '口渴', 'kǒukě', 'thirsty'),
  ], 'The right side is the same. 喝 has a mouth 口: you drink with your mouth. 渴 has water 氵: you need water.'),
  LookAlikeGroup('zai', [
    _C('在', 'zài', 'at, in', '在家', 'zài jiā', 'at home'),
    _C('再', 'zài', 'again', '再见', 'zàijiàn', 'goodbye ("see again")'),
  ], 'They sound exactly the same, so look at the meaning. 再 means again. 在 means at or in a place.'),
  LookAlikeGroup('ta', [
    _C('他', 'tā', 'he', '他们', 'tāmen', 'they (men, or a mixed group)'),
    _C('她', 'tā', 'she', '她们', 'tāmen', 'they (women)'),
    _C('它', 'tā', 'it', '它们', 'tāmen', 'they (animals or things)'),
  ], 'All three are said tā. 他 has a person 亻, 她 has a woman 女, and 它 is for animals and things.'),
  LookAlikeGroup('de', [
    _C('的', 'de', '(of, \'s)', '我的书', 'wǒ de shū', 'my book'),
    _C('得', 'de', '(how well)', '跑得快', 'pǎo de kuài', 'runs fast'),
    _C('地', 'de', '(-ly)', '慢慢地走', 'mànmàn de zǒu', 'walk slowly'),
  ], 'All three are said de. 的 comes before a thing (我的书). 得 comes after an action to say how well (跑得快). '
      '地 comes before an action to say how it is done (慢慢地走).'),
  LookAlikeGroup('zhu-wang', [
    _C('住', 'zhù', 'to live', '住在', 'zhù zài', 'to live in'),
    _C('往', 'wǎng', 'towards', '往前走', 'wǎng qián zǒu', 'go straight ahead'),
  ], '住 has a person 亻: where people live. 往 has the "step" side 彳, which looks like a double person: going somewhere.'),
  LookAlikeGroup('qing', [
    _C('晴', 'qíng', 'sunny', '晴天', 'qíngtiān', 'a sunny day'),
    _C('睛', 'jīng', 'eyeball', '眼睛', 'yǎnjing', 'eye'),
    _C('请', 'qǐng', 'please', '请问', 'qǐngwèn', 'excuse me, may I ask'),
    _C('清', 'qīng', 'clear', '清楚', 'qīngchu', 'clear'),
    _C('情', 'qíng', 'feeling', '事情', 'shìqing', 'thing, matter'),
  ], 'The right side 青 gives the sound. The left side gives the meaning: sun 日 for sunny, eye 目 for eyeball, '
      'speech 讠 for please, water 氵 for clear, heart 忄 for feelings.'),
  LookAlikeGroup('niao-wu', [
    _C('鸟', 'niǎo', 'bird', '小鸟', 'xiǎoniǎo', 'little bird'),
    _C('乌', 'wū', 'crow, black', '乌龙茶', 'wūlóng chá', 'oolong tea'),
  ], 'The crow 乌 is so black that you can\'t see its eye: it is the bird 鸟 without the dot.'),
  LookAlikeGroup('xi-xian', [
    _C('洗', 'xǐ', 'to wash', '洗手', 'xǐ shǒu', 'to wash your hands'),
    _C('先', 'xiān', 'first', '先生', 'xiānsheng', 'Mr, sir'),
  ], '洗 is 先 with water 氵 in front: you wash with water.'),
  LookAlikeGroup('er-ji', [
    _C('儿', 'ér', 'child, son', '儿子', 'érzi', 'son'),
    _C('几', 'jǐ', 'how many', '几个', 'jǐ ge', 'how many'),
  ], '几 has a lid on top, like a little table. 儿 is open at the top: two little legs.'),
  LookAlikeGroup('mao-shou', [
    _C('毛', 'máo', 'hair, fur', '毛衣', 'máoyī', 'sweater'),
    _C('手', 'shǒu', 'hand', '手机', 'shǒujī', 'mobile phone'),
  ], 'Both start with a slanting stroke. In 手 the last stroke goes straight down with a little hook. In 毛 it bends and curls away to the right, like a tail.'),
];
