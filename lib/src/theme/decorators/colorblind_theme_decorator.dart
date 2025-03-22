import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

class ColorblindThemeDecorator extends ChartThemeDecorator {
  ColorblindThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  @override
  CandleStyle get candleStyle => const CandleStyle(
      candleBullishBodyColor:
          CandleBullishThemeColors.candleBullishBodyColorBlind,
      candleBearishBodyColor:
          CandleBearishThemeColors.candleBearishBodyColorBlind,
      candleBullishWickColor:
          CandleBullishThemeColors.candleBullishWickColorBlind,
      candleBearishWickColor:
          CandleBearishThemeColors.candleBearishWickColorBlind);
}
