import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../flappy_game_multiplayer.dart';
import '../overlays/respawn_countdown_overlay.dart';
import '../services/flappy_multiplayer_service.dart';
import '../overlays/over_game_overlay.dart';
import '../overlays/start_game_overlay.dart';

class StartGameScreen extends StatefulWidget {
  final FlappyMultiplayerService multiplayerService;
  const StartGameScreen({super.key, required this.multiplayerService});

  @override
  State<StartGameScreen> createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  late final MultiplayerFlappyGame _game;

  // THÊM NAVIGATOR KEY TOÀN CỤC
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _game = MultiplayerFlappyGame(service: widget.multiplayerService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey, // ← Dùng key này để navigate từ bất kỳ đâu
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => GameWidget.controlled(
            gameFactory: () => _game,
            overlayBuilderMap: {
              "Startgame": (context, game) =>
                  StartGameOverlay(game: game as MultiplayerFlappyGame),
              "RespawnCountdown": (context, game) =>
                  RespawnCountdownOverlay(game: game as MultiplayerFlappyGame),
              "GameOver": (context, game) =>
                  GameOverOverlay(game: game as MultiplayerFlappyGame),
            },
            initialActiveOverlays: const ["Startgame"],
          ),
        ),
      ),
    );
  }
}
