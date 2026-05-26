import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

import '../utils/config.dart';

class BackgroundComponent extends ParallaxComponent {
  BackgroundComponent();

  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax([
      ParallaxImageData('background_dawn.jpg'),
    ], baseVelocity: Vector2(Config.backgroundSpeed, 0));
    await super.onLoad();
  }
}
