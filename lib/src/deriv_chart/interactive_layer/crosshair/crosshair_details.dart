import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/dimens.dart';

/// The details to show on a crosshair.
class CrosshairDetails extends StatelessWidget {
  /// Initializes the details to show on a crosshair.
  const CrosshairDetails({
    required this.mainSeries,
    required this.crosshairTick,
    required this.crosshairHeader,
    required this.crosshairInfo,
    required this.crosshairTimeLabel,
    required this.detailsBoxWidth,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// The chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// The basic data entry of a crosshair.
  final Tick crosshairTick;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  final Widget crosshairHeader;

  final Widget crosshairInfo;

  final Widget crosshairTimeLabel;

  final double detailsBoxWidth;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.read<ChartTheme>();
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
            sigmaY: theme.crosshairInformationBoxContainerGlassBackgroundBlur),
        child: Container(
          width: detailsBoxWidth,
          decoration: BoxDecoration(
            color: theme.crosshairInformationBoxContainerGlassColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              crosshairHeader,
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.margin08, vertical: Dimens.margin04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    crosshairInfo,
                    crosshairTimeLabel,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
