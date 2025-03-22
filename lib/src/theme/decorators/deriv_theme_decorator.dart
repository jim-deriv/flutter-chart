import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

class DerivThemeDecorator extends ChartThemeDecorator {
  DerivThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  @override
  LineStyle get areaLineStyle => const LineStyle(
          color: DerivThemeColors.areaDerivLine,
          hasArea: true,
          areaGradientColors: (
            start: DerivThemeColors.areaDerivGradientStart,
            end: DerivThemeColors.areaDerivGradientEnd,
          ));

  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
        color: DerivThemeColors.currentSpotDerivContainer,
        textStyle: textStyle(
            textStyle: currentSpotLabelText,
            color: DerivThemeColors.currentSpotDerivLabel),
        isDashed: false,
      );
}
