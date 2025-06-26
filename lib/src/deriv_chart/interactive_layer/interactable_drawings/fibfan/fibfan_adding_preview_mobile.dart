import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';

import '../../helpers/types.dart';
import '../fibfan/helpers.dart';
import '../drawing_adding_preview.dart';
import 'fibfan_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [FibfanInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
class FibfanAddingPreviewMobile
    extends DrawingAddingPreview<FibfanInteractableDrawing> {
  /// Initializes [FibfanAddingPreviewMobile].
  FibfanAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      if (layerSize != null) {
        // Position start point around the chart data area (middle-right region)
        final double startX = layerSize.width * 0.06;
        final double startY = layerSize.height * 0.5;

        interactableDrawing.startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(startX),
          quote: interactiveLayer.quoteFromY(startY),
        );
      } else {
        // Fallback to center if size is not available
        interactableDrawing.startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(0),
          quote: interactiveLayer.quoteFromY(0),
        );
      }
    }

    if (interactableDrawing.endPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      if (layerSize != null) {
        // Position end point to the right and above start point
        // This creates a proper upward-oriented Fibonacci fan
        final double endX = layerSize.width * 0.65;
        final double endY = layerSize.height * 0.3; // Above start point (0.5)

        interactableDrawing.endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(endX),
          quote: interactiveLayer.quoteFromY(endY),
        );
      } else {
        // Fallback with proper orientation if size is not available
        const double fallbackX = 50;
        const double fallbackY = -50; // Above start point

        interactableDrawing.endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(fallbackX),
          quote: interactiveLayer.quoteFromY(fallbackY),
        );
      }
    }
  }

  /// Track if the drawing is currently being dragged
  bool _isDragging = false;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    return interactableDrawing.hitTest(offset, epochToX, quoteToY);
  }

  @override
  String get id => 'Fibfan-adding-preview-mobile';

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _isDragging = true;
    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragUpdate(DragUpdateDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  /// Handle drag end to reset drag state
  @override
  void onDragEnd(DragEndDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _isDragging = false;
    // Call parent implementation if it exists
    super.onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState drawingState,
  ) {
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(interactableDrawing.endPoint!.epoch),
        quoteToY(interactableDrawing.endPoint!.quote),
      );

      // Validate coordinates before proceeding
      if (startOffset.dx.isNaN ||
          startOffset.dy.isNaN ||
          endOffset.dx.isNaN ||
          endOffset.dy.isNaN) {
        return;
      }

      // Calculate the base vector
      final double deltaX = endOffset.dx - startOffset.dx;
      final double deltaY = endOffset.dy - startOffset.dy;

      // Only draw if we have meaningful deltas
      if (deltaX.abs() > 1 || deltaY.abs() > 1) {
        // Draw preview fan lines with dashed style
        _drawPreviewFanLines(canvas, startOffset, deltaX, deltaY, size);
      }

      // Draw edge points for the preview
      final DrawingPaintStyle paintStyle = DrawingPaintStyle();
      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        interactableDrawing.config.lineStyle,
        radius: 4,
      );
      drawPointOffset(
        endOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        interactableDrawing.config.lineStyle,
        radius: 4,
      );

      // Draw alignment guides on each edge point when dragging
      if (_isDragging) {
        drawPointAlignmentGuides(
          canvas,
          size,
          startOffset,
          lineColor: interactableDrawing.config.lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          endOffset,
          lineColor: interactableDrawing.config.lineStyle.color,
        );
      }
    }
  }

  /// Draws preview fan lines with dashed style
  void _drawPreviewFanLines(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
  ) {
    final Paint dashPaint = Paint()
      ..color = interactableDrawing.config.lineStyle.color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = interactableDrawing.config.lineStyle.thickness;

    for (final double ratio in FibonacciFanHelpers.fibRatios) {
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
        // Vertical line
        extendedPoint = Offset(fanPoint.dx, size.height);
      } else {
        final double slope = (fanPoint.dy - startOffset.dy) / deltaXFan;
        extendedPoint = Offset(
          screenWidth,
          startOffset.dy + slope * (screenWidth - startOffset.dx),
        );
      }

      // Draw dashed line
      _drawDashedLine(canvas, startOffset, extendedPoint, dashPaint);
    }
  }

  /// Draws a dashed line between two points
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 3;
    final double distance = (end - start).distance;

    // Handle edge cases
    if (distance <= 0 ||
        start.dx.isNaN ||
        start.dy.isNaN ||
        end.dx.isNaN ||
        end.dy.isNaN) {
      return;
    }

    final Offset direction = (end - start) / distance;

    double currentDistance = 0;
    bool isDash = true;

    while (currentDistance < distance) {
      final double segmentLength = isDash ? dashWidth : dashSpace;
      final double remainingDistance = distance - currentDistance;
      final double actualSegmentLength =
          segmentLength > remainingDistance ? remainingDistance : segmentLength;

      if (isDash && actualSegmentLength > 0) {
        final Offset segmentStart = start + direction * currentDistance;
        final Offset segmentEnd =
            start + direction * (currentDistance + actualSegmentLength);

        // Validate segment points before drawing
        if (!segmentStart.dx.isNaN &&
            !segmentStart.dy.isNaN &&
            !segmentEnd.dx.isNaN &&
            !segmentEnd.dy.isNaN) {
          canvas.drawLine(segmentStart, segmentEnd, paint);
        }
      }

      currentDistance += actualSegmentLength.toDouble();
      isDash = !isDash;
    }
  }

  @override
  void paintOverYAxis(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    // Draw labels for both edge points when dragging
    if (_isDragging &&
        interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      // Draw labels for start point
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactableDrawing.startPoint!.quote,
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactableDrawing.startPoint!.epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        animationProgress: animationInfo.stateChangePercent,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );

      // Draw labels for end point
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactableDrawing.endPoint!.quote,
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactableDrawing.endPoint!.epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        animationProgress: animationInfo.stateChangePercent,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
      );
    }
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
    // For mobile, we complete the drawing on first tap since we already have both points
    onDone();
  }
}
