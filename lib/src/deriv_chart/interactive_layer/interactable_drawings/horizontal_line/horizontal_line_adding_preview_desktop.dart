import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';

import '../../enums/drawing_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'horizontal_line_interactable_drawing.dart';

/// Adding preview for horizontal line when we're adding the line tool on
/// [InteractiveLayerMobileBehaviour].
class HorizontalLineAddingPreviewDesktop
    extends DrawingAddingPreview<HorizontalLineInteractableDrawing> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  String get id => 'Horizontal-line-adding-preview-desktop';

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Set<DrawingToolState> drawingState,
  ) {}
}
