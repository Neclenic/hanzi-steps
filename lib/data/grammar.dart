// Short grammar tips. Each one appears as a card in one lesson, after the new words,
// and all of them can be read again from the Grammar page.
// Examples are written with spaces between words; every word is taught in that
// lesson or earlier (the tests check this).

class GrammarExample {
  final String zh; // words separated by spaces
  final String pinyin;
  final String en;
  const GrammarExample(this.zh, this.pinyin, this.en);

  String get hanzi => zh.replaceAll(' ', '');
}

class GrammarTip {
  final String lessonId;
  final String title;
  final String pattern; // the shape of the sentence, e.g. "… 吗？"
  final String explain;
  final List<GrammarExample> examples;
  const GrammarTip(this.lessonId, this.title, this.pattern, this.explain, this.examples);
}

typedef _E = GrammarExample;

const grammarTips = <GrammarTip>[
  // ---------- HSK 1 ----------
  GrammarTip('greet-2', 'Yes-or-no questions with 吗', 'sentence + 吗？',
      'Put 吗 at the end of a sentence to turn it into a yes-or-no question. Nothing else changes: the word order stays the same.', [
    _E('你 好 吗 ？', 'nǐ hǎo ma?', 'How are you? (literally "You good?")'),
  ]),
  GrammarTip('ppl-1', '是 joins two nouns', 'A 是 B',
      '是 means "to be", but only to say what someone or something is: "I am a teacher". It is never used before describing words like "tall" or "good".', [
    _E('我 是 中国 人 。', 'wǒ shì Zhōngguó rén.', 'I am Chinese.'),
    _E('她 是 中国 人 吗 ？', 'tā shì Zhōngguó rén ma?', 'Is she Chinese?'),
  ]),
  GrammarTip('intro-1', 'Saying "not" with 不', '不 + verb',
      '不 goes straight before the verb or describing word to make it "not". Before a fourth tone, 不 bù is said with a second tone: 不是 bú shì.', [
    _E('我 不 是 老师 。', 'wǒ bú shì lǎoshī.', "I'm not a teacher."),
    _E('他 不 是 中国 人 。', 'tā bú shì Zhōngguó rén.', "He isn't Chinese."),
  ]),
  GrammarTip('intro-2', 'Whose? 的', 'A 的 B = A\'s B',
      '的 works like "\'s" in English: it links the owner to the thing. With close family and friends you can often leave it out: 我妈妈 "my mum".', [
    _E('我 的 名字', 'wǒ de míngzi', 'my name'),
    _E('老师 的 朋友', 'lǎoshī de péngyou', "the teacher's friend"),
    _E('你 的 名字 呢 ？', 'nǐ de míngzi ne?', 'And your name?'),
  ]),
  GrammarTip('fam-1', 'Measure words: 个', 'number + 个 + noun',
      'In Chinese you can\'t put a number straight before a noun. A small "measure word" goes in between. 个 is the most common one and works for people and many things.', [
    _E('一 个 人', 'yí ge rén', 'one person'),
    _E('我 有 三 个 朋友 。', 'wǒ yǒu sān ge péngyou.', 'I have three friends.'),
  ]),
  GrammarTip('fam-2', '"Don\'t have" is 没有', '没有 + noun',
      'To say you don\'t have something, use 没有, never 不有.', [
    _E('我 没有 儿子 。', 'wǒ méiyǒu érzi.', "I don't have a son."),
    _E('你 有 几 个 朋友 ？', 'nǐ yǒu jǐ ge péngyou?', 'How many friends do you have?'),
  ]),
  GrammarTip('food-2', 'Would like to: 想', '想 + verb',
      '想 before a verb means "would like to" or "want to". It is softer and more polite than 要.', [
    _E('我 想 去 饭馆 。', 'wǒ xiǎng qù fànguǎn.', "I'd like to go to a restaurant."),
    _E('你 想 喝 什么 ？', 'nǐ xiǎng hē shénme?', 'What would you like to drink?'),
  ]),
  GrammarTip('shop-2', 'So …! 太 … 了', '太 + describing word + 了',
      '太 … 了 means "so …!" or "too …". The 了 at the end adds feeling.', [
    _E('太 漂亮 了 ！', 'tài piàoliang le!', 'So pretty!'),
    _E('我 太 高兴 了 ！', 'wǒ tài gāoxìng le!', "I'm so happy!"),
  ]),
  GrammarTip('date-1', 'Dates go from big to small', 'year 年 + month 月 + day 号',
      'Chinese dates start with the biggest unit: the year, then the month, then the day. Months are just numbers: 一月 is January, 十二月 is December.', [
    _E('今天 十 二 月 五 号 。', 'jīntiān shí\'èr yuè wǔ hào.', 'Today is the fifth of December.'),
  ]),
  GrammarTip('time-1', 'Time comes before the verb', 'who + when + what',
      'Words for time, like 今天 or 现在, go near the start of the sentence, before the verb. They never go at the end as in English.', [
    _E('我 明天 去 饭馆 。', 'wǒ míngtiān qù fànguǎn.', "I'm going to a restaurant tomorrow."),
    _E('现在 几 点 ？', 'xiànzài jǐ diǎn?', 'What time is it now?'),
  ]),
  GrammarTip('place-1', 'Where: 在 + place', 'someone 在 + place',
      '在 means "to be at". The place comes right after it. To say where you do something, put 在 + place before the verb.', [
    _E('我 在 学校 。', 'wǒ zài xuéxiào.', "I'm at school."),
    _E('你 住 在 哪儿 ？', 'nǐ zhù zài nǎr?', 'Where do you live?'),
  ]),
  GrammarTip('place-2', 'On, under, inside come after the thing', 'thing + 上 / 下 / 里',
      'English says "on the table". Chinese says "table on": the thing comes first, then 上 (on), 下 (under) or 里 (inside).', [
    _E('杯子 在 桌子 上 。', 'bēizi zài zhuōzi shang.', 'The cup is on the table.'),
    _E('苹果 在 椅子 下 。', 'píngguǒ zài yǐzi xia.', 'The apple is under the chair.'),
  ]),
  GrammarTip('go-1', 'Going by …: 坐', '坐 + vehicle + 去 + place',
      'To say how you travel, put 坐 + the vehicle before the verb of going.', [
    _E('我 坐 飞机 去 北京 。', 'wǒ zuò fēijī qù Běijīng.', "I'm flying to Beijing."),
    _E('他 坐 出租车 回 家 。', 'tā zuò chūzūchē huí jiā.', 'He takes a taxi home.'),
  ]),
  GrammarTip('work-2', '会 or 能?', '会 / 能 + verb',
      '会 is for skills you have learned, like speaking a language. 能 is for being able to, or being allowed to, at a certain moment.', [
    _E('我 会 说 汉语 。', 'wǒ huì shuō Hànyǔ.', 'I can speak Chinese.'),
    _E('我 现在 不 能 看 书 。', 'wǒ xiànzài bù néng kàn shū.', "I can't read right now."),
  ]),
  GrammarTip('wx-1', 'How is it? 怎么样', '… 怎么样？',
      'Put 怎么样 at the end to ask how something is, or to make a suggestion: "How about …?"', [
    _E('今天 天气 怎么样 ？', 'jīntiān tiānqì zěnmeyàng?', "What's the weather like today?"),
  ]),
  GrammarTip('like-1', '都 goes before the verb', 'people + 都 + verb',
      '都 means "all" or "both". It always goes after the people or things it is about, right before the verb.', [
    _E('我们 都 喜欢 狗 。', 'wǒmen dōu xǐhuan gǒu.', 'We all like dogs.'),
  ]),

  // ---------- HSK 2 ----------
  GrammarTip('h2-food-1', "Let's …: 吧", 'suggestion + 吧',
      '吧 at the end of a sentence makes it a friendly suggestion ("let\'s …") or a soft guess ("…, right?").', [
    _E('我们 喝 咖啡 吧 。', 'wǒmen hē kāfēi ba.', "Let's have a coffee."),
    _E('你 是 老师 吧 ？', 'nǐ shì lǎoshī ba?', "You're a teacher, right?"),
  ]),
  GrammarTip('h2-num-1', 'First, second: 第', '第 + number',
      'Put 第 before a number to make "first", "second" and so on. 次 counts how many times something happens.', [
    _E('这 是 我 第一 次 吃 鸡蛋 面条 。', 'zhè shì wǒ dì-yī cì chī jīdàn miàntiáo.', 'This is my first time eating egg noodles.'),
  ]),
  GrammarTip('h2-num-2', 'Comparing with 比', 'A 比 B + describing word',
      'To say A is more … than B, use A 比 B and then the describing word. Don\'t add 很.', [
    _E('西瓜 比 苹果 贵 。', 'xīguā bǐ píngguǒ guì.', 'Watermelon is more expensive than apples.'),
    _E('他 比 我 高 。', 'tā bǐ wǒ gāo.', 'He is taller than me.'),
  ]),
  GrammarTip('h2-day-2', 'Already and right now: 已经 … 了, 正在', '已经 + verb + 了 / 正在 + verb',
      '已经 … 了 says something has already happened. 正在 says it is happening right now.', [
    _E('我 已经 起床 了 。', 'wǒ yǐjīng qǐchuáng le.', "I'm already up."),
    _E('妈妈 正在 休息 。', 'māma zhèngzài xiūxi.', 'Mum is resting right now.'),
  ]),
  GrammarTip('h2-day-3', 'Just a moment: 一下', 'verb + 一下',
      'Adding 一下 after a verb makes it short and casual, like "have a quick …". It makes requests sound softer.', [
    _E('请 等 一下 。', 'qǐng děng yíxià.', 'Please wait a moment.'),
    _E('我 看 一下 。', 'wǒ kàn yíxià.', 'Let me have a look.'),
  ]),
  GrammarTip('h2-way-2', 'Distance: 离; from … to: 从 … 到', 'A 离 B + 远 / 近',
      'A 离 B 很近 means "A is close to B". 从 … 到 … means "from … to …".', [
    _E('学校 离 我 家 很 近 。', 'xuéxiào lí wǒ jiā hěn jìn.', 'The school is close to my home.'),
    _E('从 北京 到 这儿 很 远 。', 'cóng Běijīng dào zhèr hěn yuǎn.', "It's a long way from Beijing to here."),
  ]),
  GrammarTip('h2-col-2', 'The most: 最', '最 + describing word',
      '最 before a describing word means "the most …".', [
    _E('她 的 眼睛 最 漂亮 。', 'tā de yǎnjing zuì piàoliang.', 'Her eyes are the prettiest.'),
  ]),
  GrammarTip('h2-talk-2', 'Because … so …; although … but …', '因为 … 所以 … / 虽然 … 但是 …',
      'Chinese likes to use both halves of these pairs, where English uses only one word.', [
    _E('因为 下雨 ， 所以 我 不 去 。', 'yīnwèi xià yǔ, suǒyǐ wǒ bú qù.', "Because it's raining, I'm not going."),
    _E('虽然 很 累 ， 但是 我 很 快乐 。', 'suīrán hěn lèi, dànshì wǒ hěn kuàilè.', "Although I'm tired, I'm happy."),
  ]),
  GrammarTip('h2-talk-4', 'How well: 得; ever done: 过', 'verb + 得 + how / verb + 过',
      'After a verb, 得 introduces how well it is done. 过 after a verb means you have done it at some time before.', [
    _E('她 说 得 很 好 。', 'tā shuō de hěn hǎo.', 'She speaks very well.'),
    _E('我 去 过 北京 。', 'wǒ qù guo Běijīng.', "I've been to Beijing."),
  ]),

  // ---------- HSK 3 ----------
  GrammarTip('h3-feel-3', 'Should and must: 应该, 必须', '应该 / 必须 + verb',
      '应该 is "should", a piece of advice. 必须 is "must", with no choice.', [
    _E('你 应该 多 休息 。', 'nǐ yīnggāi duō xiūxi.', 'You should rest more.'),
    _E('我们 必须 走 了 。', 'wǒmen bìxū zǒu le.', 'We must go now.'),
  ]),
  GrammarTip('h3-shop-2', 'More measure words', '一 双 鞋 · 一 条 裤子 · 一 张 票',
      'Many nouns have their own measure word. 双 is for pairs, 条 for long thin things, 张 for flat things like tickets and photos.', [
    _E('一 双 鞋', 'yì shuāng xié', 'a pair of shoes'),
    _E('一 条 裤子', 'yì tiáo kùzi', 'a pair of trousers'),
    _E('两 张 票', 'liǎng zhāng piào', 'two tickets'),
  ]),
  GrammarTip('h3-time-1', 'First … then …: 先 … 然后 …', '先 + A， 然后 + B',
      'Use 先 for the first thing and 然后 for what comes next.', [
    _E('我 先 洗澡 ， 然后 睡觉 。', 'wǒ xiān xǐzǎo, ránhòu shuìjiào.', "I'll shower first, then go to bed."),
  ]),
  GrammarTip('h3-time-3', 'Again: 又 or 再?', '又 (already happened) / 再 (will happen)',
      '又 is "again" for something that already happened. 再 is "again" for the future.', [
    _E('他 又 来 了 。', 'tā yòu lái le.', "He's come again."),
    _E('明天 再 来 吧 。', 'míngtiān zài lái ba.', 'Come again tomorrow.'),
  ]),
  GrammarTip('h3-desc-2', 'More and more: 越来越', '越来越 + describing word',
      '越来越 means "more and more". 越 A 越 B means "the more A, the more B".', [
    _E('天气 越 来 越 冷 了 。', 'tiānqì yuè lái yuè lěng le.', "It's getting colder and colder."),
  ]),
  GrammarTip('h3-link-1', 'If … then …: 如果 … 就 …; or: 还是', '如果 A， 就 B',
      '如果 … 就 … makes "if … then …". In questions, "or" is 还是; in statements it is 或者.', [
    _E('如果 明天 下雨 ， 我们 就 不 去 公园 。', 'rúguǒ míngtiān xià yǔ, wǒmen jiù bú qù gōngyuán.', "If it rains tomorrow, we won't go to the park."),
    _E('你 喝 茶 还是 咖啡 ？', 'nǐ hē chá háishi kāfēi?', 'Do you drink tea or coffee?'),
  ]),
  GrammarTip('h3-link-2', 'In order to: 为了', '为了 + goal， …',
      '为了 at the start of a sentence gives the reason or goal: "in order to …".', [
    _E('为了 健康 ， 他 每 天 锻炼 。', 'wèile jiànkāng, tā měi tiān duànliàn.', 'To stay healthy, he exercises every day.'),
  ]),
  GrammarTip('h3-link-3', 'Doing something to it: 把 and 被', 'A 把 thing + verb / thing 被 A + verb',
      '把 brings the thing forward, before the verb: "I took the book and put it …". 被 is like "was … by": the thing comes first and the doer after 被.', [
    _E('我 把 作业 做 完 了 。', 'wǒ bǎ zuòyè zuò wán le.', "I've finished my homework."),
    _E('我 的 自行车 被 他 骑 走 了 。', 'wǒ de zìxíngchē bèi tā qí zǒu le.', 'My bike was ridden off by him.'),
  ]),
  // ---------- HSK 4 ----------
  GrammarTip('h4-link-1', 'Not only … but also: 不仅 … 而且 …', '不仅 A， 而且 B',
      '不仅 … 而且 … (or 不但 … 而且 …) adds a second, stronger point: "not only A, but also B". 并且 can join two actions in the same way.', [
    _E('他 不仅 会 唱歌 ， 而且 会 跳舞 。', 'tā bùjǐn huì chànggē, érqiě huì tiàowǔ.', 'He can not only sing but also dance.'),
    _E('这 个 菜 不仅 便宜 ， 而且 很 好吃 。', 'zhège cài bùjǐn piányi, érqiě hěn hǎochī.', 'This dish is not only cheap but also tasty.'),
  ]),
  GrammarTip('h4-link-2', 'Whatever happens: 不管 … 都 …; as long as: 只要 … 就 …', '不管 A， 都 B / 只要 A， 就 B',
      '不管 and 无论 ("no matter") are followed by a question word or two choices, and 都 comes in the second half. 只要 … 就 … means "as long as A, then B".', [
    _E('不管 多 忙 ， 他 都 每 天 锻炼 。', 'bùguǎn duō máng, tā dōu měi tiān duànliàn.', 'However busy he is, he exercises every day.'),
    _E('只要 你 喜欢 ， 就 买 吧 。', 'zhǐyào nǐ xǐhuan, jiù mǎi ba.', 'As long as you like it, buy it.'),
  ]),
  GrammarTip('h4-link-3', 'Because of … so: 由于 … 因此 …; but: 却', '由于 A， 因此 B / subject + 却 + verb',
      '由于 … 因此 … is a more formal "because … so …". 却 means "but, yet". It goes after the subject and before the verb, never at the start of a sentence.', [
    _E('由于 天气 不 好 ， 因此 我们 没有 去 爬山 。', 'yóuyú tiānqì bù hǎo, yīncǐ wǒmen méiyǒu qù páshān.', "Because the weather was bad, we didn't go hiking."),
    _E('他 很 有 钱 ， 却 不 快乐 。', 'tā hěn yǒu qián, què bú kuàilè.', "He's rich, but he isn't happy."),
  ]),
  GrammarTip('h4-time-3', 'Never ever: 从来 不 / 从来 没有 … 过', '从来 + 不 / 没有 + verb (+ 过)',
      '从来 makes "not" stronger. 从来不 is "never" as a habit; 从来没有 … 过 is "have never (once)".', [
    _E('他 从来 不 喝 咖啡 。', 'tā cónglái bù hē kāfēi.', 'He never drinks coffee.'),
    _E('我 从来 没有 看见 过 熊猫 。', 'wǒ cónglái méiyǒu kànjiànguo xióngmāo.', 'I have never seen a panda.'),
  ]),
  GrammarTip('h4-time-4', 'To my surprise: 竟然; sure enough: 果然', 'subject + 竟然 / 果然 + verb',
      '竟然 shows surprise: "(to my surprise) he actually …". 果然 shows it happened just as you thought: "sure enough, …".', [
    _E('他 竟然 忘记 了 我 的 生日 。', 'tā jìngrán wàngjì le wǒ de shēngrì.', 'He actually forgot my birthday!'),
    _E('我 说 他 会 迟到 ， 他 果然 迟到 了 。', 'wǒ shuō tā huì chídào, tā guǒrán chídào le.', 'I said he would be late, and sure enough he was.'),
  ]),
  GrammarTip('h4-think-2', 'What on earth? 到底; surely not? 难道 … 吗', '到底 + question / 难道 … 吗？',
      '到底 in a question shows you really want to know: "what on earth …?". 难道 … 吗？ asks a question whose answer is obvious, a bit like "Don\'t tell me …?"', [
    _E('你 到底 去 不 去 ？', 'nǐ dàodǐ qù bu qù?', 'Are you going or not?'),
    _E('难道 你 不 认识 我 了 吗 ？', 'nándào nǐ bú rènshi wǒ le ma?', "Don't you recognise me?"),
  ]),
  GrammarTip('h4-life-4', 'Any at all: 任何 … 都 …', '任何 + noun + 都 …',
      '任何 means "any (at all)". 都 or 也 comes later in the sentence, before the verb.', [
    _E('任何 人 都 可以 参加 。', 'rènhé rén dōu kěyǐ cānjiā.', 'Anyone can take part.'),
  ]),
  GrammarTip('h4-ppl-2', 'Becoming: 成为', '成为 + noun',
      '成为 means "to become" and is followed by a noun: a doctor, good friends. For describing words, Chinese uses 变得 instead ("to turn cold" is 变得很冷).', [
    _E('我们 成为 了 好 朋友 。', 'wǒmen chéngwéi le hǎo péngyou.', 'We became good friends.'),
  ]),
  GrammarTip('h4-say-1', 'Even: 连 … 都 / 也 …', '连 A 都 / 也 + verb',
      '连 … 都 … means "even". It points at the most surprising case, and the verb comes after 都 or 也.', [
    _E('连 孩子 都 会 做 这 个 题 。', 'lián háizi dōu huì zuò zhège tí.', 'Even a child could do this question.'),
    _E('我 连 一 分钟 都 没有 休息 。', 'wǒ lián yì fēnzhōng dōu méiyǒu xiūxi.', "I didn't rest for even a minute."),
  ]),
  GrammarTip('h4-say-2', 'No other way: 只好 and 不得不', '只好 / 不得不 + verb',
      'Both say you had to do something because there was no other choice. 只好 sounds resigned ("so I just …"); 不得不 is stronger ("had no choice but to").', [
    _E('没有 出租车 ， 我们 只好 走 回 家 。', 'méiyǒu chūzūchē, wǒmen zhǐhǎo zǒu huí jiā.', 'There were no taxis, so we had to walk home.'),
    _E('我 生病 了 ， 不得不 请假 。', 'wǒ shēngbìng le, bùdébù qǐngjià.', 'I was ill, so I had no choice but to take time off.'),
  ]),
];

/// The grammar tip shown in a lesson, if there is one.
GrammarTip? grammarFor(String lessonId) {
  for (final t in grammarTips) {
    if (t.lessonId == lessonId) return t;
  }
  return null;
}
