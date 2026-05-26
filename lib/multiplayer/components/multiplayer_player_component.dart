// lib/multiplayer/components/multiplayer_player_component.dart
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../components/pipe_component.dart';
import '../../components/ground_component.dart';
import '../../services/audio_service.dart';
import '../flappy_game_multiplayer.dart';

class MultiplayerPlayerComponent extends SpriteAnimationComponent
    with HasGameReference, CollisionCallbacks {
  final String playerId;
  final String playerName;
  final Color tintColor;

  int score = 0;
  bool isAlive = true;
  double velocityY = 0;

  // ✅ Getter để sync với Firebase
  double get birdY => position.y;

  MultiplayerPlayerComponent({
    required this.playerId,
    required this.playerName,
    required this.tintColor,
    required Vector2 position,
  }) : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('ong_tao.png');
    animation = SpriteAnimation.spriteList([sprite], stepTime: 0.1);

    // Tô màu cho chim (để phân biệt)
    paint = Paint()
      ..colorFilter = ColorFilter.mode(tintColor, BlendMode.srcATop);

    add(CircleHitbox());
  }

  void fly() {
    if (!isAlive) return;
    velocityY = -220;
    AudioService().playWin();
  }

  void die() {
    if (!isAlive) return;
    isAlive = false;
    velocityY = 100;
    angle = pi / 4;
    AudioService().playHit();
    
    // ✅ Update Firebase khi chết
    if (game is MultiplayerFlappyGame) {
      final mpGame = game as MultiplayerFlappyGame;
      if (playerId == mpGame.myId) {
        mpGame.service.updateBirdPosition(position.y, score, false);
      }
    }
  }

  void respawn() {
    isAlive = true;
    position.y = game.size.y / 2;
    velocityY = 0;
    angle = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // ✅ Đợi game start
    if (game is MultiplayerFlappyGame) {
      final mpGame = game as MultiplayerFlappyGame;
      if (!mpGame.gameStarted) return;
    }
    
    if (!isAlive) return;

    velocityY += 800 * dt;
    position.y += velocityY * dt;

    // Xoay theo vận tốc
    angle = (velocityY / 300).clamp(-0.5, 1.0);

    // Chạm đất hoặc trần
    if (position.y > game.size.y - 100 || position.y < 0) {
      die();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // ✅ Chỉ xử lý khi còn sống
    if (!isAlive) return;
    
    if (other is PipeComponent || other is GroundComponent) {
      die();
    }
  }
  
}