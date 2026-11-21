// Words with similar meanings that learners mix up, such as 以为 / 认为 and 改变 / 变化.
// The HSK 4 and 5 exams test these a lot. Each pair has a plain explanation and
// example sentences where only one of the words fits. Everything here is original.

class SynWord {
  final String zh;
  final String pinyin;
  final String meaning;
  final String use; // how it is used, in plain English
  const SynWord(this.zh, this.pinyin, this.meaning, this.use);
}

/// A sentence that uses one word of the pair. In the drill the word is left out.
class SynExample {
  final String zh;
  final String pinyin;
  final String en;
  final int answer; // index into the pair's words
  const SynExample(this.zh, this.pinyin, this.en, this.answer);
}

class SynonymPair {
  final String id;
  final List<SynWord> words;
  final String tip; // the difference in one or two sentences
  final List<SynExample> examples;
  const SynonymPair(this.id, this.words, this.tip, this.examples);

  String get title => words.map((w) => w.zh).join(' · ');

  /// The example with its word left out, e.g. 我＿＿今天是星期六。
  String gap(SynExample e) => e.zh.replaceFirst(words[e.answer].zh, '＿＿');
}

typedef _W = SynWord;
typedef _E = SynExample;

const synonymPairs = <SynonymPair>[
  SynonymPair('yiwei-renwei', [
    _W('以为', 'yǐwéi', 'thought (wrongly)', 'You believed something, and then found out it was not true.'),
    _W('认为', 'rènwéi', 'to think, to be of the opinion', 'Your view or judgement about something.'),
  ], '以为 is for a belief that turned out wrong, often followed by 原来 or 其实. 认为 is simply your opinion.', [
    _E('我以为今天是星期六，原来是星期五。', 'Wǒ yǐwéi jīntiān shì xīngqīliù, yuánlái shì xīngqīwǔ.',
        'I thought today was Saturday, but it is actually Friday.', 0),
    _E('大家都以为他走了，其实他还在办公室。', 'Dàjiā dōu yǐwéi tā zǒu le, qíshí tā hái zài bàngōngshì.',
        'Everyone thought he had left, but he is actually still in the office.', 0),
    _E('我认为这个办法很好。', 'Wǒ rènwéi zhège bànfǎ hěn hǎo.', 'I think this is a good way to do it.', 1),
    _E('专家认为每天应该睡七八个小时。', 'Zhuānjiā rènwéi měi tiān yīnggāi shuì qī bā ge xiǎoshí.',
        'Experts think you should sleep seven or eight hours a day.', 1),
  ]),
  SynonymPair('gaibian-bianhua', [
    _W('改变', 'gǎibiàn', 'to change (something)', 'Someone changes something: 改变计划, 改变习惯. It takes an object.'),
    _W('变化', 'biànhuà', 'a change; to change by itself', 'Something changes on its own: 变化很大. Nothing comes after it.'),
  ], 'Ask "who changes what?" If someone changes something, use 改变. If things just change, use 变化.', [
    _E('我们得改变一下计划。', 'Wǒmen děi gǎibiàn yíxià jìhuà.', 'We have to change the plan a bit.', 0),
    _E('他想改变自己的生活习惯。', 'Tā xiǎng gǎibiàn zìjǐ de shēnghuó xíguàn.', 'He wants to change his habits.', 0),
    _E('这几年我的家乡变化很大。', 'Zhè jǐ nián wǒ de jiāxiāng biànhuà hěn dà.',
        'My home town has changed a lot in the last few years.', 1),
    _E('最近天气变化很快，要注意身体。', 'Zuìjìn tiānqì biànhuà hěn kuài, yào zhùyì shēntǐ.',
        'The weather changes quickly these days, so look after yourself.', 1),
  ]),
  SynonymPair('bangzhu-bangmang', [
    _W('帮助', 'bāngzhù', 'to help; help', 'Takes a person after it: 帮助我们. Also a noun: 你的帮助.'),
    _W('帮忙', 'bāngmáng', 'to help out, to do a favour', 'Nothing comes straight after it. To add a person, say 帮我一个忙.'),
  ], 'You can 帮助 someone, but you cannot 帮忙 someone. 帮忙 stands on its own at the end.', [
    _E('老师帮助我们解决了很多问题。', 'Lǎoshī bāngzhù wǒmen jiějué le hěn duō wèntí.',
        'The teacher helped us solve a lot of problems.', 0),
    _E('他经常帮助别人。', 'Tā jīngcháng bāngzhù biérén.', 'He often helps other people.', 0),
    _E('搬家的时候，朋友们都来帮忙了。', 'Bānjiā de shíhou, péngyoumen dōu lái bāngmáng le.',
        'When I moved house, all my friends came to help.', 1),
    _E('这件事我一个人做不完，你能来帮忙吗？', 'Zhè jiàn shì wǒ yí ge rén zuò bu wán, nǐ néng lái bāngmáng ma?',
        'I cannot finish this on my own. Can you come and help?', 1),
  ]),
  SynonymPair('youdianr-yidianr', [
    _W('有点儿', 'yǒudiǎnr', 'a bit (too)', 'Before an adjective, usually something you do not like: 有点儿贵.'),
    _W('一点儿', 'yìdiǎnr', 'a little', 'After an adjective when you compare (便宜一点儿), or before a noun (一点儿水).'),
  ], '有点儿 comes before the adjective and sounds like a complaint. 一点儿 comes after it, or before a noun.', [
    _E('今天有点儿冷，多穿件衣服吧。', 'Jīntiān yǒudiǎnr lěng, duō chuān jiàn yīfu ba.',
        'It is a bit cold today, put on another layer.', 0),
    _E('我有点儿累，想休息一下。', 'Wǒ yǒudiǎnr lèi, xiǎng xiūxi yíxià.', 'I am a bit tired and want a rest.', 0),
    _E('请你说得慢一点儿。', 'Qǐng nǐ shuō de màn yìdiǎnr.', 'Please speak a little more slowly.', 1),
    _E('我想喝一点儿水。', 'Wǒ xiǎng hē yìdiǎnr shuǐ.', 'I would like to drink a little water.', 1),
  ]),
  SynonymPair('yijing-cengjing', [
    _W('已经', 'yǐjīng', 'already', 'Something has happened and is true now.'),
    _W('曾经', 'céngjīng', 'once, at one time', 'Something was true in the past and is over now.'),
  ], '已经 looks at now: it has happened. 曾经 looks back: it was so once, but not any more.', [
    _E('电影已经开始了，快进去吧。', 'Diànyǐng yǐjīng kāishǐ le, kuài jìnqu ba.',
        'The film has already started, let\'s go in quickly.', 0),
    _E('他已经三十岁了，还没结婚。', 'Tā yǐjīng sānshí suì le, hái méi jiéhūn.',
        'He is already thirty and not married yet.', 0),
    _E('他曾经是一名医生，后来当了作家。', 'Tā céngjīng shì yì míng yīshēng, hòulái dāng le zuòjiā.',
        'He was once a doctor, and later became a writer.', 1),
    _E('这里曾经是一个小村子，现在变成了大城市。', 'Zhèlǐ céngjīng shì yí ge xiǎo cūnzi, xiànzài biàn chéng le dà chéngshì.',
        'This was once a small village. Now it has become a big city.', 1),
  ]),
  SynonymPair('guanxin-danxin', [
    _W('关心', 'guānxīn', 'to care about, to look out for', 'A warm feeling: you pay attention to someone and want them to be well.'),
    _W('担心', 'dānxīn', 'to worry', 'You are afraid something bad will happen.'),
  ], '关心 is caring, a good thing to do. 担心 is worrying, a feeling you would rather not have.', [
    _E('谢谢你的关心。', 'Xièxie nǐ de guānxīn.', 'Thank you for caring.', 0),
    _E('他是一个很会关心别人的人。', 'Tā shì yí ge hěn huì guānxīn biérén de rén.',
        'He is someone who really looks out for others.', 0),
    _E('别担心，我能照顾好自己。', 'Bié dānxīn, wǒ néng zhàogù hǎo zìjǐ.', 'Don\'t worry, I can look after myself.', 1),
    _E('天这么晚了，孩子还没回家，妈妈很担心。', 'Tiān zhème wǎn le, háizi hái méi huí jiā, māma hěn dānxīn.',
        'It is so late and the child is not home yet. Mum is very worried.', 1),
  ]),
  SynonymPair('jingyan-jingli', [
    _W('经验', 'jīngyàn', 'experience (know-how)', 'What you have learned by doing something: 工作经验.'),
    _W('经历', 'jīnglì', 'an experience; to go through', 'Something that happened to you: 一次难忘的经历.'),
  ], '经验 is the skill you gain. 经历 is the event you lived through. You can have ten years of 经验, but one 经历.', [
    _E('他有十年的工作经验。', 'Tā yǒu shí nián de gōngzuò jīngyàn.', 'He has ten years of work experience.', 0),
    _E('你有照顾孩子的经验吗？', 'Nǐ yǒu zhàogù háizi de jīngyàn ma?', 'Do you have experience looking after children?', 0),
    _E('那次旅行是我最难忘的经历。', 'Nà cì lǚxíng shì wǒ zuì nánwàng de jīnglì.', 'That trip was my most unforgettable experience.', 1),
    _E('他经历了很多困难，终于成功了。', 'Tā jīnglì le hěn duō kùnnan, zhōngyú chénggōng le.',
        'He went through many difficulties and finally succeeded.', 1),
  ]),
  SynonymPair('shihe-heshi', [
    _W('适合', 'shìhé', 'to suit', 'A verb: something comes after it. 适合你.'),
    _W('合适', 'héshì', 'suitable, right', 'An adjective: nothing comes after it. 很合适.'),
  ], '适合 needs an object (适合你). 合适 ends the sentence (很合适). Remember: 合适 is like "fitting", 适合 is "fits someone".', [
    _E('这件衣服很适合你。', 'Zhè jiàn yīfu hěn shìhé nǐ.', 'This piece of clothing really suits you.', 0),
    _E('这个工作不适合我。', 'Zhège gōngzuò bú shìhé wǒ.', 'This job does not suit me.', 0),
    _E('这双鞋大小正合适。', 'Zhè shuāng xié dàxiǎo zhèng héshì.', 'This pair of shoes is just the right size.', 1),
    _E('我觉得他做经理不太合适。', 'Wǒ juéde tā zuò jīnglǐ bú tài héshì.', 'I don\'t think he is right for the manager job.', 1),
  ]),
  SynonymPair('canjia-canguan', [
    _W('参加', 'cānjiā', 'to take part in', 'An activity or event: 参加比赛, 参加会议.'),
    _W('参观', 'cānguān', 'to visit and look round', 'A place: 参观博物馆, 参观学校.'),
  ], 'You 参加 things you do with others. You 参观 places you go to see.', [
    _E('我明天要参加一个会议。', 'Wǒ míngtiān yào cānjiā yí ge huìyì.', 'Tomorrow I have a meeting to go to.', 0),
    _E('你参加过汉语比赛吗？', 'Nǐ cānjiā guo Hànyǔ bǐsài ma?', 'Have you ever taken part in a Chinese contest?', 0),
    _E('我们下午去参观博物馆。', 'Wǒmen xiàwǔ qù cānguān bówùguǎn.', 'This afternoon we are going to visit a museum.', 1),
    _E('欢迎大家来我们学校参观。', 'Huānyíng dàjiā lái wǒmen xuéxiào cānguān.', 'Everyone is welcome to come and visit our school.', 1),
  ]),
  SynonymPair('faxian-faming', [
    _W('发现', 'fāxiàn', 'to discover, to notice', 'You find something that was already there.'),
    _W('发明', 'fāmíng', 'to invent', 'You make something new that did not exist.'),
  ], 'You 发现 what already exists, like a lost wallet. You 发明 something new, like paper.', [
    _E('我发现钱包不见了。', 'Wǒ fāxiàn qiánbāo bú jiàn le.', 'I noticed my wallet was gone.', 0),
    _E('医生发现他的病不太严重。', 'Yīshēng fāxiàn tā de bìng bú tài yánzhòng.', 'The doctor found that his illness was not serious.', 0),
    _E('纸是中国人发明的。', 'Zhǐ shì Zhōngguórén fāmíng de.', 'Paper was invented by the Chinese.', 1),
    _E('电话是谁发明的？', 'Diànhuà shì shéi fāmíng de?', 'Who invented the telephone?', 1),
  ]),
  SynonymPair('anjing-pingjing', [
    _W('安静', 'ānjìng', 'quiet', 'No noise: a place, or people who stop talking.'),
    _W('平静', 'píngjìng', 'calm', 'Not upset or disturbed: your feelings, or the sea.'),
  ], '安静 is about sound. 平静 is about feelings, or water with no waves.', [
    _E('图书馆里很安静。', 'Túshūguǎn lǐ hěn ānjìng.', 'It is very quiet in the library.', 0),
    _E('请大家安静一下。', 'Qǐng dàjiā ānjìng yíxià.', 'Quiet please, everyone.', 0),
    _E('听到这个消息，他的心情很难平静。', 'Tīng dào zhège xiāoxi, tā de xīnqíng hěn nán píngjìng.',
        'After hearing the news, he found it hard to calm down.', 1),
    _E('今天没有风，海面很平静。', 'Jīntiān méiyǒu fēng, hǎimiàn hěn píngjìng.', 'There is no wind today and the sea is calm.', 1),
  ]),
  SynonymPair('haipa-kongpa', [
    _W('害怕', 'hàipà', 'to be afraid of', 'Real fear: dogs, the dark, an exam.'),
    _W('恐怕', 'kǒngpà', 'I\'m afraid that…, probably', 'A polite guess that something is so. There is no fear in it.'),
  ], '害怕 is being scared. 恐怕 is like English "I\'m afraid…": a soft way to say "probably".', [
    _E('我妹妹很害怕狗。', 'Wǒ mèimei hěn hàipà gǒu.', 'My little sister is very afraid of dogs.', 0),
    _E('别害怕，这只狗不咬人。', 'Bié hàipà, zhè zhī gǒu bù yǎo rén.', 'Don\'t be scared, this dog doesn\'t bite.', 0),
    _E('已经八点了，恐怕他不会来了。', 'Yǐjīng bā diǎn le, kǒngpà tā bú huì lái le.',
        'It\'s already eight. I\'m afraid he isn\'t coming.', 1),
    _E('这么多作业，恐怕今天做不完。', 'Zhème duō zuòyè, kǒngpà jīntiān zuò bu wán.',
        'So much homework, I probably can\'t finish it today.', 1),
  ]),
  SynonymPair('wancheng-jieshu', [
    _W('完成', 'wánchéng', 'to complete', 'You finish a task you were doing: 完成作业, 完成计划.'),
    _W('结束', 'jiéshù', 'to end, to be over', 'An event or a time comes to an end: 会议结束了.'),
  ], 'People 完成 work. Events 结束. Homework is 完成, a film is 结束.', [
    _E('我已经完成了今天的作业。', 'Wǒ yǐjīng wánchéng le jīntiān de zuòyè.', 'I have already finished today\'s homework.', 0),
    _E('这个任务很难，但是我们按时完成了。', 'Zhège rènwu hěn nán, dànshì wǒmen ànshí wánchéng le.',
        'The task was hard, but we finished it on time.', 0),
    _E('会议几点结束？', 'Huìyì jǐ diǎn jiéshù?', 'What time does the meeting end?', 1),
    _E('比赛结束以后，我们一起去吃饭吧。', 'Bǐsài jiéshù yǐhòu, wǒmen yìqǐ qù chī fàn ba.',
        'After the match, let\'s go and eat together.', 1),
  ]),
  SynonymPair('gang-gangcai', [
    _W('刚', 'gāng', 'just', 'An adverb after the subject: 我刚来. It can take a length of time: 刚来三天.'),
    _W('刚才', 'gāngcái', 'a moment ago', 'A time word: it can go before the subject, or after 比: 比刚才好.'),
  ], '刚才 is a point in time a few minutes ago. 刚 means "only just", and can cover days: 我刚来三天.', [
    _E('我刚来北京三天。', 'Wǒ gāng lái Běijīng sān tiān.', 'I only came to Beijing three days ago.', 0),
    _E('他刚到家，电话就响了。', 'Tā gāng dào jiā, diànhuà jiù xiǎng le.', 'He had only just got home when the phone rang.', 0),
    _E('刚才你去哪儿了？', 'Gāngcái nǐ qù nǎr le?', 'Where did you go just now?', 1),
    _E('他比刚才好多了。', 'Tā bǐ gāngcái hǎo duō le.', 'He is much better than a moment ago.', 1),
  ]),
  SynonymPair('jixu-lianxu', [
    _W('继续', 'jìxù', 'to carry on', 'You go on doing something, maybe after a break.'),
    _W('连续', 'liánxù', 'in a row', 'One after another without a break, usually with a number: 连续三天.'),
  ], '继续 is "keep going". 连续 counts how many times in a row.', [
    _E('休息一下，我们再继续。', 'Xiūxi yíxià, wǒmen zài jìxù.', 'Let\'s take a break, then carry on.', 0),
    _E('他毕业以后想继续学习。', 'Tā bìyè yǐhòu xiǎng jìxù xuéxí.', 'After graduating he wants to go on studying.', 0),
    _E('已经连续下了三天雨了。', 'Yǐjīng liánxù xià le sān tiān yǔ le.', 'It has rained three days in a row.', 1),
    _E('他连续工作了十个小时，太累了。', 'Tā liánxù gōngzuò le shí ge xiǎoshí, tài lèi le.',
        'He worked ten hours straight and is exhausted.', 1),
  ]),
  SynonymPair('liaojie-lijie', [
    _W('了解', 'liǎojiě', 'to know about, to be familiar with', 'Facts, a person, a place: you know what it is like.'),
    _W('理解', 'lǐjiě', 'to understand (why)', 'Feelings and reasons: you can see why someone feels or acts that way.'),
  ], '了解 is knowing the facts. 理解 is understanding the feelings or reasons behind them.', [
    _E('我很了解这个城市。', 'Wǒ hěn liǎojiě zhège chéngshì.', 'I know this city well.', 0),
    _E('你想了解中国文化吗？', 'Nǐ xiǎng liǎojiě Zhōngguó wénhuà ma?', 'Would you like to learn about Chinese culture?', 0),
    _E('我理解你的心情。', 'Wǒ lǐjiě nǐ de xīnqíng.', 'I understand how you feel.', 1),
    _E('他为什么这么做，我真不能理解。', 'Tā wèishénme zhème zuò, wǒ zhēn bù néng lǐjiě.',
        'I really cannot understand why he did that.', 1),
  ]),
  SynonymPair('putong-pubian', [
    _W('普通', 'pǔtōng', 'ordinary', 'Nothing special: 普通人, 普通的衣服.'),
    _W('普遍', 'pǔbiàn', 'widespread, common', 'Found everywhere, done by many people: 很普遍.'),
  ], '普通 describes one thing: it is ordinary. 普遍 describes how widely something has spread.', [
    _E('我只是一个普通的学生。', 'Wǒ zhǐshì yí ge pǔtōng de xuésheng.', 'I am just an ordinary student.', 0),
    _E('这是一件很普通的衣服。', 'Zhè shì yí jiàn hěn pǔtōng de yīfu.', 'This is a very ordinary piece of clothing.', 0),
    _E('现在用手机付钱已经很普遍了。', 'Xiànzài yòng shǒujī fù qián yǐjīng hěn pǔbiàn le.',
        'Paying by phone is very common now.', 1),
    _E('这种情况在大城市很普遍。', 'Zhè zhǒng qíngkuàng zài dà chéngshì hěn pǔbiàn.', 'This is very common in big cities.', 1),
  ]),
  SynonymPair('suiran-jishi', [
    _W('虽然', 'suīrán', 'although', 'It IS true. Goes with 但是 or 可是.'),
    _W('即使', 'jíshǐ', 'even if', 'It may or may not be true. Goes with 也.'),
  ], '虽然 + 但是: it is so, but… 即使 + 也: even if it were so, still…', [
    _E('虽然他很累，但是还在工作。', 'Suīrán tā hěn lèi, dànshì hái zài gōngzuò.', 'Although he is tired, he is still working.', 0),
    _E('虽然这个问题很难，可是他还是做出来了。', 'Suīrán zhège wèntí hěn nán, kěshì tā háishi zuò chūlai le.',
        'Although the problem was hard, he still solved it.', 0),
    _E('即使明天下雪，我也要去。', 'Jíshǐ míngtiān xià xuě, wǒ yě yào qù.', 'Even if it snows tomorrow, I am going.', 1),
    _E('即使你不同意，我也会这样做。', 'Jíshǐ nǐ bù tóngyì, wǒ yě huì zhèyàng zuò.',
        'Even if you don\'t agree, I will do it this way.', 1),
  ]),
  SynonymPair('zhunshi-jishi', [
    _W('准时', 'zhǔnshí', 'on time, punctual', 'At exactly the set time: 准时开始, 准时上班.'),
    _W('及时', 'jíshí', 'in time, promptly', 'Quickly, before it is too late: 及时解决.'),
  ], '准时 is about the clock: not late. 及时 is about acting quickly enough to help.', [
    _E('明天的会议八点准时开始。', 'Míngtiān de huìyì bā diǎn zhǔnshí kāishǐ.', 'Tomorrow\'s meeting starts at eight sharp.', 0),
    _E('他每天都准时上班。', 'Tā měi tiān dōu zhǔnshí shàngbān.', 'He gets to work on time every day.', 0),
    _E('幸亏你及时提醒我，不然我就忘了。', 'Xìngkuī nǐ jíshí tíxǐng wǒ, bùrán wǒ jiù wàng le.',
        'Luckily you reminded me in time, or I would have forgotten.', 1),
    _E('有问题要及时解决。', 'Yǒu wèntí yào jíshí jiějué.', 'Problems should be dealt with promptly.', 1),
  ]),
  SynonymPair('renshi-shuxi', [
    _W('认识', 'rènshi', 'to know (a person), to meet', 'You have met someone, or can recognise something.'),
    _W('熟悉', 'shúxī', 'to be familiar with', 'You know something well because you have spent a lot of time with it.'),
  ], '认识 is "we have met". 熟悉 is "I know it well", for places, work, songs or people.', [
    _E('我们是在大学认识的。', 'Wǒmen shì zài dàxué rènshi de.', 'We met at university.', 0),
    _E('很高兴认识你。', 'Hěn gāoxìng rènshi nǐ.', 'Nice to meet you.', 0),
    _E('我刚来，对这里还不太熟悉。', 'Wǒ gāng lái, duì zhèlǐ hái bú tài shúxī.',
        'I have only just arrived and don\'t know this place well yet.', 1),
    _E('这首歌我听过很多次，非常熟悉。', 'Zhè shǒu gē wǒ tīng guo hěn duō cì, fēicháng shúxī.',
        'I have heard this song many times. I know it very well.', 1),
  ]),
  SynonymPair('haishi-huozhe', [
    _W('还是', 'háishi', 'or (in a question)', 'You ask someone to choose: 茶还是咖啡？'),
    _W('或者', 'huòzhě', 'or (in a statement)', 'You say either one is possible: 周六或者周日.'),
  ], 'Question with a choice: 还是. Statement where either is fine: 或者.', [
    _E('你喝茶还是喝咖啡？', 'Nǐ hē chá háishi hē kāfēi?', 'Will you have tea or coffee?', 0),
    _E('你今天去还是明天去？', 'Nǐ jīntiān qù háishi míngtiān qù?', 'Are you going today or tomorrow?', 0),
    _E('我们周六或者周日去都可以。', 'Wǒmen zhōuliù huòzhě zhōurì qù dōu kěyǐ.', 'We can go on Saturday or Sunday.', 1),
    _E('你可以坐地铁或者坐公共汽车去。', 'Nǐ kěyǐ zuò dìtiě huòzhě zuò gōnggòng qìchē qù.', 'You can take the underground or the bus.', 1),
  ]),
  SynonymPair('biaoshi-biaoda', [
    _W('表示', 'biǎoshì', 'to show, to express; to mean', 'Showing an attitude (thanks, agreement), or what a sign means.'),
    _W('表达', 'biǎodá', 'to put into words', 'Getting your thoughts or feelings across, in speech or writing.'),
  ], '表示 shows a reaction or a meaning. 表达 is about how well you put thoughts into words.', [
    _E('他点了点头，表示同意。', 'Tā diǎn le diǎn tóu, biǎoshì tóngyì.', 'He nodded to show he agreed.', 0),
    _E('红色在中国表示快乐和幸福。', 'Hóngsè zài Zhōngguó biǎoshì kuàilè hé xìngfú.', 'In China red stands for joy and happiness.', 0),
    _E('他不太会用汉语表达自己的想法。', 'Tā bú tài huì yòng Hànyǔ biǎodá zìjǐ de xiǎngfǎ.',
        'He is not very good at putting his ideas into Chinese.', 1),
    _E('这种感觉很难用语言表达。', 'Zhè zhǒng gǎnjué hěn nán yòng yǔyán biǎodá.', 'This feeling is hard to put into words.', 1),
  ]),
  SynonymPair('gandong-jidong', [
    _W('感动', 'gǎndòng', 'moved, touched', 'By kindness or a sad or beautiful story. It can take an object: 感动了很多人.'),
    _W('激动', 'jīdòng', 'excited, worked up', 'Strong feelings that make you shake or shout, happy or angry.'),
  ], '感动 is a warm feeling in the heart, often with tears. 激动 is a strong rush of feeling, often loud.', [
    _E('她的故事感动了很多人。', 'Tā de gùshi gǎndòng le hěn duō rén.', 'Her story moved a lot of people.', 0),
    _E('谢谢你为我做的一切，我真的很感动。', 'Xièxie nǐ wèi wǒ zuò de yíqiè, wǒ zhēn de hěn gǎndòng.',
        'Thank you for everything you did for me. I am truly touched.', 0),
    _E('别激动，有话慢慢说。', 'Bié jīdòng, yǒu huà mànmàn shuō.', 'Calm down, say it slowly.', 1),
    _E('听说自己考上了大学，他激动得跳了起来。', 'Tīngshuō zìjǐ kǎo shàng le dàxué, tā jīdòng de tiào le qǐlai.',
        'When he heard he had got into university, he jumped up with excitement.', 1),
  ]),
  SynonymPair('tigao-zengjia', [
    _W('提高', 'tígāo', 'to raise, to improve', 'A level or quality goes up: 提高水平.'),
    _W('增加', 'zēngjiā', 'to increase', 'A number or amount grows: 人数增加了.'),
  ], '提高 is for how good something is. 增加 is for how many or how much there is.', [
    _E('我想提高自己的汉语水平。', 'Wǒ xiǎng tígāo zìjǐ de Hànyǔ shuǐpíng.', 'I want to improve my Chinese.', 0),
    _E('他们的服务质量提高了很多。', 'Tāmen de fúwù zhìliàng tígāo le hěn duō.', 'Their service has got a lot better.', 0),
    _E('今年学汉语的人增加了一倍。', 'Jīnnián xué Hànyǔ de rén zēngjiā le yí bèi.',
        'This year the number of people learning Chinese doubled.', 1),
    _E('我们班又增加了两个新同学。', 'Wǒmen bān yòu zēngjiā le liǎng ge xīn tóngxué.', 'Our class has two more new students.', 1),
  ]),
  SynonymPair('bixu-biyao', [
    _W('必须', 'bìxū', 'must', 'An adverb before a verb: 你必须来.'),
    _W('必要', 'bìyào', 'necessary', 'An adjective or noun, often in 没有必要 ("there is no need").'),
  ], '必须 + verb: you must do it. 没有必要: there is no need to.', [
    _E('明天你必须早点儿来。', 'Míngtiān nǐ bìxū zǎo diǎnr lái.', 'Tomorrow you must come a bit early.', 0),
    _E('进门以前必须先换鞋。', 'Jìn mén yǐqián bìxū xiān huàn xié.', 'You must change your shoes before coming in.', 0),
    _E('这个会没有必要开。', 'Zhège huì méiyǒu bìyào kāi.', 'There is no need to hold this meeting.', 1),
    _E('你没有必要这么紧张。', 'Nǐ méiyǒu bìyào zhème jǐnzhāng.', 'There is no need to be so nervous.', 1),
  ]),
  SynonymPair('yuanyin-liyou', [
    _W('原因', 'yuányīn', 'cause, reason', 'Why something happened.'),
    _W('理由', 'lǐyóu', 'reason, excuse', 'What a person says to explain or defend what they do.'),
  ], '原因 is what caused something. 理由 is the reason someone gives for their actions.', [
    _E('天气变冷是他感冒的主要原因。', 'Tiānqì biàn lěng shì tā gǎnmào de zhǔyào yuányīn.',
        'The cold weather is the main reason he caught a cold.', 0),
    _E('这次失败的原因是什么？', 'Zhè cì shībài de yuányīn shì shénme?', 'What caused this failure?', 0),
    _E('你有什么理由不来上课？', 'Nǐ yǒu shénme lǐyóu bù lái shàngkè?', 'What reason do you have for not coming to class?', 1),
    _E('他找了个理由，提前离开了。', 'Tā zhǎo le ge lǐyóu, tíqián líkāi le.', 'He found an excuse and left early.', 1),
  ]),
  SynonymPair('guoran-jingran', [
    _W('果然', 'guǒrán', 'just as expected', 'What you thought would happen did happen.'),
    _W('竟然', 'jìngrán', 'to my surprise', 'Something happened that you did not expect at all.'),
  ], '果然: "I knew it!" 竟然: "I can\'t believe it!"', [
    _E('天气预报说今天下雨，果然下雨了。', 'Tiānqì yùbào shuō jīntiān xià yǔ, guǒrán xià yǔ le.',
        'The forecast said it would rain today, and sure enough it rained.', 0),
    _E('大家都说这家店的菜好吃，我尝了尝，果然不错。', 'Dàjiā dōu shuō zhè jiā diàn de cài hǎochī, wǒ cháng le cháng, guǒrán búcuò.',
        'Everyone said the food here was good. I tried it, and it really was.', 0),
    _E('这么简单的题，他竟然做错了。', 'Zhème jiǎndān de tí, tā jìngrán zuò cuò le.', 'Such an easy question, and he got it wrong!', 1),
    _E('我没想到他竟然是我的老同学。', 'Wǒ méi xiǎngdào tā jìngrán shì wǒ de lǎo tóngxué.',
        'I never imagined he would turn out to be my old classmate.', 1),
  ]),
];

SynonymPair? synonymPairById(String id) {
  for (final p in synonymPairs) {
    if (p.id == id) return p;
  }
  return null;
}
