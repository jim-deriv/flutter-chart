import 'dart:math' as math;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Helper class for Fibonacci Fan drawing operations
class FibonacciFanHelpers {
  /// Fibonacci levels with their ratios, labels, and color keys
  static final Map<double, Map<String, String>> fibonacciLevels = {
    0.0: {'label': '0%', 'colorKey': 'level0'},
    0.382: {'label': '38.2%', 'colorKey': 'level38_2'},
    0.5: {'label': '50%', 'colorKey': 'level50'},
    0.618: {'label': '61.8%', 'colorKey': 'level61_8'},
    1.0: {'label': '100%', 'colorKey': 'level100'},
  };

  /// Fibonacci ratios for the fan lines in the desired order (reversed for proper visual ordering)
  static List<double> get fibRatios => [1.0, 0.618, 0.5, 0.382, 0.0];

  /// Labels for each Fibonacci level in the desired order
  static List<String> get fibonacciLabels => [
        fibonacciLevels[0.0]!['label']!, // 0%
        fibonacciLevels[0.382]!['label']!, // 38.2%
        fibonacciLevels[0.5]!['label']!, // 50%
        fibonacciLevels[0.618]!['label']!, // 61.8%
        fibonacciLevels[1.0]!['label']!, // 100%
      ];

  /// Color keys for each Fibonacci level in the desired visual order
  static List<String> get fibonacciColorKeys => [
        fibonacciLevels[0.0]!['colorKey']!, // level0 for 0%
        fibonacciLevels[0.382]!['colorKey']!, // level38_2 for 38.2%
        fibonacciLevels[0.5]!['colorKey']!, // level50 for 50%
        fibonacciLevels[0.618]!['colorKey']!, // level61_8 for 61.8%
        fibonacciLevels[1.0]!['colorKey']!, // level100 for 100%
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
      final double deltaXFan = fanPoint1.dx - startOffset.dx;

      // Handle vertical lines and avoid division by zero
      Offset extendedPoint1, extendedPoint2;

      if (deltaXFan.abs() < 0.001) {
        // Vertical lines - extend to top or bottom of screen
        extendedPoint1 = Offset(
          fanPoint1.dx,
          fanPoint1.dy > startOffset.dy ? size.height : 0,
        );
        extendedPoint2 = Offset(
          fanPoint2.dx,
          fanPoint2.dy > startOffset.dy ? size.height : 0,
        );
      } else {
        final double slope1 = (fanPoint1.dy - startOffset.dy) / deltaXFan;
        final double slope2 = (fanPoint2.dy - startOffset.dy) / deltaXFan;

        extendedPoint1 = Offset(
          screenWidth,
          startOffset.dy + slope1 * (screenWidth - startOffset.dx),
        );
        extendedPoint2 = Offset(
          screenWidth,
          startOffset.dy + slope2 * (screenWidth - startOffset.dx),
        );
      }

      // Validate coordinates before creating path
      if (!startOffset.dx.isNaN &&
          !startOffset.dy.isNaN &&
          !extendedPoint1.dx.isNaN &&
          !extendedPoint1.dy.isNaN &&
          !extendedPoint2.dx.isNaN &&
          !extendedPoint2.dy.isNaN) {
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
    for (int i = 0; i < fibRatios.length; i++) {
      final double ratio = fibRatios[i];
      final String colorKey = fibonacciColorKeys[i];
      final Color lineColor = (fibonacciLevelColors != null &&
              fibonacciLevelColors.containsKey(colorKey))
          ? fibonacciLevelColors[colorKey]!
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
      final double deltaXFan = fanPoint.dx - startOffset.dx;

      // Handle vertical lines and avoid division by zero
      Offset extendedPoint;
      if (deltaXFan.abs() < 0.001) {
        // Vertical line - extend to top or bottom of screen
        extendedPoint = Offset(
          fanPoint.dx,
          fanPoint.dy > startOffset.dy ? size.height : 0,
        );
      } else {
        final double slope = (fanPoint.dy - startOffset.dy) / deltaXFan;
        extendedPoint = Offset(
          screenWidth,
          startOffset.dy + slope * (screenWidth - startOffset.dx),
        );
      }

      // Validate coordinates before drawing
      if (!startOffset.dx.isNaN &&
          !startOffset.dy.isNaN &&
          !extendedPoint.dx.isNaN &&
          !extendedPoint.dy.isNaN) {
        canvas.drawLine(startOffset, extendedPoint, linePaint);
      }
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
    // final List<String> labelsToUse = fibonacciLabels;

    for (int i = 0; i < FibonacciFanHelpers.fibRatios.length; i++) {
      final double ratio = FibonacciFanHelpers.fibRatios[i];
      final String label = i < fibonacciLabels.length ? fibonacciLabels[i] : '';

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
      final String colorKey = fibonacciColorKeys[i];
      final Color labelColor = (fibonacciLevelColors != null &&
              fibonacciLevelColors.containsKey(colorKey))
          ? fibonacciLevelColors[colorKey]!
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
