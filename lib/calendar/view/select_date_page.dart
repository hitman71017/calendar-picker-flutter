import 'package:flutter/material.dart';
import 'package:jcalendar_picker_flutter/calendar/view_model/cell_subtitle.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../provider/calendar_provider.dart';
import '../utilities/utilities.dart';
import '../view/calendar_view.dart';
import '../view_model/calendar_config.dart';
import '../view_model/calendar_view_model.dart';

class SelectDatePageView extends StatefulWidget {
  final bool isDoubleSelection;

  const SelectDatePageView({
    required this.isDoubleSelection,
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
      calendarProvider.switchToSingleSelection();
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
