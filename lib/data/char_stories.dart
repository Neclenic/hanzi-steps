// "Character stories": how a character is built from smaller parts, with a hint to
// remember it. Many hints follow the real history of the character; some are simply
// memory aids, and the app says so.

/// A part of a character and what it means, e.g. ('女', 'woman').
typedef CharPart = (String, String);

class CharStory {
  final String char;
  final List<CharPart> parts;
  final String hint;
  const CharStory(this.char, this.parts, this.hint);
}

// Parts that come up again and again.
const _person = ('亻', 'person');
const _woman = ('女', 'woman');
const _child = ('子', 'child');
const _mouth = ('口', 'mouth');
const _words = ('讠', 'words, speech');
const _water = ('氵', 'water');
const _roof = ('宀', 'roof');
const _sun = ('日', 'sun');
const _moon = ('月', 'moon');
const _heart = ('心', 'heart');
const _plant = ('艹', 'grass, plants');
const _hand = ('扌', 'hand');
const _food = ('饣', 'food');
const _metal = ('钅', 'metal');
const _foot = ('⻊', 'foot');
const _silk = ('纟', 'silk, thread');
const _clothes = ('衤', 'clothing');
const _ice = ('冫', 'ice');
const _fire = ('灬', 'fire');
const _ill = ('疒', 'illness');
const _animal = ('犭', 'animal');
const _bamboo = ('⺮', 'bamboo');
const _gate = ('门', 'door, gate');
const _earth = ('土', 'earth');
const _rain = ('雨', 'rain');
const _horse = ('马', 'horse');

const charStories = <CharStory>[
  // Pictures: characters that started as drawings.
  CharStory('人', [], 'A person walking, seen from the side: two legs.'),
  CharStory('大', [('人', 'person')], 'A person stretching their arms out wide: big.'),
  CharStory('天', [('一', 'line'), ('大', 'big person')], 'The line above a big person is the sky.'),
  CharStory('太', [('大', 'big'), ('丶', 'dot')], 'Big, plus one more dot: too much, extremely.'),
  CharStory('口', [], 'An open mouth.'),
  CharStory('日', [], 'The sun, drawn as a box with a line in it.'),
  CharStory('月', [], 'A crescent moon. It also means "month", the time from one new moon to the next.'),
  CharStory('山', [], 'Three mountain peaks.'),
  CharStory('水', [], 'Water flowing in a stream, with drops splashing to the sides.'),
  CharStory('雨', [], 'Raindrops falling from a cloud under the sky.'),
  CharStory('火', [], 'Flames rising from a fire.'),
  CharStory('本', [('木', 'tree'), ('一', 'mark')], 'A mark at the bottom of a tree points to the root. It became the word for books.'),
  CharStory('上', [], 'A mark above a line: up, on top.'),
  CharStory('下', [], 'A mark below a line: down, under.'),
  CharStory('中', [('口', 'box'), ('丨', 'line')], 'A line straight through the middle of a box.'),
  CharStory('小', [], 'Something split into small bits.'),
  CharStory('米', [], 'Grains of rice scattered around.'),
  CharStory('鱼', [], 'A fish: the head on top, the body with scales, and the tail at the bottom.'),
  CharStory('马', [], 'A horse standing on its side: head, mane and legs.'),
  CharStory('鸟', [], 'A bird with its head, wing and tail.'),
  CharStory('门', [], 'A gate with two doors.'),
  CharStory('车', [], 'A cart seen from above: the axle and two wheels.'),
  CharStory('手', [], 'A hand with its fingers spread.'),
  CharStory('心', [], 'A heart.'),
  CharStory('伞', [], 'An umbrella: the top, the ribs and the handle.'),
  CharStory('电', [], 'This started as a picture of lightning. Lightning is electricity.'),
  CharStory('衣', [], 'A piece of clothing with a collar and sleeves.'),
  CharStory('网', [], 'A net, with the knots of the mesh inside.'),
  CharStory('北', [('人', 'person'), ('人', 'person')], 'Two people sitting back to back. It first meant "back", and the north is behind you when you face the sun.'),
  CharStory('从', [('人', 'person'), ('人', 'person')], 'One person following behind another: from, following.'),
  CharStory('坐', [('人', 'person'), ('人', 'person'), _earth], 'Two people sitting on the ground.'),

  // Built from meaningful parts.
  CharStory('好', [_woman, _child], 'A woman with her child: good.'),
  CharStory('休', [_person, ('木', 'tree')], 'A person leaning against a tree: to rest (休息).'),
  CharStory('明', [_sun, _moon], 'The sun and the moon together: bright, clear.'),
  CharStory('男', [('田', 'field'), ('力', 'strength')], 'Strength in the field: a man.'),
  CharStory('家', [_roof, ('豕', 'pig')], 'A pig under a roof. In old China, a home had its animals close by.'),
  CharStory('安', [_roof, _woman], 'A woman safe under a roof: calm, safe (安静).'),
  CharStory('字', [_roof, _child], 'A child under a roof, learning to write characters.'),
  CharStory('看', [('手', 'hand'), ('目', 'eye')], 'A hand held over the eyes to look into the distance.'),
  CharStory('问', [_gate, _mouth], 'A mouth at the door: to ask.'),
  CharStory('间', [_gate, _sun], 'Sunlight shining through the gap in a door: between, a room (房间).'),
  CharStory('信', [_person, ('言', 'words')], "A person's word: to trust, or a letter."),
  CharStory('话', [_words, ('舌', 'tongue')], 'Words made with the tongue: speech (说话).'),
  CharStory('国', [('囗', 'border'), ('玉', 'jade')], 'A treasure inside a border: a country.'),
  CharStory('姓', [_woman, ('生', 'birth')], 'What you get from your mother at birth: your family name.'),
  CharStory('菜', [_plant, ('采', 'to pick')], 'Plants you pick: vegetables, and a dish of food.'),
  CharStory('药', [_plant, ('约', 'sound yuē')], 'Medicine was first made from plants, so it has the plant part on top.'),
  CharStory('花', [_plant, ('化', 'change')], 'A plant that changes as it opens: a flower.'),
  CharStory('茶', [_plant, ('人', 'person'), ('木', 'tree')], 'A person between grass and a tree: tea leaves come from a bush.'),
  CharStory('笔', [_bamboo, ('毛', 'hair')], 'A brush made of bamboo and animal hair: a pen.'),
  CharStory('筷', [_bamboo, ('快', 'quick, sound kuài')], 'Bamboo sticks for eating quickly: chopsticks (筷子).'),
  CharStory('秋', [('禾', 'grain'), ('火', 'fire')], 'Grain is harvested and the fields are burned: autumn.'),
  CharStory('冰', [_ice, ('水', 'water')], 'Water that has turned to ice.'),
  CharStory('热', [('执', 'to hold'), _fire], 'The four dots at the bottom are fire: hot.'),
  CharStory('灯', [('火', 'fire'), ('丁', 'sound dīng')], 'Fire that gives light: a lamp.'),
  CharStory('忘', [('亡', 'lost'), _heart], 'Lost from the heart: to forget (忘记).'),
  CharStory('想', [('相', 'sound xiāng'), _heart], 'The heart under it shows this is about thinking and wanting.'),
  CharStory('思', [('田', 'head'), _heart], 'The top was once a picture of the head. Thinking with your head and heart (意思).'),
  CharStory('哭', [('口', 'mouth'), ('口', 'mouth'), ('犬', 'dog')], 'Two open mouths howling like a dog: to cry.'),
  CharStory('骑', [_horse, ('奇', 'sound qí')], 'Something you do on a horse: to ride (骑自行车).'),
  CharStory('钱', [_metal, ('戋', 'sound')], 'Old coins were metal: money.'),
  CharStory('银', [_metal, ('艮', 'sound')], 'A metal: silver. A bank (银行) keeps the silver.'),
  CharStory('病', [_ill, ('丙', 'sound bǐng')], 'The 疒 part is a sickbed. Under it: an illness.'),
  CharStory('疼', [_ill, ('冬', 'sound dōng')], 'The sickbed part again: it hurts.'),
  CharStory('城', [_earth, ('成', 'sound chéng')], 'Old city walls were made of earth: a city.'),
  CharStory('路', [_foot, ('各', 'each')], 'Where each foot goes: a road.'),
  CharStory('跑', [_foot, ('包', 'sound bāo')], 'Feet moving fast: to run (跑步).'),
  CharStory('踢', [_foot, ('易', 'sound yì')], 'Something you do with your foot: to kick (踢足球).'),
  CharStory('洗', [_water, ('先', 'sound xiān')], 'Water: to wash.'),
  CharStory('河', [_water, ('可', 'sound kě')], 'Water: a river (黄河).'),
  CharStory('游', [_water, ('斿', 'a flag')], 'Moving through water: to swim (游泳).'),
  CharStory('汉', [_water, ('又', 'a short form')], 'Named after the Han river. The Han dynasty took its name, and Chinese people call their language 汉语.'),
  CharStory('酒', [_water, ('酉', 'wine jar')], 'Liquid in a jar: alcohol (啤酒).'),
  CharStory('拿', [('合', 'together'), ('手', 'hand')], 'Bringing hands together: to take, to hold.'),
  CharStory('打', [_hand, ('丁', 'nail')], 'A hand hitting a nail: to hit, and many actions done with the hands (打电话).'),
  CharStory('找', [_hand, ('戈', 'spear')], 'A hand reaching out: to look for.'),
  CharStory('红', [_silk, ('工', 'sound gōng')], 'The silk part shows it first meant red silk.'),
  CharStory('衬', [_clothes, ('寸', 'sound')], 'The clothing part tells you it is something to wear: a shirt (衬衫).'),
  CharStory('裤', [_clothes, ('库', 'sound kù')], 'Clothing again: trousers (裤子).'),
  CharStory('裙', [_clothes, ('君', 'sound jūn')], 'Clothing again: a skirt (裙子).'),
  CharStory('冷', [_ice, ('令', 'sound lìng')], 'The two drops on the left are ice: cold.'),
  CharStory('晴', [_sun, ('青', 'blue sky')], 'Sun and blue sky: a sunny day.'),
  CharStory('阴', [('阝', 'hill'), _moon], 'The moon instead of the sun: a cloudy, dark day.'),
  CharStory('时', [_sun, ('寸', 'measure')], 'Measuring the sun: time.'),
  CharStory('早', [_sun, ('十', 'the ground')], 'The sun just above the ground: early morning.'),
  CharStory('星', [_sun, ('生', 'to be born')], 'Little suns being born in the sky: stars.'),
  CharStory('雪', [_rain, ('彐', 'a hand')], 'Rain you can catch in your hand: snow.'),
  CharStory('猫', [_animal, ('苗', 'sound miáo')], 'An animal whose name sounds like what it says: miāo!'),
  CharStory('狗', [_animal, ('句', 'sound gōu')], 'The animal part, plus a part that gives the sound: a dog.'),
  CharStory('吃', [_mouth, ('乞', 'sound qǐ')], 'Something you do with your mouth: to eat.'),
  CharStory('喝', [_mouth, ('曷', 'sound hé')], 'Something you do with your mouth: to drink.'),
  CharStory('叫', [_mouth, ('丩', 'sound jiū')], 'Using your mouth: to call, to be called.'),
  CharStory('唱', [_mouth, ('昌', 'sound chāng')], 'Using your mouth: to sing (唱歌).'),
  CharStory('吗', [_mouth, _horse], 'A mouth for the question, and 马 mǎ for the sound: ma?'),
  CharStory('妈', [_woman, _horse], 'A woman, and 马 mǎ for the sound: mā, mum.'),
  CharStory('姐', [_woman, ('且', 'sound qiě')], 'A woman, plus a sound part: older sister.'),
  CharStory('妹', [_woman, ('未', 'sound wèi')], 'A woman, plus a sound part: younger sister.'),
  CharStory('她', [_woman, ('也', 'also')], 'Like 他 "he", but with the woman part: she.'),
  CharStory('他', [_person, ('也', 'also')], 'A person: he.'),
  CharStory('你', [_person, ('尔', 'you, in old Chinese')], 'A person, and an old word for "you".'),
  CharStory('们', [_person, ('门', 'sound mén')], 'Added after people words to make more than one: 我们, 你们.'),
  CharStory('住', [_person, ('主', 'master')], 'A person who is master of a place: to live there.'),
  CharStory('体', [_person, ('本', 'root')], "The root of a person: the body (身体)."),
  CharStory('说', [_words, ('兑', 'sound')], 'The speech part: to speak.'),
  CharStory('语', [_words, ('吾', 'I, me')], 'The words I speak: language (汉语).'),
  CharStory('请', [_words, ('青', 'sound qīng')], 'Polite words: please, to invite.'),
  CharStory('谢', [_words, ('射', 'sound shè')], 'Words of thanks: 谢谢.'),
  CharStory('读', [_words, ('卖', 'sound mài')], 'Speaking words out loud: to read.'),
  CharStory('饿', [_food, ('我', 'I, me')], 'I want food: hungry!'),
  CharStory('饭', [_food, ('反', 'sound fǎn')], 'The food part: a meal, cooked rice (米饭).'),
  CharStory('馆', [_food, ('官', 'official')], 'First a place to eat and stay: 饭馆 restaurant, 宾馆 hotel, 图书馆 library.'),
  CharStory('动', [('云', 'cloud'), ('力', 'strength')], 'Strength that moves the clouds: to move (运动).'),
  CharStory('园', [('囗', 'wall'), ('元', 'sound yuán')], 'A place inside a wall: a garden, a park (公园).'),
  CharStory('熊', [('能', 'able'), _fire], 'The four dots here are four paws: a bear (熊猫, panda).'),
  CharStory('笑', [_bamboo, ('夭', 'bending')], 'Bamboo bending in the wind, like someone bending over laughing.'),
];

final Map<String, CharStory> _byChar = {for (final s in charStories) s.char: s};

/// The story of a character, if there is one.
CharStory? storyOf(String char) => _byChar[char];

/// Stories for the characters of a word, in order.
List<CharStory> storiesFor(String word) => [
      for (final c in word.split('').toSet())
        if (_byChar[c] case final s?) s,
    ];
