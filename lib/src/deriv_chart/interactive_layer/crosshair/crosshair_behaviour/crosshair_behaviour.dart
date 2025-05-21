import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

abstract class CrosshairBehaviour<T extends Tick> {
  /// Creates a custom painter for the crosshair lines.

  Widget getCrossHairInfo(
      {required DataSeries<T> mainSeries,
      required T crosshairTick,
      required int pipSize,
      required ChartTheme theme});

  Widget createTimeLabel(
      {required String dateText,
      required TextStyle style,
      String timeText = ''});

  CustomPainter createLinePainter({
    required ChartTheme theme,
    double cursorY = 0,
  });

  CustomPainter? createDotPainter({
    dotColor = const Color(0xFF85ACB0),
    dotBorderColor = const Color(0xFF85ACB0),
  }) =>
      null;

  Widget createCrosshairLabel(
      {required Widget content,
      required Offset translationOffset,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      EdgeInsetsGeometry? containerPadding =
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      Decoration? decoration});

  Widget createCrosshairDetails(
      {required T crosshairTick,
      required Duration animationDuration,
      required DataSeries<T> mainSeries,
      required ChartTheme theme,
      required Widget crosshairHeader,
      double? width,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      AlignmentGeometry alignment = Alignment.center,
      int pipSize = 4,
      double cursorY = 0});

  double calculateDetailsPosition({required double cursorY});

  double get detailsBoxHeight;

  double get detailsBoxWidth;
}
