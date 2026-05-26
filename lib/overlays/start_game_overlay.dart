import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 👈 Thêm package này (flutter pub add flutter_animate)
import '../services/audio_service.dart';
import '../utils/config.dart';
import '../views/flappy_bird_game.dart';

class StartGameOverlay extends StatefulWidget {
  final FlappyBirdGame game;

  const StartGameOverlay({super.key, required this.game});

  @override
  State<StartGameOverlay> createState() => _StartGameOverlayState();
}

class _StartGameOverlayState extends State<StartGameOverlay>
    with TickerProviderStateMixin {
  late AnimationController _handController;
  late Animation<Offset> _handAnimation;

  @override
  void initState() {
    super.initState();
    widget.game.pauseEngine();

    // 👋 Animation cho bàn tay tap
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _handAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0.1),
        ).animate(
          CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.game.overlays.remove("Startgame");
        widget.game.resumeEngine();
        AudioService().playBackground();
      },
      child: Stack(
        children: [
          // 🌅 Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_dawn.jpg",
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 600.ms),
          ),

          // 🕊️ Logo hoặc banner “Flappy Bird”
          Align(
            alignment: Alignment.center,
            child:
                Image.asset(
                      "assets/images/ong_tao.png",
                      width:
                          MediaQuery.of(context).size.height < Config.iphoneSE
                          ? 70
                          : MediaQuery.of(context).size.height >
                                    Config.miniIpad &&
                                MediaQuery.of(context).size.height <
                                    Config.ipadPro
                          ? 100
                          : MediaQuery.of(context).size.height > Config.ipadPro
                          ? 120
                          : 80,
                    )
                    .animate()
                    .fadeIn(duration: 1000.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
          ),

          // 💬 Dòng chữ "Tap to Start" nhịp nhịp
          Align(
            alignment: const Alignment(0, 0.4),
            child:
                Text(
                      "Chạm để bắt đầu",
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: "FzCoTrang",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: 800.ms)
                    .moveY(begin: 5, end: -5, curve: Curves.easeInOut),
          ),

          // 👉 Bàn tay tap animation
          Align(
            alignment: const Alignment(0, 0.7),
            child: SlideTransition(
              position: _handAnimation,
              child: Image.asset(
                "assets/images/hand_tap.png", // 🖐️ Thêm ảnh bàn tay (PNG trong assets/images)
                width: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
