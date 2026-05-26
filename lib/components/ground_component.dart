import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

import '../utils/config.dart';

class GroundComponent extends ParallaxComponent with CollisionCallbacks {
  GroundComponent() {
    debugMode = false;
  }

  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [ParallaxImageData('base.png')],
      baseVelocity: Vector2(Config.baseSpeed, 0),
      fill: LayerFill.none,
      alignment: Alignment.bottomLeft,
    );
    add(
      RectangleHitbox(
        position: Vector2(0, game.size.y - Config.groundHeight),
        size: Vector2(game.size.x, Config.groundHeight),
      ),
    );
    await super.onLoad();
  }
}
