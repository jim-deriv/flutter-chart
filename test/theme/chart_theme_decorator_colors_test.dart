import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test implementation of ChartThemeDecorator for testing purposes
class TestChartThemeDecorator extends ChartThemeDecorator {
  TestChartThemeDecorator(ChartTheme baseTheme) : super(baseTheme);
}

void main() {
  late ChartTheme baseTheme;
  late ChartThemeDecorator decorator;

  setUp(() {
    baseTheme = ChartDefaultDarkTheme();
    decorator = TestChartThemeDecorator(baseTheme);
  });

  group('ChartThemeDecorator withColors test', () {
    test('withColors overrides all specified colors', () {
      // Define custom colors for testing
      const Color customBackgroundColor = Color(0xFF111111);
      const Color customTextColor = Color(0xFF222222);
      const Color customLineColor = Color(0xFF333333);
      const Color customSubtitleColor = Color(0xFF444444);
      const Color customContainerColor = Color(0xFF555555);
      const Color customAccentGreenColor = Color(0xFF666666);
      const Color customAccentRedColor = Color(0xFF777777);
      const Color customAccentYellowColor = Color(0xFF888888);
      const Color customBrandCoralColor = Color(0xFF999999);
      const Color customBrandGreenishColor = Color(0xFFAAAAAA);
      const Color customBrandOrangeColor = Color(0xFFBBBBBB);

      const Color customGradientStart = Color(0xFFCCCCCC);
      const Color customGradientEnd = Color(0xFFDDDDDD);
      const Color customDotColor = Color(0xFFEEEEEE);
      const Color customEffectColor = Color(0xFFFFFFFF);
      const Color customSubtitle2Color = Color(0xFF123456);
      const Color customDesktopColor = Color(0xFF234567);
      const Color customHoverColor = Color(0xFF345678);

      const Color customBase01Color = Color(0xFF456789);
      const Color customBase02Color = Color(0xFF56789A);
      const Color customBase03Color = Color(0xFF6789AB);
      const Color customBase04Color = Color(0xFF789ABC);
      const Color customBase05Color = Color(0xFF89ABCD);
      const Color customBase06Color = Color(0xFF9ABCDE);
      const Color customBase07Color = Color(0xFFABCDEF);
      const Color customBase08Color = Color(0xFFBCDEF0);

      // Create a decorated theme with all colors overridden
      final decoratedTheme = decorator.withColors(
        backgroundColor: customBackgroundColor,
        textColor: customTextColor,
        lineColor: customLineColor,
        subtitleColor: customSubtitleColor,
        containerColor: customContainerColor,
        accentGreenColor: customAccentGreenColor,
        accentRedColor: customAccentRedColor,
        accentYellowColor: customAccentYellowColor,
        brandCoralColor: customBrandCoralColor,
        brandGreenishColor: customBrandGreenishColor,
        brandOrangeColor: customBrandOrangeColor,
        gradientStart: customGradientStart,
        gradientEnd: customGradientEnd,
        dotColor: customDotColor,
        effectColor: customEffectColor,
        subtitle2Color: customSubtitle2Color,
        desktopColor: customDesktopColor,
        hoverColor: customHoverColor,
        base01Color: customBase01Color,
        base02Color: customBase02Color,
        base03Color: customBase03Color,
        base04Color: customBase04Color,
        base05Color: customBase05Color,
        base06Color: customBase06Color,
        base07Color: customBase07Color,
        base08Color: customBase08Color,
      );

      // Verify that all colors are overridden correctly
      expect(decoratedTheme.backgroundColor, equals(customBackgroundColor));
      expect(decoratedTheme.textColor, equals(customTextColor));
      expect(decoratedTheme.lineColor, equals(customLineColor));
      expect(decoratedTheme.subtitleColor, equals(customSubtitleColor));
      expect(decoratedTheme.containerColor, equals(customContainerColor));
      expect(decoratedTheme.accentGreenColor, equals(customAccentGreenColor));
      expect(decoratedTheme.accentRedColor, equals(customAccentRedColor));
      expect(decoratedTheme.accentYellowColor, equals(customAccentYellowColor));
      expect(decoratedTheme.brandCoralColor, equals(customBrandCoralColor));
      expect(
          decoratedTheme.brandGreenishColor, equals(customBrandGreenishColor));
      expect(decoratedTheme.brandOrangeColor, equals(customBrandOrangeColor));

      expect(decoratedTheme.gradientStart, equals(customGradientStart));
      expect(decoratedTheme.gradientEnd, equals(customGradientEnd));
      expect(decoratedTheme.dotColor, equals(customDotColor));
      expect(decoratedTheme.effectColor, equals(customEffectColor));
      expect(decoratedTheme.subtitle2Color, equals(customSubtitle2Color));
      expect(decoratedTheme.desktopColor, equals(customDesktopColor));
      expect(decoratedTheme.hoverColor, equals(customHoverColor));

      expect(decoratedTheme.base01Color, equals(customBase01Color));
      expect(decoratedTheme.base02Color, equals(customBase02Color));
      expect(decoratedTheme.base03Color, equals(customBase03Color));
      expect(decoratedTheme.base04Color, equals(customBase04Color));
      expect(decoratedTheme.base05Color, equals(customBase05Color));
      expect(decoratedTheme.base06Color, equals(customBase06Color));
      expect(decoratedTheme.base07Color, equals(customBase07Color));
      expect(decoratedTheme.base08Color, equals(customBase08Color));
    });

    test('withColors only overrides specified colors', () {
      // Define a single custom color
      const Color customBackgroundColor = Color(0xFF111111);

      // Create a decorated theme with only backgroundColor overridden
      final decoratedTheme = decorator.withColors(
        backgroundColor: customBackgroundColor,
      );

      // Verify that backgroundColor is overridden
      expect(decoratedTheme.backgroundColor, equals(customBackgroundColor));

      // Verify that other colors are not overridden
      expect(decoratedTheme.textColor, equals(baseTheme.textColor));
      expect(decoratedTheme.lineColor, equals(baseTheme.lineColor));
      expect(decoratedTheme.subtitleColor, equals(baseTheme.subtitleColor));
      expect(decoratedTheme.containerColor, equals(baseTheme.containerColor));
      expect(
          decoratedTheme.accentGreenColor, equals(baseTheme.accentGreenColor));
      expect(decoratedTheme.accentRedColor, equals(baseTheme.accentRedColor));
      expect(decoratedTheme.accentYellowColor,
          equals(baseTheme.accentYellowColor));
      expect(decoratedTheme.brandCoralColor, equals(baseTheme.brandCoralColor));
      expect(decoratedTheme.brandGreenishColor,
          equals(baseTheme.brandGreenishColor));
      expect(
          decoratedTheme.brandOrangeColor, equals(baseTheme.brandOrangeColor));
      expect(decoratedTheme.gradientStart, equals(baseTheme.gradientStart));
      expect(decoratedTheme.gradientEnd, equals(baseTheme.gradientEnd));
      expect(decoratedTheme.dotColor, equals(baseTheme.dotColor));
      expect(decoratedTheme.effectColor, equals(baseTheme.effectColor));
      expect(decoratedTheme.subtitle2Color, equals(baseTheme.subtitle2Color));
      expect(decoratedTheme.desktopColor, equals(baseTheme.desktopColor));
      expect(decoratedTheme.hoverColor, equals(baseTheme.hoverColor));
      expect(decoratedTheme.base01Color, equals(baseTheme.base01Color));
      expect(decoratedTheme.base02Color, equals(baseTheme.base02Color));
      expect(decoratedTheme.base03Color, equals(baseTheme.base03Color));
      expect(decoratedTheme.base04Color, equals(baseTheme.base04Color));
      expect(decoratedTheme.base05Color, equals(baseTheme.base05Color));
      expect(decoratedTheme.base06Color, equals(baseTheme.base06Color));
      expect(decoratedTheme.base07Color, equals(baseTheme.base07Color));
      expect(decoratedTheme.base08Color, equals(baseTheme.base08Color));
    });

    test('withColors overrides newly added color properties', () {
      // Define custom colors for testing newly added properties
      const Color customGradientStart = Color(0xFFCCCCCC);
      const Color customGradientEnd = Color(0xFFDDDDDD);
      const Color customDotColor = Color(0xFFEEEEEE);
      const Color customEffectColor = Color(0xFFFFFFFF);
      const Color customSubtitle2Color = Color(0xFF123456);
      const Color customDesktopColor = Color(0xFF234567);
      const Color customHoverColor = Color(0xFF345678);
      const Color customBase01Color = Color(0xFF456789);

      // Create a decorated theme with only newly added properties overridden
      final decoratedTheme = decorator.withColors(
        gradientStart: customGradientStart,
        gradientEnd: customGradientEnd,
        dotColor: customDotColor,
        effectColor: customEffectColor,
        subtitle2Color: customSubtitle2Color,
        desktopColor: customDesktopColor,
        hoverColor: customHoverColor,
        base01Color: customBase01Color,
      );

      // Verify that newly added properties are overridden
      expect(decoratedTheme.gradientStart, equals(customGradientStart));
      expect(decoratedTheme.gradientEnd, equals(customGradientEnd));
      expect(decoratedTheme.dotColor, equals(customDotColor));
      expect(decoratedTheme.effectColor, equals(customEffectColor));
      expect(decoratedTheme.subtitle2Color, equals(customSubtitle2Color));
      expect(decoratedTheme.desktopColor, equals(customDesktopColor));
      expect(decoratedTheme.hoverColor, equals(customHoverColor));
      expect(decoratedTheme.base01Color, equals(customBase01Color));

      // Verify that original properties are not overridden
      expect(decoratedTheme.backgroundColor, equals(baseTheme.backgroundColor));
      expect(decoratedTheme.textColor, equals(baseTheme.textColor));
      expect(decoratedTheme.lineColor, equals(baseTheme.lineColor));
    });
  });
}
