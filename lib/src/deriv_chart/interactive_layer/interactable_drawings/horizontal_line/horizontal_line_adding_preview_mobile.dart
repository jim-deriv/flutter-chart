import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';
import 'package:flutter/gestures.dart';

import '../../enums/drawing_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'horizontal_line_interactable_drawing.dart';

/// Adding preview for horizontal line when we're adding the line tool on
/// [InteractiveLayerMobileBehaviour].
class HorizontalLineAddingPreviewMobile
    extends DrawingAddingPreview<HorizontalLineInteractableDrawing> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    interactableDrawing.startPoint = EdgePoint(
      epoch: interactiveLayerBehaviour.interactiveLayer.epochFromX(200),
      quote: interactiveLayerBehaviour.interactiveLayer.quoteFromY(200),
    );
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    return interactableDrawing.hitTest(offset, epochToX, quoteToY);
  }

  @override
  String get id => 'Horizontal-line-adding-preview-mobile';

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
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

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Set<DrawingToolState> drawingState,
  ) {
    if (interactableDrawing.startPoint != null) {
      final double lineY = quoteToY(interactableDrawing.startPoint!.quote);

      canvas.drawLine(
        Offset(0, lineY),
        Offset(size.width, lineY),
        Paint()
          ..color = interactableDrawing.config.lineStyle.color
          ..style = PaintingStyle.stroke,
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
    interactableDrawing.startPoint ??= EdgePoint(
      epoch: epochFromX(details.localPosition.dx),
      quote: quoteFromY(details.localPosition.dy),
    );

    onDone();
  }
}
