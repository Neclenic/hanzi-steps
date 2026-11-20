// Short culture notes, each shown inside the lesson it fits best.
// All text is original. Words are (Chinese, pinyin, English) and may go beyond the course.

class CultureNote {
  final String lessonId;
  final String emoji;
  final String title;
  final String text;
  final List<(String, String, String)> words;
  const CultureNote(this.lessonId, this.emoji, this.title, this.text, [this.words = const []]);
}

const cultureNotes = <CultureNote>[
  // ---- HSK 1 ----
  CultureNote('greet-1', '👋', 'Have you eaten?',
      'Friends often greet each other with 吃了吗？ ("Have you eaten?") instead of 你好. It is just a friendly hello, '
          'not an invitation to lunch, so a short 吃了 ("I have") is a fine answer.',
      [('吃了吗？', 'chī le ma?', 'Have you eaten?')]),
  CultureNote('greet-2', '🙏', 'Thanks between friends',
      'With shop staff and strangers, 谢谢 is always right. But close friends and family rarely thank each other '
          'for small things: lots of 谢谢 can sound a little distant, as if you were strangers.'),
  CultureNote('num-1', '✋', 'Counting on one hand',
      'Chinese has hand signs for 6 to 10, so any number fits on one hand. 6 is the thumb and little finger, '
          '8 is the thumb and index finger (an L shape), and 10 is a fist or two crossed index fingers. '
          'Very handy in a noisy market.'),
  CultureNote('num-2', '🍀', 'Lucky and unlucky numbers',
      '8 bā sounds a bit like 发 fā ("to get rich"), so it is the luckiest number: phone numbers full of 8s cost more, '
          'and the 2008 Beijing Olympics opened on 8 August at 8:08 pm. 4 sì sounds like 死 sǐ ("death"), '
          'so some buildings have no 4th floor.',
      [('发', 'fā', 'to get rich'), ('死', 'sǐ', 'to die')]),
  CultureNote('ppl-2', '🍎', 'Calling your teacher',
      'Teachers are called by their family name plus 老师: 王老师 is "Teacher Wang". Students never use a teacher\'s '
          'first name. China celebrates Teachers\' Day on 10 September.',
      [('王老师', 'Wáng lǎoshī', 'Teacher Wang')]),
  CultureNote('intro-2', '🪪', 'Family name first',
      'Chinese names start with the family name: in 王方, 王 is the family name and 方 the given name. Most family names '
          'are one character, and 王, 李 and 张 alone are shared by hundreds of millions of people. Friends may call each '
          'other 老王 ("old Wang") or 小李 ("little Li"), depending on who is older.',
      [('老王', 'Lǎo Wáng', 'old Wang'), ('小李', 'Xiǎo Lǐ', 'little Li')]),
  CultureNote('fam-1', '👨‍👩‍👧', 'Everyone is family',
      'Children call grown-ups they don\'t know 叔叔 ("uncle") and 阿姨 ("auntie"), and young people call each other '
          '哥 or 姐 ("big brother", "big sister"). Family words are used to be friendly, not only for relatives.',
      [('叔叔', 'shūshu', 'uncle'), ('阿姨', 'āyí', 'auntie')]),
  CultureNote('fam-2', '🍜', 'Long-life noodles',
      'On birthdays many people eat 长寿面, "long-life noodles": long noodles for a long life, so you shouldn\'t cut them. '
          'Asking someone\'s age is normal. 你几岁？ is for children; ask adults 你多大？.',
      [('长寿面', 'chángshòu miàn', 'long-life noodles'), ('你多大？', 'nǐ duō dà?', 'How old are you?')]),
  CultureNote('food-1', '🍵', 'Tea',
      'Green tea is the most common tea in China, and it is drunk without milk or sugar. When someone pours you tea, '
          'you can tap two fingers on the table as a quiet "thank you", a custom from the south.'),
  CultureNote('food-2', '🥢', 'Sharing dishes',
      'At a restaurant, dishes go in the middle of the table and everyone shares them. Never stand your chopsticks up in '
          'a bowl of rice: it looks like incense at a funeral. Friends often argue about who pays, saying 我来！ ("I\'ll get it!").',
      [('我来！', 'wǒ lái!', 'I\'ll get it!')]),
  CultureNote('shop-1', '📱', 'Paying with your phone',
      'In Chinese cities nearly everyone pays by scanning a QR code with WeChat Pay or Alipay, even at a fruit stall. '
          'Cash is still accepted, and visitors can link a foreign bank card to these apps.',
      [('微信支付', 'Wēixìn zhīfù', 'WeChat Pay'), ('支付宝', 'Zhīfùbǎo', 'Alipay')]),
  CultureNote('shop-2', '🏷️', 'Bargaining',
      'At markets and small shops, bargaining is part of the fun. In supermarkets and shopping centres prices are fixed. '
          'A smile and 便宜一点吧？ ("a bit cheaper?") is the classic start.',
      [('便宜一点吧？', 'piányi yìdiǎn ba?', 'A bit cheaper?')]),
  CultureNote('date-2', '📅', 'Numbered days',
      'The days of the week are simply numbered: 星期一 is "week day one", Monday, up to 星期六, Saturday. Sunday is '
          '星期天 or 星期日. Months work the same way: 一月 is January, 十二月 is December.'),
  CultureNote('time-2', '😴', 'The lunch nap',
      'Lunch is early, around noon, and many people take a short nap afterwards, called 午睡. Some schools and offices '
          'even have a quiet nap time after lunch.',
      [('午睡', 'wǔshuì', 'midday nap')]),
  CultureNote('place-1', '🎓', 'The big exam',
      'Most Chinese students wear a tracksuit as their school uniform. At the end of high school comes the 高考, the '
          'university entrance exam in June. Millions take it on the same days, and it can decide which university they go to.',
      [('高考', 'gāokǎo', 'university entrance exam')]),
  CultureNote('go-1', '🚄', 'Fast trains',
      'China has the world\'s largest high-speed rail network, with trains running at about 300 km/h. Beijing to Shanghai '
          'takes around four and a half hours. Before Spring Festival, hundreds of millions of people travel home, '
          'the biggest yearly journey on Earth.'),
  CultureNote('go-2', '💚', 'Add me on WeChat',
      'Instead of swapping phone numbers, people usually say 加个微信 ("let\'s add each other on WeChat"). The app is used '
          'for messages, calls, paying, booking and much more.',
      [('加个微信', 'jiā ge Wēixìn', 'add each other on WeChat')]),
  CultureNote('work-2', '✍️', 'Simplified and traditional',
      'Mainland China uses simplified characters, which have fewer strokes: 汉 instead of 漢. Taiwan and Hong Kong still '
          'use traditional characters. The standard spoken language you\'re learning is called 普通话.',
      [('普通话', 'pǔtōnghuà', 'Standard Mandarin')]),
  CultureNote('like-1', '🐉', 'Your zodiac animal',
      'Every year belongs to one of 12 animals, and people ask 你属什么？ ("What\'s your animal?"). 2026 is the year of '
          'the horse. The dog is one of the 12, but the cat is not: an old story says the rat tricked the cat into missing '
          'the race.',
      [('你属什么？', 'nǐ shǔ shénme?', 'What\'s your zodiac animal?')]),

  // ---- HSK 2 ----
  CultureNote('h2-fam-1', '👫', 'Older or younger?',
      'Chinese has no single word for "brother" or "sister": you always say whether they\'re older or younger. Many people '
          'grew up as only children, so they call close cousins 哥哥 and 姐姐 too.'),
  CultureNote('h2-col-1', '🧧', 'Red and white',
      'Red is the colour of luck and happiness, seen at weddings and New Year. Money is given in red envelopes, 红包. '
          'White is the colour of mourning, so avoid white wrapping paper for presents. On Chinese stock screens, red '
          'means prices are going up!',
      [('红包', 'hóngbāo', 'red envelope with money')]),
  CultureNote('h2-food-1', '🧋', 'Milk tea',
      'Coffee shops are now everywhere in Chinese cities, but the real favourite of young people is 奶茶, milk tea, '
          'often with chewy tapioca balls.',
      [('奶茶', 'nǎichá', 'milk tea')]),
  CultureNote('h2-num-1', '🔢', 'Counting in ten-thousands',
      'Big numbers are counted in 万 (10,000), not in thousands. 50,000 is 五万, "five ten-thousands", and 1,000,000 '
          'is 一百万, "a hundred ten-thousands". For 100,000,000 there is a new word, 亿.',
      [('万', 'wàn', 'ten thousand'), ('亿', 'yì', 'a hundred million')]),
  CultureNote('h2-day-1', '🌅', 'Mornings in the park',
      'Early in the morning, parks are full of older people doing taiji, dancing, singing or writing characters on the '
          'ground with water. In the evening, groups meet in squares for 广场舞, "square dancing".',
      [('太极拳', 'tàijíquán', 'taiji'), ('广场舞', 'guǎngchǎngwǔ', 'square dancing')]),
  CultureNote('h2-fun-1', '🏓', 'Table tennis',
      'Table tennis, 乒乓球, is played in schools, parks and even outside apartment blocks, on concrete tables. China '
          'has won most of the Olympic gold medals in it since it joined the Games.',
      [('乒乓球', 'pīngpāngqiú', 'table tennis')]),
  CultureNote('h2-wx-1', '♨️', 'Drink more hot water',
      'Many Chinese people drink warm or hot water, even in summer, because it\'s thought to be good for you. If you say '
          'you feel ill, someone will almost certainly tell you 多喝热水 ("drink more hot water").',
      [('多喝热水', 'duō hē rè shuǐ', 'drink more hot water')]),
  CultureNote('h2-talk-1', '🎁', 'Giving presents',
      'Give and take presents with both hands. Never give a clock: 送钟 ("give a clock") sounds like 送终, being with '
          'someone when they die. A present is often politely refused once or twice before it is accepted.',
      [('送钟', 'sòng zhōng', 'to give a clock')]),

  // ---- HSK 3 ----
  CultureNote('h3-ppl-1', '👵', 'Grandparents',
      'Grandparents often help bring up their grandchildren and may live with the family. Your father\'s parents are '
          '爷爷 and 奶奶, and your mother\'s parents have their own words: 外公 and 外婆.',
      [('外公', 'wàigōng', 'mother\'s father'), ('外婆', 'wàipó', 'mother\'s mother')]),
  CultureNote('h3-food-3', '🥂', 'Cheers!',
      'At a dinner, people toast with 干杯, literally "dry the glass". When you clink glasses with someone older or more '
          'senior, hold your glass a little lower than theirs to show respect.',
      [('干杯', 'gānbēi', 'cheers!')]),
  CultureNote('h3-nat-1', '🌾', '24 solar terms',
      'The traditional calendar splits the year into 24 short seasons called 节气, such as 立春, "the start of spring", '
          'in early February. Farmers used them to know when to plant, and many people still eat special foods on these days.',
      [('节气', 'jiéqì', 'solar term'), ('立春', 'lìchūn', 'start of spring')]),
  CultureNote('h3-nat-2', '🥮', 'The Mid-Autumn Festival',
      'On the full moon of the eighth lunar month (September or October), families meet, look at the moon and eat '
          'mooncakes. The story goes that 嫦娥 Cháng\'é flew to the moon and still lives there with a jade rabbit.',
      [('中秋节', 'Zhōngqiū jié', 'Mid-Autumn Festival'), ('月饼', 'yuèbǐng', 'mooncake')]),
  CultureNote('h3-nat-3', '🐼', 'Bear-cats',
      '熊猫 means "bear-cat". Wild giant pandas live in the bamboo forests of the mountains in Sichuan, Shaanxi and Gansu, '
          'and spend up to 14 hours a day eating bamboo.'),
  CultureNote('h3-town-2', '🧭', 'North and south',
      'In the north people eat more wheat: noodles, dumplings and steamed buns. In the south, rice is the main food. '
          'People love to argue about it, for example whether tofu pudding should be sweet or salty.',
      [('饺子', 'jiǎozi', 'dumplings'), ('包子', 'bāozi', 'steamed bun')]),
  CultureNote('h3-trip-2', '🤝', 'Being a good host',
      'Hosts often pick their guests up from the airport and insist on paying for meals. Guests say 麻烦你了 ("sorry for '
          'the trouble") and return the favour another time.',
      [('麻烦你了', 'máfan nǐ le', 'sorry for the trouble')]),
  CultureNote('h3-fun-2', '🏮', 'Spring Festival',
      'Chinese New Year, 春节, falls in January or February. Families gather for a big dinner on New Year\'s Eve, put red '
          'couplets on their doors and give children red envelopes. People wish each other 新年快乐 or 恭喜发财 '
          '("wishing you wealth").',
      [('新年快乐', 'xīnnián kuàilè', 'Happy New Year'), ('恭喜发财', 'gōngxǐ fācái', 'wishing you wealth')]),
  CultureNote('h3-fun-3', '🌿', 'Chinese medicine',
      'Traditional Chinese medicine, 中医, is used alongside Western medicine. It includes herbal teas and acupuncture, '
          'and sorts foods into "hot" and "cold" kinds that should stay in balance.',
      [('中医', 'zhōngyī', 'Chinese medicine')]),
];

final _byLesson = {for (final n in cultureNotes) n.lessonId: n};

/// The culture note shown in a lesson, if it has one.
CultureNote? cultureFor(String lessonId) => _byLesson[lessonId];
