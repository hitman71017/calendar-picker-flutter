import 'package:calendar_picker/calendar/view_model/calendar_config.dart';
import 'package:calendar_picker/calendar/view_model/calendar_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CalendarProvider extends ChangeNotifier {
  final int monthsInView;
  final DateTime startingDate;

  late final CalendarViewModel _calendarViewModel;
  final CalendarConfig config;
  bool loadingSubtitles = false;

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
  }) : _calendarViewModel = CalendarViewModel(
          startingDate: startingDate,
          monthsInView: monthsInView,
          scrollController: ScrollController(),
          startingDateView: DateTime.now(),
          calendarSelectionMode: mode,
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
    Future<List<Map<DateTime, String>>> Function() captureFunction,
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
    loadingSubtitles = true;
    notifyListeners();
    final dis = await captureFunction();
    getCalenderController.setDisabledDays(dis);
    loadingSubtitles = false;
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
    getCalenderController.selectionMode = CalendarSelectionMode.singleSelection;
    notifyListeners();
  }

  void switchToRangeSelection() {
    getCalenderController.selectionMode = CalendarSelectionMode.doubleSelection;
    notifyListeners();
  }
}
