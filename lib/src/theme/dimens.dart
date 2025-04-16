import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';

/// This class includes dimensions according to Deriv design guidelines.
///
/// More dimens values can be added here following the convention margin_x
/// In case of a theme change, use IDE refactoring technique to rename the value
/// So it can be reflected wherever it is used with ease.
class Dimens {
  /// Tiny margin.
  static const double margin04 = 4;

  /// Small margin.
  static const double margin08 = 8;

  /// Custom margin.
  static const double margin12 = 12;

  /// Normal  margin.
  static const double margin16 = 16;

  /// Large  margin.
  static const double margin24 = 24;

  /// X-Large  margin.
  static const double margin32 = 32;

  /// Border radius small.
  static const double borderRadius04 = 4;

  /// Border radius medium.
  static const double borderRadius08 = 8;

  /// Border radius large.
  static const double borderRadius16 = 16;

  /// Border radius x-large.
  static const double borderRadius24 = 24;

  /// 5 rem (Value: 80)
  static const double crosshairInformationBoxContainerGlassBackgroundBlur =
      CoreDesignTokens.coreSize4000;

  /// Default area line thickness 1
  static const double areaLineDefaultThickness = 1;

  /// Medium area line thickness 1.5
  static const double areaLineMediumThickness = 1.5;

  /// Large area line thickness 2
  static const double areaLineLargeThickness = 2;

  /// Small candle body size 4
  static const double candleBodyWidthSmall = 4;

  /// Medium candle body size 8
  static const double candleBodyWidthMedium = 8;

  /// Large candle body size 16
  static const double candleBodyWidthLarge = 16;

  /// Small candle wick size 1
  static const double candleWickWidthSmall = 1;

  /// Medium candle wick size 1
  static const double candleWickWidthMedium = 1;

  /// Large candle wick size 2
  static const double candleWickWidthLarge = 2;
}
