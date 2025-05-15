import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Utility functions and classes for drawing operations.
class DrawingUtils {
  /// Creates a dashed path from a regular path.
  static Path dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
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

  /// Checks if a point is near a line segment.
  static bool isPointNearLine(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
    double hitTestMargin,
  ) {
    // Calculate line direction vector
    final Offset lineDirection = lineEnd - lineStart;
    final double lineLength = lineDirection.distance;

    // If line length is too small, treat it as a point
    if (lineLength < 1) {
      return (point - lineStart).distance <= hitTestMargin;
    }

    // Calculate normalized line direction
    final Offset normalizedLineDirection = lineDirection / lineLength;

    // Calculate vector from line start to test point
    final Offset testVector = point - lineStart;

    // Calculate projection of test vector onto line direction
    final double projection = testVector.dx * normalizedLineDirection.dx +
        testVector.dy * normalizedLineDirection.dy;

    // If projection is outside the line segment, point is not near the line
    if (projection < 0 || projection > lineLength) {
      return false;
    }

    // Calculate perpendicular distance from point to line
    final double perpDistance =
        (testVector - normalizedLineDirection * projection).distance;

    return perpDistance <= hitTestMargin;
  }
}

/// A circular array for dash patterns.
class CircularIntervalList<T> {
  /// Creates a new circular interval list with the given values.
  CircularIntervalList(this._values);

  final List<T> _values;
  int _index = 0;

  /// Gets the next value in the circular list.
  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
