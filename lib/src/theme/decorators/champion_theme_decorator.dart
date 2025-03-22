import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

class ChampionThemeDecorator extends ChartThemeDecorator {
  ChampionThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  @override
  LineStyle get areaLineStyle => const LineStyle(
          color: ChampionThemeColors.areaChampionLine,
          hasArea: true,
          areaGradientColors: (
            start: ChampionThemeColors.areaChampionGradientStart,
            end: ChampionThemeColors.areaChampionGradientEnd,
          ));

  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
        color: ChampionThemeColors.currentSpotChampionContainer,
        textStyle: textStyle(
            textStyle: currentSpotLabelText,
            color: ChampionThemeColors.currentSpotChampionLabel),
        isDashed: false,
      );
}
