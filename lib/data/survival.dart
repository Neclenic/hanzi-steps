// Survival phrases: short packs for getting around in China. Original sentences, written for this app.

/// One phrase. [zh] has spaces between words (for the word-order game).
class Phrase {
  final String zh;
  final String pinyin;
  final String en;

  /// True for something you'll hear (a driver's or waiter's question), false for something you say.
  final bool hear;
  final String? note;
  const Phrase(this.zh, this.pinyin, this.en, {this.hear = false, this.note});

  String get hanzi => zh.replaceAll(' ', '');
}

class PhrasePack {
  final String id;
  final String title;
  final String zhTitle;
  final String pinyinTitle;
  final String scene; // an emoji
  final String intro;
  final List<Phrase> phrases;
  const PhrasePack(this.id, this.title, this.zhTitle, this.pinyinTitle, this.scene, this.intro, this.phrases);
}

typedef _P = Phrase;

const phrasePacks = <PhrasePack>[
  PhrasePack('taxi', 'Taxi', '打车', 'dǎchē', '🚕',
      'Most people book a car on an app (滴滴 Dīdī) but still talk to the driver. Keep the address on your phone to show.', [
    _P('师傅 ， 我 去 机场 。', 'Shīfu, wǒ qù jīchǎng.', 'To the airport, please.',
        note: '师傅 shīfu ("master") is the polite way to speak to a driver.'),
    _P('您 去 哪儿 ？', 'Nín qù nǎr?', 'Where are you going?', hear: true),
    _P('请 到 这个 地址 。', 'Qǐng dào zhège dìzhǐ.', 'Please take me to this address.', note: 'Show the address on your phone as you say it.'),
    _P('到 那儿 要 多 长 时间 ？', 'Dào nàr yào duō cháng shíjiān?', 'How long does it take to get there?'),
    _P('大概 二十 分钟 。', 'Dàgài èrshí fēnzhōng.', 'About twenty minutes.', hear: true),
    _P('我 有点儿 急 。', 'Wǒ yǒudiǎnr jí.', "I'm in a bit of a hurry."),
    _P('请 开 慢 一点儿 。', 'Qǐng kāi màn yìdiǎnr.', 'Please drive a little slower.'),
    _P('就 在 这儿 停 吧 。', 'Jiù zài zhèr tíng ba.', 'You can stop right here.'),
    _P('可以 用 微信 付 吗 ？', 'Kěyǐ yòng Wēixìn fù ma?', 'Can I pay with WeChat?'),
    _P('请 给 我 发票 。', 'Qǐng gěi wǒ fāpiào.', 'A receipt, please.'),
  ]),
  PhrasePack('food', 'Restaurant', '餐厅', 'cāntīng', '🍜',
      'Call the waiter with 服务员 fúwùyuán. Dishes are shared, so order a few for the table.', [
    _P('几 位 ？', 'Jǐ wèi?', 'How many people?', hear: true, note: '位 wèi is the polite counting word for people.'),
    _P('两 位 。', 'Liǎng wèi.', 'Two people.'),
    _P('服务员 ， 请 给 我 菜单 。', 'Fúwùyuán, qǐng gěi wǒ càidān.', 'Excuse me, the menu please.'),
    _P('你们 有 什么 推荐 的 ？', 'Nǐmen yǒu shénme tuījiàn de?', 'What do you recommend?'),
    _P('我 不 吃 肉 。', 'Wǒ bù chī ròu.', "I don't eat meat."),
    _P('不要 太 辣 。', 'Bú yào tài là.', 'Not too spicy, please.'),
    _P('我 对 花生 过敏 。', 'Wǒ duì huāshēng guòmǐn.', "I'm allergic to peanuts."),
    _P('还 要 别的 吗 ？', 'Hái yào biéde ma?', 'Anything else?', hear: true),
    _P('就 这些 ， 谢谢 。', 'Jiù zhèxiē, xièxie.', "That's all, thanks."),
    _P('请 再 来 一 碗 米饭 。', 'Qǐng zài lái yì wǎn mǐfàn.', 'Another bowl of rice, please.'),
    _P('可以 打包 吗 ？', 'Kěyǐ dǎbāo ma?', 'Can you pack this to take away?'),
    _P('买单 ！', 'Mǎidān!', 'The bill, please!'),
  ]),
  PhrasePack('hotel', 'Hotel', '酒店', 'jiǔdiàn', '🏨',
      'Hotels ask for your passport at check-in. Floors are counted like in the US: 一楼 is the ground floor.', [
    _P('我 预订 了 一 个 房间 。', 'Wǒ yùdìng le yí ge fángjiān.', 'I booked a room.'),
    _P('请 给 我 看 一下 您 的 护照 。', 'Qǐng gěi wǒ kàn yíxià nín de hùzhào.', 'May I see your passport, please?', hear: true),
    _P('您 的 房间 在 八 楼 。', 'Nín de fángjiān zài bā lóu.', 'Your room is on the eighth floor.', hear: true),
    _P('早饭 几 点 开始 ？', 'Zǎofàn jǐ diǎn kāishǐ?', 'What time does breakfast start?'),
    _P('无线网 的 密码 是 多少 ？', 'Wúxiànwǎng de mìmǎ shì duōshao?', "What's the Wi-Fi password?",
        note: 'Use 多少 duōshao for anything made of numbers, like a password or phone number.'),
    _P('空调 坏 了 。', 'Kōngtiáo huài le.', 'The air conditioning is broken.'),
    _P('房间 里 没有 热水 。', 'Fángjiān li méiyǒu rèshuǐ.', "There's no hot water in the room."),
    _P('可以 换 一 个 房间 吗 ？', 'Kěyǐ huàn yí ge fángjiān ma?', 'Could I change rooms?'),
    _P('可以 把 行李 放 在 这儿 吗 ？', 'Kěyǐ bǎ xíngli fàng zài zhèr ma?', 'Can I leave my luggage here?'),
    _P('我 想 退房 。', 'Wǒ xiǎng tuìfáng.', "I'd like to check out."),
  ]),
  PhrasePack('shop', 'Shopping', '购物', 'gòuwù', '🛍️',
      'In markets you can bargain. In shops and supermarkets prices are fixed.', [
    _P('这个 多少 钱 ？', 'Zhège duōshao qián?', 'How much is this?'),
    _P('我 只是 看看 。', 'Wǒ zhǐshì kànkan.', "I'm just looking."),
    _P('太 贵 了 ， 便宜 一点儿 吧 。', 'Tài guì le, piányi yìdiǎnr ba.', "That's too expensive. A bit cheaper?"),
    _P('有 大 一点儿 的 吗 ？', 'Yǒu dà yìdiǎnr de ma?', 'Do you have a bigger one?'),
    _P('可以 试试 吗 ？', 'Kěyǐ shìshi ma?', 'Can I try it on?'),
    _P('我 要 这个 。', 'Wǒ yào zhège.', "I'll take this one."),
    _P('可以 刷卡 吗 ？', 'Kěyǐ shuākǎ ma?', 'Can I pay by card?'),
    _P('要 袋子 吗 ？', 'Yào dàizi ma?', 'Do you want a bag?', hear: true),
    _P('一共 八十五 块 。', 'Yígòng bāshíwǔ kuài.', "That's 85 yuan altogether.", hear: true,
        note: 'People say 块 kuài for yuan when they talk.'),
  ]),
  PhrasePack('way', 'Directions', '问路', 'wènlù', '🧭',
      'Start with 请问 qǐngwèn ("may I ask") to stop someone politely.', [
    _P('请问 ， 地铁站 在 哪儿 ？', 'Qǐngwèn, dìtiězhàn zài nǎr?', 'Excuse me, where is the subway station?'),
    _P('洗手间 在 哪儿 ？', 'Xǐshǒujiān zài nǎr?', 'Where is the toilet?'),
    _P('离 这儿 远 吗 ？', 'Lí zhèr yuǎn ma?', 'Is it far from here?'),
    _P('一直 往 前 走 。', 'Yìzhí wǎng qián zǒu.', 'Go straight ahead.', hear: true),
    _P('在 第二 个 路口 往 左 拐 。', 'Zài dì-èr ge lùkǒu wǎng zuǒ guǎi.', 'Turn left at the second crossing.', hear: true),
    _P('走路 五 分钟 就 到 了 。', 'Zǒulù wǔ fēnzhōng jiù dào le.', "It's only a five-minute walk.", hear: true),
    _P('我 迷路 了 。', 'Wǒ mílù le.', "I'm lost."),
    _P('您 能 在 地图 上 指 给 我 看 吗 ？', 'Nín néng zài dìtú shang zhǐ gěi wǒ kàn ma?', 'Could you show me on the map?'),
    _P('请 说 慢 一点儿 。', 'Qǐng shuō màn yìdiǎnr.', 'Please speak a little more slowly.'),
    _P('我 听 不 懂 。', 'Wǒ tīng bu dǒng.', "I don't understand (what you're saying)."),
  ]),
  PhrasePack('help', 'Emergencies', '紧急情况', 'jǐnjí qíngkuàng', '🚑',
      'Phone numbers in China: 110 police, 120 ambulance, 119 fire. Learn these before you need them.', [
    _P('救命 ！', 'Jiùmìng!', 'Help!'),
    _P('请 叫 救护车 ！', 'Qǐng jiào jiùhùchē!', 'Please call an ambulance!'),
    _P('请 帮 我 报警 。', 'Qǐng bāng wǒ bàojǐng.', 'Please call the police for me.'),
    _P('我 需要 看 医生 。', 'Wǒ xūyào kàn yīshēng.', 'I need to see a doctor.'),
    _P('你 哪儿 不 舒服 ？', 'Nǐ nǎr bù shūfu?', "What's wrong? (Where do you feel unwell?)", hear: true),
    _P('附近 有 医院 吗 ？', 'Fùjìn yǒu yīyuàn ma?', 'Is there a hospital nearby?'),
    _P('我 这儿 疼 。', 'Wǒ zhèr téng.', 'It hurts here.', note: 'Point to where it hurts as you say it.'),
    _P('药店 在 哪儿 ？', 'Yàodiàn zài nǎr?', 'Where is the pharmacy?'),
    _P('我 的 钱包 丢 了 。', 'Wǒ de qiánbāo diū le.', "I've lost my wallet."),
    _P('我 的 手机 被 偷 了 。', 'Wǒ de shǒujī bèi tōu le.', 'My phone has been stolen.'),
    _P('你 会 说 英语 吗 ？', 'Nǐ huì shuō Yīngyǔ ma?', 'Do you speak English?'),
  ]),
];

PhrasePack? phrasePackById(String id) {
  for (final p in phrasePacks) {
    if (p.id == id) return p;
  }
  return null;
}
