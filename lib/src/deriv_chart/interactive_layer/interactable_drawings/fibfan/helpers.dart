import 'dart:math' as math;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Helper class for Fibonacci Fan drawing operations
class FibonacciFanHelpers {
  /// Fibonacci ratios for the fan lines
  static const List<double> fibRatios = [0.0, 0.382, 0.5, 0.618, 1.0];

  /// Labels for each Fibonacci level
  static const List<String> fibonacciLabels = [
    '100%',
    '61.8%',
    '50%',
    '38.2%',
    '0%',
  ];

  /// Draws the filled areas between fan lines
  static void drawFanFills(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    DrawingPaintStyle paintStyle,
    LineStyle fillStyle,
  ) {
    for (int i = 0; i < fibRatios.length - 1; i++) {
      final double ratio1 = fibRatios[i];
      final double ratio2 = fibRatios[i + 1];

      final Offset fanPoint1 = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio1,
      );
      final Offset fanPoint2 = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio2,
      );

      // Extend lines to the edge of the screen
      final double screenWidth = size.width;
      final double slope1 =
          (fanPoint1.dy - startOffset.dy) / (fanPoint1.dx - startOffset.dx);
      final double slope2 =
          (fanPoint2.dy - startOffset.dy) / (fanPoint2.dx - startOffset.dx);

      final Offset extendedPoint1 = Offset(
        screenWidth,
        startOffset.dy + slope1 * (screenWidth - startOffset.dx),
      );
      final Offset extendedPoint2 = Offset(
        screenWidth,
        startOffset.dy + slope2 * (screenWidth - startOffset.dx),
      );

      // Create path for the filled area
      final Path fillPath = Path()
        ..moveTo(startOffset.dx, startOffset.dy)
        ..lineTo(extendedPoint1.dx, extendedPoint1.dy)
        ..lineTo(extendedPoint2.dx, extendedPoint2.dy)
        ..close();

      // Draw filled area with alternating opacity
      final double opacity = (i % 2 == 0) ? 0.1 : 0.05;
      canvas.drawPath(
        fillPath,
        paintStyle.fillPaintStyle(
          fillStyle.color.withOpacity(opacity),
          fillStyle.thickness,
        ),
      );
    }
  }

  /// Draws the fan lines
  static void drawFanLines(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle, {
    Map<String, Color>? fibonacciLevelColors,
  }) {
    for (int i = 0; i < FibonacciFanHelpers.fibRatios.length; i++) {
      final double ratio = FibonacciFanHelpers.fibRatios[i];

      // Use custom color if provided, otherwise use default line style color
      final List<String> colorKeys = [
        'level0',
        'level38_2',
        'level50',
        'level61_8',
        'level100'
      ];
      final Color lineColor = (fibonacciLevelColors != null &&
              i < colorKeys.length &&
              fibonacciLevelColors.containsKey(colorKeys[i]))
          ? fibonacciLevelColors[colorKeys[i]]!
          : lineStyle.color;

      final Paint linePaint = paintStyle.linePaintStyle(
        lineColor,
        lineStyle.thickness,
      );

      final Offset fanPoint = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio,
      );

      // Extend line to the edge of the screen
      final double screenWidth = size.width;
      final double slope =
          (fanPoint.dy - startOffset.dy) / (fanPoint.dx - startOffset.dx);
      final Offset extendedPoint = Offset(
        screenWidth,
        startOffset.dy + slope * (screenWidth - startOffset.dx),
      );

      canvas.drawLine(startOffset, extendedPoint, linePaint);
    }
  }

  /// Draws labels for the fan lines
  static void drawFanLabels(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    LineStyle lineStyle, {
    required List<String> fibonacciLabels,
    Map<String, Color>? fibonacciLevelColors,
  }) {
    final List<String> labelsToUse = fibonacciLabels;

    for (int i = 0; i < FibonacciFanHelpers.fibRatios.length; i++) {
      final double ratio = FibonacciFanHelpers.fibRatios[i];
      final String label = i < labelsToUse.length ? labelsToUse[i] : '';

      final Offset fanPoint = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio,
      );

      // Calculate the angle of the fan line
      final double lineAngle = math.atan2(
        fanPoint.dy - startOffset.dy,
        fanPoint.dx - startOffset.dx,
      );

      // Calculate label position along the line
      final Offset labelPosition = Offset(
        startOffset.dx + (fanPoint.dx - startOffset.dx) * 1.02,
        startOffset.dy + (fanPoint.dy - startOffset.dy) * 1.02,
      );

      // Use custom color if provided, otherwise use default line style color
      final List<String> colorKeys = [
        'level0',
        'level38_2',
        'level50',
        'level61_8',
        'level100'
      ];
      final Color labelColor = (fibonacciLevelColors != null &&
              i < colorKeys.length &&
              fibonacciLevelColors.containsKey(colorKeys[i]))
          ? fibonacciLevelColors[colorKeys[i]]!
          : lineStyle.color;

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Save the current canvas state
      canvas
        ..save()

        // Translate to the label position
        ..translate(labelPosition.dx, labelPosition.dy)

        // Rotate the canvas by the line angle
        ..rotate(lineAngle);

      // Adjust text position to left-align it when rotated
      final Offset textOffset = Offset(
        5, // Small offset from the line
        -textPainter.height,
      );

      // Draw the rotated text
      textPainter.paint(canvas, textOffset);

      // Restore the canvas state
      canvas.restore();
    }
  }
}
