/// This file implements the trend line drawing tool functionality.
/// It allows users to draw, interact with, and customize trend lines on charts.
/// The implementation includes features like:
/// - Drawing a line between two points
/// - Extending the line to the left and/or right edges of the chart
/// - Interactive dragging of the entire line or individual endpoints
/// - Visual feedback for hover, selection, and dragging states
/// - Displaying axis labels showing time and price values

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

/// Enum to track which part of the trend line is being dragged.
/// This helps determine the behavior during drag operations.
enum _DragTarget {
  /// Dragging the entire trend line - moves both start and end points together
  wholeLine,

  /// Dragging only the start point - keeps the end point fixed
  startPoint,

  /// Dragging only the end point - keeps the start point fixed
  endPoint,
}

/// Interactable drawing implementation for the trend line drawing tool.
///
/// This class provides functionality to draw trend lines on a chart, with features including:
/// - Drawing a line between two points (start and end)
/// - Extending the line to the left and/or right edges of the chart
/// - Interactive dragging of the entire line or individual endpoints
/// - Visual feedback for hover, selection, and dragging states
/// - Displaying axis labels showing time and price values
///
/// The trend line drawing tool follows a specific interaction flow:
/// 1. Creation: User taps to place start point, then taps again to place end point
/// 2. Selection: User taps on an existing trend line to select it
/// 3. Dragging: User can drag the entire line or its endpoints to reposition
/// 4. Visual feedback: The line shows different visual states (normal, hovered, selected)
class TrendInteractableDrawing
    extends InteractableDrawing<TrendDrawingToolConfig> {
  /// Creates a new trend line interactable drawing.
  ///
  /// [config] contains styling and configuration options for the trend line.
  /// [startPoint] is the starting point of the trend line (can be null during creation).
  /// [endPoint] is the ending point of the trend line (can be null during creation).
  TrendInteractableDrawing({
    required TrendDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
  }) : super(config: config);

  /// Start point of the trend line.
  ///
  /// Contains the epoch (timestamp) and quote (price) values for the starting point.
  /// Can be null when the drawing is being created and the user hasn't placed the first point yet.
  EdgePoint? startPoint;

  /// End point of the trend line.
  ///
  /// Contains the epoch (timestamp) and quote (price) values for the ending point.
  /// Can be null when the drawing is being created and the user hasn't placed the second point yet.
  EdgePoint? endPoint;

  /// Tracks which part of the trend line is being dragged, if any.
  ///
  /// This is set during onDragStart and used in onDragUpdate to determine
  /// how to update the trend line's position. Values can be:
  /// - _DragTarget.wholeLine: Dragging the entire line
  /// - _DragTarget.startPoint: Dragging only the start point
  /// - _DragTarget.endPoint: Dragging only the end point
  /// - null: Not currently dragging
  _DragTarget? _dragTarget;

  /// Stores the current mouse hover position.
  ///
  /// Used for drawing preview elements during the creation process
  /// and for showing hover effects. This is updated in the onHover method.
  Offset? _hoverPosition;

  /// Handles mouse hover events over the chart.
  ///
  /// Updates the hover position to enable visual feedback and preview
  /// elements during drawing creation.
  ///
  /// [event] contains the hover event details including the cursor position.
  /// [epochFromX], [quoteFromY], [epochToX], [quoteToY] are conversion functions
  /// for translating between screen coordinates and chart values.
  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  /// Handles the start of a drag operation on the trend line.
  ///
  /// Determines which part of the trend line is being dragged based on where
  /// the user initiated the drag:
  /// - If near the start point, sets _dragTarget to startPoint
  /// - If near the end point, sets _dragTarget to endPoint
  /// - If on the line but not near endpoints, sets _dragTarget to wholeLine
  /// - If not on the line, _dragTarget remains null (no drag operation)
  ///
  /// [details] contains information about the drag start event.
  /// [epochFromX], [quoteFromY], [epochToX], [quoteToY] are conversion functions
  /// for translating between screen coordinates and chart values.
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

  /// Determines if a point is near the trend line.
  ///
  /// Uses the DrawingUtils helper to calculate if the given point is within
  /// the hitTestMargin distance from the line segment defined by lineStart and lineEnd.
  ///
  /// [point] is the point to test (usually the cursor position).
  /// [lineStart] is the start point of the line in screen coordinates.
  /// [lineEnd] is the end point of the line in screen coordinates.
  ///
  /// Returns true if the point is near the line, false otherwise.
  bool _isPointNearLine(Offset point, Offset lineStart, Offset lineEnd) {
    return DrawingUtils.isPointNearLine(
        point, lineStart, lineEnd, hitTestMargin);
  }

  /// Tests if a point is hitting (intersecting with) the trend line drawing.
  ///
  /// This is used to determine if the user's cursor is over the trend line
  /// for interaction purposes (hover effects, selection, etc.).
  ///
  /// [offset] is the point to test (usually the cursor position).
  /// [epochToX] and [quoteToY] are conversion functions to translate chart values to screen coordinates.
  ///
  /// Returns true if the point is hitting the trend line or its control points, false otherwise.
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

  /// Paints the non-clipped elements of the trend line drawing.
  ///
  /// This method is responsible for drawing elements that should appear above the chart's
  /// clipping region, such as axis labels. The actual trend line and control points
  /// are drawn in the paintWithClipping method.
  ///
  /// This separation ensures that elements like axis labels can extend beyond the chart's
  /// plotting area without being cut off, while the trend line itself is properly clipped
  /// to stay within the chart boundaries.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the drawing area.
  /// [epochToX], [quoteToY], [quoteFromY], [epochFromX] are conversion functions.
  /// [animationInfo] contains information about any ongoing animations.
  /// [getDrawingState] provides the current state of the drawing (selected, dragging, etc.).
  /// [theme] contains styling information for the chart.
  /// [chartConfig] contains configuration for the chart.
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

  /// Paints the clipped elements of the trend line drawing.
  ///
  /// This method is responsible for drawing elements that should be clipped to the chart's
  /// plotting area, such as the trend line itself, control points, and alignment guides.
  ///
  /// The method handles different states of the drawing:
  /// - Normal state: Draws a simple line
  /// - Selected/Hovered state: Draws the line with a glow effect and control points
  /// - Dragging state: Draws the line, control points, and alignment guides
  /// - Adding state: Draws preview elements during the creation process
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the drawing area.
  /// [epochToX], [quoteToY], [quoteFromY], [epochFromX] are conversion functions.
  /// [animationInfo] contains information about any ongoing animations.
  /// [getDrawingState] provides the current state of the drawing (selected, dragging, etc.).
  /// [theme] contains styling information for the chart.
  /// [chartConfig] contains configuration for the chart.
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

  /// Draws control points with a focused circle effect.
  ///
  /// Creates a visual indication of the control points (start and end points) of the trend line
  /// with a glowing effect. This consists of:
  /// - An outer, semi-transparent circle for the glow effect
  /// - An inner, solid circle for the control point itself
  ///
  /// [paintStyle] provides styling utilities for creating the paint objects.
  /// [lineStyle] contains styling information for the trend line.
  /// [canvas] is the canvas to draw on.
  /// [points] is a list of points (typically start and end points) to draw circles at.
  /// [outerCircleRadius] is the radius of the outer glow circle.
  /// [innerCircleRadius] is the radius of the inner solid circle.
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

  /// Draws axis labels for the points.
  ///
  /// Creates labels showing the time (x-axis) and price (y-axis) values for each point
  /// in the provided list. This is used to display information about the trend line's
  /// start and end points, or the hover position during creation.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the drawing area.
  /// [points] is a list of points to draw axis labels for.
  /// [lineColor] is the color to use for the labels.
  /// [theme] contains styling information for the chart.
  /// [chartConfig] contains configuration for the chart.
  /// [epochFromX] converts x-coordinates to epoch (timestamp) values.
  /// [quoteFromY] converts y-coordinates to quote (price) values.
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

  /// Draws alignment guides for multiple points without labels.
  ///
  /// Creates horizontal and vertical dashed lines extending from each point to the
  /// edges of the chart. This provides visual alignment cues during dragging operations.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the drawing area.
  /// [points] is a list of points to draw alignment guides for.
  /// [lineColor] is the color to use for the alignment guides.
  void _drawAlignmentGuidesWithoutLabels(
      Canvas canvas, Size size, List<Offset> points, Color lineColor) {
    // Draw alignment guides for all points
    for (final point in points) {
      _drawPointAlignmentGuidesWithoutLabels(canvas, size, point, lineColor);
    }
  }

  /// Draws alignment guides for a single point without labels.
  ///
  /// Creates horizontal and vertical dashed lines extending from the point to the
  /// edges of the chart. This provides visual alignment cues during dragging operations
  /// or when hovering during the creation process.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the drawing area.
  /// [pointOffset] is the point to draw alignment guides for.
  /// [lineColor] is the color to use for the alignment guides.
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

  /// Draws an axis label at the end of the alignment guides.
  ///
  /// Creates labels showing the time (x-axis) and price (y-axis) values for a point.
  /// The time label appears at the bottom of the chart, and the price label appears
  /// at the right edge of the chart.
  ///
  /// [canvas] is the canvas to draw on.
  /// [pointOffset] is the point to draw axis labels for.
  /// [color] is the color to use for the labels.
  /// [theme] contains styling information for the chart.
  /// [chartConfig] contains configuration for the chart.
  /// [epochFromX] converts x-coordinates to epoch (timestamp) values.
  /// [quoteFromY] converts y-coordinates to quote (price) values.
  /// [canvasSize] is the size of the drawing area.
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

  /// Draws a simple point marker.
  ///
  /// Creates a circle at the specified point, typically used during the drawing creation process
  /// to indicate the start point before the end point is placed.
  ///
  /// [point] is the position to draw the point at.
  /// [canvas] is the canvas to draw on.
  /// [paintStyle] provides styling utilities for creating the paint objects.
  /// [lineStyle] contains styling information for the trend line.
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

  /// Creates a text painter for rendering text labels.
  ///
  /// A utility method that creates a TextPainter object configured with the specified
  /// text and style, ready to be painted on the canvas.
  ///
  /// [text] is the text content to display.
  /// [textStyle] is the style to apply to the text.
  ///
  /// Returns a configured TextPainter object that has been laid out and is ready to paint.
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

  /// Draws a semi-transparent background for a text label.
  ///
  /// Creates a rounded rectangle with a fill and border to serve as the background
  /// for text labels, improving readability by separating the text from the chart.
  ///
  /// [canvas] is the canvas to draw on.
  /// [offset] is the position of the text label.
  /// [size] is the size of the text label.
  /// [theme] contains styling information for the chart.
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
  /// Formats the epoch time for display.
  ///
  /// Converts a Unix timestamp (milliseconds since epoch) to a formatted date string
  /// in the format "dd/MM/yy HH:mm:ss".
  ///
  /// [epoch] is the Unix timestamp in milliseconds.
  ///
  /// Returns a formatted date string.
  String _formatEpoch(int epoch) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
    return DateFormat('dd/MM/yy HH:mm:ss').format(time);
  }

  /// Handles tap events during the creation of a trend line.
  ///
  /// This method is called when the user taps on the chart while in drawing creation mode.
  /// It follows a two-step process:
  /// 1. First tap: Sets the start point of the trend line
  /// 2. Second tap: Sets the end point of the trend line and calls onDone to complete creation
  ///
  /// [details] contains information about the tap event, including the position.
  /// [epochFromX] converts x-coordinate to epoch (timestamp) value.
  /// [quoteFromY] converts y-coordinate to quote (price) value.
  /// [epochToX] converts epoch (timestamp) to x-coordinate.
  /// [quoteToY] converts quote (price) to y-coordinate.
  /// [onDone] is a callback to signal that the drawing creation is complete.
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

  /// Handles drag update events for the trend line.
  ///
  /// This method is called continuously as the user drags the trend line or its endpoints.
  /// It updates the position of the trend line based on the drag delta and the current _dragTarget:
  /// - If dragging a specific point (start or end), only that point is updated
  /// - If dragging the whole line, both points are updated to maintain the same line angle and length
  ///
  /// [details] contains information about the drag update, including the delta (change in position).
  /// [epochFromX], [quoteFromY], [epochToX], [quoteToY] are conversion functions
  /// for translating between screen coordinates and chart values.
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

  /// Handles the end of a drag operation on the trend line.
  ///
  /// This method is called when the user releases the pointer after dragging.
  /// It resets the _dragTarget to null to indicate that no dragging is in progress.
  ///
  /// [details] contains information about the drag end event.
  /// [epochFromX], [quoteFromY], [epochToX], [quoteToY] are conversion functions
  /// for translating between screen coordinates and chart values.
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

  /// Returns an updated configuration for the trend line drawing.
  ///
  /// This method is called when the drawing needs to be serialized or saved.
  /// It creates a copy of the current configuration with updated edge points
  /// and extension settings.
  ///
  /// Returns a new TrendDrawingToolConfig with the current state of the drawing.
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
