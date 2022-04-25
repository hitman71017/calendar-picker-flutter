import 'package:flutter/cupertino.dart';
import 'package:jcalendar_picker_flutter/calendar/view_model/cell_subtitle.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../extensions.dart';
import '../utilities/utilities.dart';

enum CalenderMode {
  georgian,
  jalali,
}

enum CalendarSelectionMode {
  singleSelection,
  doubleSelection,
  disabledDoubleSelection
}

class CalendarController {
  final DateTime startingDate;
  final ScrollController scrollController;
  final Duration animationDuration = const Duration(
    milliseconds: 300,
  );

  bool _lock;
  List<DateTime> holidays;
  List<DateTime> disabledDays;
  int _selectingDayIndex;
  List<List<CellSubtitle>> subtitles;
  CalendarSelectionMode selectionMode;
  CalenderMode _mode = CalenderMode.jalali;
  DateTime? selectedDate1;
  DateTime? selectedDate2;

  List<CellSubtitle> get currentSubtitles {
    if (selectingDayIndex >= subtitles.length) return [];
    return subtitles[selectingDayIndex];
  }

  CalenderMode get mode => _mode;

  int get selectingDayIndex => _selectingDayIndex;

  bool get isLocked => _lock;

  bool get canBeSubmitted {
    switch (selectionMode) {
      case CalendarSelectionMode.singleSelection:
        return selectedDate1 != null;
      case CalendarSelectionMode.doubleSelection:
        return selectedDate1 != null && selectedDate2 != null;
      case CalendarSelectionMode.disabledDoubleSelection:
        return selectedDate1 != null;
    }
  }

  DateTime? get beginSelectedDate {
    if (selectedDate1 != null && selectedDate2 != null) {
      if (selectedDate1!.isAfter(selectedDate2!)) {
        return selectedDate2;
      } else {
        return selectedDate1;
      }
    }
    return selectedDate1 ?? selectedDate2;
  }

  DateTime? get endSelectedDate {
    if (selectedDate1 != null && selectedDate2 != null) {
      if (selectedDate1!.isAfter(selectedDate2!)) {
        return selectedDate1;
      } else {
        return selectedDate2;
      }
    }
    return null;
  }

  CalendarController({
    required bool lock,
    this.holidays = const [],
    this.disabledDays = const [],
    this.subtitles = const [],
    this.selectedDate1,
    DateTime? selectedDate2,
    required this.scrollController,
    required this.startingDate,
    this.selectionMode = CalendarSelectionMode.singleSelection,
  })  : selectedDate2 = selectedDate2 != null && selectedDate1 != null
            ? (compareDateTimes(selectedDate2, selectedDate1)
                ? null
                : selectedDate2)
            : null,
        _lock = lock,
        _selectingDayIndex = 0 {
    if (selectedDate1 != null) {
      _selectingDayIndex = 1;
    }
    if (selectedDate2 != null) {
      _selectingDayIndex = 0;
    }
  }

  void lock() {
    _lock = true;
  }

  void unlock() {
    _lock = false;
  }

  void setHolidays(List<DateTime> holidays) {
    this.holidays = holidays;
  }

  void setSubtitles(List<List<CellSubtitle>> subtitles) {
    this.subtitles = subtitles;
  }

  void setDisabledDays(List<DateTime> disabledDays) {
    this.disabledDays = disabledDays;
  }

  bool isBetweenTwoSelectedDate(DateTime time) {
    if (selectedDate1 == null || selectedDate2 == null) return false;
    return (time.isAfter(selectedDate1!) && time.isBefore(selectedDate2!)) ||
        (time.isAfter(selectedDate2!) && time.isBefore(selectedDate1!));
  }

  void daySelected(DateTime time) {
    if (_lock) return;
    // check if selected date is disabled
    if (disabledDays.where(
      (element) {
        return compareDateTimes(
          time,
          element,
        );
      },
    ).isNotEmpty) {
      return;
    }
    if (selectedDate1 == null) {
      if (selectionMode == CalendarSelectionMode.doubleSelection) {
        _selectingDayIndex = 1;
      } else {
        _selectingDayIndex = 0;
      }
      selectedDate1 = time;
      return;
    }

    if (selectionMode == CalendarSelectionMode.doubleSelection &&
        selectedDate2 == null) {
      if (time.compareTo(selectedDate1!) == 0) {
        _selectingDayIndex = 0;
        selectedDate1 = null;
        return;
      }
      selectedDate2 = time;
      for (int i = 0; i < disabledDays.length; i++) {
        final t = disabledDays[i];
        if (t.isAfter(beginSelectedDate!) && t.isBefore(endSelectedDate!)) {
          selectedDate1 = time;
          selectedDate2 = null;
          break;
        }
      }
      if (selectedDate2 != null) _selectingDayIndex = 0;
      return;
    }
    reset();
  }

  void reset() {
    selectedDate1 = null;
    selectedDate2 = null;
    _selectingDayIndex = 0;
  }

  void animateToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: animationDuration,
      curve: Curves.linearToEaseOut,
    );
  }

  void switchCalendarMode() {
    if (_mode == CalenderMode.jalali) {
      _mode = CalenderMode.georgian;
      return;
    }
    _mode = CalenderMode.jalali;
  }

  void dispose() {
    scrollController.dispose();
    reset();
  }
}

class CalendarViewModel {
  final int monthsInView;
  final CalendarController calendarController;

  final List<MonthViewModel> _georgianMonths = [];
  final List<MonthViewModel> _jalaliMonths = [];

  List<MonthViewModel> get currentMonths {
    if (mode == CalenderMode.jalali) return _jalaliMonths;
    return _georgianMonths;
  }

  CalenderMode get mode => calendarController.mode;

  CalendarViewModel({
    bool lock = false,
    DateTime? startingDateView,
    this.monthsInView = 12,
    required DateTime startingDate,
    List<DateTime> holidays = const [],
    List<DateTime> disabledDays = const [],
    ScrollController? scrollController,
    DateTime? selectedDate1,
    DateTime? selectedDate2,
    CalendarSelectionMode calendarSelectionMode =
        CalendarSelectionMode.singleSelection,
  }) : calendarController = CalendarController(
          disabledDays: disabledDays,
          lock: lock,
          selectedDate1: selectedDate1,
          selectedDate2: selectedDate2,
          startingDate: startingDate,
          selectionMode: calendarSelectionMode,
          scrollController: scrollController ?? ScrollController(),
        ) {
    startingDateView ??= DateTime.now();
    _init(startingDateView);
  }

  void _init(DateTime from) {
    final j = Jalali.fromDateTime(from);
    final sMonth = j.month - 1;
    final year = j.year;
    for (int i = 0; i < monthsInView; i++) {
      final cj = j.copy(
        year: year + ((sMonth + i) / 12).floor(),
        month: ((sMonth + i) % 12) + 1,
        day: 1,
      );
      _jalaliMonths.add(
        MonthViewModel(
          mode: CalenderMode.jalali,
          monthSize: cj.monthLength,
          monthTime: cj.toDateTime(),
          calendarController: calendarController,
        ),
      );
      final cg = cj.toGregorian();
      assert(cg.toDateTime().compareTo(cj.toDateTime()) == 0);
      _georgianMonths.add(
        MonthViewModel(
          mode: CalenderMode.georgian,
          monthSize: cg.monthLength,
          monthTime: cg.toDateTime(),
          calendarController: calendarController,
        ),
      );
    }
  }

  @override
  String toString() {
    return '$mode ${calendarController.selectedDate1} ${calendarController.selectedDate2} ${calendarController.selectionMode}';
  }
}

class MonthViewModel {
  final List<DayViewModel> _days = [];
  final int monthSize;
  final DateTime myTime;
  final CalenderMode _mode;
  final CalendarController _calendarController;
  late final bool _isAnyDayAfterStaringDate;

  CalenderMode get mode => _mode;

  List<DayViewModel> get days => _days;

  bool get isAnyDayAfterStaringDate => _isAnyDayAfterStaringDate;

  String get monthName {
    return myTime.toJalali().jalaliName;
  }

  String get nextMonthName {
    return myTime.toJalali().addMonths(1).jalaliName;
  }

  String get monthNameEng {
    return myTime.toGregorian().gregorianFarsiName;
  }

  String get nextMonthNameEng {
    return myTime.toGregorian().addMonths(1).gregorianFarsiName;
  }

  String get jalaliYear {
    return myTime.toJalali().year.toString();
  }

  String get gregorianYear {
    return myTime.toGregorian().year.toString();
  }

  MonthViewModel({
    required CalenderMode mode,
    required this.monthSize,
    required DateTime monthTime,
    required CalendarController calendarController,
  })  : _calendarController = calendarController,
        myTime = monthTime,
        _mode = mode {
    _init();
  }

  void _init() {
    for (int i = 0; i < monthSize; i++) {
      DateTime date;
      if (_mode == CalenderMode.jalali) {
        date = Jalali.fromDateTime(
          myTime,
        ).copy(day: i + 1).toDateTime();
      } else {
        date = Gregorian.fromDateTime(
          myTime,
        ).copy(day: i + 1).toDateTime();
      }
      _days.add(
        DayViewModel(
          mode: _mode,
          myTime: date,
          calendarController: _calendarController,
        ),
      );
    }
    _isAnyDayAfterStaringDate = _days.any((element) {
      return element.isAfterStartDate;
    });
  }
}

class DayViewModel {
  final DateTime myTime;
  final CalendarController _calendarController;
  final CalenderMode _mode;

  CalenderMode get mode => _mode;

  Jalali get toJalali => myTime.toJalali();

  Gregorian get toGregorian => myTime.toGregorian();

  bool get isAfterStartDate =>
      _calendarController.startingDate.isBefore(myTime);

  bool get isHoliday {
    if (mode == CalenderMode.jalali && myTime.weekday == DateTime.friday) {
      return true;
    }
    if (mode == CalenderMode.georgian && myTime.weekday == DateTime.sunday) {
      return true;
    }
    return _calendarController.holidays.contains(
      DateTime(myTime.year, myTime.month, myTime.day),
    );
  }

  bool get isBetweenSelectedDates {
    return _calendarController.isBetweenTwoSelectedDate(myTime);
  }

  bool get isDoubleSelection {
    return _calendarController.selectionMode ==
        CalendarSelectionMode.doubleSelection;
  }

  bool get isAnyDateSelected {
    if (_calendarController.beginSelectedDate != null) return true;
    if (_calendarController.endSelectedDate != null) return true;
    return false;
  }

  bool get isBothDateSelected {
    if (_calendarController.beginSelectedDate == null) return false;
    if (_calendarController.endSelectedDate == null) return false;
    return true;
  }

  bool get isSameAsFirstDate {
    if (_calendarController.beginSelectedDate == null) return false;
    if (compareDateTimes(_calendarController.beginSelectedDate!, myTime)) {
      return true;
    }
    return false;
  }

  bool get isSameAsSecondDate {
    if (_calendarController.endSelectedDate == null) return false;
    if (compareDateTimes(_calendarController.endSelectedDate!, myTime)) {
      return true;
    }
    return false;
  }

  int get day {
    if (_mode == CalenderMode.jalali) {
      return myTime.toJalali().day;
    }
    return myTime.toGregorian().day;
  }

  bool get isInDisabledDays {
    if (_calendarController.disabledDays.where(
      (t) {
        return compareDateTimes(t, myTime);
      },
    ).isNotEmpty) return true;
    return false;
  }

  bool get canBeSelected {
    if (!isAfterStartDate) return false;
    if (_calendarController.isLocked) return false;
    if (isInDisabledDays) return false;
    return true;
  }

  CellSubtitle? get getSubtitle {
    final d = DateTime(myTime.year, myTime.month, myTime.day);
    final list = _calendarController.currentSubtitles.where(
      (e) => compareDateTimes(e.time, d),
    );
    if (list.isEmpty) return null;
    return list.first;
  }

  void taped() {
    if (!canBeSelected) return;
    _calendarController.daySelected(
      compareDateTimes(myTime, DateTime.now()) ? DateTime.now() : myTime,
    );
  }

  DayViewModel({
    required this.myTime,
    required CalenderMode mode,
    required CalendarController calendarController,
  })  : _mode = mode,
        _calendarController = calendarController;
}
