import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../interactive_layer_behaviours/interactive_layer_behaviour.dart';
import '../interactive_layer_controller.dart';

/// A floating menu that appears when a drawing is selected.
class SelectedDrawingFloatingMenu extends StatefulWidget {
  /// Creates a floating menu for the selected drawing.
  const SelectedDrawingFloatingMenu({
    required this.drawing,
    required this.interactiveLayerBehaviour,
    required this.onUpdateDrawing,
    required this.onRemoveDrawing,
    super.key,
  });

  /// The drawing that is currently selected.
  final InteractableDrawing<DrawingToolConfig> drawing;

  /// The controller for the interactive layer.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// Callback to update the drawing.
  final UpdateDrawingTool onUpdateDrawing;

  /// Callback to remove the drawing.
  final UpdateDrawingTool onRemoveDrawing;

  @override
  State<SelectedDrawingFloatingMenu> createState() =>
      _SelectedDrawingFloatingMenuState();
}

class _SelectedDrawingFloatingMenuState
    extends State<SelectedDrawingFloatingMenu> {
  // Store the menu size
  Size _menuSize = Size.zero;

  late final InteractiveLayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.interactiveLayerBehaviour.controller;

    // Schedule a post-frame callback to get the menu size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMenuSize();
    });
  }

  void _updateMenuSize() {
    // Get the size of this menu widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _menuSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size as a fallback
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _controller.floatingMenuPosition.dx,
      top: _controller.floatingMenuPosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          // Calculate new position
          final newPosition = _controller.floatingMenuPosition + details.delta;

          // Update menu size if not already set
          if (_menuSize == Size.zero) {
            _updateMenuSize();
          }

          // Find the nearest ancestor that provides size constraints
          final RenderBox? ancestorBox =
              context.findRenderObject()?.parent as RenderBox?;
          final Size parentSize = ancestorBox?.size ?? screenSize;

          // Constrain the position to keep the menu within the parent boundaries
          final constrainedX =
              newPosition.dx.clamp(0.0, parentSize.width - _menuSize.width);
          final constrainedY =
              newPosition.dy.clamp(0.0, parentSize.height - _menuSize.height);

          _controller.floatingMenuPosition = Offset(constrainedX, constrainedY);
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.watch<ChartTheme>().backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              _buildRemoveButton(context),
              _buildTitle(),
              _buildDrawingMenuOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingMenuOptions() => widget.drawing.getToolBarMenu(
        onUpdate: widget.onUpdateDrawing,
      );

  Widget _buildTitle() => Text(widget.drawing.runtimeType.toString());

  Widget _buildRemoveButton(BuildContext context) => IconButton(
        icon: const Icon(Icons.delete_outline),
        color: context.watch<ChartTheme>().gridTextColor,
        onPressed: () => widget.onRemoveDrawing(widget.drawing.config),
      );
}
