// Questions for the mini exam, written in the style of the real HSK 1 test
// (listening and reading, with pictures, answers to choose and gaps to fill).
// Everything here is original and uses HSK 1 words only.

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

/// Everything one level's mini exam is made from.
class ExamSet {
  final int level;
  final List<PictureWord> pictureWords;
  final List<PictureSentence> pictureSentences;
  final List<ExamQA> qas;
  final List<ExamGap> gaps;
  final List<ExamChar> chars; // only HSK 3 has a writing part
  const ExamSet(this.level, this.pictureWords, this.pictureSentences, this.qas, this.gaps, {this.chars = const []});
}

const examSets = {
  1: ExamSet(1, examPictureWords, examPictureSentences, examQAs, examGaps),
  2: ExamSet(2, examPictureWords2, examPictureSentences2, examQAs2, examGaps2),
  3: ExamSet(3, examPictureWords3, examPictureSentences3, examQAs3, examGaps3, chars: examChars3),
};
