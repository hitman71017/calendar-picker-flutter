import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../view/spin_kit.dart';
import '../view_model/calendar_config.dart';
import '../view_model/calendar_view_model.dart';

class CalendarDayCell extends StatefulWidget {
  final DayViewModel dayViewModel;

  const CalendarDayCell({
    required this.dayViewModel,
    Key? key,
  }) : super(key: key);

  @override
  _CalendarDayCellState createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<CalendarDayCell>
    with SingleTickerProviderStateMixin {
  late final CalendarConfig config;

  Color get getColor {
    if (!widget.dayViewModel.isAfterStartDate) return config.disabledCellColor;
    if (widget.dayViewModel.isSameAsFirstDate) {
      return config.selectedCellColor;
    }
    if (widget.dayViewModel.isSameAsSecondDate) {
      return config.selectedCellColor;
    }
    if (widget.dayViewModel.isBetweenSelectedDates) {
      return config.betweenSelectedCellColor;
    }
    if (widget.dayViewModel.isInDisabledDays) {
      return config.disabledDaysCellColor;
    }

    return config.deselectedCellColor;
  }

  Color get getTextColor {
    if (!widget.dayViewModel.isAfterStartDate) {
      return config.disableCellTextColor;
    }
    if (isInRange) return config.betweenSelectedCellTextColor;
    return config.normalTextColor;
  }

  bool get isInRange {
    return widget.dayViewModel.isSameAsFirstDate ||
        widget.dayViewModel.isSameAsSecondDate ||
        widget.dayViewModel.isBetweenSelectedDates;
  }

  double get _calculateMatrixValue {
    if (widget.dayViewModel.isSameAsFirstDate ||
        widget.dayViewModel.isSameAsSecondDate) {
      return 1.1;
    }
    return 1.2;
  }

  Alignment get _calculateAlignmentOfScale {
    if (widget.dayViewModel.isSameAsFirstDate) {
      return Alignment.centerLeft;
    }
    if (widget.dayViewModel.isSameAsSecondDate) {
      return Alignment.centerRight;
    }
    return Alignment.center;
  }

  Offset get _calculateOffset {
    if (widget.dayViewModel.isSameAsFirstDate) {
      return const Offset(80, 0);
    }
    if (widget.dayViewModel.isSameAsSecondDate) {
      return const Offset(-80, 0);
    }
    return Offset.zero;
  }

  BorderRadius get _calculateBorderRadius {
    if (widget.dayViewModel.isSameAsFirstDate) {
      return const BorderRadius.only(
        topRight: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    }
    if (widget.dayViewModel.isSameAsSecondDate) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(4),
        topLeft: Radius.circular(4),
      );
    }
    return BorderRadius.circular(0);
  }

  bool get shouldRebuild {
    if (widget.dayViewModel.isSameAsSecondDate) return true;
    if (widget.dayViewModel.isSameAsFirstDate) return true;
    if (widget.dayViewModel.isBetweenSelectedDates) return true;
    return false;
  }

  Color get getBorderColor {
    if (!widget.dayViewModel.isAfterStartDate) return Colors.transparent;
    if (isInRange) return config.selectedCellBorderColor;
    return config.deselectedCellBorderColor;
  }

  Color get getShadowColor {
    if (!widget.dayViewModel.isAfterStartDate) return Colors.transparent;
    if (widget.dayViewModel.isSameAsFirstDate ||
        widget.dayViewModel.isSameAsSecondDate) {
      return config.betweenSelectedCellColor.withOpacity(
        1.0 - animation.value,
      );
    }
    return config.deselectedCellBorderColor.withOpacity(animation.value);
  }

  late final AnimationController controller;
  late final Animation<double> animation;

  DateTime get myTime => widget.dayViewModel.myTime;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    config = context.read<CalendarProvider>().config;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildSubTitle(BuildContext context, bool isSelected) {
    if (widget.dayViewModel.getSubtitle == null) return const SizedBox();
    return Text(widget.dayViewModel.getSubtitle!);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CalendarProvider, bool>(
      shouldRebuild: (previous, next) {
        return previous != next || next;
      },
      selector: (context, provider) {
        return shouldRebuild;
      },
      builder: (context, provider, child) {
        if (isInRange) {
          if (controller.value == 1) {
            controller.reverse();
          }
        } else {
          controller.forward();
        }

        return Center(
          child: GestureDetector(
            onTap: () {
              context.read<CalendarProvider>().daySelected(widget.dayViewModel);
            },
            child: Selector<CalendarProvider, bool>(
              shouldRebuild: (previous, next) {
                return previous != next;
              },
              selector: (context, provider) {
                return provider.getCalenderController.holidays.isNotEmpty;
              },
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    if (isInRange && widget.dayViewModel.isBothDateSelected)
                      Transform(
                        transform: Matrix4.diagonal3Values(
                          _calculateMatrixValue,
                          1.0,
                          1.0,
                        ),
                        alignment: _calculateAlignmentOfScale,
                        origin: _calculateOffset,
                        child: Container(
                          decoration: BoxDecoration(
                            color: config.betweenSelectedCellColor,
                            borderRadius: _calculateBorderRadius,
                          ),
                        ),
                      ),
                    child!,
                    if (widget.dayViewModel.isHoliday)
                      const Positioned(
                        left: 5,
                        height: 5,
                        width: 5,
                        top: 5,
                        child: RedDot(),
                      )
                  ],
                );
              },
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                      color: getColor,
                      borderRadius: BorderRadius.circular(6),
                      border: !widget.dayViewModel.isBetweenSelectedDates
                          ? Border.all(
                              color: getBorderColor,
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 1.0 - animation.value,
                          color: getShadowColor,
                          blurRadius: 5.0 - animation.value,
                        )
                      ]),
                  child: child,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        widget.dayViewModel.day.toString(),
                        style: config.textStyle.copyWith(
                          color: getTextColor,
                        ),
                      ),
                    ),
                    if (widget.dayViewModel.isAfterStartDate)
                      Selector<CalendarProvider, bool>(
                        shouldRebuild: (previous, next) {
                          return previous != next || !next;
                        },
                        selector: (context, provider) {
                          return provider.loadingSubtitles;
                        },
                        builder: (context, loading, child) {
                          return SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            child: loading
                                ? const SpinKitThreeBounceFade()
                                : Builder(
                                    builder: (context) {
                                      return Center(
                                          child: _buildSubTitle(
                                        context,
                                        widget.dayViewModel
                                            .isBetweenSelectedDates,
                                      ));
                                    },
                                  ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RedDot extends StatelessWidget {
  const RedDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}
