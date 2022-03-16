import 'package:flutter/material.dart';

class CalendarConfig {
  final Color normalTextColor;
  final Color disabledCellColor;
  final Color disabledDaysCellColor;
  final Color disableCellTextColor;
  final Color selectedCellColor;
  final Color selectedCellBorderColor;
  final Color deselectedCellColor;
  final Color deselectedCellBorderColor;
  final Color betweenSelectedCellColor;
  final Color betweenSelectedCellTextColor;
  final Color backgroundColor;
  final Color monthBarBackgroundColor;

  final TextStyle textStyle;
  final TextStyle monthLabelStyle;

  const CalendarConfig({
    this.textStyle = const TextStyle(
      fontFamily: 'Arial',
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    this.monthLabelStyle = const TextStyle(
      fontFamily: 'Arial',
      color: Colors.grey,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    this.backgroundColor = Colors.white,
    this.disabledDaysCellColor = Colors.white,
    this.normalTextColor = Colors.black,
    this.disableCellTextColor = Colors.white70,
    this.betweenSelectedCellTextColor = Colors.white,
    this.monthBarBackgroundColor = Colors.white70,
    required this.selectedCellBorderColor,
    required this.deselectedCellBorderColor,
    required this.selectedCellColor,
    required this.betweenSelectedCellColor,
    required this.deselectedCellColor,
    required this.disabledCellColor,
  });
}
