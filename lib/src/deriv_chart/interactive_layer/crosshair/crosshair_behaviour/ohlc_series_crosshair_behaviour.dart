import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/large_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/small_screen_crosshair_behaviour.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

class OHLCSeriesLargeScreenBehaviour<T extends Tick>
    extends LargeScreenCrosshairBehavior<T> {
  @override
  double get detailsBoxHeight => 100;
  @override
  double get detailsBoxWidth => 127;
}

class OHLCSeriesSmallScreenBehaviour<T extends Tick>
    extends SmallScreenCrosshairBehaviour<T> {
  @override
  CustomPainter? createDotPainter(
      {dotColor = const Color(0xFF85ACB0),
      dotBorderColor = const Color(0xFF85ACB0)}) {
    return null;
  }
}
