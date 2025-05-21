import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/large_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/small_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

class LineSeriesLargeScreenBehaviour<T extends Tick>
    extends LargeScreenCrosshairBehavior<T> {
  @override
  double get detailsBoxHeight => 50;
  @override
  double get detailsBoxWidth => 127;
}

class LineSeriesSmallScreenBehaviour<T extends Tick>
    extends SmallScreenCrosshairBehaviour<T> {
  @override
  CustomPainter createDotPainter({
    dotColor = const Color(0xFF85ACB0),
    dotBorderColor = const Color(0xFF85ACB0),
  }) {
    return CrosshairDotPainter(
      dotColor: dotColor,
      dotBorderColor: dotBorderColor,
    );
  }
}
