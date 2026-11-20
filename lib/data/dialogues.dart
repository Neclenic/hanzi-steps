// Short everyday conversations. You listen to the other person, then pick (or say)
// your reply. All conversations are original. Words are separated by spaces, and
// every word is a course word or one of the names below (the tests check this).

/// One line of a conversation. Lines with [wrong] replies are yours to choose.
class DialogueLine {
  final String zh; // words separated by spaces
  final String pinyin;
  final String en;
  final List<(String, String)> wrong; // wrong replies (Chinese, pinyin); empty for the other person's lines
  const DialogueLine(this.zh, this.pinyin, this.en, {this.wrong = const []});

  bool get isYours => wrong.isNotEmpty;
  String get hanzi => zh.replaceAll(' ', '');
}

class Dialogue {
  final String id;
  final String title;
  final String scene; // an emoji
  final String other; // who you're talking to
  final String goal; // what you want to do, shown at the start
  final List<DialogueLine> lines;
  const Dialogue(this.id, this.title, this.scene, this.other, this.goal, this.lines);
}

/// Names used in the conversations, with their pinyin.
const dialogueNames = {'大卫': 'Dàwèi', '王方': 'Wáng Fāng'};

typedef _L = DialogueLine;

const dialogues = <Dialogue>[
  Dialogue('meet', 'Nice to meet you', '🤝', 'Wang Fang', 'You are David, a student. Introduce yourself.', [
    _L('你 好 ！ 你 叫 什么 名字 ？', 'nǐ hǎo! nǐ jiào shénme míngzi?', "Hello! What's your name?"),
    _L('我 叫 大卫 。 你 呢 ？', 'wǒ jiào Dàwèi. nǐ ne?', "I'm David. And you?",
        wrong: [('我 很 好 ， 谢谢 。', 'wǒ hěn hǎo, xièxie.'), ('再见 ！', 'zàijiàn!')]),
    _L('我 叫 王方 。 你 是 老师 吗 ？', 'wǒ jiào Wáng Fāng. nǐ shì lǎoshī ma?', "I'm Wang Fang. Are you a teacher?"),
    _L('不 是 ， 我 是 学生 。', 'bú shì, wǒ shì xuésheng.', "No, I'm a student.",
        wrong: [('是 ， 我 不 是 老师 。', 'shì, wǒ bú shì lǎoshī.'), ('我 叫 学生 。', 'wǒ jiào xuésheng.')]),
    _L('认识 你 很 高兴 ！', 'rènshi nǐ hěn gāoxìng!', 'Nice to meet you!'),
    _L('认识 你 ， 我 很 高兴 。', 'rènshi nǐ, wǒ hěn gāoxìng.', "I'm glad to meet you too.",
        wrong: [('没关系 。', 'méi guānxi.'), ('对不起 。', 'duìbuqǐ.')]),
  ]),
  Dialogue('tea', 'Ordering tea', '🍵', 'a waiter', 'You would like tea, and rice with a dish.', [
    _L('你 好 ！ 你 想 喝 什么 ？', 'nǐ hǎo! nǐ xiǎng hē shénme?', 'Hello! What would you like to drink?'),
    _L('我 想 喝 茶 。', 'wǒ xiǎng hē chá.', "I'd like some tea.",
        wrong: [('我 想 去 北京 。', 'wǒ xiǎng qù Běijīng.'), ('我 喜欢 猫 。', 'wǒ xǐhuan māo.')]),
    _L('你 想 吃 什么 ？', 'nǐ xiǎng chī shénme?', 'What would you like to eat?'),
    _L('我 想 吃 米饭 和 菜 。', 'wǒ xiǎng chī mǐfàn hé cài.', "I'd like rice and a dish.",
        wrong: [('我 在 学校 。', 'wǒ zài xuéxiào.'), ('我 是 医生 。', 'wǒ shì yīshēng.')]),
    _L('好 ， 请 坐 。', 'hǎo, qǐng zuò.', 'Okay, please take a seat.'),
    _L('谢谢 ！', 'xièxie!', 'Thank you!', wrong: [('不客气 ！', 'bú kèqi!'), ('你 好 吗 ？', 'nǐ hǎo ma?')]),
  ]),
  Dialogue('fruit', 'Buying apples', '🍎', 'a shopkeeper', 'You want to buy three apples.', [
    _L('你 好 ！ 你 想 买 什么 ？', 'nǐ hǎo! nǐ xiǎng mǎi shénme?', 'Hello! What would you like to buy?'),
    _L('我 想 买 苹果 。 多少 钱 ？', 'wǒ xiǎng mǎi píngguǒ. duōshao qián?', "I'd like some apples. How much are they?",
        wrong: [('我 想 买 衣服 。', 'wǒ xiǎng mǎi yīfu.'), ('我 没有 钱 。', 'wǒ méiyǒu qián.')]),
    _L('五 块 。 你 想 买 几 个 ？', 'wǔ kuài. nǐ xiǎng mǎi jǐ ge?', 'Five kuai each. How many would you like?'),
    _L('我 买 三 个 。', 'wǒ mǎi sān ge.', "I'll take three.",
        wrong: [('我 三 岁 。', 'wǒ sān suì.'), ('现在 三 点 。', 'xiànzài sān diǎn.')]),
    _L('十 五 块 。', 'shíwǔ kuài.', "That's fifteen kuai."),
    _L('好 的 ， 谢谢 ！', 'hǎo de, xièxie!', 'Okay, thanks!',
        wrong: [('我 叫 苹果 。', 'wǒ jiào píngguǒ.'), ('没关系 。', 'méi guānxi.')]),
  ]),
  Dialogue('time', 'What time is it?', '🕒', 'a friend', "It's three o'clock. You go to school at four, by taxi.", [
    _L('现在 几 点 ？', 'xiànzài jǐ diǎn?', 'What time is it now?'),
    _L('现在 三 点 。', 'xiànzài sān diǎn.', "It's three o'clock.",
        wrong: [('我 三 岁 。', 'wǒ sān suì.'), ('今天 星期 三 。', 'jīntiān xīngqīsān.')]),
    _L('你 几 点 去 学校 ？', 'nǐ jǐ diǎn qù xuéxiào?', 'What time are you going to school?'),
    _L('我 四 点 去 。', 'wǒ sì diǎn qù.', "I'm going at four.",
        wrong: [('我 在 学校 。', 'wǒ zài xuéxiào.'), ('学校 很 大 。', 'xuéxiào hěn dà.')]),
    _L('你 怎么 去 ？', 'nǐ zěnme qù?', 'How are you getting there?'),
    _L('我 坐 出租车 去 。', 'wǒ zuò chūzūchē qù.', "I'm going by taxi.",
        wrong: [('我 很 好 。', 'wǒ hěn hǎo.'), ('我 不 想 去 。', 'wǒ bù xiǎng qù.')]),
    _L('好 ， 再见 ！', 'hǎo, zàijiàn!', 'Okay, bye!'),
  ]),
  Dialogue('phone', 'A phone call', '📞', 'your friend', "You're at the shop buying a few things. You'll be home at five.", [
    _L('喂 ， 你 好 ！ 你 在 哪儿 ？', 'wéi, nǐ hǎo! nǐ zài nǎr?', 'Hello? Where are you?'),
    _L('我 在 商店 。', 'wǒ zài shāngdiàn.', "I'm at the shop.",
        wrong: [('我 是 学生 。', 'wǒ shì xuésheng.'), ('我 很 好 。', 'wǒ hěn hǎo.')]),
    _L('你 在 商店 做 什么 ？', 'nǐ zài shāngdiàn zuò shénme?', 'What are you doing at the shop?'),
    _L('我 买 一 些 东西 。', 'wǒ mǎi yìxiē dōngxi.', "I'm buying a few things.",
        wrong: [('我 想 睡觉 。', 'wǒ xiǎng shuìjiào.'), ('商店 很 大 。', 'shāngdiàn hěn dà.')]),
    _L('你 几 点 回 家 ？', 'nǐ jǐ diǎn huí jiā?', 'What time will you be home?'),
    _L('我 五 点 回 家 。', 'wǒ wǔ diǎn huí jiā.', "I'll be home at five.",
        wrong: [('我 有 五 个 朋友 。', 'wǒ yǒu wǔ ge péngyou.'), ('我 家 在 北京 。', 'wǒ jiā zài Běijīng.')]),
    _L('好 ， 再见 ！', 'hǎo, zàijiàn!', 'Okay, see you!'),
  ]),
  Dialogue('way', 'Asking the way', '🗺️', 'someone on the street', 'You want to walk to the train station.', [
    _L('你 好 ！ 你 去 哪儿 ？', 'nǐ hǎo! nǐ qù nǎr?', 'Hello! Where are you going?'),
    _L('我 去 火车站 。 火车站 离 这儿 远 吗 ？', 'wǒ qù huǒchēzhàn. huǒchēzhàn lí zhèr yuǎn ma?',
        "I'm going to the train station. Is it far from here?",
        wrong: [('我 是 服务员 。', 'wǒ shì fúwùyuán.'), ('我 很 忙 。', 'wǒ hěn máng.')]),
    _L('不 远 ， 很 近 。 你 往 左边 走 。', 'bù yuǎn, hěn jìn. nǐ wǎng zuǒbian zǒu.', "It's not far, it's close. Go to the left."),
    _L('走 路 要 多 长 时间 ？', 'zǒu lù yào duō cháng shíjiān?', 'How long does it take on foot?',
        wrong: [('火车站 很 漂亮 。', 'huǒchēzhàn hěn piàoliang.'), ('我 想 吃 鱼 。', 'wǒ xiǎng chī yú.')]),
    _L('十 分钟 。', 'shí fēnzhōng.', 'Ten minutes.'),
    _L('非常 谢谢 ！', 'fēicháng xièxie!', 'Thank you very much!',
        wrong: [('我 十 岁 。', 'wǒ shí suì.'), ('你 好 吗 ？', 'nǐ hǎo ma?')]),
    _L('不客气 ！', 'bú kèqi!', "You're welcome!"),
  ]),
  Dialogue('doctor', 'At the doctor', '🏥', 'a doctor', "You're ill and feel cold. You haven't taken any medicine yet.", [
    _L('你 怎么 了 ？', 'nǐ zěnme le?', "What's the matter?"),
    _L('我 生病 了 。 我 觉得 很 冷 。', 'wǒ shēngbìng le. wǒ juéde hěn lěng.', "I'm ill. I feel very cold.",
        wrong: [('我 很 高兴 。', 'wǒ hěn gāoxìng.'), ('我 想 去 旅游 。', 'wǒ xiǎng qù lǚyóu.')]),
    _L('你 吃 药 了 吗 ？', 'nǐ chī yào le ma?', 'Have you taken any medicine?'),
    _L('还 没有 。', 'hái méiyǒu.', 'Not yet.',
        wrong: [('我 吃 了 两 个 苹果 。', 'wǒ chī le liǎng ge píngguǒ.'), ('药 很 贵 。', 'yào hěn guì.')]),
    _L('吃 这 个 药 ， 每 天 三 次 。 别 喝 咖啡 ， 多 休息 。', 'chī zhège yào, měi tiān sān cì. bié hē kāfēi, duō xiūxi.',
        "Take this medicine three times a day. Don't drink coffee, and get plenty of rest."),
    _L('好 的 ， 谢谢 医生 ！', 'hǎo de, xièxie yīshēng!', 'Okay, thank you, doctor!',
        wrong: [('我 喜欢 喝 咖啡 。', 'wǒ xǐhuan hē kāfēi.'), ('我 明天 上班 。', 'wǒ míngtiān shàngbān.')]),
    _L('不客气 ！', 'bú kèqi!', "You're welcome!"),
  ]),
  Dialogue('hotel', 'At the hotel', '🏨', 'the hotel receptionist', 'You want a room for three days.', [
    _L('您 好 ， 欢迎 ！ 您 要 住 几 天 ？', 'nín hǎo, huānyíng! nín yào zhù jǐ tiān?', 'Hello, welcome! How many days will you stay?'),
    _L('我 要 住 三 天 。 有 房间 吗 ？', 'wǒ yào zhù sān tiān. yǒu fángjiān ma?', "I'd like to stay three days. Do you have a room?",
        wrong: [('我 三 岁 了 。', 'wǒ sān suì le.'), ('我 住 在 北京 。', 'wǒ zhù zài Běijīng.')]),
    _L('有 。 请 给 我 看 一下 您 的 护照 。', 'yǒu. qǐng gěi wǒ kàn yíxià nín de hùzhào.', 'We do. May I see your passport, please?'),
    _L('好 的 ， 这 是 我 的 护照 。', 'hǎo de, zhè shì wǒ de hùzhào.', 'Sure, here is my passport.',
        wrong: [('我 没有 房间 。', 'wǒ méiyǒu fángjiān.'), ('护照 很 好吃 。', 'hùzhào hěn hǎochī.')]),
    _L('您 的 房间 在 五 层 。 电梯 在 左边 。', 'nín de fángjiān zài wǔ céng. diàntī zài zuǒbian.',
        'Your room is on the fifth floor. The lift is on the left.'),
    _L('房间 里 有 空调 吗 ？', 'fángjiān li yǒu kōngtiáo ma?', 'Is there air conditioning in the room?',
        wrong: [('我 喜欢 爬山 。', 'wǒ xǐhuan pá shān.'), ('我 不 会 游泳 。', 'wǒ bú huì yóuyǒng.')]),
    _L('有 ， 还 有 冰箱 。 有 问题 就 给 我 打电话 。', 'yǒu, hái yǒu bīngxiāng. yǒu wèntí jiù gěi wǒ dǎ diànhuà.',
        "Yes, and there's a fridge too. If there's a problem, just call me."),
    _L('太 好 了 ， 谢谢 ！', 'tài hǎo le, xièxie!', 'Great, thank you!',
        wrong: [('我 不 认识 你 。', 'wǒ bú rènshi nǐ.'), ('冰箱 很 漂亮 。', 'bīngxiāng hěn piàoliang.')]),
  ]),
  Dialogue('weekend', 'Weekend plans', '⛰️', 'a friend', 'You plan to go hiking, and to a film if it rains.', [
    _L('这 个 周末 你 打算 做 什么 ？', 'zhège zhōumò nǐ dǎsuan zuò shénme?', 'What are you planning to do this weekend?'),
    _L('我 打算 去 爬山 。 你 想 跟 我 一起 去 吗 ？', 'wǒ dǎsuan qù pá shān. nǐ xiǎng gēn wǒ yìqǐ qù ma?',
        "I'm planning to go hiking. Do you want to come with me?",
        wrong: [('上 个 周末 我 很 忙 。', 'shàng ge zhōumò wǒ hěn máng.'), ('我 不 喜欢 周末 。', 'wǒ bù xǐhuan zhōumò.')]),
    _L('好 啊 ！ 如果 下雨 呢 ？', 'hǎo a! rúguǒ xià yǔ ne?', 'Sure! What if it rains?'),
    _L('如果 下雨 ， 我们 就 去 看 电影 。', 'rúguǒ xià yǔ, wǒmen jiù qù kàn diànyǐng.', "If it rains, we'll go and see a film.",
        wrong: [('我 喜欢 下雨 。', 'wǒ xǐhuan xià yǔ.'), ('昨天 下雨 了 。', 'zuótiān xià yǔ le.')]),
    _L('太 好 了 ！ 几 点 见面 ？', 'tài hǎo le! jǐ diǎn jiànmiàn?', 'Great! What time shall we meet?'),
    _L('早上 八 点 在 公园 见面 吧 。', 'zǎoshang bā diǎn zài gōngyuán jiànmiàn ba.', "Let's meet at the park at eight in the morning.",
        wrong: [('我 八 岁 。', 'wǒ bā suì.'), ('公园 很 安静 。', 'gōngyuán hěn ānjìng.')]),
    _L('好 ， 别 忘记 带 伞 ！', 'hǎo, bié wàngjì dài sǎn!', "Okay, don't forget to bring an umbrella!"),
  ]),
];
