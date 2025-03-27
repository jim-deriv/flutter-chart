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
///
/// This class implements the Decorator design pattern, allowing for dynamic
/// extension of a theme's functionality without modifying the theme itself.
/// Concrete implementations can override specific properties to customize
/// the appearance of chart elements while inheriting all other properties
/// from the base theme.
///
/// To create a custom theme decorator:
/// 1. Extend this class
/// 2. Override the properties you want to customize
/// 3. Use the base theme for all other properties
///
/// Example:
/// ```dart
/// class MyCustomThemeDecorator extends ChartThemeDecorator {
///   MyCustomThemeDecorator(ChartTheme baseTheme) : super(baseTheme);
///
///   @override
///   Color get backgroundColor => Colors.purple;
///
///   @override
///   LineStyle get lineStyle => LineStyle(color: Colors.orange);
/// }
/// ```
abstract class ChartThemeDecorator implements ChartTheme {
  /// Creates a theme decorator with the specified base theme.
  ///
  /// The [baseTheme] is the theme being decorated.
  ChartThemeDecorator(this._baseTheme);

  /// The base theme being decorated.
  final ChartTheme _baseTheme;

  /// The name or identifier of this theme decorator.
  ///
  /// This can be useful for debugging or for UI elements that need to display
  /// the current theme.
  String get themeName => runtimeType.toString();

  /// The base theme being decorated.
  ///
  /// This getter provides read-only access to the base theme for inspection.
  ChartTheme get baseTheme => _baseTheme;

  /// Returns a string representation of this theme decorator for debugging purposes.
  @override
  String toString() =>
      'ChartThemeDecorator(themeName: $themeName, baseTheme: $_baseTheme)';

  /// Creates a copy of this decorator with the specified color overrides.
  ///
  /// This method allows for customizing all color properties of the theme without
  /// creating a new decorator class.
  ChartThemeDecorator withColors({
    Color? backgroundColor,
    Color? textColor,
    Color? lineColor,
    Color? subtitleColor,
    Color? containerColor,
    Color? accentGreenColor,
    Color? accentRedColor,
    Color? accentYellowColor,
    Color? brandCoralColor,
    Color? brandGreenishColor,
    Color? brandOrangeColor,
    Color? gradientStart,
    Color? gradientEnd,
    Color? dotColor,
    Color? effectColor,
    Color? subtitle2Color,
    Color? desktopColor,
    Color? hoverColor,
    Color? base01Color,
    Color? base02Color,
    Color? base03Color,
    Color? base04Color,
    Color? base05Color,
    Color? base06Color,
    Color? base07Color,
    Color? base08Color,
  }) {
    return _ColorOverrideThemeDecorator(
      this,
      customBackgroundColor: backgroundColor,
      customTextColor: textColor,
      customLineColor: lineColor,
      customSubtitleColor: subtitleColor,
      customContainerColor: containerColor,
      customAccentGreenColor: accentGreenColor,
      customAccentRedColor: accentRedColor,
      customAccentYellowColor: accentYellowColor,
      customBrandCoralColor: brandCoralColor,
      customBrandGreenishColor: brandGreenishColor,
      customBrandOrangeColor: brandOrangeColor,
      customGradientStart: gradientStart,
      customGradientEnd: gradientEnd,
      customDotColor: dotColor,
      customEffectColor: effectColor,
      customSubtitle2Color: subtitle2Color,
      customDesktopColor: desktopColor,
      customHoverColor: hoverColor,
      customBase01Color: base01Color,
      customBase02Color: base02Color,
      customBase03Color: base03Color,
      customBase04Color: base04Color,
      customBase05Color: base05Color,
      customBase06Color: base06Color,
      customBase07Color: base07Color,
      customBase08Color: base08Color,
    );
  }

  /// Creates a copy of this decorator with the specified style overrides.
  ///
  /// This method allows for customizing all style properties of the theme without
  /// creating a new decorator class.
  ChartThemeDecorator withStyles({
    // Painting styles
    LineStyle? lineStyle,
    LineStyle? areaLineStyle,
    CandleStyle? candleStyle,
    BarStyle? barStyle,
    MarkerStyle? markerStyle,
    GridStyle? gridStyle,
    GridStyle? axisGridStyle,
    HorizontalBarrierStyle? horizontalBarrierStyle,
    VerticalBarrierStyle? verticalBarrierStyle,
    EntrySpotStyle? entrySpotStyle,
    HorizontalBarrierStyle? currentSpotStyle,

    // Text styles
    TextStyle? currentSpotLabelText,
    TextStyle? caption2,
    TextStyle? subheading,
    TextStyle? body2,
    TextStyle? body1,
    TextStyle? title,
    TextStyle? overLine,
  }) {
    return _StyleOverrideThemeDecorator(
      this,
      // Painting styles
      customLineStyle: lineStyle,
      customAreaLineStyle: areaLineStyle,
      customCandleStyle: candleStyle,
      customBarStyle: barStyle,
      customMarkerStyle: markerStyle,
      customGridStyle: gridStyle,
      customAxisGridStyle: axisGridStyle,
      customHorizontalBarrierStyle: horizontalBarrierStyle,
      customVerticalBarrierStyle: verticalBarrierStyle,
      customEntrySpotStyle: entrySpotStyle,
      customCurrentSpotStyle: currentSpotStyle,

      // Text styles
      customCurrentSpotLabelText: currentSpotLabelText,
      customCaption2: caption2,
      customSubheading: subheading,
      customBody2: body2,
      customBody1: body1,
      customTitle: title,
      customOverLine: overLine,
    );
  }

  // Cache for text styles to improve performance
  final Map<TextStyle, Map<Color?, TextStyle>> _textStyleCache =
      <TextStyle, Map<Color?, TextStyle>>{};

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
  TextStyle textStyle({required TextStyle textStyle, Color? color}) {
    // Use cached version if available
    _textStyleCache.putIfAbsent(textStyle, () => <Color?, TextStyle>{});
    return _textStyleCache[textStyle]!.putIfAbsent(
      color,
      () => _baseTheme.textStyle(textStyle: textStyle, color: color),
    );
  }

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

/// A private implementation of [ChartThemeDecorator] that overrides specific colors.
///
/// This class is used by the [ChartThemeDecorator.withColors] method to create
/// a decorator that overrides specific colors of the base theme.
class _ColorOverrideThemeDecorator extends ChartThemeDecorator {
  _ColorOverrideThemeDecorator(
    ChartTheme baseTheme, {
    this.customBackgroundColor,
    this.customTextColor,
    this.customLineColor,
    this.customSubtitleColor,
    this.customContainerColor,
    this.customAccentGreenColor,
    this.customAccentRedColor,
    this.customAccentYellowColor,
    this.customBrandCoralColor,
    this.customBrandGreenishColor,
    this.customBrandOrangeColor,
    this.customGradientStart,
    this.customGradientEnd,
    this.customDotColor,
    this.customEffectColor,
    this.customSubtitle2Color,
    this.customDesktopColor,
    this.customHoverColor,
    this.customBase01Color,
    this.customBase02Color,
    this.customBase03Color,
    this.customBase04Color,
    this.customBase05Color,
    this.customBase06Color,
    this.customBase07Color,
    this.customBase08Color,
  }) : super(baseTheme);

  final Color? customBackgroundColor;
  final Color? customTextColor;
  final Color? customLineColor;
  final Color? customSubtitleColor;
  final Color? customContainerColor;
  final Color? customAccentGreenColor;
  final Color? customAccentRedColor;
  final Color? customAccentYellowColor;
  final Color? customBrandCoralColor;
  final Color? customBrandGreenishColor;
  final Color? customBrandOrangeColor;

  final Color? customGradientStart;
  final Color? customGradientEnd;
  final Color? customDotColor;
  final Color? customEffectColor;
  final Color? customSubtitle2Color;
  final Color? customDesktopColor;
  final Color? customHoverColor;

  final Color? customBase01Color;
  final Color? customBase02Color;
  final Color? customBase03Color;
  final Color? customBase04Color;
  final Color? customBase05Color;
  final Color? customBase06Color;
  final Color? customBase07Color;
  final Color? customBase08Color;

  @override
  Color get backgroundColor => customBackgroundColor ?? super.backgroundColor;

  @override
  Color get textColor => customTextColor ?? super.textColor;

  @override
  Color get lineColor => customLineColor ?? super.lineColor;

  @override
  Color get subtitleColor => customSubtitleColor ?? super.subtitleColor;

  @override
  Color get containerColor => customContainerColor ?? super.containerColor;

  @override
  Color get accentGreenColor =>
      customAccentGreenColor ?? super.accentGreenColor;

  @override
  Color get accentRedColor => customAccentRedColor ?? super.accentRedColor;

  @override
  Color get accentYellowColor =>
      customAccentYellowColor ?? super.accentYellowColor;

  @override
  Color get brandCoralColor => customBrandCoralColor ?? super.brandCoralColor;

  @override
  Color get brandGreenishColor =>
      customBrandGreenishColor ?? super.brandGreenishColor;

  @override
  Color get brandOrangeColor =>
      customBrandOrangeColor ?? super.brandOrangeColor;

  @override
  Color get gradientStart => customGradientStart ?? super.gradientStart;

  @override
  Color get gradientEnd => customGradientEnd ?? super.gradientEnd;

  @override
  Color get dotColor => customDotColor ?? super.dotColor;

  @override
  Color get effectColor => customEffectColor ?? super.effectColor;

  @override
  Color get subtitle2Color => customSubtitle2Color ?? super.subtitle2Color;

  @override
  Color get desktopColor => customDesktopColor ?? super.desktopColor;

  @override
  Color get hoverColor => customHoverColor ?? super.hoverColor;

  @override
  Color get base01Color => customBase01Color ?? super.base01Color;

  @override
  Color get base02Color => customBase02Color ?? super.base02Color;

  @override
  Color get base03Color => customBase03Color ?? super.base03Color;

  @override
  Color get base04Color => customBase04Color ?? super.base04Color;

  @override
  Color get base05Color => customBase05Color ?? super.base05Color;

  @override
  Color get base06Color => customBase06Color ?? super.base06Color;

  @override
  Color get base07Color => customBase07Color ?? super.base07Color;

  @override
  Color get base08Color => customBase08Color ?? super.base08Color;

  @override
  String get themeName => '${super.themeName}_ColorOverride';
}

/// A private implementation of [ChartThemeDecorator] that overrides specific styles.
///
/// This class is used by the [ChartThemeDecorator.withStyles] method to create
/// a decorator that overrides specific styles of the base theme.
class _StyleOverrideThemeDecorator extends ChartThemeDecorator {
  _StyleOverrideThemeDecorator(
    ChartTheme baseTheme, {
    // Painting styles
    this.customLineStyle,
    this.customAreaLineStyle,
    this.customCandleStyle,
    this.customBarStyle,
    this.customMarkerStyle,
    this.customGridStyle,
    this.customAxisGridStyle,
    this.customHorizontalBarrierStyle,
    this.customVerticalBarrierStyle,
    this.customEntrySpotStyle,
    this.customCurrentSpotStyle,

    // Text styles
    this.customCurrentSpotLabelText,
    this.customCaption2,
    this.customSubheading,
    this.customBody2,
    this.customBody1,
    this.customTitle,
    this.customOverLine,
  }) : super(baseTheme);

  // Painting styles
  final LineStyle? customLineStyle;
  final LineStyle? customAreaLineStyle;
  final CandleStyle? customCandleStyle;
  final BarStyle? customBarStyle;
  final MarkerStyle? customMarkerStyle;
  final GridStyle? customGridStyle;
  final GridStyle? customAxisGridStyle;
  final HorizontalBarrierStyle? customHorizontalBarrierStyle;
  final VerticalBarrierStyle? customVerticalBarrierStyle;
  final EntrySpotStyle? customEntrySpotStyle;
  final HorizontalBarrierStyle? customCurrentSpotStyle;

  // Text styles
  final TextStyle? customCurrentSpotLabelText;
  final TextStyle? customCaption2;
  final TextStyle? customSubheading;
  final TextStyle? customBody2;
  final TextStyle? customBody1;
  final TextStyle? customTitle;
  final TextStyle? customOverLine;

  // Painting style overrides
  @override
  LineStyle get lineStyle => customLineStyle ?? super.lineStyle;

  @override
  LineStyle get areaLineStyle => customAreaLineStyle ?? super.areaLineStyle;

  @override
  CandleStyle get candleStyle => customCandleStyle ?? super.candleStyle;

  @override
  BarStyle get barStyle => customBarStyle ?? super.barStyle;

  @override
  MarkerStyle get markerStyle => customMarkerStyle ?? super.markerStyle;

  @override
  GridStyle get gridStyle => customGridStyle ?? super.gridStyle;

  @override
  GridStyle get axisGridStyle => customAxisGridStyle ?? super.axisGridStyle;

  @override
  HorizontalBarrierStyle get horizontalBarrierStyle =>
      customHorizontalBarrierStyle ?? super.horizontalBarrierStyle;

  @override
  VerticalBarrierStyle get verticalBarrierStyle =>
      customVerticalBarrierStyle ?? super.verticalBarrierStyle;

  @override
  EntrySpotStyle get entrySpotStyle =>
      customEntrySpotStyle ?? super.entrySpotStyle;

  @override
  HorizontalBarrierStyle get currentSpotStyle =>
      customCurrentSpotStyle ?? super.currentSpotStyle;

  // Text style overrides
  @override
  TextStyle get currentSpotLabelText =>
      customCurrentSpotLabelText ?? super.currentSpotLabelText;

  @override
  TextStyle get caption2 => customCaption2 ?? super.caption2;

  @override
  TextStyle get subheading => customSubheading ?? super.subheading;

  @override
  TextStyle get body2 => customBody2 ?? super.body2;

  @override
  TextStyle get body1 => customBody1 ?? super.body1;

  @override
  TextStyle get title => customTitle ?? super.title;

  @override
  TextStyle get overLine => customOverLine ?? super.overLine;

  @override
  String get themeName => '${super.themeName}_StyleOverride';

}
