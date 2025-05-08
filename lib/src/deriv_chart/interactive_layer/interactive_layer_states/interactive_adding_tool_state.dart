import 'dart:ui';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/horizontal_line_interactable_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../enums/state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_selected_tool_state.dart';
import 'interactive_state.dart';

/// The state of the interactive layer when a tool is being added.
///
/// This class represents the state of the [InteractiveLayer] when a new drawing tool
/// is being added to the chart. In this state, tapping on the chart will create a new
/// drawing of the specified type.
///
/// After the drawing is created, the interactive layer transitions back to the
/// [InteractiveNormalState].
class InteractiveAddingToolState extends InteractiveState
    with InteractiveHoverState {
  /// Initializes the state with the interactive layer and the [addingTool].
  ///
  /// The [addingTool] parameter specifies the configuration for the type of drawing
  /// tool that will be created when the user taps on the chart.
  ///
  /// The [interactiveLayer] parameter is passed to the superclass and provides
  /// access to the layer's methods and properties.
  InteractiveAddingToolState(
    this.addingTool, {
    required super.interactiveLayerBehaviour,
  }) {
    _addingDrawing ??= addingTool
        .getInteractableDrawing()
        .getAddingPreview(interactiveLayerBehaviour);
  }

  /// The tool being added.
  ///
  /// This configuration defines the type of drawing that will be created
  /// when the user taps on the chart.
  final DrawingToolConfig addingTool;

  /// The drawing that is currently being created.
  ///
  /// This is initialized when the user first taps on the chart and is used
  /// to render a preview of the drawing being added.
  InteractableDrawing<DrawingToolConfig>? _addingDrawing;

  @override
  List<InteractableDrawing<DrawingToolConfig>> get previewDrawings =>
      [if (_addingDrawing != null) _addingDrawing!];

  @override
  Set<DrawingToolState> getToolState(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      drawing.config.configId == addingTool.configId
          ? {DrawingToolState.adding}
          : {DrawingToolState.idle};

  @override
  void onPanEnd(DragEndDetails details) {}

  @override
  void onPanStart(DragStartDetails details) {}

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (_addingDrawing != null) {
      if (_addingDrawing!.hitTest(details.localPosition, epochToX, quoteToY)) {
        _addingDrawing!.onDragUpdate(
          details,
          epochFromX,
          quoteFromY,
          epochToX,
          quoteToY,
        );
      }
    }
  }

  @override
  void onHover(PointerHoverEvent event) {
    _addingDrawing?.onHover(
      event,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onTap(TapUpDetails details) {
    _addingDrawing!
        .onCreateTap(details, epochFromX, quoteFromY, epochToX, quoteToY, () {
      interactiveLayer.clearAddingDrawing();

      final DrawingToolConfig addedConfig =
          interactiveLayer.onAddDrawing(_addingDrawing!);

      for (final drawing in interactiveLayer.drawings) {
        if (drawing.config.configId == addedConfig.configId) {
          interactiveLayerBehaviour.updateStateTo(
            InteractiveSelectedToolState(
              selected: drawing,
              interactiveLayerBehaviour: interactiveLayerBehaviour,
            ),
            StateChangeAnimationDirection.forward,
          );
          break;
        }
      }
    });
  }
}

/// The mobile-specific implementation of the interactive adding tool state.
class InteractiveAddingToolStateMobile extends InteractiveAddingToolState {
  /// Adding tool state for mobile devices.
  InteractiveAddingToolStateMobile(
    super.addingTool, {
    required super.interactiveLayerBehaviour,
  });

  @override
  void onTap(TapUpDetails details) {
    if (!_addingDrawing!.hitTest(details.localPosition, epochToX, quoteToY)) {
      super.onTap(details);
    }
  }
}

/// The desktop-specific implementation of the interactive adding tool state.
class InteractiveAddingToolStateDesktop
    extends InteractiveAddingToolStateMobile {
  /// Initializes the state with the interactive layer and the [addingTool].
  InteractiveAddingToolStateDesktop(
    super.addingTool, {
    required super.interactiveLayerBehaviour,
  });

  final AddingToolAlignmentCrossHair _crossHair =
      AddingToolAlignmentCrossHair();

  @override
  List<InteractableDrawing<DrawingToolConfig>> get previewDrawings =>
      [...super.previewDrawings, _crossHair];

  @override
  void onHover(PointerHoverEvent event) {
    super.onHover(event);
    _crossHair.onHover(event, epochFromX, quoteFromY, epochToX, quoteToY);
  }
}

// TODO(NA): make an interface above InteractableDrawing that this class can
// also implement, so it won't need to have a config instance.
/// A cross-hair used for aligning the adding tool.
class AddingToolAlignmentCrossHair
    extends InteractableDrawing<AlignmentCrossHairConfig> {
  /// Initializes the cross-hair with a configuration.
  AddingToolAlignmentCrossHair() : super(config: _config);

  Offset? _currentHoverPosition;

  static final _config = AlignmentCrossHairConfig(
    configId: '',
    drawingData: DrawingData(id: '', drawingParts: []),
    edgePoints: const [],
  );

  @override
  AlignmentCrossHairConfig get config => _config;

  @override
  InteractableDrawing<DrawingToolConfig> getAddingPreview(
      InteractiveLayerBehaviour layerBehaviour) {
    return this;
  }

  @override
  AlignmentCrossHairConfig getUpdatedConfig() {
    return config;
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    return false;
  }

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) {
    return true;
  }

  @override
  void onDragUpdate(DragUpdateDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {}

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _currentHoverPosition = event.localPosition;
  }

  @override
  void paint(Canvas canvas, Size size, EpochToX epochToX, QuoteToY quoteToY,
      AnimationInfo animationInfo, Set<DrawingToolState> drawingState) {
    if (_currentHoverPosition == null) {
      return;
    }
    _drawPointAlignmentGuides(canvas, size, _currentHoverPosition!);
  }

  /// Draws alignment guides (horizontal and vertical lines) for a single point
  void _drawPointAlignmentGuides(Canvas canvas, Size size, Offset pointOffset) {
    // Create a dashed paint style for the alignment guides
    final Paint guidesPaint = Paint()
      ..color = const Color(0x80FFFFFF) // Semi-transparent white
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
        _dashPath(horizontalPath,
            dashArray: CircularIntervalList<double>(<double>[5, 5])),
        guidesPaint,
      )
      ..drawPath(
        _dashPath(verticalPath,
            dashArray: CircularIntervalList<double>(<double>[5, 5])),
        guidesPaint,
      );
  }

  Path _dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }
}

/// A temporary configuration class for the cross-hair used in the adding tool.
class AlignmentCrossHairConfig extends DrawingToolConfig {
  /// Initializes the cross-hair configuration.
  const AlignmentCrossHairConfig({
    required super.configId,
    required super.drawingData,
    required super.edgePoints,
  });

  @override
  DrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      this;

  @override
  DrawingToolItem getItem(
      UpdateDrawingTool updateDrawingTool, VoidCallback deleteDrawingTool) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() => {};
}
