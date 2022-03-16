import 'package:shamsi_date/shamsi_date.dart';

extension DateStringConvert on Jalali {
  String get jalaliName {
    switch (month) {
      case 1:
        return 'فروردین';
      case 2:
        return 'اردیبهشت';
      case 3:
        return 'خرداد';
      case 4:
        return 'تیر';
      case 5:
        return 'مرداد';
      case 6:
        return 'شهریور';
      case 7:
        return 'مهر';
      case 8:
        return 'آبان';
      case 9:
        return 'آذر';
      case 10:
        return 'دی';
      case 11:
        return 'بهمن';
      case 12:
        return 'اسفند';
    }
    throw Exception('this number is not valid for month');
  }
}

extension GregorianConvert on Gregorian {
  String get gregorianNameAbbreviation {
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
    }
    throw Exception('this number is not valid for month');
  }

  String get gregorianName {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
    }
    throw Exception('this number is not valid for month');
  }

  String get gregorianFarsiName {
    switch (month) {
      case 1:
        return 'ژانویه';
      case 2:
        return 'فوریه';
      case 3:
        return 'مارس';
      case 4:
        return 'آوریل';
      case 5:
        return 'می';
      case 6:
        return 'ژوئن';
      case 7:
        return 'جولای';
      case 8:
        return 'آگوست';
      case 9:
        return 'سپتامبر';
      case 10:
        return 'اکتبر';
      case 11:
        return 'نوامبر';
      case 12:
        return 'دسامبر';
    }
    throw Exception('this number is not valid for month');
  }
}
