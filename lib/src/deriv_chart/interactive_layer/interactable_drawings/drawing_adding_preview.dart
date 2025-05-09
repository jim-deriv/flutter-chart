import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_v2.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';

/// A preview of a drawing that is being added to the [InteractiveLayer].
///
/// This tool is only shown during the lifetime of the drawing addition.
/// It displays a preview of the drawing along with any alignment lines or
/// hints.
///
/// Once the drawing is added, this preview is removed.
abstract class DrawingAddingPreview<
    T extends InteractableDrawing<DrawingToolConfig>> implements DrawingV2 {
  /// Initializes the [DrawingAddingPreview].
  DrawingAddingPreview({
    required this.interactiveLayerBehaviour,
    required this.interactableDrawing,
  });

  /// The current interactive layer behaviour which is active and defines how
  /// this preview should behave. Since the behaviour of a adding preview can
  /// be different depending on the [InteractiveLayerBehaviour] (desktop or
  /// mobile).
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// The reference to the [InteractableDrawing] instance of the drawing tool
  /// that is going to be added.
  final T interactableDrawing;

  /// The tap event that is called when user taps on a position on the screen
  /// when we're in adding state.
  ///
  /// the drawing can use the tap to capture and create the coordinates required
  /// for its shape.
  ///
  /// [onDone] is a callback that should be called when the drawing is done
  /// adding. each drawing tool will know when it's done adding. For example
  /// a line tool will be done when the user taps on the second point of the
  /// line or for horizontal line tool when the user taps one time.
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  );

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
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  ) =>
      true;
}
