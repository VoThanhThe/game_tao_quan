import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../overlays/over_game_overlay.dart';
import '../overlays/start_game_overlay.dart';
import 'flappy_bird_game.dart'; // file vừa tạo ở trên

class StartGameScreen extends StatefulWidget {
  const StartGameScreen({super.key});

  @override
  State<StartGameScreen> createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  final FlappyBirdGame _game = FlappyBirdGame();
  // final PotGame _game = PotGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GameWidget(
          game: _game,
          // overlayBuilderMap: {
          //   "Buttongame": (context, PotGame game) {
          //     return ButtonOverlay(game: game);
          //   },
          // },
          // initialActiveOverlays: ["Buttongame"],
          overlayBuilderMap: {
            "Startgame": (context, FlappyBirdGame game) {
              return StartGameOverlay(game: game);
            },
            "Gameover": (context, FlappyBirdGame game) {
              return OverGameOverlay(game: game);
            },
          },
          initialActiveOverlays: ["Startgame",],
        ),
      ),
    );
  }
}
