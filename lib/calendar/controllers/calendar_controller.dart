import 'package:flutter/widgets.dart';
import 'package:jcalendar_picker_flutter/calendar/utilities/utilities.dart';
import 'package:jcalendar_picker_flutter/jcalender_picker_flutter.dart';

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
