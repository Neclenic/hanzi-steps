// HSK 2: the words of the classic HSK 2.0 level 2 list, in themed units.
// Every example sentence is original and only uses words taught before it
// (HSK 1 words included). The tests check this.

import 'course.dart';

const _v = LessonKind.vocab;

const hsk2Units = <Unit>[
  Unit('Family and people', 'Brothers, sisters, husbands and wives', 0xFF607D8B, tag: 'HSK 2 · Unit 1', level: 2, [
    Lesson(id: 'h2-fam-1', title: 'Brothers and sisters', subtitle: '哥哥 · 姐姐 · 弟弟 · 妹妹', kind: _v, words: [
      W('哥哥', 'gēge', 'older brother'),
      W('姐姐', 'jiějie', 'older sister'),
      W('弟弟', 'dìdi', 'younger brother'),
      W('妹妹', 'mèimei', 'younger sister'),
      W('大家', 'dàjiā', 'everyone'),
      W('您', 'nín', 'you (polite)', note: 'Use 您 instead of 你 with older people and people you respect.'),
    ], sentences: [
      S(['我', '有', '一', '个', '妹妹'], 'wǒ yǒu yí ge mèimei', 'I have a younger sister.'),
      S(['我', '没有', '哥哥'], 'wǒ méiyǒu gēge', "I don't have an older brother."),
      S(['大家', '好'], 'dàjiā hǎo', 'Hello, everyone!'),
      S(['您', '好'], 'nín hǎo', 'Hello! (polite)'),
    ]),
    Lesson(id: 'h2-fam-2', title: 'Husband and wife', subtitle: '丈夫 · 妻子 · 孩子', kind: _v, words: [
      W('丈夫', 'zhàngfu', 'husband'),
      W('妻子', 'qīzi', 'wife'),
      W('孩子', 'háizi', 'child'),
      W('男', 'nán', 'male / man'),
      W('女', 'nǚ', 'female / woman'),
      W('姓', 'xìng', 'surname / to be surnamed', note: '我姓王 = My surname is Wang.'),
      W('它', 'tā', 'it (for animals and things)', note: 'Sounds the same as 他 and 她.'),
    ], sentences: [
      S(['她', '的', '丈夫', '是', '老师'], 'tā de zhàngfu shì lǎoshī', 'Her husband is a teacher.'),
      S(['您', '姓', '什么'], 'nín xìng shénme', 'What is your surname?'),
      S(['我', '家', '有', '三', '个', '孩子'], 'wǒ jiā yǒu sān ge háizi', 'There are three children in my family.'),
    ]),
  ]),
  Unit('Colours and looks', 'Describe people and things', 0xFFB5179E, tag: 'HSK 2 · Unit 2', level: 2, [
    Lesson(id: 'h2-col-1', title: 'Colours', subtitle: '红色 · 白色 · 黑色', kind: _v, words: [
      W('颜色', 'yánsè', 'colour'),
      W('红色', 'hóngsè', 'red', note: 'The HSK list has 红 (red); people usually say 红色, "red colour".'),
      W('白色', 'báisè', 'white', note: 'The HSK list has 白; 白色 is "white colour".'),
      W('黑色', 'hēisè', 'black', note: 'The HSK list has 黑; 黑色 is "black colour".'),
      W('新', 'xīn', 'new'),
      W('长', 'cháng', 'long'),
    ], sentences: [
      S(['我', '喜欢', '红色'], 'wǒ xǐhuan hóngsè', 'I like red.'),
      S(['你', '喜欢', '什么', '颜色'], 'nǐ xǐhuan shénme yánsè', 'What colour do you like?'),
      S(['这', '是', '我', '的', '新', '衣服'], 'zhè shì wǒ de xīn yīfu', 'These are my new clothes.'),
    ]),
    Lesson(id: 'h2-col-2', title: 'Tall and pretty', subtitle: '高 · 真 · 非常', kind: _v, words: [
      W('高', 'gāo', 'tall / high'),
      W('真', 'zhēn', 'really / truly'),
      W('非常', 'fēicháng', 'extremely'),
      W('最', 'zuì', 'most / -est', note: '最好 = best, 最大 = biggest.'),
      W('眼睛', 'yǎnjing', 'eye'),
      W('笑', 'xiào', 'to smile / to laugh'),
    ], sentences: [
      S(['他', '非常', '高'], 'tā fēicháng gāo', 'He is extremely tall.'),
      S(['你', '的', '猫', '真', '漂亮'], 'nǐ de māo zhēn piàoliang', 'Your cat is really pretty.'),
      S(['她', '的', '眼睛', '很', '大'], 'tā de yǎnjing hěn dà', 'Her eyes are big.'),
    ]),
  ]),
  Unit('Café and restaurant', 'Order food and drinks', 0xFF795548, tag: 'HSK 2 · Unit 3', level: 2, [
    Lesson(id: 'h2-food-1', title: 'At the café', subtitle: '咖啡 · 牛奶 · 好吃', kind: _v, words: [
      W('咖啡', 'kāfēi', 'coffee'),
      W('牛奶', 'niúnǎi', 'milk'),
      W('好吃', 'hǎochī', 'tasty'),
      W('鸡蛋', 'jīdàn', 'egg'),
      W('面条', 'miàntiáo', 'noodles'),
      W('吧', 'ba', '(makes a suggestion: "let\'s…")', note: '我们去吧！= Let\'s go!'),
    ], sentences: [
      S(['我', '不', '喝', '咖啡'], 'wǒ bù hē kāfēi', "I don't drink coffee."),
      S(['米饭', '很', '好吃'], 'mǐfàn hěn hǎochī', 'The rice is very tasty.'),
      S(['我们', '吃', '面条', '吧'], 'wǒmen chī miàntiáo ba', "Let's eat noodles."),
    ]),
    Lesson(id: 'h2-food-2', title: 'Ordering food', subtitle: '要 · 鱼 · 服务员', kind: _v, words: [
      W('要', 'yào', 'to want (to have) / will'),
      W('两', 'liǎng', 'two (of something)', note: 'Use 两 before a counting word: 两个人 = two people. Use 二 when counting: 一、二、三.'),
      W('鱼', 'yú', 'fish'),
      W('羊肉', 'yángròu', 'lamb (meat)'),
      W('西瓜', 'xīguā', 'watermelon'),
      W('服务员', 'fúwùyuán', 'waiter / waitress'),
    ], sentences: [
      S(['服务员', '我', '要', '茶'], 'fúwùyuán, wǒ yào chá', "Waiter, I'd like tea."),
      S(['我', '要', '两', '个', '鸡蛋'], 'wǒ yào liǎng ge jīdàn', 'I want two eggs.'),
      S(['我', '不', '吃', '羊肉'], 'wǒ bù chī yángròu', "I don't eat lamb."),
    ]),
  ]),
  Unit('Numbers and prices', 'Big numbers, cheap and expensive', 0xFF3BB273, tag: 'HSK 2 · Unit 4', level: 2, [
    Lesson(id: 'h2-num-1', title: 'Big numbers', subtitle: '零 · 百 · 千', kind: _v, words: [
      W('零', 'líng', 'zero'),
      W('百', 'bǎi', 'hundred'),
      W('千', 'qiān', 'thousand'),
      W('第一', 'dì-yī', 'first', note: '第 + a number makes an order: 第二 = second, 第三 = third.'),
      W('次', 'cì', 'time (how often)', note: '一次 = once, 两次 = twice.'),
      W('件', 'jiàn', '(counting word for clothes and matters)'),
    ], sentences: [
      S(['一', '百', '块'], 'yìbǎi kuài', 'One hundred yuan.'),
      S(['我', '去', '了', '两', '次'], 'wǒ qù le liǎng cì', 'I went twice.'),
      S(['这', '件', '衣服', '很', '漂亮'], 'zhè jiàn yīfu hěn piàoliang', 'This piece of clothing is very pretty.'),
    ]),
    Lesson(id: 'h2-num-2', title: 'Cheap or expensive?', subtitle: '贵 · 便宜 · 卖', kind: _v, words: [
      W('贵', 'guì', 'expensive'),
      W('便宜', 'piányi', 'cheap'),
      W('卖', 'mài', 'to sell', note: 'Careful: 买 mǎi (third tone) is "to buy", 卖 mài (fourth tone) is "to sell".'),
      W('票', 'piào', 'ticket'),
      W('比', 'bǐ', 'than (to compare)', note: 'A 比 B 贵 = A is more expensive than B.'),
      W('穿', 'chuān', 'to wear'),
    ], sentences: [
      S(['这', '个', '太', '贵', '了'], 'zhège tài guì le', 'This one is too expensive.'),
      S(['苹果', '比', '西瓜', '便宜'], 'píngguǒ bǐ xīguā piányi', 'Apples are cheaper than watermelons.'),
      S(['商店', '卖', '水果', '吗'], 'shāngdiàn mài shuǐguǒ ma', 'Does the shop sell fruit?'),
    ]),
  ]),
  Unit('My day', 'Getting up, working and resting', 0xFF5C6BC0, tag: 'HSK 2 · Unit 5', level: 2, [
    Lesson(id: 'h2-day-1', title: 'Morning and evening', subtitle: '早上 · 起床 · 晚上', kind: _v, words: [
      W('早上', 'zǎoshang', 'early morning'),
      W('早上好', 'zǎoshang hǎo', 'good morning', hsk: false),
      W('起床', 'qǐchuáng', 'to get up'),
      W('洗', 'xǐ', 'to wash'),
      W('上班', 'shàngbān', 'to go to work'),
      W('晚上', 'wǎnshang', 'evening'),
      W('小时', 'xiǎoshí', 'hour'),
    ], sentences: [
      S(['我', '早上', '七', '点', '起床'], 'wǒ zǎoshang qī diǎn qǐchuáng', 'I get up at seven in the morning.'),
      S(['他', '晚上', '不', '上班'], 'tā wǎnshang bú shàngbān', "He doesn't work in the evening."),
      S(['我', '工作', '八', '个', '小时'], 'wǒ gōngzuò bā ge xiǎoshí', 'I work for eight hours.'),
    ]),
    Lesson(id: 'h2-day-2', title: 'Busy and tired', subtitle: '忙 · 累 · 休息', kind: _v, words: [
      W('忙', 'máng', 'busy'),
      W('累', 'lèi', 'tired'),
      W('休息', 'xiūxi', 'to rest'),
      W('时间', 'shíjiān', 'time (an amount of it)'),
      W('已经', 'yǐjīng', 'already'),
      W('正在', 'zhèngzài', 'in the middle of (doing)'),
    ], sentences: [
      S(['你', '忙', '吗'], 'nǐ máng ma', 'Are you busy?'),
      S(['我', '很', '累', '想', '休息'], 'wǒ hěn lèi, xiǎng xiūxi', "I'm tired and want to rest."),
      S(['我', '没有', '时间'], 'wǒ méiyǒu shíjiān', "I don't have time."),
      S(['他', '正在', '睡觉'], 'tā zhèngzài shuìjiào', 'He is sleeping right now.'),
    ]),
    Lesson(id: 'h2-day-3', title: 'Plans', subtitle: '准备 · 开始 · 一起', kind: _v, words: [
      W('准备', 'zhǔnbèi', 'to prepare / to plan to'),
      W('开始', 'kāishǐ', 'to start'),
      W('等', 'děng', 'to wait'),
      W('一起', 'yìqǐ', 'together'),
      W('一下', 'yíxià', '(do something) for a moment', note: '等一下 = wait a moment.'),
      W('每', 'měi', 'every'),
      W('天', 'tiān', 'day / sky', note: '每天 = every day.', hsk: false),
    ], sentences: [
      S(['我们', '一起', '去', '吧'], 'wǒmen yìqǐ qù ba', "Let's go together."),
      S(['请', '等', '一下'], 'qǐng děng yíxià', 'Please wait a moment.'),
      S(['电影', '几', '点', '开始'], 'diànyǐng jǐ diǎn kāishǐ', 'What time does the film start?'),
    ]),
  ]),
  Unit('Sport and fun', 'Hobbies, birthdays and holidays', 0xFFE09F3E, tag: 'HSK 2 · Unit 6', level: 2, [
    Lesson(id: 'h2-fun-1', title: 'Sports', subtitle: '运动 · 跑步 · 游泳', kind: _v, words: [
      W('运动', 'yùndòng', 'sport / to exercise'),
      W('跑步', 'pǎobù', 'to run / to jog'),
      W('游泳', 'yóuyǒng', 'to swim'),
      W('打篮球', 'dǎ lánqiú', 'to play basketball'),
      W('踢足球', 'tī zúqiú', 'to play football (soccer)'),
      W('身体', 'shēntǐ', 'body / health'),
    ], sentences: [
      S(['我', '喜欢', '游泳'], 'wǒ xǐhuan yóuyǒng', 'I like swimming.'),
      S(['他', '每', '天', '早上', '跑步'], 'tā měi tiān zǎoshang pǎobù', 'He runs every morning.'),
      S(['你', '身体', '好', '吗'], 'nǐ shēntǐ hǎo ma', 'How is your health?'),
    ]),
    Lesson(id: 'h2-fun-2', title: 'Having fun', subtitle: '玩 · 唱歌 · 生日', kind: _v, words: [
      W('玩', 'wán', 'to play / to have fun'),
      W('唱歌', 'chànggē', 'to sing'),
      W('跳舞', 'tiàowǔ', 'to dance'),
      W('旅游', 'lǚyóu', 'to travel (for fun)'),
      W('生日', 'shēngrì', 'birthday'),
      W('快乐', 'kuàilè', 'happy (joyful)'),
    ], sentences: [
      S(['生日', '快乐'], 'shēngrì kuàilè', 'Happy birthday!'),
      S(['我们', '去', '唱歌', '吧'], 'wǒmen qù chànggē ba', "Let's go and sing."),
      S(['我', '想', '去', '中国', '旅游'], 'wǒ xiǎng qù Zhōngguó lǚyóu', 'I would like to travel to China.'),
    ]),
  ]),
  Unit('Finding the way', 'Left, right, near and far', 0xFF6D4C41, tag: 'HSK 2 · Unit 7', level: 2, [
    Lesson(id: 'h2-way-1', title: 'Left and right', subtitle: '左边 · 右边 · 旁边', kind: _v, words: [
      W('左边', 'zuǒbian', 'left side'),
      W('右边', 'yòubian', 'right side'),
      W('旁边', 'pángbiān', 'next to'),
      W('外', 'wài', 'outside'),
      W('往', 'wǎng', 'towards', note: '往左 = to the left, 往前 = straight ahead.'),
      W('走', 'zǒu', 'to walk / to leave'),
      W('这儿', 'zhèr', 'here', hsk: false),
      W('那儿', 'nàr', 'there', hsk: false),
    ], sentences: [
      S(['商店', '在', '学校', '旁边'], 'shāngdiàn zài xuéxiào pángbiān', 'The shop is next to the school.'),
      S(['往', '右边', '走'], 'wǎng yòubian zǒu', 'Go to the right.'),
      S(['他', '走', '了'], 'tā zǒu le', 'He has left.'),
    ]),
    Lesson(id: 'h2-way-2', title: 'Near and far', subtitle: '离 · 远 · 近', kind: _v, words: [
      W('离', 'lí', 'away from (distance)', note: 'A 离 B 很远 = A is far from B.'),
      W('远', 'yuǎn', 'far'),
      W('近', 'jìn', 'near'),
      W('路', 'lù', 'road'),
      W('从', 'cóng', 'from'),
      W('到', 'dào', 'to arrive / until'),
    ], sentences: [
      S(['医院', '离', '这儿', '远', '吗'], 'yīyuàn lí zhèr yuǎn ma', 'Is the hospital far from here?'),
      S(['我', '家', '离', '学校', '很', '近'], 'wǒ jiā lí xuéxiào hěn jìn', 'My home is close to the school.'),
      S(['我', '从', '北京', '来'], 'wǒ cóng Běijīng lái', 'I come from Beijing.'),
    ]),
    Lesson(id: 'h2-way-3', title: 'Bus and train', subtitle: '公共汽车 · 机场 · 火车站', kind: _v, words: [
      W('公共汽车', 'gōnggòng qìchē', 'bus'),
      W('机场', 'jīchǎng', 'airport'),
      W('火车站', 'huǒchēzhàn', 'train station'),
      W('宾馆', 'bīnguǎn', 'hotel'),
      W('快', 'kuài', 'fast'),
      W('慢', 'màn', 'slow'),
    ], sentences: [
      S(['我', '坐', '公共汽车', '去', '机场'], 'wǒ zuò gōnggòng qìchē qù jīchǎng', 'I take the bus to the airport.'),
      S(['火车站', '在', '哪儿'], 'huǒchēzhàn zài nǎr', 'Where is the train station?'),
      S(['请', '说', '慢', '一点儿'], 'qǐng shuō màn yìdiǎnr', 'Please speak a bit more slowly.'),
    ]),
  ]),
  Unit('Home and school', 'Rooms, classes and tests', 0xFF00838F, tag: 'HSK 2 · Unit 8', level: 2, [
    Lesson(id: 'h2-home-1', title: 'Rooms and doors', subtitle: '门 · 房间 · 进', kind: _v, words: [
      W('门', 'mén', 'door'),
      W('房间', 'fángjiān', 'room'),
      W('进', 'jìn', 'to enter / to come in', note: 'Sounds just like 近 (near). 请进！= Come in, please!'),
      W('出', 'chū', 'to go out / to come out'),
      W('找', 'zhǎo', 'to look for'),
      W('手机', 'shǒujī', 'mobile phone'),
    ], sentences: [
      S(['请', '进'], 'qǐng jìn', 'Come in, please.'),
      S(['我', '找', '我', '的', '手机'], 'wǒ zhǎo wǒ de shǒujī', "I'm looking for my phone."),
      S(['你', '的', '房间', '很', '大'], 'nǐ de fángjiān hěn dà', 'Your room is big.'),
    ]),
    Lesson(id: 'h2-home-2', title: 'In class', subtitle: '教室 · 课 · 考试', kind: _v, words: [
      W('教室', 'jiàoshì', 'classroom'),
      W('课', 'kè', 'class / lesson'),
      W('考试', 'kǎoshì', 'exam / to take an exam'),
      W('题', 'tí', 'question (on a test)'),
      W('问', 'wèn', 'to ask'),
      W('问题', 'wèntí', 'question / problem'),
    ], sentences: [
      S(['明天', '有', '考试'], 'míngtiān yǒu kǎoshì', 'There is an exam tomorrow.'),
      S(['我', '能', '问', '一', '个', '问题', '吗'], 'wǒ néng wèn yí ge wèntí ma', 'Can I ask a question?'),
      S(['老师', '在', '教室', '里'], 'lǎoshī zài jiàoshì lǐ', 'The teacher is in the classroom.'),
    ]),
    Lesson(id: 'h2-home-3', title: 'Right or wrong?', subtitle: '懂 · 对 · 错', kind: _v, words: [
      W('懂', 'dǒng', 'to understand'),
      W('意思', 'yìsi', 'meaning'),
      W('对', 'duì', 'right / correct', note: '对 can also mean "towards" or "to": 对我很好 = good to me.'),
      W('错', 'cuò', 'wrong'),
      W('告诉', 'gàosu', 'to tell'),
      W('铅笔', 'qiānbǐ', 'pencil'),
      W('报纸', 'bàozhǐ', 'newspaper'),
    ], sentences: [
      S(['你', '懂', '吗'], 'nǐ dǒng ma', 'Do you understand?'),
      S(['这', '个', '字', '是', '什么', '意思'], 'zhège zì shì shénme yìsi', 'What does this character mean?'),
      S(['你', '是', '对', '的'], 'nǐ shì duì de', "You're right."),
      S(['请', '告诉', '我'], 'qǐng gàosu wǒ', 'Please tell me.'),
    ]),
  ]),
  Unit('Health and weather', 'Feeling ill, sun and snow', 0xFFF57C00, tag: 'HSK 2 · Unit 9', level: 2, [
    Lesson(id: 'h2-wx-1', title: 'Feeling ill', subtitle: '生病 · 药 · 觉得', kind: _v, words: [
      W('生病', 'shēngbìng', 'to get ill'),
      W('药', 'yào', 'medicine', note: 'Sounds the same as 要 (to want).'),
      W('觉得', 'juéde', 'to feel / to think (an opinion)'),
      W('可能', 'kěnéng', 'maybe / possible'),
      W('希望', 'xīwàng', 'to hope'),
      W('别', 'bié', "don't (do)"),
    ], sentences: [
      S(['我', '妈妈', '生病', '了'], 'wǒ māma shēngbìng le', 'My mum is ill.'),
      S(['别', '说', '了'], 'bié shuō le', 'Stop talking.'),
      S(['我', '觉得', '很', '冷'], 'wǒ juéde hěn lěng', 'I feel cold.'),
      S(['他', '可能', '不', '来'], 'tā kěnéng bù lái', "He may not come."),
    ]),
    Lesson(id: 'h2-wx-2', title: 'Sun and snow', subtitle: '晴 · 阴 · 雪', kind: _v, words: [
      W('晴', 'qíng', 'sunny / clear'),
      W('阴', 'yīn', 'cloudy / overcast'),
      W('雪', 'xuě', 'snow', note: '下雪 = to snow, just like 下雨 = to rain.'),
      W('去年', 'qùnián', 'last year'),
      W('日', 'rì', 'day / date (written)', note: 'In writing, dates use 日; in speech people say 号.'),
      W('手表', 'shǒubiǎo', 'wristwatch'),
    ], sentences: [
      S(['今天', '是', '晴', '天'], 'jīntiān shì qíngtiān', "It's a sunny day today."),
      S(['明天', '会', '下', '雪'], 'míngtiān huì xià xuě', 'It will snow tomorrow.'),
      S(['去年', '我', '去', '了', '北京'], 'qùnián wǒ qù le Běijīng', 'I went to Beijing last year.'),
    ]),
  ]),
  Unit('Talking with people', 'Help, reasons and little words', 0xFF2E86AB, tag: 'HSK 2 · Unit 10', level: 2, [
    Lesson(id: 'h2-talk-1', title: 'Helping out', subtitle: '帮助 · 介绍 · 送', kind: _v, words: [
      W('帮助', 'bāngzhù', 'to help'),
      W('介绍', 'jièshào', 'to introduce'),
      W('送', 'sòng', 'to give (as a gift) / to see off'),
      W('给', 'gěi', 'to give / for', note: '给我 = give me / for me.'),
      W('让', 'ràng', 'to let / to make (someone do)'),
      W('知道', 'zhīdào', 'to know (a fact)'),
    ], sentences: [
      S(['谢谢', '你', '的', '帮助'], 'xièxie nǐ de bāngzhù', 'Thank you for your help.'),
      S(['我', '介绍', '一下'], 'wǒ jièshào yíxià', 'Let me introduce (myself / someone).'),
      S(['我', '不', '知道'], 'wǒ bù zhīdào', "I don't know."),
      S(['请', '给', '我', '水'], 'qǐng gěi wǒ shuǐ', 'Please give me some water.'),
    ]),
    Lesson(id: 'h2-talk-2', title: 'Because and why', subtitle: '为什么 · 因为 · 所以', kind: _v, words: [
      W('为什么', 'wèishénme', 'why'),
      W('因为', 'yīnwèi', 'because'),
      W('所以', 'suǒyǐ', 'so / therefore', note: '因为…所以… = because …, so …'),
      W('虽然', 'suīrán', 'although'),
      W('但是', 'dànshì', 'but', note: '虽然…但是… = although …, (but) …'),
      W('说话', 'shuōhuà', 'to talk / to speak'),
    ], sentences: [
      S(['你', '为什么', '不', '来'], 'nǐ wèishénme bù lái', "Why aren't you coming?"),
      S(['因为', '下雨', '所以', '我', '不', '去'], 'yīnwèi xià yǔ, suǒyǐ wǒ bú qù', "Because it's raining, I'm not going."),
      S(['虽然', '很', '贵', '但是', '很', '好吃'], 'suīrán hěn guì, dànshì hěn hǎochī', "It's expensive, but it's tasty."),
    ]),
    Lesson(id: 'h2-talk-3', title: 'Little words', subtitle: '也 · 还 · 就', kind: _v, words: [
      W('也', 'yě', 'also / too'),
      W('还', 'hái', 'still / in addition'),
      W('就', 'jiù', 'just / right then'),
      W('可以', 'kěyǐ', 'may / can (allowed)'),
      W('公司', 'gōngsī', 'company'),
      W('完', 'wán', 'to finish', note: 'Sounds the same as 玩 (to play).'),
      W('再', 'zài', 'again (later)', note: '再见 = "see again", goodbye.'),
    ], sentences: [
      S(['我', '也', '是', '学生'], 'wǒ yě shì xuésheng', "I'm a student too."),
      S(['我', '可以', '坐', '这儿', '吗'], 'wǒ kěyǐ zuò zhèr ma', 'May I sit here?'),
      S(['他', '还', '在', '公司'], 'tā hái zài gōngsī', 'He is still at the company.'),
    ]),
    Lesson(id: 'h2-talk-4', title: 'Grammar helpers', subtitle: '得 · 着 · 过', kind: _v, words: [
      W('得', 'de', '(links a verb to how well it is done)', note: '他说得很好 = He speaks well.'),
      W('着', 'zhe', '(shows something is ongoing)', note: '门开着 = The door is open.'),
      W('过', 'guo', '(shows you have done it before)', note: '我去过中国 = I have been to China.'),
      W('事情', 'shìqing', 'matter / thing to do'),
    ], sentences: [
      S(['他', '汉语', '说', '得', '很', '好'], 'tā Hànyǔ shuō de hěn hǎo', 'He speaks Chinese well.'),
      S(['我', '去', '过', '北京'], 'wǒ qù guo Běijīng', 'I have been to Beijing.'),
      S(['门', '开', '着'], 'mén kāi zhe', 'The door is open.'),
      S(['我', '有', '事情'], 'wǒ yǒu shìqing', 'I have something to do.'),
    ]),
  ]),
];
