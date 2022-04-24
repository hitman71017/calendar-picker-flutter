import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../view/calendar_month_cell.dart';
import '../view_model/calendar_view_model.dart';

class CalendarView extends StatelessWidget {
  final todayDate = DateTime.now();

  CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    return Container(
      color: provider.config.backgroundColor,
      child: Selector<CalendarProvider, CalenderMode>(
          shouldRebuild: (previous, next) {
        return previous != next;
      }, selector: (context, provider) {
        return provider.calendarViewModel.calendarController.mode;
      }, builder: (context, __, ___) {
        final months = provider.calendarViewModel.currentMonths;
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: months.length + 1,
          separatorBuilder: (_, index) {
            if (!months[index].isAnyDayAfterStaringDate)
              return const SizedBox();
            return index >= months.length - 1
                ? const SizedBox()
                : const Divider();
          },
          controller: provider.scrollController,
          itemBuilder: (context, index) {
            if (index > months.length - 1) {
              return const SizedBox(
                height: 48,
              );
            }
            if (!months[index].isAnyDayAfterStaringDate)
              return const SizedBox();
            return CalendarMonthCell(
              months[index],
            );
          },
        );
      }),
    );
  }
}
