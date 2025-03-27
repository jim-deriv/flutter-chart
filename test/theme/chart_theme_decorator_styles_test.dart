import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_spot_style.dart';
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

  group('ChartThemeDecorator withStyles test', () {
    test('withStyles overrides all specified painting styles', () {
      // Define custom styles for testing
      final customLineStyle = LineStyle(color: Colors.red);
      final customAreaLineStyle = LineStyle(color: Colors.blue);
      final customCandleStyle = CandleStyle(
        candleBullishBodyColor: Colors.green,
        candleBearishBodyColor: Colors.red,
        candleBullishWickColor: Colors.lightGreen,
        candleBearishWickColor: Colors.pink,
      );
      final customBarStyle = BarStyle(
        positiveColor: Colors.green,
        negativeColor: Colors.red,
      );
      final customMarkerStyle = MarkerStyle(
        upColor: Colors.purple,
        radius: 5.0,
      );
      final customGridStyle = GridStyle(
        gridLineColor: Colors.grey,
        lineThickness: 1.0,
      );
      final customAxisGridStyle = GridStyle(
        gridLineColor: Colors.lightBlue,
        lineThickness: 0.5,
      );
      final customHorizontalBarrierStyle = HorizontalBarrierStyle(
        color: Colors.orange,
        isDashed: true,
      );
      final customVerticalBarrierStyle = VerticalBarrierStyle(
        color: Colors.yellow,
        isDashed: true,
      );
      final customEntrySpotStyle = EntrySpotStyle(
        mainColor: Colors.teal,
        radius: 4.0,
      );
      final customCurrentSpotStyle = HorizontalBarrierStyle(
        color: Colors.deepPurple,
        isDashed: false,
      );

      // Create a decorated theme with all painting styles overridden
      final decoratedTheme = decorator.withStyles(
        lineStyle: customLineStyle,
        areaLineStyle: customAreaLineStyle,
        candleStyle: customCandleStyle,
        barStyle: customBarStyle,
        markerStyle: customMarkerStyle,
        gridStyle: customGridStyle,
        axisGridStyle: customAxisGridStyle,
        horizontalBarrierStyle: customHorizontalBarrierStyle,
        verticalBarrierStyle: customVerticalBarrierStyle,
        entrySpotStyle: customEntrySpotStyle,
        currentSpotStyle: customCurrentSpotStyle,
      );

      // Verify that all painting styles are overridden correctly
      expect(decoratedTheme.lineStyle, equals(customLineStyle));
      expect(decoratedTheme.areaLineStyle, equals(customAreaLineStyle));
      expect(decoratedTheme.candleStyle, equals(customCandleStyle));
      expect(decoratedTheme.barStyle, equals(customBarStyle));
      expect(decoratedTheme.markerStyle, equals(customMarkerStyle));
      expect(decoratedTheme.gridStyle, equals(customGridStyle));
      expect(decoratedTheme.axisGridStyle, equals(customAxisGridStyle));
      expect(decoratedTheme.horizontalBarrierStyle,
          equals(customHorizontalBarrierStyle));
      expect(decoratedTheme.verticalBarrierStyle,
          equals(customVerticalBarrierStyle));
      expect(decoratedTheme.entrySpotStyle, equals(customEntrySpotStyle));
      expect(decoratedTheme.currentSpotStyle, equals(customCurrentSpotStyle));
    });

    test('withStyles overrides all specified text styles', () {
      // Define custom text styles for testing
      final customCurrentSpotLabelText = TextStyle(
        color: Colors.red,
        fontSize: 14.0,
      );
      final customCaption2 = TextStyle(
        color: Colors.blue,
        fontSize: 12.0,
      );
      final customSubheading = TextStyle(
        color: Colors.green,
        fontSize: 16.0,
      );
      final customBody2 = TextStyle(
        color: Colors.orange,
        fontSize: 14.0,
      );
      final customBody1 = TextStyle(
        color: Colors.purple,
        fontSize: 16.0,
      );
      final customTitle = TextStyle(
        color: Colors.teal,
        fontSize: 18.0,
      );
      final customOverLine = TextStyle(
        color: Colors.pink,
        fontSize: 10.0,
      );

      // Create a decorated theme with all text styles overridden
      final decoratedTheme = decorator.withStyles(
        currentSpotLabelText: customCurrentSpotLabelText,
        caption2: customCaption2,
        subheading: customSubheading,
        body2: customBody2,
        body1: customBody1,
        title: customTitle,
        overLine: customOverLine,
      );

      // Verify that all text styles are overridden correctly
      expect(decoratedTheme.currentSpotLabelText,
          equals(customCurrentSpotLabelText));
      expect(decoratedTheme.caption2, equals(customCaption2));
      expect(decoratedTheme.subheading, equals(customSubheading));
      expect(decoratedTheme.body2, equals(customBody2));
      expect(decoratedTheme.body1, equals(customBody1));
      expect(decoratedTheme.title, equals(customTitle));
      expect(decoratedTheme.overLine, equals(customOverLine));
    });

    test('withStyles only overrides specified styles', () {
      // Define a single custom style
      final customLineStyle = LineStyle(color: Colors.red);

      // Create a decorated theme with only lineStyle overridden
      final decoratedTheme = decorator.withStyles(
        lineStyle: customLineStyle,
      );

      // Verify that lineStyle is overridden
      expect(decoratedTheme.lineStyle, equals(customLineStyle));

      // Verify that other styles are not overridden
      expect(decoratedTheme.areaLineStyle, equals(baseTheme.areaLineStyle));
      expect(decoratedTheme.candleStyle, equals(baseTheme.candleStyle));
      expect(decoratedTheme.barStyle, equals(baseTheme.barStyle));

      // For MarkerStyle, compare individual properties instead of the whole object
      expect(decoratedTheme.markerStyle.upColor,
          equals(baseTheme.markerStyle.upColor));
      expect(decoratedTheme.markerStyle.downColor,
          equals(baseTheme.markerStyle.downColor));
      expect(decoratedTheme.markerStyle.radius,
          equals(baseTheme.markerStyle.radius));

      // For GridStyle, compare individual properties
      expect(decoratedTheme.gridStyle.gridLineColor,
          equals(baseTheme.gridStyle.gridLineColor));
      expect(decoratedTheme.gridStyle.lineThickness,
          equals(baseTheme.gridStyle.lineThickness));

      expect(decoratedTheme.axisGridStyle.gridLineColor,
          equals(baseTheme.axisGridStyle.gridLineColor));
      expect(decoratedTheme.axisGridStyle.lineThickness,
          equals(baseTheme.axisGridStyle.lineThickness));

      // For barrier styles, compare individual properties
      expect(decoratedTheme.horizontalBarrierStyle.color,
          equals(baseTheme.horizontalBarrierStyle.color));
      expect(decoratedTheme.horizontalBarrierStyle.isDashed,
          equals(baseTheme.horizontalBarrierStyle.isDashed));

      expect(decoratedTheme.verticalBarrierStyle.color,
          equals(baseTheme.verticalBarrierStyle.color));
      expect(decoratedTheme.verticalBarrierStyle.isDashed,
          equals(baseTheme.verticalBarrierStyle.isDashed));

      // For EntrySpotStyle, compare individual properties
      expect(decoratedTheme.entrySpotStyle.mainColor,
          equals(baseTheme.entrySpotStyle.mainColor));
      expect(decoratedTheme.entrySpotStyle.radius,
          equals(baseTheme.entrySpotStyle.radius));

      // For CurrentSpotStyle, compare individual properties
      expect(decoratedTheme.currentSpotStyle.color,
          equals(baseTheme.currentSpotStyle.color));
      expect(decoratedTheme.currentSpotStyle.isDashed,
          equals(baseTheme.currentSpotStyle.isDashed));
      expect(decoratedTheme.currentSpotLabelText,
          equals(baseTheme.currentSpotLabelText));
      expect(decoratedTheme.caption2, equals(baseTheme.caption2));
      expect(decoratedTheme.subheading, equals(baseTheme.subheading));
      expect(decoratedTheme.body2, equals(baseTheme.body2));
      expect(decoratedTheme.body1, equals(baseTheme.body1));
      expect(decoratedTheme.title, equals(baseTheme.title));
      expect(decoratedTheme.overLine, equals(baseTheme.overLine));
    });

    test('withStyles overrides newly added style properties', () {
      // Define custom styles for testing newly added properties
      final customAxisGridStyle = GridStyle(
        gridLineColor: Colors.lightBlue,
        lineThickness: 0.5,
      );
      final customCurrentSpotStyle = HorizontalBarrierStyle(
        color: Colors.deepPurple,
        isDashed: false,
      );
      final customCurrentSpotLabelText = TextStyle(
        color: Colors.red,
        fontSize: 14.0,
      );

      // Create a decorated theme with only newly added properties overridden
      final decoratedTheme = decorator.withStyles(
        axisGridStyle: customAxisGridStyle,
        currentSpotStyle: customCurrentSpotStyle,
        currentSpotLabelText: customCurrentSpotLabelText,
      );

      // Verify that newly added properties are overridden
      expect(decoratedTheme.axisGridStyle, equals(customAxisGridStyle));
      expect(decoratedTheme.currentSpotStyle, equals(customCurrentSpotStyle));
      expect(decoratedTheme.currentSpotLabelText,
          equals(customCurrentSpotLabelText));

      // Verify that original properties are not overridden
      expect(decoratedTheme.lineStyle, equals(baseTheme.lineStyle));
      expect(decoratedTheme.areaLineStyle, equals(baseTheme.areaLineStyle));
      expect(decoratedTheme.candleStyle, equals(baseTheme.candleStyle));
    });
  });
}
