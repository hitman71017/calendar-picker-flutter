import 'package:flutter/material.dart';
import 'package:jcalendar_picker_flutter/jcalender_picker_flutter.dart';

import '../view_model/calendar_view_model.dart';

class CalendarProvider extends ChangeNotifier {
  final int monthsInView;
  final DateTime startingDate;

  late final CalendarViewModel _calendarViewModel;
  final CalendarConfig config;
  bool loadingSubtitles = false;
  bool loadingDisabledDays = false;

  CalendarViewModel get calendarViewModel => _calendarViewModel;

  CalenderMode get mode => _calendarViewModel.mode;

  bool get isSelectingReturnDate {
    final c = getCalenderController;
    return c.selectionMode == CalendarSelectionMode.doubleSelection;
  }

  bool get canBeSubmitted {
    return _calendarViewModel.calendarController.canBeSubmitted;
  }

  ScrollController get scrollController {
    return _calendarViewModel.calendarController.scrollController;
  }

  CalendarController get getCalenderController {
    return calendarViewModel.calendarController;
  }

  CalendarProvider({
    this.monthsInView = 8,
    required this.startingDate,
    required this.config,
    CalendarSelectionMode mode = CalendarSelectionMode.singleSelection,
    DateTime? selectedDate1,
    DateTime? selectedDate2,
  }) : _calendarViewModel = CalendarViewModel(
          startingDate: startingDate,
          monthsInView: monthsInView,
          scrollController: ScrollController(),
          startingDateView: DateTime.now(),
          calendarSelectionMode: mode,
          selectedDate1: selectedDate1,
          selectedDate2: selectedDate2,
        );

  Future<void> loadHolidays(
      Future<List<DateTime>> Function() getHolidaysFunction) async {
    try {
      final holidays = await getHolidaysFunction();
      getCalenderController.setHolidays(holidays);
      notifyListeners();
    } on Exception catch (_) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadSubTitle(
    Future<List<List<CellSubtitle>>> Function() captureFunction,
  ) async {
    loadingSubtitles = true;
    notifyListeners();
    final subs = await captureFunction();
    getCalenderController.setSubtitles(subs);
    loadingSubtitles = false;
    notifyListeners();
  }

  Future<void> loadDisabledDays(
    Future<List<DateTime>> Function() captureFunction,
  ) async {
    loadingDisabledDays = true;
    notifyListeners();
    final dis = await captureFunction();
    getCalenderController.setDisabledDays(dis);
    loadingDisabledDays = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _calendarViewModel.calendarController.dispose();
  }

  void switchMode() {
    _calendarViewModel.calendarController.switchCalendarMode();
    notifyListeners();
  }

  void lock() {
    calendarViewModel.calendarController.lock();
  }

  void unlock() {
    calendarViewModel.calendarController.unlock();
  }

  void daySelected(DayViewModel dayViewModel) {
    dayViewModel.taped();
    notifyListeners();
  }

  bool checkValidation() {
    return getCalenderController.canBeSubmitted;
  }

  void switchToSingleSelection() {
    getCalenderController.selectionMode =
        CalendarSelectionMode.disabledDoubleSelection;
    notifyListeners();
  }

  void switchToRangeSelection() {
    getCalenderController.selectionMode = CalendarSelectionMode.doubleSelection;
    notifyListeners();
  }
}
