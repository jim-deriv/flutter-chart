import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';

import '../drawing_adding_preview.dart';
import 'adding_tool_alignment_cross_hair.dart';
import 'line_interactable_drawing.dart';

/// Interactable drawing for line drawing tool.
class LineAddingPreviewDesktop
    extends DrawingAddingPreview<LineInteractableDrawing> {
  /// Initializes [LineInteractableDrawing].
  LineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  Offset? _hoverPosition;

  final AddingToolAlignmentCrossHair _addingToolAlignmentCrossHair =
      AddingToolAlignmentCrossHair();

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
    _addingToolAlignmentCrossHair.onHover(
        event, epochFromX, quoteFromY, epochToX, quoteToY);
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

    final EdgePoint? startPoint = interactableDrawing.startPoint;

    if (startPoint != null) {
      drawPoint(startPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);
      drawPointAlignmentGuides(
        canvas,
        size,
        Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote)),
      );

      if (_hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview line from startPoint to hoverPosition.
        final Offset startPosition =
            Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));

        canvas.drawLine(startPosition, _hoverPosition!,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));
        drawPointAlignmentGuides(canvas, size, _hoverPosition!);
      }
    }

    if (interactableDrawing.endPoint != null) {
      drawPoint(interactableDrawing.endPoint!, epochToX, quoteToY, canvas,
          paintStyle, lineStyle);
    }

    _addingToolAlignmentCrossHair.paint(
        canvas, size, epochToX, quoteToY, animationInfo, drawingState);
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
    } else {
      interactableDrawing.endPoint ??= EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onDone();
    }
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
