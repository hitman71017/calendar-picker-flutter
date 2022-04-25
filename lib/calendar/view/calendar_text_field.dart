import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../view_model/calendar_view_model.dart';

class CalendarTextField extends StatefulWidget {
  final bool isFocused;
  final bool isRemovable;
  final bool isSelected;
  final bool alwaysWhite;
  final String placeHolder;
  final String? title;

  const CalendarTextField({
    required this.isFocused,
    required this.isSelected,
    this.alwaysWhite = false,
    this.isRemovable = false,
    required this.placeHolder,
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  _CalendarTextFieldState createState() => _CalendarTextFieldState();
}

class _CalendarTextFieldState extends State<CalendarTextField> {
  bool get isBlueStyle => widget.isFocused;

  bool get isWhite => widget.isFocused;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.read<CalendarProvider>();
    bool isEnabled = cp.getCalenderController.selectionMode ==
        CalendarSelectionMode.doubleSelection;

    return GestureDetector(
      onTap: () => _textFieldTapped(isEnabled),
      child: SizedBox(
        height: 35,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isEnabled || widget.alwaysWhite
                ? widget.isFocused
                    ? Colors.white
                    : Colors.white70
                : Colors.white70,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _buildTitle(),
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: isEnabled || widget.alwaysWhite
                                ? widget.isFocused
                                    ? Colors.blue
                                    : Colors.grey
                                : Colors.grey,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              if (widget.isRemovable)
                GestureDetector(
                  onTap: () => _textFieldTapped(isEnabled),
                  child: Icon(
                    isEnabled ? Icons.cancel : Icons.add_circle,
                    size: 24,
                    color: isEnabled ? Colors.white : Colors.blue,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  String _buildTitle() {
    String finalValue = widget.placeHolder;
    final hasValue = widget.title != null && widget.title!.isNotEmpty;
    if (hasValue) {
      finalValue = widget.title!;
    }
    return finalValue;
  }

  _textFieldTapped(bool isEnabled) {
    if (widget.isRemovable) {
      final calendarProvider =
          Provider.of<CalendarProvider>(context, listen: false);
      isEnabled
          ? calendarProvider.switchToSingleSelection()
          : calendarProvider.switchToRangeSelection();
    }
  }
}
