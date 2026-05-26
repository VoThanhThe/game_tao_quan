import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:game_tao_quan/multiplayer/flappy_game_multiplayer.dart';

import '../../components/ground_component.dart';
import '../../services/audio_service.dart';
import '../../utils/config.dart';
import 'pipe_multiplayer_component.dart';

class MultiplayerBirdComponent extends SpriteComponent
    with HasGameReference, CollisionCallbacks {
  final String playerId;
  final VoidCallback? onDeath; // 🔥 Callback khi chết

  bool isAlive = true;
  int score = 0;
  double gravity = Config.gravity;
  double velocity = 0;

  // Vị trí remote
  double? targetY;

  // Smooth interpolation
  double smoothFactor = 8.0;

  bool isVisibleToOthers = true;

  MultiplayerBirdComponent({
    required this.playerId,
    required Sprite sprite,
    super.position,
    Vector2? size,
    this.onDeath, // 🔥 Nhận callback
  }) : super(sprite: sprite, size: size ?? Vector2.all(Config.characterSize)) {
    debugMode = false;
  }

  @override
  Future<void> onLoad() async {
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
    add(CircleHitbox());
    anchor = Anchor.center;
    return super.onLoad();
  }

  void fly() {
    if (!isAlive) return;
    velocity = Config.velocity;
  }

  @override
  void update(double dt) {
    if (!isAlive) {
      // Option 1: Rơi xuống đất
      if (targetY == null) {
        velocity += gravity * dt;
        position.y += velocity * dt;

        // Dừng rơi khi chạm đất
        final groundY =
            game.size.y - Config.groundHeight; // Config.groundHeight
        if (position.y >= groundY) {
          position.y = groundY;
          velocity = 0;
        }
      }

      // Option 2: Fade out (giảm opacity)
      if (opacity > 0.3) {
        opacity -= dt * 0.5; // Giảm dần
      }

      return;
    }

    // Nếu là player của mình
    if (targetY == null) {
      velocity += gravity * dt;
      position.y += velocity * dt;

      // Xoay bird theo vận tốc
      final alpha = clampDouble(velocity / 180, -pi * 0.25, pi * 0.25);
      angle = alpha;

      // Check va chạm với trần
      if (position.y < 5) {
        die();
      }

      // Check va chạm với đất (backup nếu collision không hoạt động)
      final groundY = game.size.y - Config.groundHeight;
      if (position.y >= groundY) {
        die();
      }
    } else {
      // Bird của player khác - Interpolate mượt
      final distance = targetY! - position.y;
      final movement = distance * smoothFactor * dt;

      if (distance.abs() > 0.5) {
        position.y += movement;
      } else {
        position.y = targetY!;
      }

      // Xoay bird của người khác theo vị trí
      final alpha = clampDouble(distance / 50, -pi * 0.25, pi * 0.25);
      angle = alpha;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Chỉ bird của mình mới check collision
    if (targetY == null && isAlive) {
      if (other is GroundComponent || other is PipeMultiplayerComponent) {
        debugPrint("🔴 Player $playerId va chạm ${other.runtimeType}!");
        die();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void die() {
    if (!isAlive) return;
    // AudioService().stopBackground();
    AudioService().playHit();
    AudioService().playDie();
    isAlive = false;
    isVisibleToOthers = false;
    debugPrint("💀 Player $playerId đã chết. Score: $score");

    // 🔥 Gọi callback để notify game
    onDeath?.call();
    // HỒI SINH SAU 1.5 GIÂY
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!isMounted) return; // Nếu component đã bị xóa thì thôi
      game.overlays.add("Startgame");
      Future.delayed(const Duration(milliseconds: 500), () {
        respawn();
      });
      (game as MultiplayerFlappyGame).clearPipesForMe();
    });
  }

  void reset() {
    isAlive = true;
    velocity = 0;
    score = 0;
    angle = 0;
    opacity = 1.0;
  }

  // 🔥 Respawn với vị trí tùy chỉnh
  void respawn({Vector2? spawnPosition}) {
    isAlive = true;
    isVisibleToOthers = false;
    velocity = 0;
    angle = 0;
    opacity = 1.0;
    position = Vector2(game.size.x / 2, game.size.y / 2);
    // Đặt lại vị trí ban đầu
    // if (spawnPosition != null) {
    //   position = spawnPosition;
    // } else {
    //   position = Vector2(game.size.x / 2, game.size.y / 2);
    // }
    debugPrint("✨ Player $playerId respawn tại $position");
  }
}
