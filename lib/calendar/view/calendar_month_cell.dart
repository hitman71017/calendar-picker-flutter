import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../view/calendar_day_cell.dart';
import '../view_model/calendar_view_model.dart';

class CalendarMonthCell extends StatelessWidget {
  final MonthViewModel monthViewModel;

  const CalendarMonthCell(
    this.monthViewModel, {
    Key? key,
  }) : super(key: key);

  String get firstPartOfBar {
    if (monthViewModel.mode == CalenderMode.jalali) {
      return '${monthViewModel.monthName}  ${monthViewModel.jalaliYear}';
    }
    return '${monthViewModel.monthNameEng}  ${monthViewModel.gregorianYear}';
  }

  String get secondPartOfBar {
    if (monthViewModel.mode == CalenderMode.jalali) {
      return '${monthViewModel.monthNameEng} - ${monthViewModel.nextMonthNameEng}  ${monthViewModel.gregorianYear}';
    }
    return '${monthViewModel.monthName} - ${monthViewModel.nextMonthName}  ${monthViewModel.jalaliYear}';
  }

  bool get isJalali => monthViewModel.mode == CalenderMode.jalali;

  int get startingIndex {
    if (monthViewModel.mode == CalenderMode.jalali) {
      return monthViewModel.days.first.toJalali.weekDay - 1;
    }
    return monthViewModel.days.first.toGregorian.weekDay - 1;
  }

  int get endingIndex {
    return startingIndex + monthViewModel.monthSize - 1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    return Column(
      children: <Widget>[
        Transform.translate(
          offset: const Offset(0, 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: provider.config.monthBarBackgroundColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              height: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      firstPartOfBar,
                      style: provider.config.monthLabelStyle,
                    ),
                    Expanded(
                      child: Text(
                        secondPartOfBar,
                        style: provider.config.monthLabelStyle,
                        textDirection: TextDirection.ltr,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: <Widget>[
              provider.mode == CalenderMode.jalali
                  ? const JalaliDaysGrid()
                  : const GregorianDaysGrid(),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                addRepaintBoundaries: false,
                addAutomaticKeepAlives: false,
                shrinkWrap: true,
                itemCount: endingIndex >= 35 ? 42 : 35,
                itemBuilder: (_, index) {
                  if (index < startingIndex || index > endingIndex) {
                    return const SizedBox();
                  }
                  return CalendarDayCell(
                    dayViewModel: monthViewModel.days[index - startingIndex],
                  );
                },
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}

class JalaliDaysGrid extends StatelessWidget {
  const JalaliDaysGrid({Key? key}) : super(key: key);

  final strJ = const ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final config = context.read<CalendarProvider>().config;
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 24,
        crossAxisCount: 7,
        crossAxisSpacing: 8,
      ),
      addRepaintBoundaries: false,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      shrinkWrap: true,
      children: strJ.map((e) {
        return Center(
          child: Text(
            e,
            style: config.textStyle.copyWith(
              color: config.normalTextColor.withOpacity(0.5),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GregorianDaysGrid extends StatelessWidget {
  const GregorianDaysGrid({Key? key}) : super(key: key);

  final strG = const ['د', 'س', 'چ', 'پ', 'ج', 'ش', 'ی'];

  @override
  Widget build(BuildContext context) {
    final config = context.read<CalendarProvider>().config;
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 24,
        crossAxisCount: 7,
        crossAxisSpacing: 8,
      ),
      addRepaintBoundaries: false,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      shrinkWrap: true,
      children: strG.map((e) {
        return Center(
          child: Text(
            e,
            style: config.textStyle.copyWith(
              color: config.normalTextColor.withOpacity(0.5),
            ),
          ),
        );
      }).toList(),
    );
  }
}
