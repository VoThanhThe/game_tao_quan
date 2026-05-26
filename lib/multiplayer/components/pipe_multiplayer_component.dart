import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../utils/config.dart';

class PipeMultiplayerComponent extends SpriteComponent
    with HasGameReference, CollisionCallbacks {
  final bool isTop;
  final double height;
  PipeMultiplayerComponent({required this.isTop, required this.height}) {
    debugMode = false;
  }

  @override
  FutureOr<void> onLoad() async {
    final pipe = await Flame.images.load("pipe.png");
    double heightDevice = game.size.y;
    size = Vector2(
      heightDevice < Config.iphoneSE
          ? 52
          : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
          ? 72
          : heightDevice > Config.ipadPro
          ? 92
          : 62,
      height,
    );

    if (isTop) {
      flipVerticallyAroundCenter();
      position.y = height;
      sprite = Sprite(pipe);
    } else {
      position.y = game.size.y - Config.groundHeight - size.y;
      sprite = Sprite(pipe);
    }

    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
    return super.onLoad();
  }
}
