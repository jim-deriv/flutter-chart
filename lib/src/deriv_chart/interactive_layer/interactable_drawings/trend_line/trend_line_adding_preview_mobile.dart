import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/state_change_direction.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/paint_helpers.dart';
import '../../interactable_drawing_custom_painter.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import 'trend_line_interactable_drawing.dart';

/// A class to show a preview and handle adding a [TrendLineInteractableDrawing]
/// to the chart. This is for when we're on [InteractiveLayerMobileBehaviour]
class TrendLineAddingPreviewMobile
    extends DrawingAddingPreview<TrendLineInteractableDrawing> {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.layerSize!;

      final bottomLeftCenter = Offset(size.width / 4, size.height * 3 / 4);
      final topRightCenter = Offset(size.width * 3 / 4, size.height / 4);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(bottomLeftCenter.dx),
          quote: interactiveLayer.quoteFromY(bottomLeftCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(topRightCenter.dx),
          quote: interactiveLayer.quoteFromY(topRightCenter.dy),
        );
    }
  }

  /// If `true` it indicates that the position of the first point is confirmed
  /// by the user and the second point should be spawned and animated to the
  /// center of the screen. Once the animation is done, it will become `false`.
  bool _animating = false;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) =>
      interactableDrawing.hitTest(offset, epochToX, quoteToY);

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    GetDrawingState getDrawingState,
  ) {
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;
    final Set<DrawingToolState> drawingState = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      // End point is also spawned at the chart, user can move it, we should
      // show alignment cross-hair on end point.

      final startOffset =
          Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));
      final targetEndOffset =
          Offset(epochToX(endPoint.epoch), quoteToY(endPoint.quote));

      late final Offset endOffset;

      endOffset = targetEndOffset;

      print(5 + 8 * animationInfo.stateChangePercent);

      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
      );
      if (interactableDrawing.isDraggingStartPoint != null &&
          interactableDrawing.isDraggingStartPoint!) {
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          4 + 8 * animationInfo.stateChangePercent,
          4,
        );

        drawPointAlignmentGuides(canvas, size, startOffset);
      }

      drawPointOffset(
          endOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle,
          radius: 4);

      if (interactableDrawing.isDraggingStartPoint != null &&
          !interactableDrawing.isDraggingStartPoint!) {
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          endOffset,
          4 + 8 * animationInfo.stateChangePercent,
          4,
        );

        drawPointAlignmentGuides(canvas, size, endOffset);
      }

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
    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;

    if (!interactableDrawing.hitTest(
        details.localPosition, epochToX, quoteToY)) {
      onDone();
    }

    // if (startPoint == null) {
    //   interactableDrawing.startPoint = EdgePoint(
    //     epoch: epochFromX(details.localPosition.dx),
    //     quote: quoteFromY(details.localPosition.dy),
    //   );
    // } else if (endPoint == null) {
    //   _animatingSecondPoint = true;
    //   interactiveLayerBehaviour
    //       .updateStateTo(
    //         interactiveLayerBehaviour.currentState,
    //         StateChangeAnimationDirection.forward,
    //         waitForAnimation: true,
    //       )
    //       .then(
    //         (_) => _animatingSecondPoint = false,
    //       );
    //
    //   final Offset centerOffset = _getCenterOfScreen();
    //
    //   interactableDrawing.endPoint = EdgePoint(
    //     epoch: epochFromX(centerOffset.dx),
    //     quote: quoteFromY(centerOffset.dy),
    //   );
    // } else {
    //   onDone();
    // }
  }

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactiveLayerBehaviour
        .updateStateTo(
          interactiveLayerBehaviour.currentState,
          StateChangeAnimationDirection.forward,
          waitForAnimation: true,
        )
        .then(
          (_) => _animating = false,
        );

    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragEnd(DragEndDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactiveLayerBehaviour
        .updateStateTo(
          interactiveLayerBehaviour.currentState,
          StateChangeAnimationDirection.backward,
          waitForAnimation: true,
        )
        .then(
          (_) => _animating = false,
        );
    interactableDrawing.onDragEnd(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    interactableDrawing.onDragUpdate(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
    // final EdgePoint? startPoint = interactableDrawing.startPoint;
    // final EdgePoint? endPoint = interactableDrawing.endPoint;
    //
    // if (startPoint != null && endPoint == null) {
    //   // If we're dragging the start point, we need to update its position
    //   final Offset startOffset =
    //       Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));
    //
    //   // Apply the delta to get the new screen position
    //   final Offset newOffset = startOffset + details.delta;
    //
    //   // Convert back to epoch and quote coordinates
    //   final int newEpoch = epochFromX(newOffset.dx);
    //   final double newQuote = quoteFromY(newOffset.dy);
    //
    //   // Update the start point
    //   interactableDrawing.startPoint =
    //       EdgePoint(epoch: newEpoch, quote: newQuote);
    // } else if (endPoint != null) {
    //   // If we're dragging the start point, we need to update its position
    //   final Offset endOffset =
    //       Offset(epochToX(endPoint.epoch), quoteToY(endPoint.quote));
    //
    //   // Apply the delta to get the new screen position
    //   final Offset newOffset = endOffset + details.delta;
    //
    //   // Convert back to epoch and quote coordinates
    //   final int newEpoch = epochFromX(newOffset.dx);
    //   final double newQuote = quoteFromY(newOffset.dy);
    //
    //   // Update the start point
    //   interactableDrawing.endPoint =
    //       EdgePoint(epoch: newEpoch, quote: newQuote);
    // }
  }

  @override
  bool shouldRepaint(Set<DrawingToolState> drawingState, DrawingV2 oldDrawing) {
    return true;
  }

  @override
  String get id => 'line-adding-preview-mobile';
}
