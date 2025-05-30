import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/zigzag_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'zigzag_indicator_item.dart';

part 'zigzag_indicator_config.g.dart';

/// ZigZag indicator config
@JsonSerializable()
class ZigZagIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const ZigZagIndicatorConfig({
    this.distance = 10,
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    String? title,
    super.number,
  }) : super(title: title ?? ZigZagIndicatorConfig.name);

  /// Initializes from JSON.
  factory ZigZagIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$ZigZagIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'zigzag';

  @override
  Map<String, dynamic> toJson() => _$ZigZagIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// ZigZag distance in %
  final double distance;

  /// ZigZag line style
  final LineStyle lineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => ZigZagSeries(
        indicatorInput,
        distance: distance,
        style: lineStyle,
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      ZigZagIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  ZigZagIndicatorConfig copyWith({
    double? distance,
    LineStyle? lineStyle,
    String? title,
    int? number,
    bool? showLastIndicator,
    int? pipSize,
  }) =>
      ZigZagIndicatorConfig(
        distance: distance ?? this.distance,
        lineStyle: lineStyle ?? this.lineStyle,
        title: title ?? this.title,
        number: number ?? this.number,
      );
}
