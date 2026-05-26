import 'package:flutter/material.dart';

import '../views/flappy_bird_game.dart';

class OverGameOverlay extends StatelessWidget {
  final FlappyBirdGame game;
  const OverGameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/gameover.png"),
          ElevatedButton(
            onPressed: () {
              game.overlays.remove("Gameover");
              game.playerComponent.resetGame();
              game.resumeEngine();
            },
            child: Text(
              "Restart",
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  ),
                ],
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
