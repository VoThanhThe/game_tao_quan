import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/background_component.dart';
// import '../components/game_timer_component.dart';
import '../components/ground_component.dart';
import '../components/group_pipe_component.dart';
import '../components/player_component.dart';
import '../components/score_component.dart'; // Import component mới

class FlappyBirdGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  late PlayerComponent playerComponent;
  // late GameTimerComponent gameTimer;
  late ScoreComponent scoreComponent; // Thay TextComponent bằng ScoreComponent
  double elapseTimePipe = 0;

  bool isGameStarted = false;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 255, 29, 29);

  @override
  Future<void> onLoad() async {
    add(BackgroundComponent());
    add(GroundComponent());
    add(playerComponent = PlayerComponent());

    // Thêm score component với sprite images
    scoreComponent = ScoreComponent(position: Vector2(size.x * 0.5, 100));
    add(scoreComponent);
    scoreComponent.priority = 2;

    // Thêm timer component
    // gameTimer = GameTimerComponent(
    //   totalTime: 60.0, // 60 giây để thắng
    // );
    // add(gameTimer);
    // gameTimer.priority = 1; // Hiển thị trên cùng

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isGameStarted) {
      isGameStarted = true;
      // gameTimer.startTimer();
    }
    playerComponent.addFly();
    super.onTapDown(event);
  }

  @override
  void update(double dt) {
    if (isGameStarted) {
      if (elapseTimePipe > 3) {
        add(GroupPipeComponent());
        elapseTimePipe = 0;
      }
      elapseTimePipe += dt;
    } else {
      // gameTimer.resetTimer();
    }

    // Cập nhật điểm số
    scoreComponent.score = playerComponent.score;

    super.update(dt);
  }

  void removePipe() {
    for (var node in children) {
      if (node is GroupPipeComponent) {
        node.removeFromParent();
      }
    }
  }

  @override
  void onRemove() {
    // Optional based on your game needs.
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();
    // Any other code that you want to run when the game is removed.
  }
}
