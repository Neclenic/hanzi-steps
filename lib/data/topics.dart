// Speak on a topic: questions like the speaking part of the HSKK exam, each with useful
// words and an original model answer that Xiaoxiao reads aloud.

class TopicWord {
  final String zh;
  final String pinyin;
  final String en;
  const TopicWord(this.zh, this.pinyin, this.en);
}

class SpeakTopic {
  final String id;
  final String scene; // an emoji
  final String title; // in English
  final int level; // roughly which HSK level the model answer is
  final String question;
  final String questionPinyin;
  final String questionEn;
  final List<TopicWord> words;
  final String model; // the model answer
  final String modelPinyin;
  final String modelEn;
  const SpeakTopic(this.id, this.scene, this.title, this.level, this.question, this.questionPinyin, this.questionEn,
      this.words, this.model, this.modelPinyin, this.modelEn);
}

/// Things to check after speaking, for every topic.
const topicChecks = [
  'I spoke for 30 seconds or more',
  'I used at least three of the useful words',
  'I gave a reason or an example',
  'I joined my sentences (然后, 因为, 但是…)',
];

typedef _W = TopicWord;

const speakTopics = <SpeakTopic>[
  SpeakTopic(
    'weekend', '🛋️', 'Your weekend', 3,
    '你周末一般做什么？', 'Nǐ zhōumò yìbān zuò shénme?', 'What do you usually do at the weekend?',
    [
      _W('一般', 'yìbān', 'usually'),
      _W('先', 'xiān', 'first'),
      _W('然后', 'ránhòu', 'then'),
      _W('有时候', 'yǒu shíhou', 'sometimes'),
      _W('放松', 'fàngsōng', 'to relax'),
    ],
    '我周末一般起得比较晚，九点左右才起床。吃完早饭以后，我先打扫房间，然后去超市买东西。下午有时候我和朋友去公园散步，有时候在家看电影。晚上我喜欢做饭，做完饭以后早点儿睡觉。周末很放松，我很喜欢。',
    'Wǒ zhōumò yìbān qǐ de bǐjiào wǎn, jiǔ diǎn zuǒyòu cái qǐchuáng. Chīwán zǎofàn yǐhòu, wǒ xiān dǎsǎo fángjiān, ránhòu qù chāoshì mǎi dōngxi. Xiàwǔ yǒu shíhou wǒ hé péngyou qù gōngyuán sànbù, yǒu shíhou zài jiā kàn diànyǐng. Wǎnshang wǒ xǐhuan zuò fàn, zuòwán fàn yǐhòu zǎo diǎnr shuìjiào. Zhōumò hěn fàngsōng, wǒ hěn xǐhuan.',
    'At the weekend I usually get up quite late, not until about nine. After breakfast I first tidy my room, then go to the supermarket. In the afternoon I sometimes go for a walk in the park with friends, and sometimes watch a film at home. In the evening I like cooking, and after dinner I go to bed a bit early. Weekends are relaxing, and I really like them.',
  ),
  SpeakTopic(
    'family', '👨‍👩‍👧', 'Your family', 3,
    '请介绍一下你的家人。', 'Qǐng jièshào yíxià nǐ de jiārén.', 'Please tell me about your family.',
    [
      _W('家人', 'jiārén', 'family members'),
      _W('工作', 'gōngzuò', 'work; to work'),
      _W('热情', 'rèqíng', 'warm, friendly'),
      _W('比', 'bǐ', 'than (姐姐比我大)'),
      _W('一起', 'yìqǐ', 'together'),
    ],
    '我家有四口人：爸爸、妈妈、姐姐和我。我爸爸是医生，他工作很忙，但是周末常常带我们出去玩。我妈妈是老师，她很热情，也很会做饭。姐姐比我大三岁，现在在北京上大学。我们家的关系很好，每年春节我们都一起过。',
    'Wǒ jiā yǒu sì kǒu rén: bàba, māma, jiějie hé wǒ. Wǒ bàba shì yīshēng, tā gōngzuò hěn máng, dànshì zhōumò chángcháng dài wǒmen chūqù wán. Wǒ māma shì lǎoshī, tā hěn rèqíng, yě hěn huì zuò fàn. Jiějie bǐ wǒ dà sān suì, xiànzài zài Běijīng shàng dàxué. Wǒmen jiā de guānxi hěn hǎo, měi nián Chūnjié wǒmen dōu yìqǐ guò.',
    'There are four of us: Dad, Mum, my older sister and me. My dad is a doctor. He is very busy at work, but at weekends he often takes us out. My mum is a teacher; she is very warm and a great cook. My sister is three years older than me and is at university in Beijing. We all get on well, and every Spring Festival we celebrate together.',
  ),
  SpeakTopic(
    'food', '🌶️', 'Your favourite food', 3,
    '你最喜欢吃什么菜？为什么？', 'Nǐ zuì xǐhuan chī shénme cài? Wèishénme?', 'What food do you like best? Why?',
    [
      _W('最', 'zuì', 'most'),
      _W('特别', 'tèbié', 'especially'),
      _W('又…又…', 'yòu… yòu…', 'both… and…'),
      _W('因为…所以…', 'yīnwèi… suǒyǐ…', 'because… so…'),
      _W('健康', 'jiànkāng', 'healthy'),
    ],
    '我最喜欢吃中国菜，特别是四川菜。四川菜又辣又香，味道很好。因为我常常吃，所以现在我也会做几个简单的菜。不过我觉得吃太多辣的不太健康，所以我也吃很多水果和蔬菜。',
    'Wǒ zuì xǐhuan chī Zhōngguó cài, tèbié shì Sìchuān cài. Sìchuān cài yòu là yòu xiāng, wèidào hěn hǎo. Yīnwèi wǒ chángcháng chī, suǒyǐ xiànzài wǒ yě huì zuò jǐ ge jiǎndān de cài. Búguò wǒ juéde chī tài duō là de bú tài jiànkāng, suǒyǐ wǒ yě chī hěn duō shuǐguǒ hé shūcài.',
    "My favourite is Chinese food, especially Sichuan food. Sichuan dishes are spicy and fragrant, and taste great. Because I eat it often, I can now cook a few simple dishes myself. But I think too much spicy food isn't very healthy, so I also eat lots of fruit and vegetables.",
  ),
  SpeakTopic(
    'city', '🏙️', 'Where you live', 3,
    '你住在哪个城市？那儿怎么样？', 'Nǐ zhù zài nǎge chéngshì? Nàr zěnmeyàng?', 'Which city do you live in? What is it like?',
    [
      _W('城市', 'chéngshì', 'city'),
      _W('环境', 'huánjìng', 'surroundings, environment'),
      _W('方便', 'fāngbiàn', 'convenient'),
      _W('附近', 'fùjìn', 'nearby'),
      _W('比较', 'bǐjiào', 'quite, rather'),
    ],
    '我住在一个不太大的城市。这里环境很好，有很多公园，空气也比较新鲜。交通很方便，坐地铁去哪儿都很快。我家附近有超市、银行和医院，生活很方便。唯一的问题是冬天太冷了。',
    'Wǒ zhù zài yí ge bú tài dà de chéngshì. Zhèlǐ huánjìng hěn hǎo, yǒu hěn duō gōngyuán, kōngqì yě bǐjiào xīnxiān. Jiāotōng hěn fāngbiàn, zuò dìtiě qù nǎr dōu hěn kuài. Wǒ jiā fùjìn yǒu chāoshì, yínháng hé yīyuàn, shēnghuó hěn fāngbiàn. Wéiyī de wèntí shì dōngtiān tài lěng le.',
    "I live in a city that isn't very big. The surroundings are nice: there are many parks and the air is quite fresh. Getting around is easy; the metro takes you anywhere fast. Near my home there's a supermarket, a bank and a hospital, so daily life is convenient. The only problem is that winter is too cold.",
  ),
  SpeakTopic(
    'trip', '🏞️', 'A trip you remember', 4,
    '你去过的地方中，哪儿让你印象最深？', 'Nǐ qùguo de dìfang zhōng, nǎr ràng nǐ yìnxiàng zuì shēn?',
    'Of the places you have been to, which made the deepest impression on you?',
    [
      _W('印象', 'yìnxiàng', 'impression'),
      _W('风景', 'fēngjǐng', 'scenery'),
      _W('当地', 'dāngdì', 'local'),
      _W('虽然…但是…', 'suīrán… dànshì…', 'although… (still)…'),
      _W('值得', 'zhíde', 'to be worth it'),
    ],
    '去年夏天我去了云南，那次旅行让我印象最深。那里的风景特别美，山很高，天很蓝。我们还去了一个小村子，当地人非常热情，请我们吃了很多好吃的东西。虽然路上有点儿累，但是我觉得非常值得。以后有机会我还想再去一次。',
    'Qùnián xiàtiān wǒ qùle Yúnnán, nà cì lǚxíng ràng wǒ yìnxiàng zuì shēn. Nàlǐ de fēngjǐng tèbié měi, shān hěn gāo, tiān hěn lán. Wǒmen hái qùle yí ge xiǎo cūnzi, dāngdì rén fēicháng rèqíng, qǐng wǒmen chīle hěn duō hǎochī de dōngxi. Suīrán lùshang yǒudiǎnr lèi, dànshì wǒ juéde fēicháng zhíde. Yǐhòu yǒu jīhuì wǒ hái xiǎng zài qù yí cì.',
    "Last summer I went to Yunnan, and that trip made the deepest impression on me. The scenery is stunning: high mountains and blue sky. We also visited a small village where the locals were very welcoming and treated us to lots of delicious food. The journey was a bit tiring, but it was well worth it. If I get the chance, I'd like to go again.",
  ),
  SpeakTopic(
    'chinese', '🀄', 'Learning Chinese', 4,
    '你为什么学习汉语？学汉语难不难？', 'Nǐ wèishénme xuéxí Hànyǔ? Xué Hànyǔ nán bu nán?', 'Why are you learning Chinese? Is it hard?',
    [
      _W('对…感兴趣', 'duì… gǎn xìngqù', 'to be interested in…'),
      _W('刚开始的时候', 'gāng kāishǐ de shíhou', 'at the very start'),
      _W('坚持', 'jiānchí', 'to keep at it'),
      _W('习惯', 'xíguàn', 'to get used to'),
      _W('提高', 'tígāo', 'to improve'),
    ],
    '我学习汉语是因为我对中国文化很感兴趣。刚开始的时候，我觉得声调特别难，汉字也很难记。后来我每天坚持听和说，慢慢地就习惯了。现在我的汉语水平提高了不少，我希望以后有机会去中国工作。',
    'Wǒ xuéxí Hànyǔ shì yīnwèi wǒ duì Zhōngguó wénhuà hěn gǎn xìngqù. Gāng kāishǐ de shíhou, wǒ juéde shēngdiào tèbié nán, Hànzì yě hěn nán jì. Hòulái wǒ měi tiān jiānchí tīng hé shuō, mànmàn de jiù xíguàn le. Xiànzài wǒ de Hànyǔ shuǐpíng tígāole bù shǎo, wǒ xīwàng yǐhòu yǒu jīhuì qù Zhōngguó gōngzuò.',
    "I'm learning Chinese because I'm very interested in Chinese culture. At first I found the tones really hard, and characters were hard to remember. Then I kept listening and speaking every day, and slowly got used to it. My Chinese has improved quite a lot, and I hope to get the chance to work in China one day.",
  ),
  SpeakTopic(
    'phones', '📱', 'Phones and our lives', 4,
    '你觉得手机对我们的生活有什么影响？', 'Nǐ juéde shǒujī duì wǒmen de shēnghuó yǒu shénme yǐngxiǎng?',
    'How do you think phones affect our lives?',
    [
      _W('影响', 'yǐngxiǎng', 'influence, effect'),
      _W('一方面…另一方面…', 'yì fāngmiàn… lìng yì fāngmiàn…', 'on the one hand… on the other…'),
      _W('浪费', 'làngfèi', 'to waste'),
      _W('应该', 'yīnggāi', 'should'),
      _W('合理', 'hélǐ', 'sensible, reasonable'),
    ],
    '我觉得手机对我们的生活影响很大。一方面，手机让生活更方便了，我们可以用它买东西、付钱、和朋友聊天。另一方面，很多人每天看手机的时间太长，浪费了很多时间，对眼睛也不好。所以我觉得应该合理地使用手机。',
    'Wǒ juéde shǒujī duì wǒmen de shēnghuó yǐngxiǎng hěn dà. Yì fāngmiàn, shǒujī ràng shēnghuó gèng fāngbiàn le, wǒmen kěyǐ yòng tā mǎi dōngxi, fù qián, hé péngyou liáotiān. Lìng yì fāngmiàn, hěn duō rén měi tiān kàn shǒujī de shíjiān tài cháng, làngfèile hěn duō shíjiān, duì yǎnjing yě bù hǎo. Suǒyǐ wǒ juéde yīnggāi hélǐ de shǐyòng shǒujī.',
    "I think phones have a big effect on our lives. On the one hand, they make life more convenient: we can use them to shop, pay and chat with friends. On the other hand, many people look at their phones for too long every day, wasting a lot of time, and it's bad for the eyes too. So I think we should use phones sensibly.",
  ),
  SpeakTopic(
    'job', '💼', 'Your ideal job', 4,
    '你理想的工作是什么样的？', 'Nǐ lǐxiǎng de gōngzuò shì shénme yàng de?', 'What would your ideal job be like?',
    [
      _W('理想', 'lǐxiǎng', 'ideal'),
      _W('收入', 'shōurù', 'income'),
      _W('压力', 'yālì', 'pressure, stress'),
      _W('同事', 'tóngshì', 'colleague'),
      _W('另外', 'lìngwài', 'besides, also'),
    ],
    '我理想的工作不一定收入很高，但是要有意思。我希望同事们都很友好，大家可以互相帮助。工作压力不要太大，这样下班以后我还有时间运动和学习。另外，我想做能经常出差的工作，因为我喜欢去不同的地方，积累更多经验。',
    'Wǒ lǐxiǎng de gōngzuò bù yídìng shōurù hěn gāo, dànshì yào yǒu yìsi. Wǒ xīwàng tóngshìmen dōu hěn yǒuhǎo, dàjiā kěyǐ hùxiāng bāngzhù. Gōngzuò yālì bú yào tài dà, zhèyàng xiàbān yǐhòu wǒ hái yǒu shíjiān yùndòng hé xuéxí. Lìngwài, wǒ xiǎng zuò néng jīngcháng chūchāi de gōngzuò, yīnwèi wǒ xǐhuan qù bù tóng de dìfang, jīlěi gèng duō jīngyàn.',
    "My ideal job doesn't have to pay a lot, but it should be interesting. I'd like friendly colleagues who help each other. The pressure shouldn't be too high, so I still have time for sport and study after work. Also, I'd like a job with regular business trips, because I enjoy going to different places and gaining more experience.",
  ),
  SpeakTopic(
    'countryside', '🌾', 'City or countryside?', 5,
    '你更愿意住在城市还是农村？为什么？', 'Nǐ gèng yuànyì zhù zài chéngshì háishi nóngcūn? Wèishénme?',
    'Would you rather live in a city or in the countryside? Why?',
    [
      _W('农村', 'nóngcūn', 'countryside'),
      _W('优点', 'yōudiǎn', 'advantage'),
      _W('缺点', 'quēdiǎn', 'drawback'),
      _W('相比之下', 'xiāngbǐ zhī xià', 'by comparison'),
      _W('如果…', 'rúguǒ…', 'if…'),
    ],
    '城市和农村各有优点和缺点。城市的工作机会多，交通和医疗条件也比较好，但是生活压力大，房子也贵。相比之下，农村空气好，生活节奏慢，非常安静。如果让我选择，年轻的时候我愿意在城市工作，等退休以后再搬到农村去住。',
    'Chéngshì hé nóngcūn gè yǒu yōudiǎn hé quēdiǎn. Chéngshì de gōngzuò jīhuì duō, jiāotōng hé yīliáo tiáojiàn yě bǐjiào hǎo, dànshì shēnghuó yālì dà, fángzi yě guì. Xiāngbǐ zhī xià, nóngcūn kōngqì hǎo, shēnghuó jiézòu màn, fēicháng ānjìng. Rúguǒ ràng wǒ xuǎnzé, niánqīng de shíhou wǒ yuànyì zài chéngshì gōngzuò, děng tuìxiū yǐhòu zài bān dào nóngcūn qù zhù.',
    "Cities and the countryside each have pros and cons. Cities have more jobs and better transport and healthcare, but life is stressful and housing is expensive. By comparison, the countryside has clean air, a slow pace of life and lots of quiet. If I had to choose, I'd work in a city while I'm young and move to the countryside after I retire.",
  ),
  SpeakTopic(
    'difficulty', '🧗', 'A difficulty you overcame', 5,
    '说说你遇到过的一个困难，你是怎么解决的？', 'Shuōshuo nǐ yùdàoguo de yí ge kùnnan, nǐ shì zěnme jiějué de?',
    'Talk about a difficulty you met. How did you deal with it?',
    [
      _W('困难', 'kùnnan', 'difficulty'),
      _W('解决', 'jiějué', 'to solve'),
      _W('甚至', 'shènzhì', 'even'),
      _W('放弃', 'fàngqì', 'to give up'),
      _W('经历', 'jīnglì', 'an experience (lived through)'),
    ],
    '刚来中国的时候，我遇到了很多困难。我听不懂别人说话，买东西、坐车都很麻烦，有一段时间我甚至想放弃。后来我交了几个中国朋友，他们经常和我聊天，还耐心地纠正我的发音。慢慢地，我对自己越来越有信心。这段经历让我明白，遇到困难的时候一定要坚持。',
    'Gāng lái Zhōngguó de shíhou, wǒ yùdàole hěn duō kùnnan. Wǒ tīng bu dǒng biérén shuōhuà, mǎi dōngxi, zuò chē dōu hěn máfan, yǒu yí duàn shíjiān wǒ shènzhì xiǎng fàngqì. Hòulái wǒ jiāole jǐ ge Zhōngguó péngyou, tāmen jīngcháng hé wǒ liáotiān, hái nàixīn de jiūzhèng wǒ de fāyīn. Mànmàn de, wǒ duì zìjǐ yuè lái yuè yǒu xìnxīn. Zhè duàn jīnglì ràng wǒ míngbai, yùdào kùnnan de shíhou yídìng yào jiānchí.',
    "When I first came to China, I ran into many difficulties. I couldn't understand people, and shopping and taking buses were a hassle; for a while I even wanted to give up. Then I made a few Chinese friends who often chatted with me and patiently corrected my pronunciation. Bit by bit, I grew more confident. That experience taught me to keep going when things get hard.",
  ),
  SpeakTopic(
    'environment', '🌍', 'Protecting the environment', 5,
    '你觉得普通人可以为保护环境做些什么？', 'Nǐ juéde pǔtōng rén kěyǐ wèi bǎohù huánjìng zuò xiē shénme?',
    'What can ordinary people do to protect the environment?',
    [
      _W('保护', 'bǎohù', 'to protect'),
      _W('污染', 'wūrǎn', 'pollution'),
      _W('节约', 'jiéyuē', 'to save, not waste'),
      _W('减少', 'jiǎnshǎo', 'to reduce'),
      _W('从小事做起', 'cóng xiǎo shì zuò qǐ', 'to start with small things'),
    ],
    '保护环境不只是政府的事，每个普通人都可以从小事做起。比如，出门的时候尽量坐公共汽车或者骑自行车，这样可以减少空气污染。在家里要节约用水用电，买东西的时候自己带购物袋，少用塑料袋。如果每个人都做一点儿，我们的环境就会越来越好。',
    'Bǎohù huánjìng bù zhǐ shì zhèngfǔ de shì, měi ge pǔtōng rén dōu kěyǐ cóng xiǎo shì zuò qǐ. Bǐrú, chūmén de shíhou jǐnliàng zuò gōnggòng qìchē huòzhě qí zìxíngchē, zhèyàng kěyǐ jiǎnshǎo kōngqì wūrǎn. Zài jiā lǐ yào jiéyuē yòng shuǐ yòng diàn, mǎi dōngxi de shíhou zìjǐ dài gòuwùdài, shǎo yòng sùliàodài. Rúguǒ měi ge rén dōu zuò yìdiǎnr, wǒmen de huánjìng jiù huì yuè lái yuè hǎo.',
    "Protecting the environment isn't only the government's job; everyone can start with small things. For example, take the bus or cycle when you go out, which cuts air pollution. At home, save water and electricity, and bring your own bag when shopping instead of using plastic ones. If everyone does a little, our environment will keep getting better.",
  ),
  SpeakTopic(
    'success', '🏅', 'What is success?', 5,
    '你认为什么样的人生才算成功？', 'Nǐ rènwéi shénme yàng de rénshēng cái suàn chénggōng?', 'What kind of life do you think counts as a success?',
    [
      _W('成功', 'chénggōng', 'success'),
      _W('标准', 'biāozhǔn', 'standard, measure'),
      _W('对…来说', 'duì… lái shuō', 'for (someone)'),
      _W('追求', 'zhuīqiú', 'to pursue; a goal'),
      _W('满足', 'mǎnzú', 'content, satisfied'),
    ],
    '很多人认为有钱、有名就是成功，但我不这么看。我觉得每个人成功的标准都不一样。对我来说，能做自己喜欢的事情，身体健康，和家人朋友关系好，就已经很成功了。人应该有自己的追求，但也要学会满足，这样才能生活得快乐。',
    'Hěn duō rén rènwéi yǒu qián, yǒu míng jiù shì chénggōng, dàn wǒ bú zhème kàn. Wǒ juéde měi ge rén chénggōng de biāozhǔn dōu bù yíyàng. Duì wǒ lái shuō, néng zuò zìjǐ xǐhuan de shìqing, shēntǐ jiànkāng, hé jiārén péngyou guānxi hǎo, jiù yǐjīng hěn chénggōng le. Rén yīnggāi yǒu zìjǐ de zhuīqiú, dàn yě yào xuéhuì mǎnzú, zhèyàng cái néng shēnghuó de kuàilè.',
    "Many people think being rich and famous means success, but I don't see it that way. I think everyone's measure of success is different. For me, doing what I enjoy, being healthy, and getting on well with family and friends already counts as success. We should have our own goals, but also learn to be content; that's how to live happily.",
  ),
];
