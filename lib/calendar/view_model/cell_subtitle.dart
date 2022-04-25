import 'package:flutter/material.dart';

class CellSubtitle {
  final String? string;
  final TextStyle? style;
  final DateTime time;
  final Widget Function()? builder;

  CellSubtitle({
    required this.time,
    this.style,
    this.builder,
    this.string,
  })  : assert(
          builder == null || (style == null && string == null),
          'both color and builder can\'t be provided',
        ),
        assert(
          builder != null || (style != null && string != null),
          'at least "builder" or "color must be provided',
        );

  bool get hasBuilder => builder != null;

  Widget build(BuildContext context) {
    return builder?.call() ??
        Text(
          string!,
          style: style,
        );
  }
}
