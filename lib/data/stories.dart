// Graded reading: short original stories.
//
// Each paragraph is written with spaces between words, so the app knows where each
// word starts and ends (Chinese has no spaces). Every word must be either a course
// word or listed in [storyExtras] below; the tests check this.
//
// Two stories retell classic Chinese fables (守株待兔 and 画蛇添足). The fables are
// thousands of years old and free to use; the retellings here are written fresh.

class StoryParagraph {
  final String zh; // words separated by spaces
  final String en; // translation
  const StoryParagraph(this.zh, this.en);

  List<String> get tokens => zh.split(' ').where((t) => t.isNotEmpty).toList();
  String get text => tokens.join();
}

class StoryQuestion {
  final String zh;
  final String en;
  final List<String> options;
  final int correct;
  const StoryQuestion(this.zh, this.en, this.options, this.correct);
}

class Story {
  final String id;
  final String title;
  final String titleEn;
  final String blurb; // one line about the story, in English
  final List<StoryParagraph> paragraphs;
  final List<StoryQuestion> questions;
  const Story(this.id, this.title, this.titleEn, this.blurb, this.paragraphs, this.questions);
}

/// Words used in stories that are not taught in the course: names, and words a
/// story needs (like 兔子 rabbit). Shown as "new words" with their meaning.
const storyExtras = <String, (String, String)>{
  // names
  '小明': ('Xiǎo Míng', 'Xiaoming (a boy\'s name)'),
  '豆豆': ('Dòudou', 'Doudou (a dog\'s name)'),
  '咪咪': ('Mīmi', 'Mimi (a cat\'s name)'),
  '王丽': ('Wáng Lì', 'Wang Li (a girl\'s name)'),
  // numbers written together
  '二十': ('èrshí', 'twenty'),
  '四十': ('sìshí', 'forty'),
  '八十': ('bāshí', 'eighty'),
  // extra words
  '只': ('zhī', '(counting word for animals)'),
  '它': ('tā', 'it'),
  '天': ('tiān', 'day'),
  '前': ('qián', 'ago / before'),
  '每': ('měi', 'every'),
  '再': ('zài', 'again'),
  '饭': ('fàn', 'meal / food'),
  '杯': ('bēi', 'a cup of'),
  '给': ('gěi', 'to give / for'),
  '快': ('kuài', 'fast / quickly'),
  '你们': ('nǐmen', 'you (more than one)'),
  '他们': ('tāmen', 'they / them'),
  '汉字': ('Hànzì', 'Chinese characters'),
  '生日': ('shēngrì', 'birthday'),
  '故事': ('gùshi', 'story'),
  '农民': ('nóngmín', 'farmer'),
  '树': ('shù', 'tree'),
  '兔子': ('tùzi', 'rabbit'),
  '跑': ('pǎo', 'to run'),
  '撞': ('zhuàng', 'to bump into'),
  '死': ('sǐ', 'to die / dead'),
  '画': ('huà', 'to draw'),
  '蛇': ('shé', 'snake'),
  '脚': ('jiǎo', 'foot / leg'),
  '酒': ('jiǔ', 'wine / alcohol'),
  '第一': ('dì-yī', 'first'),
  '守株待兔': ('shǒu zhū dài tù', '"guard the tree, wait for rabbits": waiting for luck instead of working'),
  '画蛇添足': ('huà shé tiān zú', '"draw a snake, add feet": ruining something by doing too much'),
};

/// Names don't count when working out a story's level.
const storyNames = {'小明', '豆豆', '咪咪', '王丽'};

/// Numbers built only from HSK 1 numbers count as HSK 1.
const storyHskNumbers = {'二十', '四十', '八十'};

/// Punctuation marks: shown as they are, not tappable.
const storyPunctuation = {'，', '。', '？', '！', '：', '、', '“', '”'};

const stories = <Story>[
  Story('my-family', '我的家', 'My family', 'Xiaoming introduces his family and his dog.', [
    StoryParagraph('你 好 ！ 我 叫 小明 。 我 是 学生 。', 'Hello! My name is Xiaoming. I am a student.'),
    StoryParagraph('我 家 有 三 个 人 ： 爸爸 、 妈妈 和 我 。 我 家 有 一 只 小 狗 ， 它 叫 豆豆 。',
        'There are three people in my family: Dad, Mum and me. We have a little dog. It is called Doudou.'),
    StoryParagraph('我 爸爸 是 医生 ， 他 在 医院 工作 。 我 妈妈 是 老师 ， 她 在 学校 工作 。',
        'My dad is a doctor; he works at a hospital. My mum is a teacher; she works at a school.'),
    StoryParagraph('我 爱 我 的 家 ！', 'I love my family!'),
  ], [
    StoryQuestion('小明 家 有 几 个 人 ？', 'How many people are in Xiaoming\'s family?', ['三个', '四个', '五个'], 0),
    StoryQuestion('小明 的 爸爸 做 什么 工作 ？', 'What does Xiaoming\'s dad do?', ['老师', '医生', '学生'], 1),
    StoryQuestion('小 狗 叫 什么 名字 ？', 'What is the dog called?', ['小明', '咪咪', '豆豆'], 2),
  ]),
  Story('shopping', '去商店', 'Going shopping', 'A Saturday trip to the shop with Mum.', [
    StoryParagraph('今天 是 星期六 。 上午 ， 我 和 妈妈 去 商店 买 东西 。',
        'Today is Saturday. In the morning, Mum and I go to the shop to buy things.'),
    StoryParagraph('妈妈 想 买 水果 。 她 买 了 很 多 苹果 。', 'Mum wants to buy fruit. She buys lots of apples.'),
    StoryParagraph('我 喜欢 一 个 杯子 。 我 说 ： “ 这 个 杯子 多少 钱 ？ ”',
        'I like a cup. I say: "How much is this cup?"'),
    StoryParagraph('“ 二十 块 钱 。 ” 太 好 了 ， 我 有 钱 ！ 我 买 了 这 个 杯子 。',
        '"Twenty yuan." Great, I have the money! I buy the cup.'),
  ], [
    StoryQuestion('他们 什么 时候 去 商店 ？', 'When do they go to the shop?', ['上午', '中午', '下午'], 0),
    StoryQuestion('妈妈 买 了 什么 ？', 'What does Mum buy?', ['衣服', '苹果', '杯子'], 1),
    StoryQuestion('杯子 多少 钱 ？', 'How much is the cup?', ['五块', '十块', '二十块'], 2),
  ]),
  Story('where-is-the-cat', '咪咪在哪儿？', 'Where is Mimi?', 'The cat has disappeared. Where can she be?', [
    StoryParagraph('我 家 有 一 只 小 猫 ， 名字 叫 咪咪 。', 'We have a little cat at home. Her name is Mimi.'),
    StoryParagraph('今天 下午 我 回 家 ， 咪咪 不 在 桌子 上 。',
        'This afternoon I come home, and Mimi is not on the table.'),
    StoryParagraph('咪咪 在 哪儿 ？ 我 看 椅子 下 ： 没有 。 我 看 衣服 里 ： 没有 。',
        'Where is Mimi? I look under the chair: not there. I look in the clothes: not there.'),
    StoryParagraph('我 很 不 高兴 。 五 点 ， 妈妈 回 来 了 。', 'I am very unhappy. At five o\'clock, Mum comes home.'),
    StoryParagraph('妈妈 说 ： “ 你 看 ， 咪咪 在 电脑 后面 睡觉 ！ ” 太 好 了 ！',
        'Mum says: "Look, Mimi is sleeping behind the computer!" Great!'),
  ], [
    StoryQuestion('小 猫 叫 什么 名字 ？', 'What is the cat called?', ['豆豆', '咪咪', '小明'], 1),
    StoryQuestion('咪咪 在 哪儿 ？', 'Where is Mimi?', ['椅子下', '衣服里', '电脑后面'], 2),
    StoryQuestion('妈妈 几 点 回 家 ？', 'What time does Mum come home?', ['五点', '三点', '九点'], 0),
  ]),
  Story('rainy-sunday', '下雨的星期天', 'A rainy Sunday', 'Bad weather, a phone call and a film.', [
    StoryParagraph('今天 星期天 ， 天气 不 好 ， 下雨 了 。', 'Today is Sunday. The weather is bad; it is raining.'),
    StoryParagraph('我 不 想 去 商店 ， 我 想 在 家 看 书 。', 'I don\'t want to go to the shop. I want to read at home.'),
    StoryParagraph('下午 ， 我 的 同学 打电话 ： “ 喂 ！ 你 在 家 吗 ？ 我们 去 看 电影 ， 怎么样 ？ ”',
        'In the afternoon, my classmate calls: "Hello! Are you at home? Let\'s go and see a film, how about it?"'),
    StoryParagraph('我 说 ： “ 好 ！ 几 点 ？ ” “ 三 点 。 我 坐 出租车 来 你 家 。 ”',
        'I say: "OK! What time?" "Three o\'clock. I\'ll come to your home by taxi."'),
    StoryParagraph('电影 很 好 ， 我 很 高兴 。', 'The film is good. I am very happy.'),
  ], [
    StoryQuestion('今天 天气 怎么样 ？', 'How is the weather today?', ['很热', '下雨', '很好'], 1),
    StoryQuestion('同学 几 点 来 ？', 'What time does the classmate come?', ['三点', '十点', '一点'], 0),
    StoryQuestion('他们 去 做 什么 ？', 'What do they go to do?', ['买东西', '看电影', '吃米饭'], 1),
  ]),
  Story('restaurant', '在饭馆', 'At the restaurant', 'Lunch with a friend, and paying the bill.', [
    StoryParagraph('中午 ， 我 和 朋友 去 饭馆 吃 饭 。', 'At noon, my friend and I go to a restaurant to eat.'),
    StoryParagraph('朋友 说 ： “ 你 想 吃 什么 ？ ” 我 说 ： “ 我 想 吃 米饭 和 菜 。 ”',
        'My friend says: "What would you like to eat?" I say: "I\'d like rice and some dishes."'),
    StoryParagraph('“ 你 喝 茶 吗 ？ ” “ 不 喝 ， 我 喝 水 。 ”', '"Do you drink tea?" "No, I\'ll have water."'),
    StoryParagraph('菜 很 多 ， 我们 吃 了 很 多 。', 'There are lots of dishes, and we eat a lot.'),
    StoryParagraph('朋友 说 ： “ 多少 钱 ？ ” “ 八十 块 。 ” 我们 一 个 人 四十 块 。',
        'My friend asks: "How much is it?" "Eighty yuan." That\'s forty yuan each.'),
  ], [
    StoryQuestion('他们 什么 时候 去 饭馆 ？', 'When do they go to the restaurant?', ['上午', '中午', '下午'], 1),
    StoryQuestion('我 喝 什么 ？', 'What do I drink?', ['水', '茶', '咖啡'], 0),
    StoryQuestion('一 个 人 多少 钱 ？', 'How much does each person pay?', ['八十块', '二十块', '四十块'], 2),
  ]),
  Story('chinese-friend', '我的中国朋友', 'My Chinese friend', 'Meet Wang Li from Beijing.', [
    StoryParagraph('我 有 一 个 中国 朋友 ， 她 叫 王丽 。', 'I have a Chinese friend. Her name is Wang Li.'),
    StoryParagraph('王丽 是 北京 人 ， 她 二十 岁 。 她 是 学生 ， 在 学校 学习 。',
        'Wang Li is from Beijing. She is twenty. She is a student and studies at school.'),
    StoryParagraph('她 会 说 汉语 ， 我 会 说 一点儿 汉语 。 她 能 读 很 多 字 ！',
        'She speaks Chinese, and I speak a little Chinese. She can read lots of characters!'),
    StoryParagraph('我们 都 喜欢 狗 。 星期六 ， 我们 在 她 家 看 电视 ， 吃 水果 。',
        'We both like dogs. On Saturday we watch TV and eat fruit at her home.'),
    StoryParagraph('我们 是 好 朋友 。', 'We are good friends.'),
  ], [
    StoryQuestion('王丽 是 哪儿 人 ？', 'Where is Wang Li from?', ['北京', '学校', '医院'], 0),
    StoryQuestion('王丽 做 什么 ？', 'What does Wang Li do?', ['老师', '医生', '学生'], 2),
    StoryQuestion('他们 都 喜欢 什么 ？', 'What do they both like?', ['猫', '狗', '电影'], 1),
  ]),
  Story('birthday', '妈妈的生日', 'Mum\'s birthday', 'Shopping for a birthday present.', [
    StoryParagraph('今天 是 三 月 九 号 ， 是 妈妈 的 生日 。', 'Today is March 9th. It is Mum\'s birthday.'),
    StoryParagraph('爸爸 和 我 去 商店 给 妈妈 买 东西 。', 'Dad and I go to the shop to buy something for Mum.'),
    StoryParagraph('我们 买 了 一 些 漂亮 的 衣服 和 一 个 杯子 。', 'We buy some pretty clothes and a cup.'),
    StoryParagraph('下午 ， 我们 在 饭馆 吃 饭 。 妈妈 说 ： “ 衣服 太 漂亮 了 ！ 谢谢 你们 ！ ”',
        'In the afternoon we eat at a restaurant. Mum says: "The clothes are so pretty! Thank you!"'),
    StoryParagraph('妈妈 很 高兴 ， 我们 都 很 高兴 。', 'Mum is very happy, and we are all very happy.'),
  ], [
    StoryQuestion('妈妈 的 生日 是 几 月 几 号 ？', 'When is Mum\'s birthday?', ['三月九号', '九月三号', '五月一号'], 0),
    StoryQuestion('他们 买 了 什么 ？', 'What do they buy?', ['苹果和茶', '衣服和杯子', '电脑'], 1),
    StoryQuestion('他们 在 哪儿 吃 饭 ？', 'Where do they eat?', ['在家', '在学校', '在饭馆'], 2),
  ]),
  Story('xiaoming-day', '小明的一天', 'A day in Xiaoming\'s life', 'School, lunch, TV and bed.', [
    StoryParagraph('小明 是 学生 。 他 上午 八 点 去 学校 。', 'Xiaoming is a student. He goes to school at eight in the morning.'),
    StoryParagraph('他 坐 出租车 去 吗 ？ 不 ， 学校 在 他 家 后面 。',
        'Does he go by taxi? No, the school is behind his home.'),
    StoryParagraph('上午 ， 他 学习 汉语 ， 写 汉字 。', 'In the morning he studies Chinese and writes characters.'),
    StoryParagraph('中午 ， 他 和 同学 在 学校 吃 米饭 。', 'At noon he eats rice at school with his classmates.'),
    StoryParagraph('下午 四 点 ， 他 回 家 看 电视 。 十 点 ， 他 睡觉 了 。',
        'At four in the afternoon he goes home and watches TV. At ten he goes to bed.'),
  ], [
    StoryQuestion('小明 几 点 去 学校 ？', 'What time does Xiaoming go to school?', ['八点', '四点', '十点'], 0),
    StoryQuestion('学校 在 哪儿 ？', 'Where is the school?', ['在医院前面', '在他家后面', '在北京'], 1),
    StoryQuestion('小明 几 点 睡觉 ？', 'What time does Xiaoming go to bed?', ['八点', '四点', '十点'], 2),
  ]),
  Story('rabbit-fable', '守株待兔', 'The farmer and the rabbit', 'A classic fable about waiting for luck.', [
    StoryParagraph('很 多 年 前 ， 中国 有 一 个 农民 。', 'Many years ago, there was a farmer in China.'),
    StoryParagraph('一 天 ， 他 在 工作 。 一 只 兔子 跑 来 ， 撞 在 树 上 ， 死 了 。',
        'One day he was working. A rabbit came running, bumped into a tree and died.'),
    StoryParagraph('农民 很 高兴 。 他 想 ： “ 太 好 了 ！ 我 不 工作 了 。 ”',
        'The farmer was very happy. He thought: "Great! I won\'t work any more."'),
    StoryParagraph('他 每 天 坐 在 树 下 ， 看 兔子 来 不 来 。',
        'Every day he sat under the tree, watching to see if a rabbit would come.'),
    StoryParagraph('兔子 没有 再 来 。 他 的 菜 都 死 了 。', 'No rabbit ever came again. All his vegetables died.'),
    StoryParagraph('这 个 故事 叫 “ 守株待兔 ” 。', 'This story is called "守株待兔".'),
  ], [
    StoryQuestion('兔子 撞 在 什么 上 ？', 'What did the rabbit bump into?', ['桌子', '树', '椅子'], 1),
    StoryQuestion('农民 每 天 做 什么 ？', 'What did the farmer do every day?', ['在饭馆吃饭', '坐在树下', '在学校学习'], 1),
    StoryQuestion('他 的 菜 怎么样 了 ？', 'What happened to his vegetables?', ['都死了', '很好吃', '很多'], 0),
  ]),
  Story('snake-fable', '画蛇添足', 'Drawing legs on a snake', 'A classic fable about doing too much.', [
    StoryParagraph('很 多 年 前 ， 有 几 个 人 想 喝 一 杯 酒 。 一 杯 酒 太 少 了 。',
        'Many years ago, some people wanted to drink a cup of wine. One cup of wine was too little.'),
    StoryParagraph('一 个 人 说 ： “ 我们 都 画 蛇 。 谁 第一 画 好 ， 谁 喝 酒 ！ ”',
        'One person said: "Let\'s all draw a snake. Whoever finishes first drinks the wine!"'),
    StoryParagraph('一 个 人 很 快 画 好 了 。 他 说 ： “ 我 能 给 蛇 画 脚 ！ ”',
        'One person finished very quickly. He said: "I can even draw feet on the snake!"'),
    StoryParagraph('他 在 画 脚 的 时候 ， 一 个 人 画 好 了 蛇 。', 'While he was drawing the feet, another person finished their snake.'),
    StoryParagraph('那 个 人 说 ： “ 蛇 没有 脚 ！ 你 画 的 不 是 蛇 。 ” 他 喝 了 酒 。',
        'That person said: "Snakes have no feet! What you drew is not a snake." And he drank the wine.'),
    StoryParagraph('画 脚 的 人 很 不 高兴 。', 'The man who drew the feet was very unhappy.'),
  ], [
    StoryQuestion('他们 想 喝 什么 ？', 'What did they want to drink?', ['茶', '水', '酒'], 2),
    StoryQuestion('第一 个 画 好 的 人 给 蛇 画 了 什么 ？', 'What did the first person to finish add to the snake?', ['脚', '猫', '树'], 0),
    StoryQuestion('画 脚 的 人 高兴 吗 ？', 'Was the man who drew the feet happy?', ['很高兴', '不高兴'], 1),
  ]),
];
