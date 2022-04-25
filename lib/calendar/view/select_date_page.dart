import 'package:flutter/material.dart';
import 'package:jcalendar_picker_flutter/calendar/utilities/utilities.dart';
import 'package:jcalendar_picker_flutter/calendar/view/calendar_text_field.dart';
import 'package:jcalendar_picker_flutter/calendar/view_model/calendar_view_model.dart';
import 'package:jcalendar_picker_flutter/jcalender_picker_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

class SelectDatePageView extends StatefulWidget {
  final bool isDoubleSelection;
  final bool isAlwaysDoubleSelection;

  const SelectDatePageView({
    required this.isDoubleSelection,
    this.isAlwaysDoubleSelection = false,
    Key? key,
  }) : super(key: key);

  @override
  _SelectDatePageViewState createState() => _SelectDatePageViewState();
}

class _SelectDatePageViewState extends State<SelectDatePageView> {
  late CalendarProvider calendarProvider;

  CalendarController get _calendarController {
    return calendarProvider.getCalenderController;
  }

  String get actionBeginText {
    final date = _calendarController.beginSelectedDate?.toJalali();
    if (date == null) return 'تاریخ رفت';
    return '${getJalaliWeekDayName(date.weekDay)} '
        '${date.year}/${date.month}/${date.day}';
  }

  String get actionEndText {
    final date = _calendarController.endSelectedDate?.toJalali();
    if (date == null) return 'تاریخ برگشت';
    return '${getJalaliWeekDayName(date.weekDay)} '
        '${date.year}/${date.month}/${date.day}';
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    calendarProvider = CalendarProvider(
      startingDate: DateTime(now.year, now.month, now.day),
      selectedDate1: now.add(const Duration(days: 6)),
      selectedDate2: now.add(const Duration(days: 8)),
      config: const CalendarConfig(
        backgroundColor: Colors.white70,
        monthBarBackgroundColor: Color(0xffdfdfdf),
        disabledDaysCellColor: Color(0xfff06b6b),
        deselectedCellColor: Colors.white,
        deselectedCellBorderColor: Color(0xffdfdfdf),
        betweenSelectedCellColor: Colors.lightBlueAccent,
        disabledCellColor: Colors.white,
        disableCellTextColor: Colors.grey,
        selectedCellBorderColor: Colors.blue,
        selectedCellColor: Colors.blue,
      ),
    );
    if (widget.isDoubleSelection) {
      calendarProvider.switchToRangeSelection();
    }
    calendarProvider.loadSubTitle(() async {
      await Future.delayed(Duration.zero);
      final now = DateTime.now();
      return [
        List.generate(
          16,
          (index) => CellSubtitle(
            time: DateTime(
              now.year,
              now.month,
              (now.day + index * index + 1).floor(),
            ),
            string: index.toString(),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ];
    });
    calendarProvider.loadDisabledDays(() async {
      final now = DateTime.now();
      return List.generate(
        8,
        (index) => DateTime(
          now.year,
          now.month,
          (now.day + index * index).floor(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: ChangeNotifierProvider.value(
        value: calendarProvider,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: <Widget>[
              Transform.scale(
                scale: 1.01,
                child: Container(
                  color: Colors.blue,
                  child: _buildTextFields(context),
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    CalendarView(),
                    _buildOverlayGradient(),
                  ],
                ),
              ),
              _buildBottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFields(BuildContext context) {
    final isRangeSelection = _calendarController.selectionMode !=
        CalendarSelectionMode.singleSelection;

    return Consumer<CalendarProvider>(
      builder: (c, p, w) {
        final isSelectingFrom = getIsSelectingFrom(p, isRangeSelection);
        final isSelectingTo = getIsSelectingTo(p, isRangeSelection);
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 23, right: 23, top: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: CalendarTextField(
                        //  isFocused: isFocusedFrom,
                        isFocused: isSelectingFrom,
                        isSelected:
                            _calendarController.beginSelectedDate != null,
                        placeHolder: widget.isAlwaysDoubleSelection
                            ? 'تاریخ ورود'
                            : 'تاریخ رفت',
                        title: actionBeginText,
                        alwaysWhite: true,
                      ),
                    ),
                  ),
                  if (isRangeSelection)
                    const SizedBox(
                      width: 20,
                    ),
                  if (isRangeSelection)
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: CalendarTextField(
                          isRemovable: !widget.isAlwaysDoubleSelection,
                          //  isFocused: isFocusedTo,
                          isFocused: isSelectingTo,
                          isSelected:
                              _calendarController.endSelectedDate != null,
                          placeHolder: widget.isAlwaysDoubleSelection
                              ? 'تاریخ خروج'
                              : 'تاریخ برگشت',
                          title: actionEndText,
                        ),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, right: 16, left: 16, top: 12),
      child: Consumer<CalendarProvider>(
          builder: (c, p, w) => Column(
                children: [
                  Row(
                    children: [
                      _buildTextInfo(context, 'روزهای تعطیل', Colors.red),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      ...[
                        Expanded(
                          child: TextButton(
                            child: Text('تبدیل به تقویم ' +
                                (p.mode == CalenderMode.jalali
                                    ? 'میلادی'
                                    : 'شمسی')),
                            onPressed: () => calendarProvider.switchMode(),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                      Expanded(
                        child: buildButton(context),
                      ),
                    ],
                  ),
                ],
              )),
    );
  }

  Widget _buildTextInfo(
    BuildContext context,
    String text,
    Color color, {
    bool hasDot = true,
    TextStyle? style,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasDot)
            Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                )),
          Text(
            text,
            style: style?.copyWith(
                  color: color,
                ) ??
                Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: color,
                    ),
          )
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return MaterialButton(
      child: const Text('تأیید'),
      onPressed: calendarProvider.checkValidation() ? _confirmTapped : null,
      color: Colors.blue,
    );
  }

  _confirmTapped() {
    final p = calendarProvider.getCalenderController;
    Navigator.of(context).pop([
      p.beginSelectedDate,
      p.endSelectedDate,
    ]);
  }

  Widget _buildOverlayGradient() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white70,
            gradient: LinearGradient(
              stops: const [0, 0.3, 0.6, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white70.withOpacity(0),
                Colors.white70.withOpacity(0.1),
                Colors.white70.withOpacity(0.3),
                Colors.white70.withOpacity(0.7)
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool getIsSelectingTo(CalendarProvider p, bool isRangeSelection) {
    if (!isRangeSelection) return false;
    if (_calendarController.beginSelectedDate == null) return false;
    return _calendarController.endSelectedDate != null;
  }

  bool getIsSelectingFrom(CalendarProvider p, bool isRangeSelection) {
    return _calendarController.beginSelectedDate == null;
  }
}
