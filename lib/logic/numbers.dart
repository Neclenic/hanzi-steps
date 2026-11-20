import 'dart:math';

// Numbers as they are said in everyday life: prices, phone numbers, dates and clock times.

const _digitHanzi = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];

const _pinyinOf = {
  '零': 'líng', '一': 'yī', '二': 'èr', '三': 'sān', '四': 'sì', '五': 'wǔ', '六': 'liù', '七': 'qī',
  '八': 'bā', '九': 'jiǔ', '十': 'shí', '百': 'bǎi', '千': 'qiān', '万': 'wàn', '两': 'liǎng', '幺': 'yāo',
  '块': 'kuài', '毛': 'máo', '月': 'yuè', '号': 'hào', '年': 'nián', '点': 'diǎn', '半': 'bàn', '分': 'fēn',
  '刻': 'kè', '星': 'xīng', '期': 'qī', '天': 'tiān', '早': 'zǎo', '上': 'shàng', '午': 'wǔ', '中': 'zhōng',
  '下': 'xià', '晚': 'wǎn',
};

/// A whole number from 0 to 9999 in Chinese characters, e.g. 115 → 一百一十五.
/// With [liang], a 2 counted on its own or before 百 and 千 is 两, as in 两块 and 两百.
String chineseNumber(int n, {bool liang = false}) {
  assert(n >= 0 && n < 10000);
  if (n < 10) return liang && n == 2 ? '两' : _digitHanzi[n];
  return _big(n, liang: liang, first: true);
}

String _big(int n, {required bool liang, required bool first}) {
  if (n < 10) return _digitHanzi[n];
  if (n < 20) return first ? (n == 10 ? '十' : '十${_digitHanzi[n - 10]}') : '一十${n == 10 ? '' : _digitHanzi[n - 10]}';
  if (n < 100) return '${_digitHanzi[n ~/ 10]}十${n % 10 == 0 ? '' : _digitHanzi[n % 10]}';
  final (unit, size) = n < 1000 ? ('百', 100) : ('千', 1000);
  final lead = n ~/ size, rest = n % size;
  final head = '${liang && lead == 2 ? '两' : _digitHanzi[lead]}$unit';
  if (rest == 0) return head;
  // A gap in the middle is read as 零: 105 → 一百零五, 1005 → 一千零五.
  final gap = rest < size ~/ 10;
  return '$head${gap ? '零' : ''}${_big(rest, liang: false, first: false)}';
}

/// Pinyin for Chinese made of number words, e.g. 三块五 → "sān kuài wǔ".
/// 一 changes tone before 百, 千 and 万 (yìbǎi, yìqiān, yíwàn).
/// Number words written together share one pinyin word: 二十五 → "èrshíwǔ".
String numberPinyin(String hanzi) {
  const numberChars = '零一二三四五六七八九十百千万两';
  final words = <String>[];
  var current = StringBuffer();
  void flush() {
    if (current.isNotEmpty) words.add(current.toString());
    current = StringBuffer();
  }

  final chars = hanzi.split('');
  for (var i = 0; i < chars.length; i++) {
    final c = chars[i];
    final p = _pinyinOf[c];
    if (p == null) {
      flush();
      continue;
    }
    var syl = p;
    final next = i + 1 < chars.length ? chars[i + 1] : '';
    if (c == '一' && (next == '百' || next == '千')) syl = 'yì';
    if (c == '一' && next == '万') syl = 'yí';
    final isNumber = numberChars.contains(c);
    if (!isNumber) flush();
    // An apostrophe keeps syllables apart when the next starts with a vowel: èrshí'èr.
    if (current.isNotEmpty && 'aeoāáǎàēéěèōóǒò'.contains(syl[0])) current.write("'");
    current.write(syl);
    if (!isNumber) flush();
  }
  flush();
  return words.join(' ');
}

const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const weekdayHanzi = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期天'];

/// What kind of number a question is about.
enum NumberKind { price, phone, date, time }

/// One number from real life, in Chinese and in figures.
class LifeNumber {
  final NumberKind kind;
  final String hanzi; // how it is written in Chinese words, e.g. 三块五
  final String speak; // what the voice reads (phone numbers use 幺 for 1)
  final String pinyin;
  final String figures; // the answer in figures, e.g. ¥3.50 or 14:30
  const LifeNumber(this.kind, this.hanzi, this.speak, this.pinyin, this.figures);

  @override
  bool operator ==(Object other) => other is LifeNumber && other.figures == figures;
  @override
  int get hashCode => figures.hashCode;
}

// ---------- Prices ----------

/// A price in yuan (块) and tenths of a yuan (毛), as said in a shop: 3.50 → 三块五.
LifeNumber price(int yuan, int jiao) {
  String hanzi;
  if (yuan == 0) {
    hanzi = '${chineseNumber(jiao, liang: true)}毛';
  } else {
    hanzi = '${chineseNumber(yuan, liang: true)}块${jiao == 0 ? '' : _digitHanzi[jiao]}';
  }
  return LifeNumber(NumberKind.price, hanzi, hanzi, numberPinyin(hanzi), '¥$yuan.${jiao}0');
}

LifeNumber _randomPrice(Random r) {
  final yuan = switch (r.nextInt(4)) {
    0 => r.nextInt(10) + 1,
    1 => r.nextInt(90) + 10,
    2 => r.nextInt(900) + 100,
    _ => r.nextInt(30) + 1,
  };
  final jiao = r.nextBool() ? 0 : r.nextInt(9) + 1;
  return price(yuan, yuan > 100 ? 0 : jiao);
}

// Numbers that sound alike or look alike in Chinese, used for wrong answers.
int _nearMiss(int n, Random r) {
  final s = '$n';
  final options = <int>[
    n + 1,
    if (n > 1) n - 1,
    // 四 sì and 十 shí sound alike: 14 ↔ 40, 4 ↔ 10.
    if (n == 4) 10,
    if (n == 10) 4,
    if (n >= 11 && n <= 19) (n - 10) * 10,
    if (n >= 20 && n < 100 && n % 10 == 0) 10 + n ~/ 10,
    // Digits swapped: 12 ↔ 21.
    if (s.length == 2 && s[0] != s[1] && s[1] != '0') int.parse('${s[1]}${s[0]}'),
    // 七 qī and 一 yī sound alike.
    if (s.contains('7')) int.parse(s.replaceFirst('7', '1')),
    if (s.contains('1') && !s.startsWith('1')) int.parse(s.replaceFirst('1', '7')),
    n * 10,
    if (n >= 10 && n % 10 == 0) n ~/ 10,
  ].where((x) => x > 0 && x != n && x < 10000).toList();
  return options[r.nextInt(options.length)];
}

// ---------- Phone numbers ----------

/// An 11-digit mobile number. When said aloud, 1 is yāo (幺) so it isn't mixed up with 七 qī.
LifeNumber phone(String digits) {
  final groups = [digits.substring(0, 3), digits.substring(3, 7), digits.substring(7)];
  String say(String g) => g.split('').map((d) => d == '1' ? '幺' : _digitHanzi[int.parse(d)]).join();
  final hanzi = groups.map(say).join('，');
  final pinyin = groups.map((g) => say(g).split('').map((c) => _pinyinOf[c]).join(' ')).join(', ');
  return LifeNumber(NumberKind.phone, hanzi, hanzi, pinyin, groups.join(' '));
}

LifeNumber _randomPhone(Random r) {
  const starts = ['13', '15', '17', '18', '19'];
  final b = StringBuffer(starts[r.nextInt(starts.length)]);
  for (var i = 0; i < 9; i++) {
    b.write(r.nextInt(10));
  }
  return phone(b.toString());
}

// ---------- Dates ----------

const _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// A date, said from big to small: (year,) month, day, then the day of the week.
/// Years are read digit by digit: 2026 → 二零二六年.
LifeNumber date(int month, int day, {int? weekday, int? year}) {
  final yearDigits = year == null ? <String>[] : '$year'.split('').map((d) => _digitHanzi[int.parse(d)]).toList();
  final y = year == null ? '' : '${yearDigits.join()}年';
  final w = weekday == null ? '' : '，${weekdayHanzi[weekday - 1]}';
  final hanzi = '$y${chineseNumber(month)}月${chineseNumber(day)}号$w';
  final pinyin = [
    if (year != null) '${yearDigits.map((c) => _pinyinOf[c]).join(' ')} nián',
    '${numberPinyin(chineseNumber(month))} yuè',
    '${numberPinyin(chineseNumber(day))} hào',
    if (weekday != null) 'xīngqī${weekday == 7 ? 'tiān' : numberPinyin(_digitHanzi[weekday])}',
  ].join(' ');
  final en = '${weekday == null ? '' : '${weekdayNames[weekday - 1]} '}$day ${monthNames[month - 1]}${year == null ? '' : ' $year'}';
  return LifeNumber(NumberKind.date, hanzi, hanzi, pinyin, en);
}

LifeNumber _randomDate(Random r) {
  final m = r.nextInt(12) + 1;
  final d = r.nextInt(_monthDays[m - 1]) + 1;
  final withDay = r.nextInt(3) > 0;
  final withYear = r.nextInt(4) == 0;
  return date(m, d, weekday: withDay ? r.nextInt(7) + 1 : null, year: withYear ? 2020 + r.nextInt(10) : null);
}

// ---------- Clock times ----------

/// The part of the day for an hour from 0 to 23.
String dayPart(int hour24) => switch (hour24) {
      < 9 => '早上',
      < 12 => '上午',
      12 => '中午',
      < 18 => '下午',
      _ => '晚上',
    };

const _dayPartPinyin = {'早上': 'zǎoshang', '上午': 'shàngwǔ', '中午': 'zhōngwǔ', '下午': 'xiàwǔ', '晚上': 'wǎnshang'};

/// A clock time as it is said: 14:30 → 下午两点半. Quarter past can be 一刻.
LifeNumber clockTime(int hour24, int minute, {bool useKe = false}) {
  final h12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final hour = chineseNumber(h12, liang: true);
  final (String min, String minPinyin) = switch (minute) {
    0 => ('', ''),
    30 => ('半', ' bàn'),
    15 when useKe => ('一刻', ' yí kè'),
    < 10 => ('零${_digitHanzi[minute]}分', ' líng ${_pinyinOf[_digitHanzi[minute]]} fēn'),
    _ => ('${chineseNumber(minute)}分', ' ${numberPinyin(chineseNumber(minute))} fēn'),
  };
  final part = dayPart(hour24);
  final hanzi = '$part$hour点$min';
  final pinyin = '${_dayPartPinyin[part]} ${numberPinyin(hour)} diǎn$minPinyin';
  final figures = '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  return LifeNumber(NumberKind.time, hanzi, hanzi, pinyin, figures);
}

LifeNumber _randomTime(Random r) {
  final h = 6 + r.nextInt(18); // 6:00 to 23:00
  const minutes = [0, 0, 30, 30, 15, 45, 5, 10, 20, 25, 40, 50, 55];
  final m = minutes[r.nextInt(minutes.length)];
  return clockTime(h, m, useKe: m == 15 && r.nextBool());
}

// ---------- Questions ----------

LifeNumber randomLifeNumber(NumberKind kind, Random r) => switch (kind) {
      NumberKind.price => _randomPrice(r),
      NumberKind.phone => _randomPhone(r),
      NumberKind.date => _randomDate(r),
      NumberKind.time => _randomTime(r),
    };

/// Three wrong answers that are easy to mix up with [n].
List<LifeNumber> numberDistractors(LifeNumber n, Random r) {
  final out = <LifeNumber>{};
  var tries = 0;
  while (out.length < 3 && tries++ < 200) {
    final c = _variant(n, r);
    if (c != null && c != n) out.add(c);
  }
  // Rarely the near misses run out (e.g. for 1 January): fill up with simple neighbours.
  for (var k = 1; out.length < 3; k++) {
    final c = _neighbour(n, k);
    if (c != null && c != n) out.add(c);
  }
  return out.toList();
}

LifeNumber? _neighbour(LifeNumber n, int k) {
  switch (n.kind) {
    case NumberKind.price:
      final parts = n.figures.substring(1).split('.');
      final yuan = int.parse(parts[0]) + k;
      return price(yuan, yuan > 100 ? 0 : int.parse(parts[1][0]));
    case NumberKind.phone:
      final d = n.figures.replaceAll(' ', '').split('');
      d[10] = '${(int.parse(d[10]) + k) % 10}';
      return phone(d.join());
    case NumberKind.date:
      final m = RegExp(r'(?:(\w+) )?(\d+) (\w+)(?: (\d+))?').firstMatch(n.figures)!;
      final month = monthNames.indexOf(m[3]!) + 1;
      final day = (int.parse(m[2]!) + k - 1) % 28 + 1;
      final weekday = m[1] == null ? null : weekdayNames.indexOf(m[1]!) + 1;
      return date(month, day, weekday: weekday, year: m[4] == null ? null : int.parse(m[4]!));
    case NumberKind.time:
      final h = int.parse(n.figures.substring(0, 2));
      final min = int.parse(n.figures.substring(3));
      return clockTime(h, (min + 5 * k) % 60);
  }
}

LifeNumber? _variant(LifeNumber n, Random r) {
  switch (n.kind) {
    case NumberKind.price:
      final parts = n.figures.substring(1).split('.');
      var yuan = int.parse(parts[0]);
      var jiao = int.parse(parts[1][0]);
      if (yuan == 0 || (jiao > 0 && r.nextInt(3) == 0)) {
        // Mix up the 块 and the 毛: 3.50 ↔ 5.30, or change the 毛.
        if (r.nextBool() && yuan > 0 && yuan < 10) {
          (yuan, jiao) = (jiao, yuan);
        } else {
          jiao = (jiao + 1 + r.nextInt(8)) % 10;
        }
      } else {
        yuan = _nearMiss(yuan, r);
      }
      if (yuan >= 10000) return null;
      return price(yuan, yuan > 100 ? 0 : jiao);
    case NumberKind.phone:
      final d = n.figures.replaceAll(' ', '').split('');
      final i = 3 + r.nextInt(8);
      d[i] = '${(int.parse(d[i]) + 1 + r.nextInt(9)) % 10}';
      return phone(d.join());
    case NumberKind.date:
      final m = RegExp(r'(?:(\w+) )?(\d+) (\w+)(?: (\d+))?').firstMatch(n.figures)!;
      var day = int.parse(m[2]!);
      var month = monthNames.indexOf(m[3]!) + 1;
      var weekday = m[1] == null ? null : weekdayNames.indexOf(m[1]!) + 1;
      final year = m[4] == null ? null : int.parse(m[4]!);
      switch (r.nextInt(weekday == null ? 3 : 4)) {
        case 0:
          // Month and day swapped: 三月十二号 ↔ 十二月三号.
          if (day <= 12 && day != month) (month, day) = (day, month);
          break;
        case 1:
          day = _nearMiss(day, r);
          break;
        case 2:
          month = _nearMiss(month, r);
          break;
        default:
          weekday = weekday! % 7 + 1;
      }
      if (month > 12 || day > _monthDays[month - 1]) return null;
      return date(month, day, weekday: weekday, year: year);
    case NumberKind.time:
      final h = int.parse(n.figures.substring(0, 2));
      final min = int.parse(n.figures.substring(3));
      int? hour;
      var minute = min;
      switch (r.nextInt(4)) {
        case 0:
          // Morning and evening mixed up.
          hour = h < 12 ? h + 12 : h - 12;
        case 1:
          // 半 (half) and 一刻 (quarter) mixed up.
          minute = min == 30 ? 15 : (min == 15 ? 30 : (min + 30) % 60);
          hour = h;
        case 2:
          final h12 = _nearMiss(h % 12 == 0 ? 12 : h % 12, r);
          if (h12 > 12) return null;
          hour = h12 % 12 + (h >= 12 ? 12 : 0);
        default:
          minute = min == 0 ? 30 : 0;
          hour = h;
      }
      if (hour < 6 || hour > 23) return null;
      return clockTime(hour, minute);
  }
}

/// Tips shown before each kind of round.
const numberTips = {
  NumberKind.price: '块 kuài is the everyday word for yuan, and 毛 máo is a tenth of a yuan. '
      'The 毛 after 块 is usually dropped: 三块五 is ¥3.50. And 2 yuan is 两块, not 二块.',
  NumberKind.phone: 'Phone numbers are read digit by digit, in groups. '
      'The digit 1 is said yāo (幺) so it doesn\'t sound like 七 qī.',
  NumberKind.date: 'Dates go from big to small: year, month, day. 号 hào is the day of the month. '
      'Years are read digit by digit: 2026 is 二零二六年.',
  NumberKind.time: 'The part of the day comes first: 下午两点半 is 14:30. '
      '半 means half past, 一刻 a quarter past. 2 o\'clock is 两点, not 二点.',
};
