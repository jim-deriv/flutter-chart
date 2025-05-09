import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/paint_helpers.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import 'line_interactable_drawing.dart';

/// A Line interactable just for the preview of the line when we're adding the
/// line tool on mobile.
class LineAddingPreviewMobile
    extends DrawingAddingPreview<LineInteractableDrawing> {
  /// Initializes [LineInteractableDrawing].
  LineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    // TODO(Ramin): use center of the screen which is received from interactive layer instead of hardcoded values
    interactableDrawing.startPoint = EdgePoint(
      epoch: interactiveLayerBehaviour.interactiveLayer.epochFromX(200),
      quote: interactiveLayerBehaviour.interactiveLayer.quoteFromY(200),
    );
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint == null) {
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );

      // Check if the drag is starting on the start point
      if ((details.localPosition - startOffset).distance <= hitTestMargin) {
        // _isDraggingStartPoint = true;
        return;
      }
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint == null) {
      final startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );

      if ((offset - startOffset).distance <= hitTestMargin) {
        return true;
      }
    } else if (interactableDrawing.endPoint != null) {
      final endOffset = Offset(
        epochToX(interactableDrawing.endPoint!.epoch),
        quoteToY(interactableDrawing.endPoint!.quote),
      );

      if ((offset - endOffset).distance <= hitTestMargin) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Set<DrawingToolState> drawingState,
  ) {
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    // Check if this drawing is selected

    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint == null) {
      drawPoint(interactableDrawing.startPoint!, epochToX, quoteToY, canvas,
          paintStyle, lineStyle);
      drawPointAlignmentGuides(
          canvas,
          size,
          Offset(epochToX(interactableDrawing.startPoint!.epoch),
              quoteToY(interactableDrawing.startPoint!.quote)));
    } else if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      drawPoint(interactableDrawing.endPoint!, epochToX, quoteToY, canvas,
          paintStyle, lineStyle);
      drawPointAlignmentGuides(
          canvas,
          size,
          Offset(epochToX(interactableDrawing.endPoint!.epoch),
              quoteToY(interactableDrawing.endPoint!.quote)));
      final startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );
      final endOffset = Offset(
        epochToX(interactableDrawing.endPoint!.epoch),
        quoteToY(interactableDrawing.endPoint!.quote),
      );

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint = drawingState.contains(DrawingToolState.selected) ||
              drawingState.contains(DrawingToolState.dragging)
          ? paintStyle.linePaintStyle(
              lineStyle.color, 1 + 1 * animationInfo.stateChangePercent)
          : paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);
      canvas.drawLine(startOffset, endOffset, paint);
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
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint == null) {
      interactableDrawing.endPoint = EdgePoint(
        epoch: epochFromX(200),
        quote: quoteFromY(200),
      );
    } else if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
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
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint == null) {
      // If we're dragging the start point, we need to update its position
      final Offset startOffset = Offset(
        epochToX(interactableDrawing.startPoint!.epoch),
        quoteToY(interactableDrawing.startPoint!.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = startOffset + details.delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Update the start point
      interactableDrawing.startPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );
    } else if (interactableDrawing.endPoint != null) {
      // If we're dragging the start point, we need to update its position
      final Offset endOffset = Offset(
        epochToX(interactableDrawing.endPoint!.epoch),
        quoteToY(interactableDrawing.endPoint!.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = endOffset + details.delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Update the start point
      interactableDrawing.endPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );
    }
  }

  @override
  String get id => 'line-adding-preview-mobile';
}
