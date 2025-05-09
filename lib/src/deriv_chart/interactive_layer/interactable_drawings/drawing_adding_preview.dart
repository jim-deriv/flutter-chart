import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_v2.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';

/// The base class for drawing previews.
abstract class DrawingAddingPreview<
    T extends InteractableDrawing<DrawingToolConfig>> implements DrawingV2 {
  /// Initializes the [DrawingAddingPreview].
  DrawingAddingPreview({
    required this.interactiveLayerBehaviour,
    required this.interactableDrawing,
  });

  ///
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// The config of the drawing tool that is going to be added.
  final T interactableDrawing;

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  ) {}

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  void onHover(
    PointerHoverEvent event,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) => true;

  @override
  bool shouldRepaint(Set<DrawingToolState> drawingState, DrawingV2 oldDrawing) {
    return true;
  }
}
