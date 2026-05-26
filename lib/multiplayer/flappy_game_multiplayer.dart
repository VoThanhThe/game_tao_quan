import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_tao_quan/multiplayer/components/group_pipe_multiplayer_component.dart';
import 'dart:math';

import '../components/background_component.dart';
import '../components/ground_component.dart';
import '../services/navigation_service.dart';
import '../utils/config.dart';
import '../services/audio_service.dart';
import '../views/game_over_screen.dart';
import 'components/game_timer_multiplayer_component.dart';
import 'components/leaderboard_multiplayer_component.dart';
import 'components/multiplayer_bird_component.dart';
import 'components/score_multiplayer_component.dart';
import 'services/flappy_multiplayer_service.dart';
import 'views/game_over_multiplayer_screen.dart';

class MultiplayerFlappyGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final FlappyMultiplayerService service;
  late final String myId;
  final Map<String, MultiplayerBirdComponent> birds = {};

  bool gameStarted = false;
  late GameTimerMultiplayerComponent timer;

  // Update Firebase
  double updateTimer = 0;
  static const updateInterval = 0.1;

  // Seed đồng bộ pipes
  int? gameSeed;
  int pipeIndex = 0;
  static const pipeInterval = 3.0;
  double gameStartTime = 0;
  int _pipeCounter = 0;

  // BuildContext để navigate
  BuildContext? buildContext;
  bool hasNavigatedToGameOver = false;

  final List<String> playerImages = [
    'ong_tao.png',
    'ninja_girl.png',
    'jack.png',
    'santa.png',
    'red_hat.png',
  ];

  MultiplayerFlappyGame({required this.service}) {
    myId = service.currentPlayerId!;
  }

  late final Map<String, Sprite> preloadedAvatars;
  double _lastSentY = 0;
  int _lastSentScore = 0;

  bool hasShownGameOver = false; // Cờ chống gọi nhiều lần
  bool hasShownGameOverFromServer = false;
  late final Map<String, String> playerIdToAvatar;

  void _assignFixedAvatars() {
    final sortedIds = service.currentPlayers.keys.toList()..sort();
    playerIdToAvatar = {};
    for (int i = 0; i < sortedIds.length; i++) {
      final playerId = sortedIds[i];
      playerIdToAvatar[playerId] = playerImages[i % playerImages.length];
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 🔥 Priority levels:
    // 0: Background
    // 10: Ground, Pipes, Items
    // 20: Birds
    // 100: UI (Timer, Leaderboard)
    _assignFixedAvatars();

    preloadedAvatars = {
      for (var img in playerImages) img: await loadSprite(img),
    };

    add(BackgroundComponent()..priority = 0);
    add(GroundComponent()..priority = 10);

    final myScoreDisplay = ScoreMultiplayerComponent(
      position: Vector2(size.x / 2, 60), // Cách timer một chút
    )..priority = 101; // Trên cả timer và leaderboard

    add(myScoreDisplay);

    // Timer với callback khi hết giờ
    timer = GameTimerMultiplayerComponent(totalTime: 120)
      ..position = Vector2(size.x / 2, 80)
      ..onTimerEnd = _handleTimerEnd
      ..priority = 100; // 🔥 Priority cao nhất
    add(timer);
    AudioService().playBackground();
    await _spawnBirdsFromPlayers();

    // Leaderboard
    final avatars = <String, Sprite>{};
    int i = 0;
    for (final entry in service.currentPlayers.entries) {
      avatars[entry.key] = await loadSprite(
        playerImages[i % playerImages.length],
      );
      i++;
    }

    final leaderboard = LeaderboardMultiplayerComponent(
      service: service,
      avatars: Map.fromEntries(
        playerIdToAvatar.entries.map(
          (e) => MapEntry(e.key, preloadedAvatars[e.value]!),
        ),
      ),
    )..priority = 100; // 🔥 Priority cao nhất
    add(leaderboard);

    service.onPlayersUpdated = (players) async {
      for (final entry in players.entries) {
        final id = entry.key;
        final player = entry.value;

        if (id == myId) {
          final myBird = birds[id];
          if (myBird != null) {
            myBird.score = player.score;
            myBird.isAlive = player.isAlive;
            myScoreDisplay.score = player.score;
          }
        } else {
          // Cập nhật dữ liệu leaderboard thôi, không render chim
          service.currentPlayers[id]?.score = player.score;
        }
      }
    };

    service.onGameStatusChanged = (status) {
      if (status == 'playing' && !gameStarted) {
        gameStarted = true;
        gameStartTime = 0;
        pipeIndex = 0;
      }
    };

    // LẮNG NGHE SERVER BÁO GAME XONG (an toàn nhất)
    service.onGameFinished = () {
      debugPrint("SERVER XÁC NHẬN: GAME ĐÃ KẾT THÚC!");
      _showGameOverForAll();
    };

    // Timer hết → tự động hiện (dự phòng)
    timer.onTimerEnd = () {
      _showGameOverForAll();

      // Chỉ host báo cho server (tránh spam)
      if (!hasShownGameOverFromServer) {
        hasShownGameOverFromServer = true;
        service.finishGame(); // GỌI HÀM MỚI
      }
    };

    // Khi nhận start game → bắt đầu timer
    service.onGameStarted = (startTimestamp) {
      debugPrint('NHẬN ĐƯỢC START GAME: $startTimestamp');
      gameSeed = startTimestamp;
      gameStarted = true;
      hasShownGameOver = false; // Reset lại cho ván mới
      hasShownGameOverFromServer = false;
      timer.startTimerWithTimestamp(startTimestamp);
    };
  }

  void _showGameOverForAll() {
    if (hasShownGameOver) return;
    hasShownGameOver = true;

    pauseEngine();
    overlays.clear();

    AudioService().stopBackground();
    AudioService().playWin();

    final context = NavigationService.context;
    if (context != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameOverMultiplayerScreen(
            myScore: birds[myId]?.score ?? 0,
            multiplayerService: service,
            game: this,
          ),
        ),
      );
    }
  }

  Future<void> _spawnBirdsFromPlayers() async {
    // Chỉ lấy player của mình
    final sprite = await loadSprite(
      playerIdToAvatar[myId] ?? playerImages.first,
    );

    final myBird =
        MultiplayerBirdComponent(
            playerId: myId,
            sprite: sprite,
            position: Vector2(size.x / 2, size.y / 2),
          )
          ..anchor = Anchor.center
          ..priority = 999;

    birds[myId] = myBird;
    add(myBird);
  }

  @override
  void onTapDown(TapDownEvent event) {
    AudioService().playWing();
    final myBird = birds[myId];
    if (myBird == null || !myBird.isAlive) return;

    myBird.fly();
    _updateBirdToFirebase();
  }

  void _updateBirdToFirebase() {
    final myBird = birds[myId];
    if (myBird == null || !myBird.isAlive) return;

    // 🔥 Không sync nếu đang ẩn
    if (!myBird.isVisibleToOthers) return;

    // Chỉ gửi khi vị trí thay đổi > 5px hoặc điểm tăng
    final currentY = myBird.position.y;
    if ((currentY - _lastSentY).abs() > 5 || myBird.score != _lastSentScore) {
      service.updateBirdPosition(currentY, myBird.score, myBird.isAlive);
      _lastSentY = currentY;
      _lastSentScore = myBird.score;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameStarted || gameSeed == null) return;

    gameStartTime += dt;
    if (gameStartTime < 2.0) return;

    // Spawn pipe theo index
    final expectedPipeIndex = ((gameStartTime - 2.0) / pipeInterval).floor();

    while (pipeIndex <= expectedPipeIndex) {
      _spawnDeterministicPipe(pipeIndex);
      pipeIndex++;
    }

    updateTimer += dt;
    if (updateTimer >= updateInterval) {
      _updateBirdToFirebase();
      updateTimer = 0;
    }
  }

  // Thay thế method _spawnDeterministicPipe trong MultiplayerFlappyGame

  void _spawnDeterministicPipe(int index) {
    _pipeCounter++;

    final pipeSeed = (gameSeed ?? 0) + _pipeCounter;
    final random = Random(pipeSeed);

    // 🔥 Sử dụng dynamic spacing
    final space = Config.getSpaceCenterPipe(size.y);
    final playableHeight = size.y - Config.groundHeight;

    // 🔥 Sử dụng dynamic margins
    final minSafeMargin = Config.getMinTopMargin(size.y);
    final maxSafeMargin = Config.getMaxTopMargin(size.y);

    final topMargin =
        minSafeMargin + random.nextDouble() * (maxSafeMargin - minSafeMargin);
    final bottomMargin =
        minSafeMargin + random.nextDouble() * (maxSafeMargin - minSafeMargin);

    final minGapY = topMargin + space / 2;
    final maxGapY = playableHeight - bottomMargin - space / 2;

    // Fallback nếu không đủ không gian
    if (maxGapY <= minGapY) {
      final gapY = playableHeight / 2;
      final pipe = GroupPipeMultiplayerComponent(
        topHeight: gapY - space / 2,
        gapY: gapY,
      )..priority = 10;
      add(pipe);
      return;
    }

    // 🔥 Random với bias về trung tâm (30-70% of range)
    final range = maxGapY - minGapY;
    final randomValue = random.nextDouble();
    final biasedValue = 0.3 + (randomValue * 0.4); // Bias về giữa
    final gapY = minGapY + (range * biasedValue);

    // 🔥 Troll pipes (15% chance) - extreme positions
    final trollChance = random.nextDouble();
    if (trollChance < 0.15) {
      final isHigh = random.nextBool();
      // Troll pipes ở vị trí extreme nhưng vẫn possible
      final trollGapY = isHigh
          ? minGapY +
                (range * 0.1) // Very high (10% from min)
          : maxGapY - (range * 0.1); // Very low (10% from max)

      final pipe = GroupPipeMultiplayerComponent(
        topHeight: trollGapY - space / 2,
        gapY: trollGapY,
      )..priority = 10;
      add(pipe);
      return;
    }

    // Normal pipe
    final pipe = GroupPipeMultiplayerComponent(
      topHeight: gapY - space / 2,
      gapY: gapY,
    )..priority = 10;
    add(pipe);
  }

  // Xử lý khi hết giờ
  void _handleTimerEnd() {
    if (hasNavigatedToGameOver) return;

    hasNavigatedToGameOver = true;

    final myBird = birds[myId];
    if (myBird == null) return;

    // AudioService().stopBackground();
    _updateBirdToFirebase();
    // pauseEngine();

    debugPrint('⏰ Time\'s up! Final score: ${myBird.score}');

    if (buildContext != null && buildContext!.mounted) {
      Navigator.of(buildContext!).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              GameOverScreen(score: myBird.score, multiplayerService: service),
        ),
      );
    }
  }

  // Thêm vào class MultiplayerFlappyGame
  void clearPipesForMe() {
    // Chỉ xóa ống CHO CHIM CỦA MÌNH (không ảnh hưởng người khác)
    final pipesToRemove = children
        .whereType<GroupPipeMultiplayerComponent>()
        .toList();
    for (final pipe in pipesToRemove) {
      pipe.removeFromParent();
    }
  }

  @override
  void onRemove() {
    service.leaveRoom();
    super.onRemove();
  }
}
