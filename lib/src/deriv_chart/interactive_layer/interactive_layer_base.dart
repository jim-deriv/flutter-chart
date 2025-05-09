import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_selected_tool_state.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';

import '../chart/data_visualization/chart_data.dart';
import 'enums/drawing_tool_state.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactive_layer_states/interactive_adding_tool_state.dart';
import 'interactive_layer_states/interactive_normal_state.dart';
import 'interactive_layer_states/interactive_state.dart';
import 'enums/state_change_direction.dart';

/// The interactive layer base class interface.
abstract class InteractiveLayerBase {
  /// Updates the state of the interactive layer to the [state].
  ///
  /// The [direction] defines the possible animation direction of the state
  /// change. for example from [InteractiveNormalState] to
  /// [InteractiveSelectedToolState] can be forward
  /// and from [InteractiveSelectedToolState] to [InteractiveNormalState] can be
  /// backward. so the [InteractiveLayerBase] can animate the transition accordingly.
  ///
  /// The [waitForAnimation] defines if interactive layer should wait for the
  /// animation to finish before changing to the new state or should change
  /// to the new state right away.
  Future<void> animateStateChange(StateChangeAnimationDirection direction);

  /// The drawings of the interactive layer.
  List<InteractableDrawing<DrawingToolConfig>> get drawings;

  /// The animation controller that [InteractiveLayerBase] can have to play
  /// state change animations. Like selecting a drawing tool.
  AnimationController? get stateChangeAnimationController;

  /// Converts x to epoch.
  EpochFromX get epochFromX;

  /// Converts y to quote.
  QuoteFromY get quoteFromY;

  /// Converts epoch to x.
  EpochToX get epochToX;

  /// Converts quote to y.
  QuoteToY get quoteToY;

  /// Clears the adding drawing.
  void clearAddingDrawing();

  /// Adds the [drawing] to the interactive layer.
  DrawingToolConfig onAddDrawing(
      InteractableDrawing<DrawingToolConfig> drawing);

  /// Save the drawings with the latest changes (positions or anything) to the
  /// repository.
  void onSaveDrawing(InteractableDrawing<DrawingToolConfig> drawing);
}

/// The base class for managing the interactive layer.
abstract class InteractiveLayerBehaviour {
  late InteractiveState _interactiveState;

  /// Initializes the interactive layer manager.
  void init({
    required InteractiveLayerBase interactiveLayer,
    required VoidCallback onUpdate,
  }) {
    this.interactiveLayer = interactiveLayer;
    this.onUpdate = onUpdate;
    _interactiveState = InteractiveNormalState(interactiveLayerBehaviour: this);
  }

  /// Return the adding preview of the [drawing] we're currently adding for this
  /// Behaviour.
  InteractableDrawing getAddingDrawingPreview(InteractableDrawing drawing);

  /// Updates the interactive layer state to the new state.
  Future<void> updateStateTo(
    InteractiveState newState,
    StateChangeAnimationDirection direction, {
    bool waitForAnimation = false,
  }) async {
    if (waitForAnimation) {
      await interactiveLayer.animateStateChange(direction);

      _interactiveState = newState;
      onUpdate();
    } else {
      unawaited(interactiveLayer.animateStateChange(direction));

      _interactiveState = newState;
      onUpdate();
    }
  }

  /// Handles the addition of a drawing tool.
  void onAddDrawingTool(DrawingToolConfig drawingTool) {
    updateStateTo(
      InteractiveAddingToolState(drawingTool, interactiveLayerBehaviour: this),
      StateChangeAnimationDirection.forward,
    );
  }

  /// The interactive layer that this manager is managing.
  late final InteractiveLayerBase interactiveLayer;

  /// The callback that is called when the interactive layer needs to be
  late final VoidCallback onUpdate;

  /// The drawings of the interactive layer.
  Set<DrawingToolState> getToolState(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      _interactiveState.getToolState(drawing);

  /// The drawings of the interactive layer.
  List<InteractableDrawing<DrawingToolConfig>> get previewDrawings =>
      _interactiveState.previewDrawings;

  /// Handles tap event.
  void onTap(TapUpDetails details) {
    _interactiveState.onTap(details);
  }

  /// Handles pan update event.
  void onPanUpdate(DragUpdateDetails details) {
    _interactiveState.onPanUpdate(details);
  }

  /// Handles pan end event.
  void onPanEnd(DragEndDetails details) {
    _interactiveState.onPanEnd(details);
  }

  /// Handles pan start event.
  void onPanStart(DragStartDetails details) {
    _interactiveState.onPanStart(details);
  }

  /// Handles hover event.
  void onHover(PointerHoverEvent event) {
    _interactiveState.onHover(event);
  }
}

/// The mobile-specific implementation of the interactive layer behaviour.
class InteractiveLayerMobileBehaviour extends InteractiveLayerBehaviour {
  @override
  void onAddDrawingTool(DrawingToolConfig drawingTool) {
    final newState = InteractiveAddingToolStateMobile(
      drawingTool,
      interactiveLayerBehaviour: this,
    );

    updateStateTo(
      newState,
      StateChangeAnimationDirection.forward,
    );
  }

  @override
  InteractableDrawing<DrawingToolConfig> getAddingDrawingPreview(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      drawing.getAddingPreviewForMobileBehaviour(this);
}

/// The Desktop-specific implementation of the interactive layer behaviour.
class InteractiveLayerDesktopBehaviour extends InteractiveLayerBehaviour {
  @override
  void onAddDrawingTool(DrawingToolConfig drawingTool) {
    updateStateTo(
      InteractiveAddingToolStateDesktop(
        drawingTool,
        interactiveLayerBehaviour: this,
      ),
      StateChangeAnimationDirection.forward,
    );
  }

  @override
  InteractableDrawing<DrawingToolConfig> getAddingDrawingPreview(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      drawing.getAddingPreviewForDesktopBehaviour(this);
}
