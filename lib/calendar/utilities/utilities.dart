import 'package:shamsi_date/shamsi_date.dart';

bool compareDateTimes(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int adjustWeekdayForJalali(int dayNum) => (dayNum + 1) % 7;

int adjustWeekdayForGregorian(int dayNum) => (dayNum) % 7;

String translate(String input, Jalali date) {
  input = input.replaceAll("YYYY", date.year.toString());
  input = input.replaceAll("YY", date.year.toString().substring(2, 4));
  input = input.replaceAll("MMMM", getJalaliMonthName(date.month));
  input = input.replaceAll("MMM", getJalaliMonthName(date.month));
  input = input.replaceAll("MM", date.month.toString().padLeft(2, "0"));
  input = input.replaceAll("M", date.month.toString());
  input = input.replaceAll("DD", date.day.toString().padLeft(2, "0"));
  input = input.replaceAll("D", date.day.toString());

  return input;
}

String translateStandardDateTime(String input, DateTime date) {
  input = input.replaceAll("YYYY", date.year.toString());
  input = input.replaceAll("YY", date.year.toString().substring(2, 4));
  input = input.replaceAll("MMMM", getGregorianMonthName(date.month));
  input = input.replaceAll("MMM", getGregorianMonthNameAbbr(date.month));
  input = input.replaceAll("MM", date.month.toString().padLeft(2, "0"));
  input = input.replaceAll("M", date.month.toString());
  input = input.replaceAll("DD", date.day.toString().padLeft(2, "0"));
  input = input.replaceAll("D", date.day.toString());
  return input;
}

String getGregorianMonthRange(int jalaliMonth) {
  Jalali date = Jalali(1400, jalaliMonth, 1);
  final firstMonth = getGregorianMonthName(date.toGregorian().month);
  date = date.copy(day: date.monthLength);
  final lastMonth = getGregorianMonthName(date.toGregorian().month);
  return '$firstMonth - $lastMonth';
}

String getJalaliMonthRange(int gregorinaMonth) {
  Gregorian date = Gregorian(2020, gregorinaMonth, 1);
  final firstMonth = getJalaliMonthName(date.toJalali().month);
  date = date.copy(day: date.monthLength);
  final lastMonth = getJalaliMonthName(date.toJalali().month);
  return '$firstMonth - $lastMonth';
}

String getGregorianMonthNameAbbr(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'Aug';
    case 9:
      return 'Sept';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '??????';
  }
}

String getGregorianMonthName(int month) {
  switch (month) {
    case 1:
      return '????????????';
    case 2:
      return '??????????';
    case 3:
      return '????????';
    case 4:
      return '??????????';
    case 5:
      return '????';
    case 6:
      return '????????';
    case 7:
      return '??????????';
    case 8:
      return '??????????';
    case 9:
      return '??????????????';
    case 10:
      return '??????????';
    case 11:
      return '????????????';
    case 12:
      return '????????????';
    default:
      return '??????';
  }
}

String getJalaliWeekDayName(int weekDay) {
  switch (weekDay) {
    case 1:
      return '????????????';

    case 2:
      return '???? ????????';

    case 3:
      return '????????????????';

    case 4:
      return '?????? ????????';

    case 5:
      return '????????';

    case 6:
      return '????????';

    case 7:
      return '????????????';

    default:
      return '';
  }
}

String getJalaliMonthName(int month) {
  switch (month) {
    case 1:
      return '??????????????';
    case 2:
      return '????????????????';
    case 3:
      return '??????????';
    case 4:
      return '??????';
    case 5:
      return '??????????';
    case 6:
      return '????????????';
    case 7:
      return '??????';
    case 8:
      return '????????';
    case 9:
      return '??????';
    case 10:
      return '????';
    case 11:
      return '????????';
    case 12:
      return '??????????';
    default:
      return '??????';
  }
}

String getJalaliDateWithMonthName(DateTime dateTime) {
  String result = '';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.day.toString();
  result += ' ';
  result += getJalaliMonthName(jalali.month);
  return result;
}

String getJalaliDateWithMonthNameNoYear(DateTime dateTime) {
  String result = '';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.day.toString();
  result += ' ';
  result += getJalaliMonthName(jalali.month);
  return result;
}

String getJalaliDateWithMonthNameAndWeekDay(DateTime dateTime) {
  String result = '';
  result += getJalaliWeekDayName(dateTime.weekday);
  result += ' ';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.day.toString();
  result += ' ';
  result += getJalaliMonthName(jalali.month);
  return result;
}

String getJalaliDateWithMonthNameAndWeekDayNumber(DateTime dateTime) {
  String result = '';
  result += getJalaliWeekDayName(dateTime.weekday);
  result += ' ';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.month.toString();
  result += '/';
  result += jalali.day.toString();
  return result;
}

String getJalaliDateWithMonthNameAndWeekDayNumberAndYearAndTime(
  DateTime dateTime,
) {
  String result = '';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.year.toString().substring(2);
  result += '/';
  result += jalali.month.toString();
  result += '/';
  result += jalali.day.toString();
  result += ' - ';
  result += dateTime.toIso8601String().substring(11, 16);
  return result;
}

String getTimeFromDateTime(DateTime dateTime) {
  return dateTime.toIso8601String().substring(11, 16);
}

String getJalaliDateWithMonthNameAndHour(DateTime dateTime) {
  String result = '';
  var jalali = Jalali.fromDateTime(dateTime);
  result += jalali.day.toString();
  result += ' ';
  result += getJalaliMonthName(jalali.month);
  result += ' ';
  result += ' - ';
  result += dateTime.toIso8601String().substring(11, 16);
  return result;
}

//todo: refactor this file
