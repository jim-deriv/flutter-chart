import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';

class CrosshairBehaviourFactory<T extends CrosshairBehaviour> {
  CrosshairBehaviourFactory({
    required this.smallScreenBehaviourBuilder,
    required this.largeScreenBehaviourBuilder,
  });
  final T Function() smallScreenBehaviourBuilder;
  final T Function() largeScreenBehaviourBuilder;
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
