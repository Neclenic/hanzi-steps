// Listening at real speed: short original dialogues and talks, read at natural speed,
// each with questions like the listening part of the HSK exam.
// In dialogues, speaker A is a woman (voice Xiaoxiao) and B is a man (voice Yunxi).
// tool/make_voice.py records each clip as assets/voice/listen-<id>.mp3.

class ListenLine {
  final String speaker; // 'A' or 'B'
  final String zh;
  final String pinyin;
  final String en;
  const ListenLine(this.speaker, this.zh, this.pinyin, this.en);
}

class ListenQuestion {
  final String zh;
  final String en;
  final List<String> options; // in Chinese
  final List<String> optionsEn; // the same options in English, shown after checking
  final int correct;
  const ListenQuestion(this.zh, this.en, this.options, this.optionsEn, this.correct);
}

class ListenClip {
  final String id;
  final String title;
  final String scene; // an emoji
  final int level; // roughly which HSK level the words are
  final bool dialogue;
  final List<ListenLine> lines;
  final List<ListenQuestion> questions;
  const ListenClip(this.id, this.title, this.scene, this.level, this.dialogue, this.lines, this.questions);

  String get audio => 'listen-$id';
  String get text => lines.map((l) => l.zh).join();
}

typedef _L = ListenLine;
typedef _Q = ListenQuestion;

const listenClips = <ListenClip>[
  ListenClip('cafe', 'At the café', '☕', 3, true, [
    _L('A', '你好，请问你们有什么喝的？', 'Nǐ hǎo, qǐngwèn nǐmen yǒu shénme hē de?', 'Hello, what do you have to drink?'),
    _L('B', '我们有咖啡、茶和果汁。今天的绿茶很新鲜。', 'Wǒmen yǒu kāfēi, chá hé guǒzhī. Jīntiān de lǜchá hěn xīnxiān.',
        "We have coffee, tea and juice. Today's green tea is very fresh."),
    _L('A', '那我要一杯绿茶，不要糖。多少钱？', 'Nà wǒ yào yì bēi lǜchá, bú yào táng. Duōshao qián?',
        "Then I'll have a green tea, no sugar. How much is it?"),
    _L('B', '十八块。您在这儿喝还是带走？', 'Shíbā kuài. Nín zài zhèr hē háishi dàizǒu?', 'Eighteen yuan. To drink here or to take away?'),
    _L('A', '在这儿喝。谢谢！', 'Zài zhèr hē. Xièxie!', "I'll drink it here. Thanks!"),
  ], [
    _Q('女的要喝什么？', 'What does the woman order?', ['咖啡', '绿茶', '果汁'], ['coffee', 'green tea', 'juice'], 1),
    _Q('一共多少钱？', 'How much does it cost?', ['八块', '十块', '十八块'], ['8 yuan', '10 yuan', '18 yuan'], 2),
    _Q('她在哪儿喝？', 'Where will she drink it?', ['在店里', '带回家', '在公司'], ['in the café', 'at home', 'at work'], 0),
  ]),
  ListenClip('hike', 'A weekend hike', '⛰️', 3, false, [
    _L('A', '上个周末天气很好，我和朋友去爬山了。', 'Shàng ge zhōumò tiānqì hěn hǎo, wǒ hé péngyou qù pá shān le.',
        'Last weekend the weather was lovely, so my friends and I went hiking.'),
    _L('A', '山不太高，我们爬了两个小时就到了。', 'Shān bú tài gāo, wǒmen pále liǎng ge xiǎoshí jiù dào le.',
        "The mountain isn't very high. We reached the top in two hours."),
    _L('A', '山上的空气特别新鲜，我们照了很多照片。', 'Shān shang de kōngqì tèbié xīnxiān, wǒmen zhàole hěn duō zhàopiàn.',
        'The air up there was really fresh, and we took lots of photos.'),
    _L('A', '下山以后，我们去饭馆吃了面条。', 'Xià shān yǐhòu, wǒmen qù fànguǎn chīle miàntiáo.',
        'After coming down, we went to a restaurant and had noodles.'),
    _L('A', '虽然很累，但是我们都很高兴。', 'Suīrán hěn lèi, dànshì wǒmen dōu hěn gāoxìng.', "We were tired, but we were all happy."),
  ], [
    _Q('她周末做什么了？', 'What did she do at the weekend?', ['游泳', '爬山', '看电影'], ['went swimming', 'went hiking', 'saw a film'], 1),
    _Q('她们爬了多长时间？', 'How long did they climb?', ['两个小时', '二十分钟', '一整天'], ['two hours', 'twenty minutes', 'all day'], 0),
    _Q('下山以后她们吃了什么？', 'What did they eat afterwards?', ['饺子', '米饭', '面条'], ['dumplings', 'rice', 'noodles'], 2),
  ]),
  ListenClip('bank', 'Asking the way', '🧭', 3, true, [
    _L('A', '请问，附近有银行吗？', 'Qǐngwèn, fùjìn yǒu yínháng ma?', 'Excuse me, is there a bank nearby?'),
    _L('B', '有。你一直往前走，到第二个路口往右拐，银行就在超市旁边。',
        'Yǒu. Nǐ yìzhí wǎng qián zǒu, dào dì-èr ge lùkǒu wǎng yòu guǎi, yínháng jiù zài chāoshì pángbiān.',
        'Yes. Go straight on, turn right at the second crossing, and the bank is right next to the supermarket.'),
    _L('A', '远不远？要走多长时间？', 'Yuǎn bu yuǎn? Yào zǒu duō cháng shíjiān?', 'Is it far? How long is the walk?'),
    _L('B', '不远，走路五分钟就到了。', 'Bù yuǎn, zǒulù wǔ fēnzhōng jiù dào le.', "Not far, it's only a five-minute walk."),
    _L('A', '太好了，谢谢您！', 'Tài hǎo le, xièxie nín!', 'Great, thank you!'),
  ], [
    _Q('女的要去哪儿？', 'Where does the woman want to go?', ['超市', '医院', '银行'], ['the supermarket', 'the hospital', 'the bank'], 2),
    _Q('在第几个路口拐？', 'At which crossing should she turn?', ['第一个', '第二个', '第三个'], ['the first', 'the second', 'the third'], 1),
    _Q('走路要多长时间？', 'How long is the walk?', ['五分钟', '十五分钟', '半个小时'], ['five minutes', 'fifteen minutes', 'half an hour'], 0),
  ]),
  ListenClip('doctor', 'At the doctor', '🩺', 3, true, [
    _L('B', '你哪儿不舒服？', 'Nǐ nǎr bù shūfu?', "What's wrong?"),
    _L('A', '我从昨天晚上开始头疼，还有点儿发烧。', 'Wǒ cóng zuótiān wǎnshang kāishǐ tóu téng, hái yǒudiǎnr fāshāo.',
        "I've had a headache since last night, and a bit of a fever."),
    _L('B', '咳嗽吗？', 'Késou ma?', 'Are you coughing?'),
    _L('A', '有一点儿，晚上睡不着。', 'Yǒu yìdiǎnr, wǎnshang shuì bu zháo.', "A little. I can't sleep at night."),
    _L('B', '你感冒了。这个药一天吃三次，多喝水，好好休息。', 'Nǐ gǎnmào le. Zhège yào yì tiān chī sān cì, duō hē shuǐ, hǎohǎo xiūxi.',
        "You've got a cold. Take this medicine three times a day, drink plenty of water and get some rest."),
    _L('A', '我明天能去上班吗？', 'Wǒ míngtiān néng qù shàngbān ma?', 'Can I go to work tomorrow?'),
    _L('B', '最好在家休息两天。', 'Zuìhǎo zài jiā xiūxi liǎng tiān.', "It's best to stay home and rest for two days."),
  ], [
    _Q('她什么时候开始不舒服？', 'When did she start feeling ill?', ['今天早上', '昨天晚上', '上个星期'], ['this morning', 'last night', 'last week'], 1),
    _Q('药一天吃几次？', 'How many times a day should she take the medicine?', ['一次', '两次', '三次'], ['once', 'twice', 'three times'], 2),
    _Q('医生让她做什么？', 'What does the doctor tell her to do?', ['在家休息两天', '明天去上班', '去医院打针'],
        ['rest at home for two days', 'go to work tomorrow', 'get an injection at the hospital'], 0),
  ]),
  ListenClip('interview', 'A job interview', '💼', 4, true, [
    _L('B', '请你先介绍一下自己。', 'Qǐng nǐ xiān jièshào yíxià zìjǐ.', 'Please start by introducing yourself.'),
    _L('A', '您好，我叫王小雨。我大学的专业是新闻，毕业以后当了三年记者。',
        'Nín hǎo, wǒ jiào Wáng Xiǎoyǔ. Wǒ dàxué de zhuānyè shì xīnwén, bìyè yǐhòu dāngle sān nián jìzhě.',
        'Hello, my name is Wang Xiaoyu. I studied journalism at university, and after graduating I worked as a journalist for three years.'),
    _L('B', '你为什么想来我们公司工作？', 'Nǐ wèishénme xiǎng lái wǒmen gōngsī gōngzuò?', 'Why do you want to work for our company?'),
    _L('A', '我对广告很感兴趣，而且我觉得这份工作能让我学到很多新东西。',
        'Wǒ duì guǎnggào hěn gǎn xìngqù, érqiě wǒ juéde zhè fèn gōngzuò néng ràng wǒ xuédào hěn duō xīn dōngxi.',
        "I'm very interested in advertising, and I think this job would teach me a lot of new things."),
    _L('B', '你能接受经常加班吗？', 'Nǐ néng jiēshòu jīngcháng jiābān ma?', 'Are you OK with working overtime often?'),
    _L('A', '没问题。只要工作有意思，我不怕累。', 'Méi wèntí. Zhǐyào gōngzuò yǒu yìsi, wǒ bú pà lèi.',
        "No problem. As long as the work is interesting, I don't mind working hard."),
  ], [
    _Q('她以前做什么工作？', 'What was her job before?', ['律师', '记者', '老师'], ['lawyer', 'journalist', 'teacher'], 1),
    _Q('她对什么感兴趣？', 'What is she interested in?', ['广告', '旅游', '历史'], ['advertising', 'travel', 'history'], 0),
    _Q('她能接受加班吗？', 'Is she OK with overtime?', ['不能', '没说', '能'], ['no', "she doesn't say", 'yes'], 2),
  ]),
  ListenClip('move', 'A new flat', '🏠', 4, false, [
    _L('A', '上个月我搬家了。', 'Shàng ge yuè wǒ bān jiā le.', 'I moved house last month.'),
    _L('A', '新房子离公司很近，骑自行车只要十分钟，所以我每天早上可以多睡半个小时。',
        'Xīn fángzi lí gōngsī hěn jìn, qí zìxíngchē zhǐ yào shí fēnzhōng, suǒyǐ wǒ měitiān zǎoshang kěyǐ duō shuì bàn ge xiǎoshí.',
        'The new place is close to work, only ten minutes by bike, so I can sleep half an hour longer every morning.'),
    _L('A', '房子不大，但是很干净，窗户外面就是一个小公园。', 'Fángzi bú dà, dànshì hěn gānjìng, chuānghu wàimiàn jiù shì yí ge xiǎo gōngyuán.',
        "It isn't big, but it's very clean, and there's a little park right outside the window."),
    _L('A', '唯一的问题是房租比以前贵了五百块。', 'Wéiyī de wèntí shì fángzū bǐ yǐqián guìle wǔbǎi kuài.',
        'The only problem is that the rent is 500 yuan more than before.'),
    _L('A', '不过我觉得很值得。', 'Búguò wǒ juéde hěn zhíde.', "But I think it's worth it."),
  ], [
    _Q('新房子离哪儿很近？', 'What is the new flat close to?', ['学校', '火车站', '公司'], ['a school', 'the train station', 'her work'], 2),
    _Q('她每天怎么去上班？', 'How does she get to work?', ['骑自行车', '坐地铁', '走路'], ['by bike', 'by subway', 'on foot'], 0),
    _Q('新房子有什么问题？', 'What is the problem with the new flat?', ['太小了', '房租更贵', '不干净'], ["it's too small", 'the rent is higher', "it isn't clean"], 1),
  ]),
  ListenClip('late', 'Where is our food?', '🍲', 4, true, [
    _L('A', '服务员，我们点的菜已经等了四十分钟了，怎么还没来？',
        'Fúwùyuán, wǒmen diǎn de cài yǐjīng děngle sìshí fēnzhōng le, zěnme hái méi lái?',
        "Excuse me, we've been waiting forty minutes for our food. Why hasn't it come yet?"),
    _L('B', '真抱歉，今天客人特别多，厨房太忙了。我马上去问一下。',
        'Zhēn bàoqiàn, jīntiān kèrén tèbié duō, chúfáng tài máng le. Wǒ mǎshàng qù wèn yíxià.',
        "I'm really sorry, we're very busy today and the kitchen is swamped. I'll go and check right away."),
    _L('A', '好的，麻烦你快一点儿，我们一点半还要开会。', 'Hǎo de, máfan nǐ kuài yìdiǎnr, wǒmen yì diǎn bàn hái yào kāihuì.',
        'OK, please hurry, we have a meeting at half past one.'),
    _L('B', '没问题。为了表示歉意，我们送您一份水果。', 'Méi wèntí. Wèile biǎoshì qiànyì, wǒmen sòng nín yí fèn shuǐguǒ.',
        "Of course. To say sorry, we'll give you a plate of fruit on the house."),
  ], [
    _Q('他们等了多长时间？', 'How long have they been waiting?', ['十四分钟', '四十分钟', '一个小时'], ['14 minutes', '40 minutes', 'an hour'], 1),
    _Q('菜为什么还没来？', "Why hasn't the food come?", ['客人太多', '厨师生病了', '菜卖完了'], ['there are too many customers', 'the cook is ill', 'the dish is sold out'], 0),
    _Q('饭馆送了他们什么？', 'What does the restaurant give them for free?', ['一杯茶', '打折', '一份水果'], ['a cup of tea', 'a discount', 'a plate of fruit'], 2),
  ]),
  ListenClip('plans', 'Weekend plans', '🎬', 4, true, [
    _L('A', '这个周末你有什么打算？', 'Zhège zhōumò nǐ yǒu shénme dǎsuan?', 'What are your plans for this weekend?'),
    _L('B', '我本来想去海边玩儿，可是天气预报说周六有大雨。', 'Wǒ běnlái xiǎng qù hǎibiān wánr, kěshì tiānqì yùbào shuō zhōuliù yǒu dàyǔ.',
        'I was going to go to the seaside, but the forecast says heavy rain on Saturday.'),
    _L('A', '那太可惜了。要不我们去看电影吧？听说最近有个新电影很不错。',
        'Nà tài kěxī le. Yàobù wǒmen qù kàn diànyǐng ba? Tīngshuō zuìjìn yǒu ge xīn diànyǐng hěn búcuò.',
        "That's a shame. How about we go to the cinema? I hear there's a good new film out."),
    _L('B', '好主意！我们周六下午去，看完电影再一起吃晚饭。', 'Hǎo zhǔyi! Wǒmen zhōuliù xiàwǔ qù, kànwán diànyǐng zài yìqǐ chī wǎnfàn.',
        "Good idea! Let's go on Saturday afternoon and have dinner together after the film."),
    _L('A', '行，我先在网上买票。', 'Xíng, wǒ xiān zài wǎngshang mǎi piào.', "OK, I'll buy the tickets online."),
  ], [
    _Q('男的本来打算去哪儿？', 'Where was the man going to go?', ['山上', '海边', '电影院'], ['the mountains', 'the seaside', 'the cinema'], 1),
    _Q('他为什么不去了？', "Why isn't he going?", ['周六有大雨', '太远了', '票卖完了'], ["it'll rain heavily on Saturday", "it's too far", 'tickets are sold out'], 0),
    _Q('谁买电影票？', 'Who buys the tickets?', ['男的', '他们的朋友', '女的'], ['the man', 'their friend', 'the woman'], 2),
  ]),
  ListenClip('learning', 'Learning Chinese', '📚', 4, false, [
    _L('A', '我学汉语已经两年了。', 'Wǒ xué Hànyǔ yǐjīng liǎng nián le.', "I've been learning Chinese for two years."),
    _L('A', '刚开始的时候，我觉得声调特别难，常常把“买”和“卖”说错。',
        'Gāng kāishǐ de shíhou, wǒ juéde shēngdiào tèbié nán, chángcháng bǎ “mǎi” hé “mài” shuōcuò.',
        'At first I found the tones really hard, and I often mixed up mǎi (buy) and mài (sell).'),
    _L('A', '后来老师建议我每天跟着录音练习十五分钟，还要多跟中国朋友聊天。',
        'Hòulái lǎoshī jiànyì wǒ měitiān gēnzhe lùyīn liànxí shíwǔ fēnzhōng, hái yào duō gēn Zhōngguó péngyou liáotiān.',
        'Then my teacher suggested I practise along with recordings for fifteen minutes a day, and chat with Chinese friends more.'),
    _L('A', '现在我说得越来越流利了，下个月我打算参加汉语水平考试。',
        'Xiànzài wǒ shuō de yuè lái yuè liúlì le, xià ge yuè wǒ dǎsuan cānjiā Hànyǔ Shuǐpíng Kǎoshì.',
        "Now I'm getting more and more fluent, and next month I'm going to take the HSK exam."),
  ], [
    _Q('她学汉语多长时间了？', 'How long has she been learning Chinese?', ['半年', '两个月', '两年'], ['half a year', 'two months', 'two years'], 2),
    _Q('刚开始什么最难？', 'What was hardest at first?', ['声调', '汉字', '语法'], ['the tones', 'the characters', 'the grammar'], 0),
    _Q('老师建议她做什么？', 'What did her teacher suggest?', ['每天写汉字', '每天跟着录音练习', '去中国留学'],
        ['write characters every day', 'practise along with recordings every day', 'study in China'], 1),
  ]),
  ListenClip('coat', 'Bought online', '🧥', 4, true, [
    _L('A', '你这件大衣真好看，在哪儿买的？', 'Nǐ zhè jiàn dàyī zhēn hǎokàn, zài nǎr mǎi de?', 'Your coat looks great. Where did you buy it?'),
    _L('B', '网上买的，正在打折，才三百块。', 'Wǎngshang mǎi de, zhèngzài dǎzhé, cái sānbǎi kuài.',
        'Online. It was on sale, only three hundred yuan.'),
    _L('A', '这么便宜！质量怎么样？', 'Zhème piányi! Zhìliàng zěnmeyàng?', "That cheap! What's the quality like?"),
    _L('B', '还不错。不过第一次买的那件太小了，我又换了一件大一号的。',
        'Hái búcuò. Búguò dì-yī cì mǎi de nà jiàn tài xiǎo le, wǒ yòu huànle yí jiàn dà yí hào de.',
        'Not bad. But the first one I bought was too small, so I swapped it for one a size bigger.'),
    _L('A', '网上买衣服就是这个问题，不能先试试。', 'Wǎngshang mǎi yīfu jiù shì zhège wèntí, bù néng xiān shìshi.',
        "That's the problem with buying clothes online: you can't try them on first."),
  ], [
    _Q('大衣多少钱？', 'How much was the coat?', ['一百块', '三百块', '三千块'], ['100 yuan', '300 yuan', '3,000 yuan'], 1),
    _Q('第一件大衣有什么问题？', 'What was wrong with the first coat?', ['太贵了', '颜色不好', '太小了'], ['too expensive', 'the wrong colour', 'too small'], 2),
    _Q('女的觉得网上买衣服有什么问题？', 'What does the woman think is the problem with buying clothes online?', ['不能先试', '质量不好', '太慢了'],
        ["you can't try them on first", 'the quality is poor', "it's too slow"], 0),
  ]),
];

ListenClip? listenClipById(String id) {
  for (final c in listenClips) {
    if (c.id == id) return c;
  }
  return null;
}
