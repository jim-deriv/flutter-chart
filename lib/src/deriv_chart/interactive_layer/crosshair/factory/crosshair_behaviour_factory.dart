import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';

/// A factory class for creating appropriate CrosshairBehaviour instances.
///
/// This factory simplifies the creation of crosshair behaviours by providing a unified
/// interface to create behaviours based on the specified crosshair variant (small screen
/// or large screen). It encapsulates the logic for selecting the appropriate behaviour
/// implementation, making it easier to switch between different crosshair styles.
///
/// Type Parameter:
/// - [T]: The specific type of CrosshairBehaviour to create. This is typically a
///   concrete implementation like LineSeriesLargeScreenBehaviour or OHLCSeriesSmallScreenBehaviour.
class CrosshairBehaviourFactory<T extends CrosshairBehaviour> {
  /// Creates a new CrosshairBehaviourFactory.
  ///
  /// Parameters:
  /// - [smallScreenBehaviourBuilder]: A function that creates a CrosshairBehaviour
  ///   implementation optimized for small screens.
  /// - [largeScreenBehaviourBuilder]: A function that creates a CrosshairBehaviour
  ///   implementation optimized for large screens.
  CrosshairBehaviourFactory({
    required this.smallScreenBehaviourBuilder,
    required this.largeScreenBehaviourBuilder,
  });

  /// A function that creates a CrosshairBehaviour implementation for small screens.
  ///
  /// This function is called when the CrosshairVariant.smallScreen variant is specified.
  final T Function() smallScreenBehaviourBuilder;

  /// A function that creates a CrosshairBehaviour implementation for large screens.
  ///
  /// This function is called when the CrosshairVariant.largeScreen variant is specified.
  final T Function() largeScreenBehaviourBuilder;

  /// Creates a CrosshairBehaviour instance based on the specified variant.
  ///
  /// This method selects the appropriate behaviour builder function based on the
  /// provided crosshair variant and returns the resulting behaviour instance.
  ///
  /// Parameters:
  /// - [crosshairVariant]: The variant of crosshair to create (smallScreen or largeScreen)
  ///
  /// Returns:
  /// A CrosshairBehaviour instance appropriate for the specified variant.
  ///
  /// Throws:
  /// ArgumentError if an unknown crosshair variant is provided.
  T create({required CrosshairVariant crosshairVariant}) {
    switch (crosshairVariant) {
      case CrosshairVariant.smallScreen:
        return smallScreenBehaviourBuilder();
      case CrosshairVariant.largeScreen:
        return largeScreenBehaviourBuilder();
      default:
        throw ArgumentError('Unknown crosshair variant: $crosshairVariant');
    }
  }
}
