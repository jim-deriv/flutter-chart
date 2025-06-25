import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';

import '../../helpers/types.dart';
import '../drawing_adding_preview.dart';
import 'fibfan_interactable_drawing.dart';

/// A class to show a preview and handle adding
/// [FibfanInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour]
class FibfanAddingPreviewDesktop
    extends DrawingAddingPreview<FibfanInteractableDrawing> {
  /// Initializes [FibfanAddingPreviewDesktop].
  FibfanAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  Offset? _hoverPosition;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  String get id => 'Fibfan-adding-preview-desktop';

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
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final LineStyle fillStyle = interactableDrawing.config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    if (interactableDrawing.startPoint == null && _hoverPosition != null) {
      final Offset pointOffset = Offset(
        _hoverPosition!.dx,
        _hoverPosition!.dy,
      );
      drawPointAlignmentGuides(canvas, size, pointOffset,
          lineColor: interactableDrawing.config.lineStyle.color);
    }
    if (interactableDrawing.startPoint != null && _hoverPosition != null) {
      // Draw preview fan from start point to hover position
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );

      // Validate coordinates before proceeding
      if (startOffset.dx.isNaN ||
          startOffset.dy.isNaN ||
          _hoverPosition!.dx.isNaN ||
          _hoverPosition!.dy.isNaN) {
        return;
      }

      final double deltaX = _hoverPosition!.dx - startOffset.dx;
      final double deltaY = _hoverPosition!.dy - startOffset.dy;

      // Only draw if we have meaningful deltas
      if (deltaX.abs() > 1 || deltaY.abs() > 1) {
        // Draw filled areas between fan lines
        FibonacciFanHelpers.drawFanFills(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, fillStyle);
        // Draw fan lines
        FibonacciFanHelpers.drawFanLines(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle,
            fibonacciLevelColors:
                interactableDrawing.config.fibonacciLevelColors);
      }
      // Draw labels for the fan lines
      FibonacciFanHelpers.drawFanLabels(
          canvas, startOffset, deltaX, deltaY, size, lineStyle,
          fibonacciLabels: FibonacciFanHelpers.fibonacciLabels,
          fibonacciLevelColors:
              interactableDrawing.config.fibonacciLevelColors);
      final Offset pointOffset = Offset(
        _hoverPosition!.dx,
        _hoverPosition!.dy,
      );
      drawPointAlignmentGuides(canvas, size, pointOffset,
          lineColor: interactableDrawing.config.lineStyle.color);
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
    if (_hoverPosition != null) {
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactiveLayerBehaviour.interactiveLayer
            .quoteFromY(_hoverPosition!.dy),
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
      );
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: interactiveLayerBehaviour.interactiveLayer
            .epochFromX(_hoverPosition!.dx),
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
    if (interactableDrawing.startPoint == null) {
      // First tap - set start point
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else if (interactableDrawing.endPoint == null) {
      // Second tap - set end point and complete the drawing
      interactableDrawing.endPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onDone();
    }
  }
}
