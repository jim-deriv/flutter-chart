import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_spot_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// A decorator for [ChartTheme] which allows for the decoration of a theme.
/// This class is useful for adding additional functionality to a theme without
/// modifying the theme itself.
abstract class ChartThemeDecorator implements ChartTheme {
  /// Creates a theme decorator with the specified base theme.
  ///
  /// The [baseTheme] is the theme being decorated.
  ChartThemeDecorator(this._baseTheme);

  /// The base theme being decorated.
  final ChartTheme _baseTheme;

  @override
  Color get accentGreenColor => _baseTheme.accentGreenColor;

  @override
  Color get accentRedColor => _baseTheme.accentRedColor;

  @override
  Color get accentYellowColor => _baseTheme.accentYellowColor;

  @override
  LineStyle get areaLineStyle => _baseTheme.areaLineStyle;

  @override
  GridStyle get axisGridStyle => _baseTheme.axisGridStyle;

  @override
  Color get backgroundColor => _baseTheme.backgroundColor;

  @override
  BarStyle get barStyle => _baseTheme.barStyle;

  @override
  Color get base01Color => _baseTheme.base01Color;

  @override
  Color get base02Color => _baseTheme.base02Color;

  @override
  Color get base03Color => _baseTheme.base03Color;

  @override
  Color get base04Color => _baseTheme.base04Color;

  @override
  Color get base05Color => _baseTheme.base05Color;

  @override
  Color get base06Color => _baseTheme.base06Color;

  @override
  Color get base07Color => _baseTheme.base07Color;

  @override
  Color get base08Color => _baseTheme.base08Color;

  @override
  Color get hoverColor => _baseTheme.hoverColor;

  @override
  TextStyle get body1 => _baseTheme.body1;

  @override
  TextStyle get body2 => _baseTheme.body2;

  @override
  double get borderRadius04Chart => _baseTheme.borderRadius04Chart;

  @override
  double get borderRadius08Chart => _baseTheme.borderRadius08Chart;

  @override
  double get borderRadius16Chart => _baseTheme.borderRadius16Chart;

  @override
  double get borderRadius24Chart => _baseTheme.borderRadius24Chart;

  @override
  Color get brandCoralColor => _baseTheme.brandCoralColor;

  @override
  Color get brandGreenishColor => _baseTheme.brandGreenishColor;

  @override
  Color get brandOrangeColor => _baseTheme.brandOrangeColor;

  @override
  CandleStyle get candleStyle => _baseTheme.candleStyle;

  @override
  TextStyle get caption2 => _baseTheme.caption2;

  @override
  TextStyle get currentSpotLabelText => _baseTheme.currentSpotLabelText;

  @override
  HorizontalBarrierStyle get currentSpotStyle => _baseTheme.currentSpotStyle;

  @override
  EntrySpotStyle get entrySpotStyle => _baseTheme.entrySpotStyle;

  @override
  String get fontFamily => _baseTheme.fontFamily;

  @override
  GridStyle get gridStyle => _baseTheme.gridStyle;

  @override
  HorizontalBarrierStyle get horizontalBarrierStyle =>
      _baseTheme.horizontalBarrierStyle;

  @override
  LineStyle get lineStyle => _baseTheme.lineStyle;

  @override
  double get margin04Chart => _baseTheme.margin04Chart;

  @override
  double get margin08Chart => _baseTheme.margin08Chart;

  @override
  double get margin12Chart => _baseTheme.margin12Chart;

  @override
  double get margin16Chart => _baseTheme.margin16Chart;

  @override
  double get margin24Chart => _baseTheme.margin24Chart;

  @override
  double get margin32Chart => _baseTheme.margin32Chart;

  @override
  MarkerStyle get markerStyle => _baseTheme.markerStyle;

  @override
  TextStyle get overLine => _baseTheme.overLine;

  @override
  TextStyle get subheading => _baseTheme.subheading;

  @override
  TextStyle textStyle({required TextStyle textStyle, Color? color}) =>
      _baseTheme.textStyle(textStyle: textStyle, color: color);

  @override
  TextStyle get title => _baseTheme.title;

  @override
  VerticalBarrierStyle get verticalBarrierStyle =>
      _baseTheme.verticalBarrierStyle;

  @override
  Color get containerColor => _baseTheme.containerColor;

  @override
  Color get desktopColor => _baseTheme.desktopColor;

  @override
  Color get dotColor => _baseTheme.dotColor;

  @override
  Color get effectColor => _baseTheme.effectColor;

  @override
  Color get gradientEnd => _baseTheme.gradientEnd;

  @override
  Color get gradientStart => _baseTheme.gradientStart;

  @override
  Color get lineColor => _baseTheme.lineColor;

  @override
  Color get subtitle2Color => _baseTheme.subtitle2Color;

  @override
  Color get subtitleColor => _baseTheme.subtitleColor;

  @override
  Color get textColor => _baseTheme.textColor;
}
