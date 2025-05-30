import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../interactive_layer_controller.dart';

/// A floating menu that appears when a drawing is selected.
class SelectedDrawingFloatingMenu extends StatefulWidget {
  /// Creates a floating menu for the selected drawing.
  const SelectedDrawingFloatingMenu({
    required this.drawing,
    required this.controller,
    super.key,
  });

  /// The drawing that is currently selected.
  final InteractableDrawing<DrawingToolConfig> drawing;

  /// The controller for the interactive layer.
  final InteractiveLayerController controller;

  @override
  State<SelectedDrawingFloatingMenu> createState() =>
      _SelectedDrawingFloatingMenuState();
}

class _SelectedDrawingFloatingMenuState
    extends State<SelectedDrawingFloatingMenu> {
  // Store the menu size
  Size _menuSize = Size.zero;

  @override
  void initState() {
    super.initState();
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
      left: widget.controller.floatingMenuPosition.dx,
      top: widget.controller.floatingMenuPosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          // Calculate new position
          final newPosition =
              widget.controller.floatingMenuPosition + details.delta;

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

          widget.controller.floatingMenuPosition =
              Offset(constrainedX, constrainedY);
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.watch<ChartTheme>().backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.delete_outline,
                  color: context.watch<ChartTheme>().gridTextColor),
              Text(widget.drawing.runtimeType.toString())
            ],
          ),
        ),
      ),
    );
  }
}
