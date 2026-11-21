// Questions for the mini exams, written in the style of the real HSK 1 to 4 tests
// (listening and reading, with pictures, answers to choose and gaps to fill; HSK 3
// and 4 also have a writing part). Everything here is original.

/// A word with a picture, for "does the picture match?" questions.
class PictureWord {
  final String hanzi;
  final String picture; // an emoji
  const PictureWord(this.hanzi, this.picture);
}

/// A sentence that goes with one picture.
class PictureSentence {
  final String zh;
  final String pinyin;
  final String picture;
  const PictureSentence(this.zh, this.pinyin, this.picture);
}

/// A question with the right reply first, then two wrong replies.
class ExamQA {
  final String q;
  final String qPinyin;
  final List<(String, String)> replies; // (Chinese, pinyin); the first is right
  const ExamQA(this.q, this.qPinyin, this.replies);
}

/// A sentence with a gap; the first option is the word that fits.
class ExamGap {
  final String zh; // the gap is written （  ）
  final String pinyin; // the gap is written (  )
  final List<String> options; // course words; the first is right
  const ExamGap(this.zh, this.pinyin, this.options);
}

const examPictureWords = <PictureWord>[
  PictureWord('苹果', '🍎'),
  PictureWord('猫', '🐱'),
  PictureWord('狗', '🐶'),
  PictureWord('飞机', '✈️'),
  PictureWord('出租车', '🚕'),
  PictureWord('茶', '🍵'),
  PictureWord('米饭', '🍚'),
  PictureWord('书', '📖'),
  PictureWord('电脑', '💻'),
  PictureWord('电视', '📺'),
  PictureWord('杯子', '🥤'),
  PictureWord('衣服', '👕'),
  PictureWord('椅子', '🪑'),
  PictureWord('医院', '🏥'),
  PictureWord('学校', '🏫'),
  PictureWord('下雨', '🌧️'),
  PictureWord('水', '💧'),
  PictureWord('电影', '🎬'),
  PictureWord('打电话', '📞'),
  PictureWord('睡觉', '😴'),
  PictureWord('钱', '💰'),
  PictureWord('商店', '🏪'),
  PictureWord('热', '🥵'),
  PictureWord('冷', '🥶'),
  PictureWord('水果', '🍇'),
  PictureWord('儿子', '👦'),
  PictureWord('女儿', '👧'),
  PictureWord('妈妈', '👩'),
  PictureWord('爸爸', '👨'),
];

const examPictureSentences = <PictureSentence>[
  PictureSentence('我想喝茶。', 'Wǒ xiǎng hē chá.', '🍵'),
  PictureSentence('她在看书。', 'Tā zài kàn shū.', '📖'),
  PictureSentence('我的猫很漂亮。', 'Wǒ de māo hěn piàoliang.', '🐱'),
  PictureSentence('今天下雨了。', 'Jīntiān xià yǔ le.', '🌧️'),
  PictureSentence('我坐飞机去北京。', 'Wǒ zuò fēijī qù Běijīng.', '✈️'),
  PictureSentence('他在打电话。', 'Tā zài dǎ diànhuà.', '📞'),
  PictureSentence('我想去看电影。', 'Wǒ xiǎng qù kàn diànyǐng.', '🎬'),
  PictureSentence('我爱吃苹果。', 'Wǒ ài chī píngguǒ.', '🍎'),
  PictureSentence('我女儿五岁了。', 'Wǒ nǚ\'ér wǔ suì le.', '👧'),
  PictureSentence('儿子在睡觉。', 'Érzi zài shuìjiào.', '😴'),
  PictureSentence('我想买一些衣服。', 'Wǒ xiǎng mǎi yìxiē yīfu.', '👕'),
  PictureSentence('这个椅子很小。', 'Zhège yǐzi hěn xiǎo.', '🪑'),
  PictureSentence('我爸爸在医院工作。', 'Wǒ bàba zài yīyuàn gōngzuò.', '🏥'),
  PictureSentence('我们坐出租车回家。', 'Wǒmen zuò chūzūchē huí jiā.', '🚕'),
  PictureSentence('今天太热了！', 'Jīntiān tài rè le!', '🥵'),
  PictureSentence('这是我的电脑。', 'Zhè shì wǒ de diànnǎo.', '💻'),
  PictureSentence('我很喜欢我的狗。', 'Wǒ hěn xǐhuan wǒ de gǒu.', '🐶'),
  PictureSentence('你喝水吗？', 'Nǐ hē shuǐ ma?', '💧'),
];

const examQAs = <ExamQA>[
  ExamQA('你叫什么名字？', 'Nǐ jiào shénme míngzi?', [
    ('我叫王方。', 'Wǒ jiào Wáng Fāng.'),
    ('我很好。', 'Wǒ hěn hǎo.'),
    ('我是学生。', 'Wǒ shì xuésheng.'),
  ]),
  ExamQA('你几岁了？', 'Nǐ jǐ suì le?', [
    ('我七岁。', 'Wǒ qī suì.'),
    ('我是医生。', 'Wǒ shì yīshēng.'),
    ('我在家。', 'Wǒ zài jiā.'),
  ]),
  ExamQA('这个多少钱？', 'Zhège duōshao qián?', [
    ('十五块。', 'Shíwǔ kuài.'),
    ('很漂亮。', 'Hěn piàoliang.'),
    ('在商店。', 'Zài shāngdiàn.'),
  ]),
  ExamQA('你在哪儿工作？', 'Nǐ zài nǎr gōngzuò?', [
    ('在医院。', 'Zài yīyuàn.'),
    ('昨天。', 'Zuótiān.'),
    ('我爱工作。', 'Wǒ ài gōngzuò.'),
  ]),
  ExamQA('现在几点？', 'Xiànzài jǐ diǎn?', [
    ('三点十分。', 'Sān diǎn shí fēn.'),
    ('星期三。', 'Xīngqīsān.'),
    ('三月。', 'Sān yuè.'),
  ]),
  ExamQA('今天天气怎么样？', 'Jīntiān tiānqì zěnmeyàng?', [
    ('很冷。', 'Hěn lěng.'),
    ('我不去。', 'Wǒ bú qù.'),
    ('是我的。', 'Shì wǒ de.'),
  ]),
  ExamQA('你想喝什么？', 'Nǐ xiǎng hē shénme?', [
    ('我想喝茶。', 'Wǒ xiǎng hē chá.'),
    ('我想去北京。', 'Wǒ xiǎng qù Běijīng.'),
    ('我叫李明。', 'Wǒ jiào Lǐ Míng.'),
  ]),
  ExamQA('他是谁？', 'Tā shì shéi?', [
    ('他是我爸爸。', 'Tā shì wǒ bàba.'),
    ('他在学校。', 'Tā zài xuéxiào.'),
    ('他很好。', 'Tā hěn hǎo.'),
  ]),
  ExamQA('你什么时候回家？', 'Nǐ shénme shíhou huí jiā?', [
    ('明天下午。', 'Míngtiān xiàwǔ.'),
    ('坐出租车。', 'Zuò chūzūchē.'),
    ('我家很大。', 'Wǒ jiā hěn dà.'),
  ]),
  ExamQA('你会说汉语吗？', 'Nǐ huì shuō Hànyǔ ma?', [
    ('会一点儿。', 'Huì yìdiǎnr.'),
    ('我是老师。', 'Wǒ shì lǎoshī.'),
    ('不客气。', 'Bú kèqi.'),
  ]),
  ExamQA('你家有几个人？', 'Nǐ jiā yǒu jǐ ge rén?', [
    ('四个。', 'Sì ge.'),
    ('在北京。', 'Zài Běijīng.'),
    ('我爱我家。', 'Wǒ ài wǒ jiā.'),
  ]),
  ExamQA('谢谢你！', 'Xièxie nǐ!', [
    ('不客气。', 'Bú kèqi.'),
    ('对不起。', 'Duìbuqǐ.'),
    ('没有。', 'Méiyǒu.'),
  ]),
  ExamQA('对不起！', 'Duìbuqǐ!', [
    ('没关系。', 'Méi guānxi.'),
    ('谢谢。', 'Xièxie.'),
    ('是的。', 'Shì de.'),
  ]),
  ExamQA('你喜欢什么水果？', 'Nǐ xǐhuan shénme shuǐguǒ?', [
    ('苹果。', 'Píngguǒ.'),
    ('星期天。', 'Xīngqītiān.'),
    ('我女儿。', 'Wǒ nǚ\'ér.'),
  ]),
  ExamQA('你怎么去学校？', 'Nǐ zěnme qù xuéxiào?', [
    ('坐出租车。', 'Zuò chūzūchē.'),
    ('在前面。', 'Zài qiánmiàn.'),
    ('很多人。', 'Hěn duō rén.'),
  ]),
  ExamQA('你的书在哪儿？', 'Nǐ de shū zài nǎr?', [
    ('在桌子上。', 'Zài zhuōzi shang.'),
    ('是中国的。', 'Shì Zhōngguó de.'),
    ('有三本。', 'Yǒu sān běn.'),
  ]),
  ExamQA('你明天去商店吗？', 'Nǐ míngtiān qù shāngdiàn ma?', [
    ('不去，我想在家睡觉。', 'Bú qù, wǒ xiǎng zài jiā shuìjiào.'),
    ('十块钱。', 'Shí kuài qián.'),
    ('是我的书。', 'Shì wǒ de shū.'),
  ]),
  ExamQA('你认识她吗？', 'Nǐ rènshi tā ma?', [
    ('认识，她是我同学。', 'Rènshi, tā shì wǒ tóngxué.'),
    ('她八岁。', 'Tā bā suì.'),
    ('我想去。', 'Wǒ xiǎng qù.'),
  ]),
];

const examGaps = <ExamGap>[
  ExamGap('我（  ）中国人。', 'Wǒ (  ) Zhōngguó rén.', ['是', '在', '有']),
  ExamGap('这（  ）书是我的。', 'Zhè (  ) shū shì wǒ de.', ['本', '块', '岁']),
  ExamGap('我家（  ）三个人。', 'Wǒ jiā (  ) sān ge rén.', ['有', '叫', '会']),
  ExamGap('她（  ）王丽。', 'Tā (  ) Wáng Lì.', ['叫', '有', '去']),
  ExamGap('你叫什么（  ）？', 'Nǐ jiào shénme (  )?', ['名字', '天气', '时候']),
  ExamGap('我（  ）喝茶。', 'Wǒ (  ) hē chá.', ['想', '太', '很']),
  ExamGap('你好（  ）？', 'Nǐ hǎo (  )?', ['吗', '的', '个']),
  ExamGap('我（  ）说汉语。', 'Wǒ (  ) shuō Hànyǔ.', ['会', '岁', '个']),
  ExamGap('今天（  ）冷。', 'Jīntiān (  ) lěng.', ['很', '有', '去']),
  ExamGap('现在下午三（  ）。', 'Xiànzài xiàwǔ sān (  ).', ['点', '岁', '本']),
  ExamGap('我爸爸（  ）北京工作。', 'Wǒ bàba (  ) Běijīng gōngzuò.', ['在', '和', '吗']),
  ExamGap('这些衣服（  ）漂亮了！', 'Zhèxiē yīfu (  ) piàoliang le!', ['太', '几', '谁']),
  ExamGap('你家在（  ）？', 'Nǐ jiā zài (  )?', ['哪儿', '什么', '几']),
  ExamGap('我们（  ）出租车去医院。', 'Wǒmen (  ) chūzūchē qù yīyuàn.', ['坐', '喝', '叫']),
  ExamGap('他是我的（  ）。', 'Tā shì wǒ de (  ).', ['朋友', '苹果', '天气']),
  ExamGap('我不（  ）他。', 'Wǒ bú (  ) tā.', ['认识', '漂亮', '多少']),
];

// ---------------- HSK 2 ----------------

const examPictureWords2 = <PictureWord>[
  PictureWord('咖啡', '☕'),
  PictureWord('牛奶', '🥛'),
  PictureWord('鸡蛋', '🥚'),
  PictureWord('鱼', '🐟'),
  PictureWord('西瓜', '🍉'),
  PictureWord('面条', '🍜'),
  PictureWord('跑步', '🏃'),
  PictureWord('游泳', '🏊'),
  PictureWord('打篮球', '🏀'),
  PictureWord('踢足球', '⚽'),
  PictureWord('唱歌', '🎤'),
  PictureWord('跳舞', '💃'),
  PictureWord('手机', '📱'),
  PictureWord('手表', '⌚'),
  PictureWord('雪', '❄️'),
  PictureWord('药', '💊'),
  PictureWord('公共汽车', '🚌'),
  PictureWord('门', '🚪'),
  PictureWord('铅笔', '✏️'),
  PictureWord('报纸', '📰'),
  PictureWord('眼睛', '👀'),
  PictureWord('生日', '🎂'),
  PictureWord('票', '🎟️'),
  PictureWord('笑', '😄'),
  PictureWord('晴', '☀️'),
];

const examPictureSentences2 = <PictureSentence>[
  PictureSentence('他每天早上都去跑步。', 'Tā měi tiān zǎoshang dōu qù pǎobù.', '🏃'),
  PictureSentence('我们在机场等飞机。', 'Wǒmen zài jīchǎng děng fēijī.', '🛫'),
  PictureSentence('她唱歌唱得很好。', 'Tā chàng gē chàng de hěn hǎo.', '🎤'),
  PictureSentence('下雪了，今天很冷。', 'Xià xuě le, jīntiān hěn lěng.', '❄️'),
  PictureSentence('哥哥喜欢踢足球。', 'Gēge xǐhuan tī zúqiú.', '⚽'),
  PictureSentence('这个西瓜真大！', 'Zhège xīguā zhēn dà!', '🍉'),
  PictureSentence('你生病了，要吃药。', 'Nǐ shēngbìng le, yào chī yào.', '💊'),
  PictureSentence('今天是我的生日，我很快乐。', 'Jīntiān shì wǒ de shēngrì, wǒ hěn kuàilè.', '🎂'),
  PictureSentence('我坐公共汽车去上班。', 'Wǒ zuò gōnggòng qìchē qù shàngbān.', '🚌'),
  PictureSentence('爸爸早上看报纸。', 'Bàba zǎoshang kàn bàozhǐ.', '📰'),
  PictureSentence('我们去游泳吧！', 'Wǒmen qù yóuyǒng ba!', '🏊'),
  PictureSentence('早上我喝一杯牛奶。', 'Zǎoshang wǒ hē yì bēi niúnǎi.', '🥛'),
];

const examQAs2 = <ExamQA>[
  ExamQA('你今天怎么没去上班？', 'Nǐ jīntiān zěnme méi qù shàngbān?', [
    ('我生病了。', 'Wǒ shēngbìng le.'),
    ('我坐公共汽车。', 'Wǒ zuò gōnggòng qìchē.'),
    ('今天星期一。', 'Jīntiān xīngqīyī.'),
  ]),
  ExamQA('你喜欢什么运动？', 'Nǐ xǐhuan shénme yùndòng?', [
    ('我喜欢游泳。', 'Wǒ xǐhuan yóuyǒng.'),
    ('我不喜欢吃鱼。', 'Wǒ bù xǐhuan chī yú.'),
    ('我昨天很累。', 'Wǒ zuótiān hěn lèi.'),
  ]),
  ExamQA('机场离这儿远吗？', 'Jīchǎng lí zhèr yuǎn ma?', [
    ('不太远，坐出租车二十分钟。', 'Bú tài yuǎn, zuò chūzūchē èrshí fēnzhōng.'),
    ('我明天去机场。', 'Wǒ míngtiān qù jīchǎng.'),
    ('飞机票很贵。', 'Fēijī piào hěn guì.'),
  ]),
  ExamQA('这件衣服多少钱？', 'Zhè jiàn yīfu duōshao qián?', [
    ('三百块。', 'Sān bǎi kuài.'),
    ('是红色的。', 'Shì hóngsè de.'),
    ('我很喜欢。', 'Wǒ hěn xǐhuan.'),
  ]),
  ExamQA('你为什么学习汉语？', 'Nǐ wèishénme xuéxí Hànyǔ?', [
    ('因为我想去中国旅游。', 'Yīnwèi wǒ xiǎng qù Zhōngguó lǚyóu.'),
    ('我学习了两年。', 'Wǒ xuéxí le liǎng nián.'),
    ('汉语老师姓王。', 'Hànyǔ lǎoshī xìng Wáng.'),
  ]),
  ExamQA('你吃过羊肉吗？', 'Nǐ chī guo yángròu ma?', [
    ('吃过，非常好吃。', 'Chī guo, fēicháng hǎochī.'),
    ('羊肉在桌子上。', 'Yángròu zài zhuōzi shang.'),
    ('我在饭馆。', 'Wǒ zài fànguǎn.'),
  ]),
  ExamQA('你每天几点起床？', 'Nǐ měi tiān jǐ diǎn qǐchuáng?', [
    ('早上六点。', 'Zǎoshang liù diǎn.'),
    ('我睡了八个小时。', 'Wǒ shuì le bā ge xiǎoshí.'),
    ('我已经起床了。', 'Wǒ yǐjīng qǐchuáng le.'),
  ]),
  ExamQA('你的手机在哪儿？', 'Nǐ de shǒujī zài nǎr?', [
    ('在我的房间里。', 'Zài wǒ de fángjiān li.'),
    ('是新的。', 'Shì xīn de.'),
    ('我在打电话。', 'Wǒ zài dǎ diànhuà.'),
  ]),
  ExamQA('我们一起去唱歌，好吗？', 'Wǒmen yìqǐ qù chàng gē, hǎo ma?', [
    ('好，我们几点去？', 'Hǎo, wǒmen jǐ diǎn qù?'),
    ('她唱得很好。', 'Tā chàng de hěn hǎo.'),
    ('我有一个妹妹。', 'Wǒ yǒu yí ge mèimei.'),
  ]),
];

const examGaps2 = <ExamGap>[
  ExamGap('我（  ）北京来。', 'Wǒ (  ) Běijīng lái.', ['从', '到', '离']),
  ExamGap('学校（  ）我家很近。', 'Xuéxiào (  ) wǒ jiā hěn jìn.', ['离', '从', '往']),
  ExamGap('他跑（  ）很快。', 'Tā pǎo (  ) hěn kuài.', ['得', '的', '着']),
  ExamGap('我去（  ）中国两次。', 'Wǒ qù (  ) Zhōngguó liǎng cì.', ['过', '着', '得']),
  ExamGap('这个西瓜（  ）那个大。', 'Zhège xīguā (  ) nàge dà.', ['比', '最', '真']),
  ExamGap('（  ）下雨了，所以我没去。', '(  ) xià yǔ le, suǒyǐ wǒ méi qù.', ['因为', '虽然', '但是']),
  ExamGap('我们（  ）去吃饭吧。', 'Wǒmen (  ) qù chī fàn ba.', ['一起', '已经', '虽然']),
  ExamGap('请（  ）我一杯咖啡。', 'Qǐng (  ) wǒ yì bēi kāfēi.', ['给', '对', '比']),
];

// ---------------- HSK 3 ----------------

const examPictureWords3 = <PictureWord>[
  PictureWord('熊猫', '🐼'),
  PictureWord('香蕉', '🍌'),
  PictureWord('葡萄', '🍇'),
  PictureWord('面包', '🍞'),
  PictureWord('蛋糕', '🍰'),
  PictureWord('啤酒', '🍺'),
  PictureWord('帽子', '🧢'),
  PictureWord('裙子', '👗'),
  PictureWord('鞋', '👟'),
  PictureWord('眼镜', '👓'),
  PictureWord('伞', '☂️'),
  PictureWord('太阳', '☀️'),
  PictureWord('月亮', '🌙'),
  PictureWord('鸟', '🐦'),
  PictureWord('马', '🐴'),
  PictureWord('自行车', '🚲'),
  PictureWord('船', '🚢'),
  PictureWord('地铁', '🚇'),
  PictureWord('照相机', '📷'),
  PictureWord('礼物', '🎁'),
  PictureWord('发烧', '🤒'),
  PictureWord('生气', '😠'),
  PictureWord('哭', '😢'),
  PictureWord('地图', '🗺️'),
  PictureWord('筷子', '🥢'),
];

const examPictureSentences3 = <PictureSentence>[
  PictureSentence('这只熊猫很可爱。', 'Zhè zhī xióngmāo hěn kě\'ài.', '🐼'),
  PictureSentence('下雨了，别忘了带伞。', 'Xià yǔ le, bié wàng le dài sǎn.', '☂️'),
  PictureSentence('他骑自行车去上班。', 'Tā qí zìxíngchē qù shàngbān.', '🚲'),
  PictureSentence('妹妹哭了，她很难过。', 'Mèimei kū le, tā hěn nánguò.', '😢'),
  PictureSentence('我发烧了，不太舒服。', 'Wǒ fāshāo le, bú tài shūfu.', '🤒'),
  PictureSentence('生日那天，朋友送了我一个礼物。', 'Shēngrì nà tiān, péngyou sòng le wǒ yí ge lǐwù.', '🎁'),
  PictureSentence('她每天晚上刷牙以后才睡觉。', 'Tā měi tiān wǎnshang shuā yá yǐhòu cái shuìjiào.', '🪥'),
  PictureSentence('周末我们去爬山了。', 'Zhōumò wǒmen qù pá shān le.', '⛰️'),
  PictureSentence('用筷子吃面条不难。', 'Yòng kuàizi chī miàntiáo bù nán.', '🥢'),
  PictureSentence('你的护照放在哪儿了？', 'Nǐ de hùzhào fàng zài nǎr le?', '🛂'),
  PictureSentence('我们坐地铁去吧，地铁比较快。', 'Wǒmen zuò dìtiě qù ba, dìtiě bǐjiào kuài.', '🚇'),
  PictureSentence('今天的月亮又大又圆。', 'Jīntiān de yuèliang yòu dà yòu yuán.', '🌙'),
];

const examQAs3 = <ExamQA>[
  ExamQA('你周末一般做什么？', 'Nǐ zhōumò yìbān zuò shénme?', [
    ('我一般去公园锻炼身体。', 'Wǒ yìbān qù gōngyuán duànliàn shēntǐ.'),
    ('我的邻居很热情。', 'Wǒ de línjū hěn rèqíng.'),
    ('上个周末下雨了。', 'Shàng ge zhōumò xià yǔ le.'),
  ]),
  ExamQA('你怎么又迟到了？', 'Nǐ zěnme yòu chídào le?', [
    ('对不起，地铁出了问题。', 'Duìbuqǐ, dìtiě chū le wèntí.'),
    ('我习惯早上洗澡。', 'Wǒ xíguàn zǎoshang xǐzǎo.'),
    ('我明天再来吧。', 'Wǒ míngtiān zài lái ba.'),
  ]),
  ExamQA('这双鞋怎么样？', 'Zhè shuāng xié zěnmeyàng?', [
    ('很漂亮，但是有点儿小。', 'Hěn piàoliang, dànshì yǒudiǎnr xiǎo.'),
    ('鞋在楼下。', 'Xié zài lóu xià.'),
    ('我穿着衬衫。', 'Wǒ chuān zhe chènshān.'),
  ]),
  ExamQA('你认为这个问题难吗？', 'Nǐ rènwéi zhège wèntí nán ma?', [
    ('不难，很简单。', 'Bù nán, hěn jiǎndān.'),
    ('我忘记他的名字了。', 'Wǒ wàngjì tā de míngzi le.'),
    ('他回答得很快。', 'Tā huídá de hěn kuài.'),
  ]),
  ExamQA('你会骑自行车吗？', 'Nǐ huì qí zìxíngchē ma?', [
    ('会，我小时候就学会了。', 'Huì, wǒ xiǎo shíhou jiù xuéhuì le.'),
    ('自行车是蓝色的。', 'Zìxíngchē shì lánsè de.'),
    ('我坐地铁去。', 'Wǒ zuò dìtiě qù.'),
  ]),
  ExamQA('你为什么这么着急？', 'Nǐ wèishénme zhème zháojí?', [
    ('飞机马上就要起飞了！', 'Fēijī mǎshàng jiù yào qǐfēi le!'),
    ('我很少生气。', 'Wǒ hěn shǎo shēngqì.'),
    ('我已经吃饱了。', 'Wǒ yǐjīng chī bǎo le.'),
  ]),
  ExamQA('你能帮我照顾一下我的猫吗？', 'Nǐ néng bāng wǒ zhàogù yíxià wǒ de māo ma?', [
    ('当然可以，你放心吧。', 'Dāngrán kěyǐ, nǐ fàngxīn ba.'),
    ('我的猫很胖。', 'Wǒ de māo hěn pàng.'),
    ('我不喜欢喝牛奶。', 'Wǒ bù xǐhuan hē niúnǎi.'),
  ]),
  ExamQA('我们去哪儿吃饭？', 'Wǒmen qù nǎr chī fàn?', [
    ('学校附近有一个新饭馆。', 'Xuéxiào fùjìn yǒu yí ge xīn fànguǎn.'),
    ('我吃了两碗。', 'Wǒ chī le liǎng wǎn.'),
    ('我已经洗澡了。', 'Wǒ yǐjīng xǐzǎo le.'),
  ]),
];

const examGaps3 = <ExamGap>[
  ExamGap('我（  ）作业做完了。', 'Wǒ (  ) zuòyè zuò wán le.', ['把', '被', '给']),
  ExamGap('我的自行车（  ）弟弟骑走了。', 'Wǒ de zìxíngchē (  ) dìdi qí zǒu le.', ['被', '把', '从']),
  ExamGap('天气越来（  ）热了。', 'Tiānqì yuè lái (  ) rè le.', ['越', '更', '最']),
  ExamGap('（  ）明天不下雨，我们就去爬山。', '(  ) míngtiān bú xià yǔ, wǒmen jiù qù pá shān.', ['如果', '虽然', '因为']),
  ExamGap('她慢慢（  ）走进了教室。', 'Tā mànmàn (  ) zǒu jìn le jiàoshì.', ['地', '的', '得']),
  ExamGap('你喝茶（  ）喝咖啡？', 'Nǐ hē chá (  ) hē kāfēi?', ['还是', '或者', '而且']),
  ExamGap('除了数学，我（  ）喜欢历史。', 'Chúle shùxué, wǒ (  ) xǐhuan lìshǐ.', ['还', '就', '才']),
  ExamGap('你（  ）多休息，别太累了。', 'Nǐ (  ) duō xiūxi, bié tài lèi le.', ['应该', '已经', '一边']),
];

/// HSK 3 writing, mini version: a sentence with one missing character and its pinyin.
/// In the real exam you write the character by hand; here you pick it.
class ExamChar {
  final String zh; // the gap is written （  ）
  final String pinyin; // the whole sentence
  final String gapPinyin; // pinyin of the missing character
  final List<String> options; // the first is right
  const ExamChar(this.zh, this.pinyin, this.gapPinyin, this.options);
}

const examChars3 = <ExamChar>[
  ExamChar('我在（  ）书馆看书。', 'Wǒ zài túshūguǎn kàn shū.', 'tú', ['图', '土', '途']),
  ExamChar('他的（  ）绩很好。', 'Tā de chéngjì hěn hǎo.', 'chéng', ['成', '城', '程']),
  ExamChar('我们一起去公（  ）吧。', 'Wǒmen yìqǐ qù gōngyuán ba.', 'yuán', ['园', '元', '员']),
  ExamChar('请（  ）答这个问题。', 'Qǐng huídá zhège wèntí.', 'huí', ['回', '会', '汇']),
  ExamChar('谢谢你的（  ）心。', 'Xièxie nǐ de guānxīn.', 'guān', ['关', '观', '馆']),
  ExamChar('她每天都很（  ）真地学习。', 'Tā měi tiān dōu hěn rènzhēn de xuéxí.', 'rèn', ['认', '人', '任']),
  ExamChar('我们（  ）在去机场。', 'Wǒmen xiànzài qù jīchǎng.', 'xiàn', ['现', '先', '线']),
  ExamChar('这个问题很（  ）单。', 'Zhège wèntí hěn jiǎndān.', 'jiǎn', ['简', '见', '件']),
  ExamChar('他是我的（  ）居。', 'Tā shì wǒ de línjū.', 'lín', ['邻', '林', '临']),
];

// ---------------- HSK 4 ----------------

/// HSK 4: a short passage, and a statement (★) about it that is right or wrong.
class ExamJudge {
  final String passage;
  final String passagePinyin;
  final String statement;
  final String statementPinyin;
  final bool right;
  const ExamJudge(this.passage, this.passagePinyin, this.statement, this.statementPinyin, this.right);
}

/// HSK 4 writing, mini version: words to put in order. In the real exam you write
/// the sentence; here you pick the one in the right order.
class ExamOrder {
  final List<String> pieces; // shown mixed up, in this order
  final List<String> options; // whole sentences; the first is right
  final String pinyin; // of the right sentence
  const ExamOrder(this.pieces, this.options, this.pinyin);
}

const examJudges4 = <ExamJudge>[
  ExamJudge('我以前很少运动，后来医生说我应该多锻炼身体。现在我每天早上都去公园跑步，已经坚持了半年了。',
      'Wǒ yǐqián hěn shǎo yùndòng, hòulái yīshēng shuō wǒ yīnggāi duō duànliàn shēntǐ. Xiànzài wǒ měi tiān zǎoshang dōu qù gōngyuán pǎobù, yǐjīng jiānchí le bàn nián le.',
      '说话人现在经常运动。', 'Shuōhuàrén xiànzài jīngcháng yùndòng.', true),
  ExamJudge('这家饭馆的菜虽然很好吃，但是价格太贵了，而且服务员的态度也不太好，所以我很少去。',
      'Zhè jiā fànguǎn de cài suīrán hěn hǎochī, dànshì jiàgé tài guì le, érqiě fúwùyuán de tàidu yě bú tài hǎo, suǒyǐ wǒ hěn shǎo qù.',
      '说话人经常去这家饭馆。', 'Shuōhuàrén jīngcháng qù zhè jiā fànguǎn.', false),
  ExamJudge('小王，明天的会议改到下午三点了，请你通知一下其他同事。',
      'Xiǎo Wáng, míngtiān de huìyì gǎi dào xiàwǔ sān diǎn le, qǐng nǐ tōngzhī yíxià qítā tóngshì.',
      '会议的时间变了。', 'Huìyì de shíjiān biàn le.', true),
  ExamJudge('我女儿从小就对音乐很感兴趣，五岁开始学弹钢琴。现在她已经是一名钢琴老师了。',
      'Wǒ nǚ\'ér cóngxiǎo jiù duì yīnyuè hěn gǎn xìngqù, wǔ suì kāishǐ xué tán gāngqín. Xiànzài tā yǐjīng shì yì míng gāngqín lǎoshī le.',
      '说话人的女儿不喜欢音乐。', 'Shuōhuàrén de nǚ\'ér bù xǐhuan yīnyuè.', false),
  ExamJudge('很多人以为喝咖啡对身体不好，其实每天喝一两杯没有什么问题，只是晚上最好别喝，否则容易睡不着。',
      'Hěn duō rén yǐwéi hē kāfēi duì shēntǐ bù hǎo, qíshí měi tiān hē yì liǎng bēi méiyǒu shénme wèntí, zhǐshì wǎnshang zuìhǎo bié hē, fǒuzé róngyì shuì bu zháo.',
      '晚上喝咖啡可能会影响睡觉。', 'Wǎnshang hē kāfēi kěnéng huì yǐngxiǎng shuìjiào.', true),
  ExamJudge('我们公司离地铁站很近，走路只要五分钟，所以我每天都坐地铁上班，从来没有迟到过。',
      'Wǒmen gōngsī lí dìtiě zhàn hěn jìn, zǒulù zhǐ yào wǔ fēnzhōng, suǒyǐ wǒ měi tiān dōu zuò dìtiě shàngbān, cónglái méiyǒu chídào guo.',
      '说话人上班经常迟到。', 'Shuōhuàrén shàngbān jīngcháng chídào.', false),
  ExamJudge('这本书我已经看了三遍了，每次看都有新的感受。我建议你也买一本看看。',
      'Zhè běn shū wǒ yǐjīng kàn le sān biàn le, měi cì kàn dōu yǒu xīn de gǎnshòu. Wǒ jiànyì nǐ yě mǎi yì běn kànkan.',
      '说话人觉得这本书值得看。', 'Shuōhuàrén juéde zhè běn shū zhíde kàn.', true),
  ExamJudge('今天雨下得特别大，路上堵车很严重。如果没有重要的事情，大家最好不要开车出门。',
      'Jīntiān yǔ xià de tèbié dà, lù shang dǔchē hěn yánzhòng. Rúguǒ méiyǒu zhòngyào de shìqing, dàjiā zuìhǎo búyào kāichē chūmén.',
      '今天天气很好。', 'Jīntiān tiānqì hěn hǎo.', false),
  ExamJudge('我弟弟大学毕业以后，没有马上找工作，而是去南方旅游了三个月。他说想先了解一下这个世界。',
      'Wǒ dìdi dàxué bìyè yǐhòu, méiyǒu mǎshàng zhǎo gōngzuò, ér shì qù nánfāng lǚyóu le sān ge yuè. Tā shuō xiǎng xiān liǎojiě yíxià zhège shìjiè.',
      '弟弟毕业后马上就工作了。', 'Dìdi bìyè hòu mǎshàng jiù gōngzuò le.', false),
  ExamJudge('学习语言最重要的是多听多说。不要害怕说错，说错了也没关系，别人一般都会原谅你的。',
      'Xuéxí yǔyán zuì zhòngyào de shì duō tīng duō shuō. Búyào hàipà shuō cuò, shuō cuò le yě méi guānxi, biérén yìbān dōu huì yuánliàng nǐ de.',
      '学语言不应该怕说错。', 'Xué yǔyán bù yīnggāi pà shuō cuò.', true),
  ExamJudge('这台电脑是我去年买的，用了不到一年就坏了两次。我打算明天拿去商店，看看能不能换一台新的。',
      'Zhè tái diànnǎo shì wǒ qùnián mǎi de, yòng le bú dào yì nián jiù huài le liǎng cì. Wǒ dǎsuàn míngtiān ná qù shāngdiàn, kànkan néng bu néng huàn yì tái xīn de.',
      '说话人的电脑出了问题。', 'Shuōhuàrén de diànnǎo chū le wèntí.', true),
  ExamJudge('李老师对学生要求很严格，但是大家都很喜欢她，因为她上课非常有意思，而且总是很耐心地回答问题。',
      'Lǐ lǎoshī duì xuésheng yāoqiú hěn yángé, dànshì dàjiā dōu hěn xǐhuan tā, yīnwèi tā shàngkè fēicháng yǒu yìsi, érqiě zǒngshì hěn nàixīn de huídá wèntí.',
      '学生们不喜欢李老师。', 'Xuéshengmen bù xǐhuan Lǐ lǎoshī.', false),
  ExamJudge('周末的机票比平时贵很多，如果你的时间比较自由，可以选择周二或者周三出发，能省不少钱。',
      'Zhōumò de jīpiào bǐ píngshí guì hěn duō, rúguǒ nǐ de shíjiān bǐjiào zìyóu, kěyǐ xuǎnzé zhōu\'èr huòzhě zhōusān chūfā, néng shěng bù shǎo qián.',
      '周末的机票比较便宜。', 'Zhōumò de jīpiào bǐjiào piányi.', false),
  ExamJudge('我奶奶今年八十岁了，身体还很健康。她每天早上都和邻居们一起在楼下打太极拳。',
      'Wǒ nǎinai jīnnián bāshí suì le, shēntǐ hái hěn jiànkāng. Tā měi tiān zǎoshang dōu hé línjūmen yìqǐ zài lóu xià dǎ tàijíquán.',
      '奶奶的身体很好。', 'Nǎinai de shēntǐ hěn hǎo.', true),
];

const examQAs4 = <ExamQA>[
  ExamQA('你最近怎么瘦了这么多？', 'Nǐ zuìjìn zěnme shòu le zhème duō?', [
    ('我每天晚饭后都去跑步。', 'Wǒ měi tiān wǎnfàn hòu dōu qù pǎobù.'),
    ('这件衣服有点儿瘦。', 'Zhè jiàn yīfu yǒudiǎnr shòu.'),
    ('我最近胖了两公斤。', 'Wǒ zuìjìn pàng le liǎng gōngjīn.'),
  ]),
  ExamQA('你觉得这份工作怎么样？', 'Nǐ juéde zhè fèn gōngzuò zěnmeyàng?', [
    ('工资不错，就是压力有点儿大。', 'Gōngzī búcuò, jiùshì yālì yǒudiǎnr dà.'),
    ('我是去年九月毕业的。', 'Wǒ shì qùnián jiǔ yuè bìyè de.'),
    ('他明天去面试。', 'Tā míngtiān qù miànshì.'),
  ]),
  ExamQA('你能不能把空调关小一点儿？', 'Nǐ néng bu néng bǎ kōngtiáo guān xiǎo yìdiǎnr?', [
    ('好的，你是不是觉得冷？', 'Hǎo de, nǐ shì bu shì juéde lěng?'),
    ('空调是上个月买的。', 'Kōngtiáo shì shàng ge yuè mǎi de.'),
    ('今天外面特别热闹。', 'Jīntiān wàimian tèbié rènao.'),
  ]),
  ExamQA('你怎么没参加昨天的聚会？', 'Nǐ zěnme méi cānjiā zuótiān de jùhuì?', [
    ('我突然有事，实在走不开。', 'Wǒ tūrán yǒu shì, shízài zǒu bu kāi.'),
    ('聚会在一家咖啡馆举行。', 'Jùhuì zài yì jiā kāfēiguǎn jǔxíng.'),
    ('我很喜欢参加聚会。', 'Wǒ hěn xǐhuan cānjiā jùhuì.'),
  ]),
  ExamQA('这个问题你是怎么解决的？', 'Zhège wèntí nǐ shì zěnme jiějué de?', [
    ('我上网查了很多资料。', 'Wǒ shàngwǎng chá le hěn duō zīliào.'),
    ('这个问题很重要。', 'Zhège wèntí hěn zhòngyào.'),
    ('我明天才有时间。', 'Wǒ míngtiān cái yǒu shíjiān.'),
  ]),
  ExamQA('你打算什么时候回国？', 'Nǐ dǎsuàn shénme shíhou huí guó?', [
    ('等签证办好了就回去。', 'Děng qiānzhèng bàn hǎo le jiù huíqu.'),
    ('我回国坐了十个小时飞机。', 'Wǒ huí guó zuò le shí ge xiǎoshí fēijī.'),
    ('我的国家很美。', 'Wǒ de guójiā hěn měi.'),
  ]),
  ExamQA('麻烦你帮我把这封信寄出去，好吗？', 'Máfan nǐ bāng wǒ bǎ zhè fēng xìn jì chūqu, hǎo ma?', [
    ('没问题，我正好要去邮局。', 'Méi wèntí, wǒ zhènghǎo yào qù yóujú.'),
    ('这封信是我妈妈写的。', 'Zhè fēng xìn shì wǒ māma xiě de.'),
    ('我昨天收到了你的信。', 'Wǒ zuótiān shōudào le nǐ de xìn.'),
  ]),
  ExamQA('你对这次比赛的结果满意吗？', 'Nǐ duì zhè cì bǐsài de jiéguǒ mǎnyì ma?', [
    ('还行，不过我觉得还能做得更好。', 'Hái xíng, búguò wǒ juéde hái néng zuò de gèng hǎo.'),
    ('比赛下午两点开始。', 'Bǐsài xiàwǔ liǎng diǎn kāishǐ.'),
    ('我们队有十一个人。', 'Wǒmen duì yǒu shíyī ge rén.'),
  ]),
];

const examGaps4 = <ExamGap>[
  ExamGap('他（  ）会说汉语，而且还会说日语。', 'Tā (  ) huì shuō Hànyǔ, érqiě hái huì shuō Rìyǔ.', ['不仅', '不管', '尽管']),
  ExamGap('（  ）天气怎么样，我们都要按时出发。', '(  ) tiānqì zěnmeyàng, wǒmen dōu yào ànshí chūfā.', ['不管', '虽然', '因为']),
  ExamGap('我（  ）他是中国人，原来他是新加坡人。', 'Wǒ (  ) tā shì Zhōngguórén, yuánlái tā shì Xīnjiāpōrén.', ['以为', '希望', '认为']),
  ExamGap('他练习了一年，（  ）通过了考试。', 'Tā liànxí le yì nián, (  ) tōngguò le kǎoshì.', ['终于', '从来', '一直']),
  ExamGap('请大家（  ）顺序排队上车。', 'Qǐng dàjiā (  ) shùnxù páiduì shàng chē.', ['按照', '为了', '关于']),
  ExamGap('他（  ）忙，也会每周给父母打电话。', 'Tā (  ) máng, yě huì měi zhōu gěi fùmǔ dǎ diànhuà.', ['再', '更', '太']),
  ExamGap('（  ）明天下雨，我们也要去。', '(  ) míngtiān xià yǔ, wǒmen yě yào qù.', ['即使', '因为', '所以']),
  ExamGap('大家（  ）这个计划都很满意。', 'Dàjiā (  ) zhège jìhuà dōu hěn mǎnyì.', ['对', '向', '往']),
  ExamGap('我（  ）没去过上海，你给我介绍一下吧。', 'Wǒ (  ) méi qù guo Shànghǎi, nǐ gěi wǒ jièshào yíxià ba.', ['从来', '已经', '刚才']),
  ExamGap('由于下大雨，比赛（  ）推迟了。', 'Yóuyú xià dà yǔ, bǐsài (  ) tuīchí le.', ['只好', '只要', '不管']),
  ExamGap('这件衣服的颜色和样子都很好，（  ）有点儿贵。', 'Zhè jiàn yīfu de yánsè hé yàngzi dōu hěn hǎo, (  ) yǒudiǎnr guì.', ['不过', '而且', '所以']),
  ExamGap('你（  ）去哪儿，都要注意安全。', 'Nǐ (  ) qù nǎr, dōu yào zhùyì ānquán.', ['无论', '虽然', '因为']),
];

const examOrders4 = <ExamOrder>[
  ExamOrder(['弟弟', '借走了', '那本书', '被'], ['那本书被弟弟借走了。', '弟弟被那本书借走了。', '那本书弟弟被借走了。'],
      'Nà běn shū bèi dìdi jiè zǒu le.'),
  ExamOrder(['打扫', '把', '干净了', '他', '房间'], ['他把房间打扫干净了。', '他房间把打扫干净了。', '把他房间打扫干净了。'],
      'Tā bǎ fángjiān dǎsǎo gānjìng le.'),
  ExamOrder(['比', '去年', '今年的冬天', '冷多了'], ['今年的冬天比去年冷多了。', '今年的冬天冷多了比去年。', '比今年的冬天去年冷多了。'],
      'Jīnnián de dōngtiān bǐ qùnián lěng duō le.'),
  ExamOrder(['我', '一个小时', '等了', '他'], ['我等了他一个小时。', '我一个小时等了他。', '他一个小时我等了。'],
      'Wǒ děng le tā yí ge xiǎoshí.'),
  ExamOrder(['让', '这个消息', '很', '大家', '吃惊'], ['这个消息让大家很吃惊。', '大家让这个消息很吃惊。', '这个消息大家让很吃惊。'],
      'Zhège xiāoxi ràng dàjiā hěn chījīng.'),
  ExamOrder(['得', '他', '流利', '说', '汉语', '很'], ['他汉语说得很流利。', '他说汉语得很流利。', '他汉语很说得流利。'],
      'Tā Hànyǔ shuō de hěn liúlì.'),
  ExamOrder(['越来越', '天气', '了', '暖和'], ['天气越来越暖和了。', '越来越天气暖和了。', '天气暖和越来越了。'],
      'Tiānqì yuè lái yuè nuǎnhuo le.'),
  ExamOrder(['是', '的', '坐火车', '我', '来'], ['我是坐火车来的。', '我坐火车是来的。', '是我坐火车的来。'],
      'Wǒ shì zuò huǒchē lái de.'),
];

/// Everything one level's mini exam is made from.
class ExamSet {
  final int level;
  final List<PictureWord> pictureWords;
  final List<PictureSentence> pictureSentences;
  final List<ExamQA> qas;
  final List<ExamGap> gaps;
  final List<ExamChar> chars; // HSK 3 writing: the missing character
  final List<ExamJudge> judges; // HSK 4: is the statement right?
  final List<ExamOrder> orders; // HSK 4 writing: words in the right order
  const ExamSet(this.level, this.pictureWords, this.pictureSentences, this.qas, this.gaps,
      {this.chars = const [], this.judges = const [], this.orders = const []});
}

const examSets = {
  1: ExamSet(1, examPictureWords, examPictureSentences, examQAs, examGaps),
  2: ExamSet(2, examPictureWords2, examPictureSentences2, examQAs2, examGaps2),
  3: ExamSet(3, examPictureWords3, examPictureSentences3, examQAs3, examGaps3, chars: examChars3),
  4: ExamSet(4, [], [], examQAs4, examGaps4, judges: examJudges4, orders: examOrders4),
};
