import 'dart:ui' as ui;
import 'package:deriv_chart/src/deriv_chart/utils/drawing_utils.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../chart/data_visualization/chart_data.dart';
import '../../chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../chart/data_visualization/models/animation_info.dart';
import '../interactable_drawing_custom_painter.dart';
import 'interactable_drawing.dart';

/// Enum to track which part of the trend line is being dragged
enum _DragTarget {
  /// Dragging the entire trend line
  wholeLine,

  /// Dragging the start point
  startPoint,

  /// Dragging the end point
  endPoint,
}

/// Interactable drawing for trend drawing tool.
class TrendInteractableDrawing
    extends InteractableDrawing<TrendDrawingToolConfig> {
  TrendInteractableDrawing({
    required TrendDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
  }) : super(config: config);

  /// Start point of the trend line.
  EdgePoint? startPoint;

  /// End point of the trend line.
  EdgePoint? endPoint;

  /// Tracks which part of the trend line is being dragged, if any
  _DragTarget? _dragTarget;

  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Reset the dragging flag
    _dragTarget = null;

    // Convert points to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the drag is starting on one of the control points
    if ((details.localPosition - startOffset).distance <= hitTestMargin) {
      _dragTarget = _DragTarget.startPoint;
      return;
    }

    if ((details.localPosition - endOffset).distance <= hitTestMargin) {
      _dragTarget = _DragTarget.endPoint;
      return;
    }

    // Check if the drag is on the trend line
    if (_isPointNearLine(details.localPosition, startOffset, endOffset)) {
      // Dragging the whole trend line
      _dragTarget = _DragTarget.wholeLine;
      return;
    }
  }

  bool _isPointNearLine(Offset point, Offset lineStart, Offset lineEnd) {
    return DrawingUtils.isPointNearLine(
        point, lineStart, lineEnd, hitTestMargin);
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    // Convert points to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the point is near any of the control points
    if ((offset - startOffset).distance <= hitTestMargin ||
        (offset - endOffset).distance <= hitTestMargin) {
      return true;
    }

    // Check if the point is near the trend line
    return _isPointNearLine(offset, startOffset, endOffset);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    QuoteFromY quoteFromY,
    EpochFromX epochFromX,
    AnimationInfo animationInfo,
    GetDrawingState getDrawingState,
    ChartTheme theme,
    ChartConfig chartConfig,
  ) {
    // Only draw the axis labels in the non-clipped paint method
    final LineStyle lineStyle = config.lineStyle;
    final Set<DrawingToolState> state = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Draw axis labels only (these should not be clipped)
      if (state.contains(DrawingToolState.dragging) ||
          state.contains(DrawingToolState.selected)) {
        _drawAxisLabels(
          canvas: canvas,
          size: size,
          points: [startOffset, endOffset],
          lineColor: lineStyle.color,
          theme: theme,
          chartConfig: chartConfig,
          epochFromX: epochFromX,
          quoteFromY: quoteFromY,
        );
      }
    } else if (state.contains(DrawingToolState.adding)) {
      if (_hoverPosition != null) {
        // Draw axis labels for hover position
        _drawAxisLabels(
          canvas: canvas,
          size: size,
          points: [_hoverPosition!],
          lineColor: lineStyle.color,
          theme: theme,
          chartConfig: chartConfig,
          epochFromX: epochFromX,
          quoteFromY: quoteFromY,
        );
      }
    }
  }

  @override
  void paintWithClipping(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    QuoteFromY quoteFromY,
    EpochFromX epochFromX,
    AnimationInfo animationInfo,
    GetDrawingState getDrawingState,
    ChartTheme theme,
    ChartConfig chartConfig,
  ) {
    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    // Check if this drawing is selected
    final Set<DrawingToolState> state = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Create paint styles for normal, hovered, and selected states
      Paint paint;

      if (state.contains(DrawingToolState.selected) ||
          state.contains(DrawingToolState.dragging) ||
          state.contains(DrawingToolState.hovered)) {
        // For selected or hovered state, first draw a thicker semi-transparent line for the glow effect
        final Paint glowPaint = Paint()
          ..color = lineStyle.color.withOpacity(0.3)
          ..strokeWidth = lineStyle.thickness + 6
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(startOffset, endOffset, glowPaint);

        // Then draw the main line on top
        paint = paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);
      } else {
        // For normal state, just use the regular line style
        paint = paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);
      }

      // Draw the trend line
      canvas.drawLine(startOffset, endOffset, paint);

      // Calculate the trend line direction and extend it
      if (config.extendLeft || config.extendRight) {
        final Offset direction = endOffset - startOffset;
        final double lineLength = direction.distance;

        if (lineLength > 0) {
          final Offset normalizedDirection = direction / lineLength;

          // For selected or hovered state, create a glow paint for extensions
          final Paint extensionPaint = paint;
          Paint? extensionGlowPaint;

          if (state.contains(DrawingToolState.selected) ||
              state.contains(DrawingToolState.dragging) ||
              state.contains(DrawingToolState.hovered)) {
            extensionGlowPaint = Paint()
              ..color = lineStyle.color.withOpacity(0.3)
              ..strokeWidth = lineStyle.thickness
              ..strokeCap = StrokeCap.round;
          }

          // Extend to the left
          if (config.extendLeft) {
            final double leftExtension =
                startOffset.dx; // Extend to the left edge
            final Offset leftExtendedPoint = startOffset -
                normalizedDirection.scale(leftExtension, leftExtension);

            // Make sure the extended point is within the chart bounds
            if (leftExtendedPoint.dx >= 0) {
              // Draw glow effect first if selected
              if (extensionGlowPaint != null) {
                canvas.drawLine(
                    startOffset, leftExtendedPoint, extensionGlowPaint);
              }
              canvas.drawLine(startOffset, leftExtendedPoint, extensionPaint);
            } else {
              // Calculate intersection with left edge
              final double t = -startOffset.dx / normalizedDirection.dx;
              final Offset intersection =
                  startOffset + normalizedDirection.scale(t, t);
              if (intersection.dy >= 0 && intersection.dy <= size.height) {
                // Draw glow effect first if selected
                if (extensionGlowPaint != null) {
                  canvas.drawLine(
                      startOffset, intersection, extensionGlowPaint);
                }
                canvas.drawLine(startOffset, intersection, extensionPaint);
              }
            }
          }

          // Extend to the right
          if (config.extendRight) {
            final double rightExtension =
                size.width - endOffset.dx; // Extend to the right edge
            final Offset rightExtendedPoint = endOffset +
                normalizedDirection.scale(rightExtension, rightExtension);

            // Make sure the extended point is within the chart bounds
            if (rightExtendedPoint.dx <= size.width) {
              // Draw glow effect first if selected
              if (extensionGlowPaint != null) {
                canvas.drawLine(
                    endOffset, rightExtendedPoint, extensionGlowPaint);
              }
              canvas.drawLine(endOffset, rightExtendedPoint, extensionPaint);
            } else {
              // Calculate intersection with right edge
              final double t =
                  (size.width - endOffset.dx) / normalizedDirection.dx;
              final Offset intersection =
                  endOffset + normalizedDirection.scale(t, t);
              if (intersection.dy >= 0 && intersection.dy <= size.height) {
                // Draw glow effect first if selected
                if (extensionGlowPaint != null) {
                  canvas.drawLine(endOffset, intersection, extensionGlowPaint);
                }
                canvas.drawLine(endOffset, intersection, extensionPaint);
              }
            }
          }
        }
      }

      // Draw control points with glowy effect if selected
      if (state.contains(DrawingToolState.selected) ||
          state.contains(DrawingToolState.dragging)) {
        _drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          [startOffset, endOffset],
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
        );
      } else if (state.contains(DrawingToolState.hovered)) {
        _drawPointsFocusedCircle(
            paintStyle, lineStyle, canvas, [startOffset, endOffset], 10, 3);
      }

      // Draw alignment guides when dragging (but not the axis labels)
      if (state.contains(DrawingToolState.dragging)) {
        _drawAlignmentGuidesWithoutLabels(
            canvas, size, [startOffset, endOffset], lineStyle.color);
      }
    } else if (state.contains(DrawingToolState.adding)) {
      if (startPoint == null && _hoverPosition != null) {
        // Draw a cross at the hover position (but not the axis labels)
        _drawPointAlignmentGuidesWithoutLabels(
          canvas,
          size,
          _hoverPosition!,
          lineStyle.color,
        );
      }
      if (startPoint != null) {
        final Offset startOffset = Offset(
          epochToX(startPoint!.epoch),
          quoteToY(startPoint!.quote),
        );

        _drawPoint(
          startOffset,
          canvas,
          paintStyle,
          lineStyle,
        );

        if (_hoverPosition != null) {
          // Draw a preview line from start point to hover position
          canvas.drawLine(
            startOffset,
            _hoverPosition!,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
          );

          _drawPointAlignmentGuidesWithoutLabels(
            canvas,
            size,
            _hoverPosition!,
            lineStyle.color,
          );
        }
      }
    }
  }

  void _drawPointsFocusedCircle(
      DrawingPaintStyle paintStyle,
      LineStyle lineStyle,
      ui.Canvas canvas,
      List<Offset> points,
      double outerCircleRadius,
      double innerCircleRadius) {
    final normalPaintStyle = paintStyle.glowyCirclePaintStyle(lineStyle.color);
    final glowyPaintStyle =
        paintStyle.glowyCirclePaintStyle(lineStyle.color.withOpacity(0.3));

    for (final point in points) {
      canvas
        ..drawCircle(
          point,
          outerCircleRadius,
          glowyPaintStyle,
        )
        ..drawCircle(
          point,
          innerCircleRadius,
          normalPaintStyle,
        );
    }
  }

  /// Draws axis labels for the points
  void _drawAxisLabels({
    required Canvas canvas,
    required Size size,
    required List<Offset> points,
    required Color lineColor,
    required ChartTheme theme,
    required ChartConfig chartConfig,
    required EpochFromX epochFromX,
    required QuoteFromY quoteFromY,
  }) {
    // Only draw axis labels if we have both start and end points
    if (startPoint != null && endPoint != null) {
      // Draw axis labels for all points
      for (final point in points) {
        _drawAxisLabelAtGuideEnd(
            canvas: canvas,
            pointOffset: point,
            color: lineColor,
            canvasSize: size,
            theme: theme,
            chartConfig: chartConfig,
            epochFromX: epochFromX,
            quoteFromY: quoteFromY);
      }
    } else {
      // Draw axis labels for the hover position
      for (final point in points) {
        _drawAxisLabelAtGuideEnd(
          canvas: canvas,
          pointOffset: point,
          color: lineColor,
          canvasSize: size,
          theme: theme,
          chartConfig: chartConfig,
          epochFromX: epochFromX,
          quoteFromY: quoteFromY,
        );
      }
    }
  }

  /// Draws alignment guides (horizontal and vertical lines) from the points without labels
  void _drawAlignmentGuidesWithoutLabels(
      Canvas canvas, Size size, List<Offset> points, Color lineColor) {
    // Draw alignment guides for all points
    for (final point in points) {
      _drawPointAlignmentGuidesWithoutLabels(canvas, size, point, lineColor);
    }
  }

  /// Draws alignment guides (horizontal and vertical lines) for a single point without labels
  void _drawPointAlignmentGuidesWithoutLabels(
    Canvas canvas,
    Size size,
    Offset pointOffset,
    Color lineColor,
  ) {
    // Create a dashed paint style for the alignment guides
    final Paint guidesPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create paths for horizontal and vertical guides
    final Path horizontalPath = Path();
    final Path verticalPath = Path();

    // Draw horizontal and vertical guides from the point
    horizontalPath
      ..moveTo(0, pointOffset.dy)
      ..lineTo(size.width, pointOffset.dy);

    verticalPath
      ..moveTo(pointOffset.dx, 0)
      ..lineTo(pointOffset.dx, size.height);

    // Draw the dashed lines
    canvas
      ..drawPath(
        DrawingUtils.dashPath(horizontalPath,
            dashArray: CircularIntervalList<double>(<double>[5, 5])),
        guidesPaint,
      )
      ..drawPath(
        DrawingUtils.dashPath(verticalPath,
            dashArray: CircularIntervalList<double>(<double>[5, 5])),
        guidesPaint,
      );
  }

  /// Draws an axis label at the end of the alignment guides
  void _drawAxisLabelAtGuideEnd({
    required Canvas canvas,
    required Offset pointOffset,
    required Color color,
    required ChartTheme theme,
    required ChartConfig chartConfig,
    required EpochFromX epochFromX,
    required QuoteFromY quoteFromY,
    required Size canvasSize,
  }) {
    final double quote = quoteFromY(pointOffset.dy);
    final int epoch = epochFromX(pointOffset.dx);

    // Format the price value for display
    final String quoteFormatted = quote.toStringAsFixed(chartConfig.pipSize);

    final TextStyle labelTextStyle =
        theme.drawingToolsContainerTextStyle.copyWith(color: color);

    // Create text painter for the price label
    final TextPainter quotePainter = _createTextPainter(
      text: quoteFormatted,
      textStyle: labelTextStyle,
    );

    // Position the price label at the right edge of the horizontal guide
    final double rightEdgeX = canvasSize.width;
    // Use a relative margin (0.4% of canvas width)
    final double rightMargin = (canvasSize.width) * 0.004;
    final Offset quoteLabelOffset = Offset(
      rightEdgeX - quotePainter.width - rightMargin,
      pointOffset.dy - quotePainter.height / 2,
    );

    // Draw rectangle for the label
    _drawLabel(canvas, quoteLabelOffset, quotePainter.size, theme);

    // Draw the price label
    quotePainter.paint(
      canvas,
      quoteLabelOffset,
    );

    final String timeFormatted = _formatEpoch(epoch);

    // Create text painter for the timestamp label
    final TextPainter timePainter = _createTextPainter(
      text: timeFormatted,
      textStyle: labelTextStyle,
    );

    // Position the timestamp label at the bottom of the vertical guide
    final Offset timeLabelOffset = Offset(
      pointOffset.dx - timePainter.width / 2,
      canvasSize.height,
    );

    // Draw rectangle for the timestamp label
    _drawLabel(canvas, timeLabelOffset, timePainter.size, theme);

    // Draw the timestamp label
    timePainter.paint(canvas, timeLabelOffset);
  }

  void _drawPoint(
    Offset point,
    Canvas canvas,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle,
  ) {
    canvas.drawCircle(
      point,
      5,
      paintStyle.glowyCirclePaintStyle(lineStyle.color),
    );
  }

  /// Creates a text painter for the label
  TextPainter _createTextPainter(
      {required String text, required TextStyle textStyle}) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    return textPainter;
  }

  /// Draws a semi-transparent background for the label
  void _drawLabel(Canvas canvas, Offset offset, Size size, ChartTheme theme) {
    final Paint backgroundPaint = Paint()
      ..color = theme.drawingToolsContainerColor
      ..style = PaintingStyle.fill;

    // Border paint
    final Paint borderPaint = Paint()
      ..color = theme
          .drawingToolsBaseColor // Add this property to your theme or use a fixed color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final RRect backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - 4,
        offset.dy - 2,
        size.width + 8,
        size.height + 4,
      ),
      const Radius.circular(4),
    );

    // Draw filled background
    canvas
      ..drawRRect(backgroundRect, backgroundPaint)

      // Draw border
      ..drawRRect(backgroundRect, borderPaint);
  }

  // TODO(Jim): Replace this with date utils when the crosshair PR is merged
  /// Formats the epoch time for display
  String _formatEpoch(int epoch) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
    return DateFormat('dd/MM/yy HH:mm:ss').format(time);
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  ) {
    if (startPoint == null) {
      startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else {
      endPoint ??= EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onDone();
    }
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    if (_dragTarget != null && _dragTarget != _DragTarget.wholeLine) {
      // We're dragging a specific point
      final bool isDraggingStartPoint = _dragTarget == _DragTarget.startPoint;

      // Get the current point being dragged
      final EdgePoint pointBeingDragged =
          isDraggingStartPoint ? startPoint! : endPoint!;

      // Get the current screen position of the point
      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = currentOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Create updated point
      final EdgePoint updatedPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );

      // Update the appropriate point
      if (isDraggingStartPoint) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      // We're dragging the whole trend line
      // Convert points to screen coordinates
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Apply the delta to get new screen coordinates
      final Offset newStartOffset = startOffset + delta;
      final Offset newEndOffset = endOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newStartEpoch = epochFromX(newStartOffset.dx);
      final double newStartQuote = quoteFromY(newStartOffset.dy);
      final int newEndEpoch = epochFromX(newEndOffset.dx);
      final double newEndQuote = quoteFromY(newEndOffset.dy);

      // Update the start and end points
      startPoint = EdgePoint(
        epoch: newStartEpoch,
        quote: newStartQuote,
      );
      endPoint = EdgePoint(
        epoch: newEndEpoch,
        quote: newEndQuote,
      );
    }
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // Reset the dragging flag when drag is complete
    _dragTarget = null;
  }

  @override
  TrendDrawingToolConfig getUpdatedConfig() => config.copyWith(
        edgePoints: <EdgePoint>[
          if (startPoint != null) startPoint!,
          if (endPoint != null) endPoint!,
        ],
        extendLeft: config.extendLeft,
        extendRight: config.extendRight,
      );
}
