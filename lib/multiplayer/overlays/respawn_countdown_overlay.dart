import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../flappy_game_multiplayer.dart';

class RespawnCountdownOverlay extends StatefulWidget {
  final MultiplayerFlappyGame game;

  const RespawnCountdownOverlay({super.key, required this.game});

  @override
  State<RespawnCountdownOverlay> createState() =>
      _RespawnCountdownOverlayState();
}

class _RespawnCountdownOverlayState extends State<RespawnCountdownOverlay> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Đếm ngược 3 → 2 → 1 → 0
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();

        // Ẩn overlay và resume game
        widget.game.overlays.remove("RespawnCountdown");
        widget.game.resumeEngine();
        AudioService().playBackground();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha((0.6 * 255).toInt()), // nền mờ
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Respawning in...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "$_countdown",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
