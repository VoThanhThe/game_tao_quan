import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/config.dart';
import '../views/flappy_bird_game.dart';
import '../views/game_over_screen.dart';
import 'ground_component.dart';
import 'pipe_component.dart';

class PlayerComponent extends SpriteAnimationComponent
    with HasGameReference, CollisionCallbacks {
  PlayerComponent() {
    debugMode = false;
  }
  var velocityBird = 0.0;
  int score = 0;
  bool isAlive = true;
  @override
  Future<void> onLoad() async {
    List<Sprite> spritesList = [
      await Sprite.load('ong_tao.png'),
      // await Sprite.load('yellowbird-midflap.png'),
      // await Sprite.load('yellowbird-upflap.png'),
    ];

    final anim = SpriteAnimation.spriteList(spritesList, stepTime: 0.1);
    // size = Vector2(34, 24);
    double heightDevice = game.size.y;
    Config.characterSize = heightDevice < Config.iphoneSE
        ? 70
        : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
        ? 100
        : heightDevice > Config.ipadPro
        ? 120
        : 80;
    Config.updateByCharacterSize();
    size = Vector2.all(Config.characterSize);
    animation = anim;
    position = Vector2(game.size.x / 2, game.size.y / 2);
    add(CircleHitbox());
    super.onLoad();
  }

  @override
  void update(double dt) {
    addGravity(dt);
    if (position.y < 5) {
      gameOver();
    }
    super.update(dt);
  }

  addGravity(double dt) {
    velocityBird += Config.gravity * dt;
    final newY = position.y + velocityBird * dt;
    position = Vector2(position.x, newY);
    anchor = Anchor.center;
    final anpha = clampDouble(velocityBird / 180, -pi * 0.25, pi * 0.25);
    angle = anpha;
  }

  void addFly() {
    AudioService().playWing();
    velocityBird = Config.velocity;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is GroundComponent || other is PipeComponent) {
      debugPrint("Cham vao dat roi");
      gameOver();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  Future<void> gameOver() async {
    AudioService().stopBackground();
    AudioService().playHit();
    AudioService().playDie();
    game.pauseEngine();
    // game.overlays.add("Gameover");
    // Lấy BuildContext từ game
    final context = (game as FlappyBirdGame).buildContext;

    if (context != null) {
      // Navigate sang màn hình GameOver
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GameOverScreen(score: score)),
      );
    }
  }

  void resetGame() {
    (game as FlappyBirdGame).removePipe();
    position = Vector2(70, game.size.y / 2);
    velocityBird = 0;
    score = 0;
  }
}
