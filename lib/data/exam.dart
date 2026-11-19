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
