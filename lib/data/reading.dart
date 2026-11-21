// Reading practice at HSK 4 and 5 level: short news reports, opinions and stories.
// Everything here is original.
//
// Paragraphs are written with spaces between words, like the graded stories, so each
// word can be tapped. Every word is a course word, a story extra, or listed in
// [readingExtras] below; the tests check this.

import 'stories.dart' show Story, StoryParagraph, StoryQuestion;

typedef _P = StoryParagraph;
typedef _Q = StoryQuestion;

class ReadingArticle {
  final String id;
  final String emoji;
  final String kind; // News, Opinion, Story, Science
  final int level; // HSK 4 or 5
  final String title;
  final String titleEn;
  final String blurb;
  final List<StoryParagraph> paragraphs;
  final List<StoryQuestion> questions;
  const ReadingArticle(this.id, this.emoji, this.kind, this.level, this.title, this.titleEn, this.blurb,
      this.paragraphs, this.questions);

  String get text => paragraphs.map((p) => p.text).join();

  /// The article as a story, so the story reader and its questions can show it.
  Story get asStory => Story(id, title, titleEn, blurb, paragraphs, questions);
}

/// Words in the articles that the course does not teach, with pinyin and meaning.
const readingExtras = <String, (String, String)>{
  '共享单车': ('gòngxiǎng dānchē', 'shared bikes (rented with an app)'),
  '扫': ('sǎo', 'to scan; to sweep'),
  '停车': ('tíngchē', 'to park'),
  '该': ('gāi', 'should'),
  '家长': ('jiāzhǎng', 'parent (of a pupil)'),
  '放学': ('fàngxué', 'school is out'),
  '随时': ('suíshí', 'at any time'),
  '好好': ('hǎohǎo', 'properly, well'),
  '本身': ('běnshēn', 'itself'),
  '好坏': ('hǎohuài', 'good or bad'),
  '门口': ('ménkǒu', 'doorway, entrance'),
  '这时': ('zhè shí', 'at this moment'),
  '女孩': ('nǚhái', 'girl'),
  '还给': ('huán gěi', 'to give back'),
  '老人': ('lǎorén', 'old person'),
  '传': ('chuán', 'to pass on'),
  '年轻人': ('niánqīngrén', 'young people'),
  '半夜': ('bànyè', 'midnight, the middle of the night'),
  '成年人': ('chéngniánrén', 'adult'),
  '打工': ('dǎgōng', 'to work for a wage (often away from home)'),
  '网上': ('wǎng shang', 'online'),
  '茶叶': ('cháyè', 'tea leaves'),
  '村子': ('cūnzi', 'village'),
  '民宿': ('mínsù', 'guesthouse, B&B'),
  '游客': ('yóukè', 'tourist, visitor'),
  '城里人': ('chénglǐrén', 'city people'),
  '呼吸': ('hūxī', 'to breathe'),
  '体验': ('tǐyàn', 'to experience for yourself'),
  '人才': ('réncái', 'talented people, skilled workers'),
  '未来': ('wèilái', 'the future'),
  '农村': ('nóngcūn', 'the countryside'),
  '留学生': ('liúxuéshēng', 'student studying abroad'),
  '好几': ('hǎo jǐ', 'quite a few'),
  '变成': ('biànchéng', 'to turn into'),
  '唯一': ('wéiyī', 'the only'),
  '而是': ('ér shì', 'but rather'),
  '有些': ('yǒuxiē', 'some'),
  '大熊猫': ('dà xióngmāo', 'giant panda'),
  '国宝': ('guóbǎo', 'national treasure'),
  '全世界': ('quán shìjiè', 'the whole world'),
  '它们': ('tāmen', 'they, them (animals or things)'),
  '属于': ('shǔyú', 'to belong to'),
  '食肉': ('shí ròu', 'meat-eating'),
  '祖先': ('zǔxiān', 'ancestor'),
  '竹子': ('zhúzi', 'bamboo'),
  '科学家': ('kēxuéjiā', 'scientist'),
  '一年四季': ('yì nián sì jì', 'all year round'),
  '十几': ('shí jǐ', 'ten-odd, a dozen or so'),
  '看起来': ('kàn qǐlai', 'to look, to seem'),
  '懒洋洋': ('lǎnyángyáng', 'lazy, sluggish'),
  '那时候': ('nà shíhou', 'at that time'),
  '回信': ('huíxìn', 'to write back'),
  '熬夜': ('áoyè', 'to stay up late'),
  '抽屉': ('chōuti', 'drawer'),
  '书桌': ('shūzhuō', 'desk'),
  '厚厚': ('hòuhòu', 'very thick'),
  '本子': ('běnzi', 'notebook'),
  '一刻': ('yí kè', 'moment'),
  '那么': ('nàme', 'then, in that case'),
  '人们': ('rénmen', 'people'),
  '带来': ('dàilái', 'to bring'),
  '出来': ('chūlai', 'to come out'),
  '车': ('chē', 'car; bike, vehicle'),
  '一些': ('yìxiē', 'some, a few'),
  '有的': ('yǒude', 'some'),
  '专家': ('zhuānjiā', 'expert'),
  '遵守': ('zūnshǒu', 'to follow (rules)'),
  '变': ('biàn', 'to change, to become'),
  '小学生': ('xiǎoxuéshēng', 'primary school pupil'),
  '父母': ('fùmǔ', 'parents'),
  '越来越': ('yuè lái yuè', 'more and more'),
  '每天': ('měi tiān', 'every day'),
  '下班': ('xiàbān', 'to finish work'),
  '起': ('qǐ', 'to start (下起雨 = to start raining)'),
  '雨': ('yǔ', 'rain'),
  '没': ('méi', 'did not, have not'),
  '停': ('tíng', 'to stop'),
  '过来': ('guòlai', 'to come over'),
  '看到': ('kàndào', 'to see'),
  '这样': ('zhèyàng', 'like this'),
  '下去': ('xiàqu', 'to go on (doing)'),
  '晚': ('wǎn', 'late'),
  '睡': ('shuì', 'to sleep'),
  '白天': ('báitiān', 'daytime'),
  '常常': ('chángcháng', 'often'),
  '第二': ('dì-èr', 'second (第二天 = the next day)'),
  '不要': ('búyào', 'don\'t'),
  '刚': ('gāng', 'just'),
  '早': ('zǎo', 'early'),
  '坚持': ('jiānchí', 'to keep at it'),
  '回到': ('huídào', 'to go back to'),
  '家乡': ('jiāxiāng', 'home town'),
  '网络': ('wǎngluò', 'the internet, network'),
  '生意': ('shēngyi', 'business, trade'),
  '开车': ('kāichē', 'to drive'),
  '这里': ('zhèlǐ', 'here'),
  '学': ('xué', 'to learn'),
  '外语': ('wàiyǔ', 'foreign language'),
  '出国': ('chūguó', 'to go abroad'),
  '国外': ('guówài', 'abroad'),
  '进步': ('jìnbù', 'progress'),
  '国': ('guó', 'country'),
  '外国': ('wàiguó', 'foreign'),
  '部分': ('bùfen', 'part'),
  '肉': ('ròu', 'meat'),
  '节约': ('jiéyuē', 'to save, to not waste'),
  '大学': ('dàxué', 'university'),
  '封': ('fēng', '(counting word for letters)'),
  '总': ('zǒng', 'always'),
  '帮': ('bāng', 'to help'),
  '打开': ('dǎkāi', 'to open'),
  '里面': ('lǐmiàn', 'inside'),
  '小时候': ('xiǎo shíhou', 'as a child'),
  '那些': ('nàxiē', 'those'),
};

const readingArticles = <ReadingArticle>[
  ReadingArticle('bikes', '🚲', 'News', 4, '城市里的共享单车', 'Shared bikes in the city',
      'How shared bikes changed city life, and the problems they brought.', [
    _P('最近 几 年 ， 中国 的 很 多 城市 出现 了 共享单车 。 人们 只要 用 手机 扫 一下 ， 就 可以 骑 走 一 辆 自行车 。',
        'In the last few years, shared bikes have appeared in many Chinese cities. You just scan with your phone and you can ride a bike away.'),
    _P('共享单车 给 人们 的 生活 带来 了 很 大 的 方便 。 上班 的 人 从 地铁 站 出来 以后 ， 可以 骑 车 去 公司 ， 又 快 又 便宜 ， 还 能 锻炼 身体 。',
        'Shared bikes have made life much more convenient. After coming out of the underground, people going to work can cycle to the office. It is fast and cheap, and good exercise too.'),
    _P('不过 ， 共享单车 也 带来 了 一些 问题 。 有的 人 骑 完 车 以后 随便 乱 放 ， 影响 了 交通 。 因此 ， 很 多 城市 规定 了 停车 的 地方 。',
        'But shared bikes have also brought some problems. Some people leave the bikes anywhere after riding, which gets in the way of traffic. So many cities now have rules about where to park.'),
    _P('专家 认为 ， 只要 大家 都 遵守 规定 ， 共享单车 会 让 城市 变 得 更 绿色 、 更 方便 。',
        'Experts think that as long as everyone follows the rules, shared bikes will make cities greener and more convenient.'),
  ], [
    _Q('怎么 才 能 骑 走 共享单车 ？', 'How do you take a shared bike?', ['用手机扫一下', '去商店买一辆', '给司机打电话'], 0),
    _Q('共享单车 带来 了 什么 问题 ？', 'What problem have shared bikes brought?', ['车太贵了', '有人乱放车，影响交通', '骑车不能锻炼身体'], 1),
    _Q('专家 认为 大家 应该 怎么 做 ？', 'What do experts think everyone should do?', ['都坐出租车', '不骑自行车', '遵守停车的规定'], 2),
  ]),
  ReadingArticle('phones', '📱', 'Opinion', 4, '孩子该不该有手机？', 'Should children have phones?',
      'Parents disagree. The writer suggests a middle way.', [
    _P('现在 ， 很 多 小学生 都 有 自己 的 手机 。 孩子 该 不 该 有 手机 ？ 家长 的 看法 很 不 一样 。',
        'These days many primary school pupils have their own phone. Should children have phones? Parents see it very differently.'),
    _P('有的 家长 认为 ， 孩子 有 手机 比较 安全 。 放学 以后 ， 父母 随时 可以 联系 到 孩子 ， 知道 他们 在 哪儿 。',
        'Some parents think it is safer for a child to have a phone. After school, the parents can reach their child at any time and know where they are.'),
    _P('也 有 家长 担心 ， 孩子 拿 着 手机 就 会 一直 玩 游戏 ， 不 好好 学习 ， 眼睛 也 会 越来越 差 。',
        'Other parents worry that with a phone in their hands, children will play games all the time, not study properly, and their eyesight will get worse and worse.'),
    _P('我 觉得 ， 手机 本身 没有 好坏 ， 关键 是 怎么 用 。 父母 可以 和 孩子 一起 商量 ， 规定 每天 玩 手机 的 时间 。',
        'I think the phone itself is neither good nor bad. The key is how it is used. Parents can talk it over with their child and agree how long the phone can be used each day.'),
  ], [
    _Q('有的 家长 为什么 想 给 孩子 买 手机 ？', 'Why do some parents want to buy their child a phone?', ['可以随时联系孩子', '孩子学习不好', '手机很便宜'], 0),
    _Q('有的 家长 担心 什么 ？', 'What do some parents worry about?', ['手机太贵', '孩子一直玩游戏', '孩子不会用手机'], 1),
    _Q('作者 觉得 应该 怎么 做 ？', 'What does the writer think should be done?', ['不让孩子用手机', '让孩子想玩就玩', '和孩子一起规定玩手机的时间'], 2),
  ]),
  ReadingArticle('umbrella', '☂️', 'Story', 4, '一把伞', 'An umbrella',
      'A stranger lends the writer an umbrella in the rain.', [
    _P('那 天 下班 的 时候 ， 突然 下 起 了 大 雨 。 我 没 带 伞 ， 只好 站 在 公司 门口 等 雨 停 。',
        'That day, just as I finished work, it suddenly started to pour. I had no umbrella, so I had to stand at the office door and wait for the rain to stop.'),
    _P('这时 ， 一 个 不 认识 的 女孩 走 过来 ， 把 她 的 伞 给 了 我 。 她 说 ： “ 我 家 就 在 附近 ， 你 拿 去 用 吧 。 ” 说 完 ， 她 就 跑 进 了 雨 里 。',
        'Just then a girl I did not know came over and gave me her umbrella. She said, "I live just nearby. Take it and use it." Then she ran off into the rain.'),
    _P('我 想 把 伞 还给 她 ， 可是 不 知道 她 是 谁 。 后来 ， 我 每 天 都 带 着 这 把 伞 ， 希望 能 再 遇到 她 。',
        'I wanted to give the umbrella back to her, but I did not know who she was. After that I carried the umbrella every day, hoping to meet her again.'),
    _P('一 个 月 以后 ， 又 下 雨 了 。 我 在 地铁 站 看到 一 个 没 带 伞 的 老人 ， 就 把 伞 送 给 了 他 。 我 想 ， 这 把 伞 应该 一直 这样 传 下去 。',
        'A month later it rained again. At the underground station I saw an old man with no umbrella, so I gave it to him. I think this umbrella should keep being passed on like this.'),
  ], [
    _Q('那 天 作者 为什么 站 在 公司 门口 ？', 'Why was the writer standing at the office door that day?', ['他在等朋友', '他没带伞，在等雨停', '他不想回家'], 1),
    _Q('女孩 把 伞 给 作者 以后 做 了 什么 ？', 'What did the girl do after giving the writer her umbrella?', ['跑进了雨里', '和作者一起走', '坐出租车回家了'], 0),
    _Q('最后 作者 把 伞 给 了 谁 ？', 'Who did the writer give the umbrella to in the end?', ['那个女孩', '他的同事', '一个没带伞的老人'], 2),
  ]),
  ReadingArticle('sleep', '😴', 'Life', 4, '早睡早起', 'Early to bed',
      'Why so many young people stay up late, and what doctors suggest.', [
    _P('很 多 年轻人 有 晚 睡 的 习惯 。 他们 白天 工作 很 忙 ， 晚上 才 有 自己 的 时间 ， 所以 常常 玩 手机 玩 到 半夜 。',
        'Many young people are in the habit of going to bed late. They are busy at work during the day and only have time for themselves in the evening, so they often play on their phones until midnight.'),
    _P('可是 ， 睡 得 太 晚 对 身体 很 不 好 。 第二 天 上班 的 时候 ， 人 会 觉得 很 累 ， 工作 的 时候 也 容易 出 错 。',
        'But going to bed too late is bad for your health. At work the next day you feel very tired, and it is easy to make mistakes.'),
    _P('医生 建议 ， 成年人 每天 最好 睡 七 到 八 个 小时 。 睡觉 以前 一 个 小时 最好 不要 看 手机 ， 可以 看 书 或者 听 音乐 。',
        'Doctors suggest that adults should sleep seven to eight hours a day. For an hour before bed it is best not to look at your phone. You could read or listen to music instead.'),
    _P('刚 开始 早 睡 的 时候 可能 不 太 习惯 ， 但是 只要 坚持 一 两 个 星期 ， 你 就 会 发现 自己 的 精神 好 多 了 。',
        'When you first start going to bed early it may feel strange, but if you keep it up for a week or two, you will find you have much more energy.'),
  ], [
    _Q('年轻人 为什么 常常 睡 得 很 晚 ？', 'Why do young people often go to bed late?', ['晚上才有自己的时间', '他们不累', '医生让他们晚睡'], 0),
    _Q('医生 建议 睡觉 以前 做 什么 ？', 'What do doctors suggest doing before bed?', ['玩手机', '看书或者听音乐', '喝咖啡'], 1),
    _Q('坚持 早 睡 一 两 个 星期 以后 会 怎么样 ？', 'What happens after going to bed early for a week or two?', ['更累了', '不习惯了', '精神好多了'], 2),
  ]),
  ReadingArticle('village', '🌾', 'News', 5, '回到农村的年轻人', 'Young people going back to the countryside',
      'The internet is bringing young people back to their home villages.', [
    _P('过去 ， 很 多 农村 的 年轻人 都 去 大 城市 打工 。 可是 最近 几 年 ， 越来越 多 的 年轻人 选择 回到 自己 的 家乡 。',
        'In the past, many young people from the countryside went to big cities to work. But in recent years, more and more young people are choosing to go back to their home towns.'),
    _P('有 了 网络 以后 ， 在 农村 也 可以 做 生意 。 有的 年轻人 在 网上 卖 家乡 的 水果 和 茶叶 ， 收入 比 在 城市 打工 还 高 。',
        'With the internet, you can do business in the countryside too. Some young people sell fruit and tea from their home town online, and earn more than they did working in the city.'),
    _P('也 有 人 在 村子 里 开 了 小 饭馆 和 民宿 ， 吸引 了 很 多 城市 里 的 游客 。 周末 ， 城里人 开车 来 这里 呼吸 新鲜 空气 ， 体验 农村 的 生活 。',
        'Others have opened small restaurants and guesthouses in their village, which draw many visitors from the city. At weekends, city people drive here to breathe fresh air and try country life.'),
    _P('当然 ， 回 农村 发展 也 不 容易 。 交通 不 方便 ， 找 人才 也 很 难 。 但是 很 多 人 相信 ， 农村 的 未来 会 越来越 好 。',
        'Of course, building a future in the countryside is not easy. Transport is poor and skilled people are hard to find. But many believe the future of the countryside will keep getting better.'),
  ], [
    _Q('过去 农村 的 年轻人 一般 去 哪儿 ？', 'Where did young people from the countryside usually go in the past?', ['去国外留学', '去大城市打工', '在家里休息'], 1),
    _Q('有的 年轻人 在 网上 卖 什么 ？', 'What do some young people sell online?', ['手机和电脑', '衣服和鞋', '家乡的水果和茶叶'], 2),
    _Q('回 农村 发展 有 什么 困难 ？', 'What is hard about building a future in the countryside?', ['交通不方便，找人才难', '没有新鲜空气', '城里人不喜欢农村'], 0),
  ]),
  ReadingArticle('abroad', '✈️', 'Opinion', 5, '学外语一定要出国吗？', 'Do you have to go abroad to learn a language?',
      'Some people never leave home and still speak fluently. How?', [
    _P('很 多 人 认为 ， 要 学 好 外语 ， 就 一定 要 出国 。 在 国外 ， 每天 都 要 用 外语 ， 进步 当然 会 很 快 。',
        'Many people think that to learn a foreign language well, you have to go abroad. Abroad you use the language every day, so of course you make quick progress.'),
    _P('可是 我 发现 ， 有些 留学生 在 国外 住 了 好几 年 ， 外语 水平 却 没有 提高 多少 。 原因 很 简单 ： 他们 每天 都 和 自己 国家 的 朋友 在 一起 。',
        'But I have noticed that some students live abroad for years and their language hardly improves. The reason is simple: they spend every day with friends from their own country.'),
    _P('相反 ， 有的 人 从来 没有 出 过 国 ， 却 说 得 非常 流利 。 他们 每天 坚持 听 外语 节目 ， 在 网上 找 外国 朋友 聊天 ， 把 学 外语 变成 了 生活 的 一 部分 。',
        'On the other hand, some people have never been abroad, yet speak very fluently. Every day they listen to programmes in the language and chat with foreign friends online. Learning the language has become part of their life.'),
    _P('所以 我 认为 ， 出国 不 是 学 好 外语 的 唯一 办法 。 重要 的 不 是 你 在 哪儿 ， 而是 你 每天 用 了 多少 时间 去 练习 。',
        'So I think going abroad is not the only way to learn a language well. What matters is not where you are, but how much time you spend practising every day.'),
  ], [
    _Q('有些 留学生 的 外语 为什么 没有 提高 ？', 'Why has the language of some students abroad not improved?', ['他们每天和自己国家的朋友在一起', '他们学习太努力了', '国外的老师不好'], 0),
    _Q('没 出 过 国 的 人 是 怎么 学 外语 的 ？', 'How do people who have never been abroad learn?', ['每天去上课', '每天听外语节目，找外国朋友聊天', '只看书'], 1),
    _Q('作者 认为 学 外语 最 重要 的 是 什么 ？', 'What does the writer think matters most?', ['一定要出国', '买很多书', '每天花时间练习'], 2),
  ]),
  ReadingArticle('panda', '🐼', 'Science', 5, '熊猫为什么爱吃竹子？', 'Why do pandas eat bamboo?',
      'Pandas come from a family of meat-eaters. So why bamboo?', [
    _P('大熊猫 是 中国 的 国宝 ， 全世界 的 人 都 很 喜欢 它们 。 很 多 人 不 知道 ， 熊猫 其实 属于 食肉 动物 ， 它们 的 祖先 是 吃 肉 的 。',
        'The giant panda is China\'s national treasure, and people all over the world love them. Many people don\'t know that pandas actually belong to the meat-eaters: their ancestors ate meat.'),
    _P('那么 ， 熊猫 为什么 后来 主要 吃 竹子 呢 ？ 科学家 认为 ， 这 和 环境 的 变化 有 关系 。 很 久 以前 ， 它们 生活 的 地方 肉 越来越 少 ， 可是 竹子 却 很 多 ， 而且 一年四季 都 有 。',
        'So why did pandas come to eat mainly bamboo? Scientists think it has to do with changes in the environment. Long ago, there was less and less meat where they lived, but bamboo was plentiful, and there all year round.'),
    _P('不过 ， 竹子 的 营养 很 少 ， 熊猫 只好 吃 很 多 。 一 只 大熊猫 每天 要 花 十几 个 小时 吃 东西 ， 能 吃 掉 十 多 公斤 竹子 。',
        'But bamboo has very little nutrition, so pandas have to eat a lot of it. A giant panda spends ten-odd hours a day eating, and can get through more than ten kilos of bamboo.'),
    _P('为了 节约 力气 ， 熊猫 吃 完 东西 就 睡觉 ， 很 少 运动 。 这 也 是 它们 看起来 总是 懒洋洋 的 原因 。',
        'To save energy, pandas sleep as soon as they finish eating and hardly move. That is also why they always look so lazy.'),
  ], [
    _Q('熊猫 的 祖先 吃 什么 ？', 'What did pandas\' ancestors eat?', ['竹子', '肉', '水果'], 1),
    _Q('熊猫 为什么 开始 吃 竹子 ？', 'Why did pandas start eating bamboo?', ['竹子比肉好吃', '人们给它们竹子', '环境变了，肉少了，竹子多'], 2),
    _Q('熊猫 为什么 很 少 运动 ？', 'Why do pandas move so little?', ['为了节约力气', '它们生病了', '它们不喜欢玩'], 0),
  ]),
  ReadingArticle('letters', '✉️', 'Story', 5, '父亲的信', 'My father\'s letters',
      'Short letters the writer hardly read, and what they really meant.', [
    _P('我 上 大学 的 时候 ， 父亲 每 个 月 都 给 我 写 一 封 信 。 那时候 已经 有 手机 了 ， 我 觉得 写 信 太 麻烦 ， 很 少 回信 。',
        'When I was at university, my father wrote me a letter every month. There were already mobile phones then, and I thought writing letters was too much trouble, so I hardly ever wrote back.'),
    _P('父亲 的 信 都 很 短 ， 内容 也 差不多 ： 天气 冷 了 ， 多 穿 衣服 ， 别 总 熬夜 ， 钱 够 不 够 用 。 我 常常 看 一 遍 就 放 进 抽屉 里 了 。',
        'His letters were all short and almost the same: it\'s getting cold, wear more clothes, don\'t keep staying up late, do you have enough money. I usually read them once and put them in a drawer.'),
    _P('毕业 那 年 ， 父亲 生病 了 ， 住 进 了 医院 。 我 回 家 帮 他 拿 东西 的 时候 ， 在 他 的 书桌 里 发现 了 一 本 厚厚 的 本子 。 打开 一 看 ， 里面 写 满 了 我 小时候 的 事情 。',
        'The year I graduated, my father fell ill and went into hospital. When I went home to fetch some things for him, I found a thick notebook in his desk. When I opened it, it was full of things about my childhood.'),
    _P('那 一刻 我 才 明白 ， 父亲 不 太 会 用 语言 表达 感情 ， 他 把 所有 的 爱 都 写 在 了 那些 简单 的 信 里 。 现在 ， 我 也 开始 给 他 写 信 了 。',
        'Only then did I understand: my father was not good at putting his feelings into words, so he put all his love into those simple letters. Now I have started writing letters to him too.'),
  ], [
    _Q('上 大学 的 时候 ， 作者 为什么 很 少 回信 ？', 'Why did the writer hardly ever write back at university?', ['他觉得写信太麻烦', '他没有收到信', '他不会写字'], 0),
    _Q('作者 在 父亲 的 书桌 里 发现 了 什么 ？', 'What did the writer find in his father\'s desk?', ['很多钱', '一本写满他小时候事情的本子', '一封新的信'], 1),
    _Q('现在 作者 开始 做 什么 ？', 'What has the writer started doing now?', ['每天给父亲打电话', '写一本书', '给父亲写信'], 2),
  ]),
];

ReadingArticle? readingArticleById(String id) {
  for (final a in readingArticles) {
    if (a.id == id) return a;
  }
  return null;
}
