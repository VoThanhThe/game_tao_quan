import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/config.dart';
import '../flappy_game_multiplayer.dart';

class StartGameOverlay extends StatefulWidget {
  final MultiplayerFlappyGame game;

  const StartGameOverlay({super.key, required this.game});

  @override
  State<StartGameOverlay> createState() => _StartGameOverlayState();
}

class _StartGameOverlayState extends State<StartGameOverlay>
    with TickerProviderStateMixin {
  late AnimationController _handController;
  late Animation<Offset> _handAnimation;

  // Danh sách avatar giống hệt game và phòng chờ
  final List<String> playerImages = [
    'ong_tao.png',
    'ninja_girl.png',
    'jack.png',
    'santa.png',
    'red_hat.png',
  ];

  // Lấy avatar chính xác 100% của mình
  String get myAvatar {
    final myId = widget.game.myId;
    final players = widget.game.service.currentPlayers;

    final sortedEntries = players.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final myIndex = sortedEntries.indexWhere((e) => e.key == myId);
    return playerImages[myIndex % playerImages.length];
  }

  @override
  void initState() {
    super.initState();
    widget.game.pauseEngine();

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _handAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.1)).animate(
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

        final myBird = widget.game.birds[widget.game.myId];
        if (myBird != null) {
          myBird.opacity = 1.0;
          myBird.isVisibleToOthers = true; // ✅ Bật hiển thị cho người khác
          widget.game.service.updateBirdPosition(
            myBird.position.y,
            myBird.score,
            myBird.isAlive,
          );
        }
      },
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_dawn.jpg",
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
          ),

          // AVATAR CỦA BẠN – ĐẸP LUNG LINH!
          Align(
            alignment: const Alignment(0, -0.25),
            child:
                Image.asset(
                      'assets/images/$myAvatar',
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
                      height:
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
                      fit: BoxFit.contain,
                    )
                    .animate()
                    .scale(
                      begin: const Offset(
                        0.0,
                        0.0,
                      ), // ← FIX lỗi double → Offset
                      end: const Offset(1.0, 1.0), // ← FIX lỗi double → Offset
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 600.ms),
          ),

          // Tên người chơi
          Align(
            alignment: const Alignment(0, -0.02),
            child: Text(
              widget.game.service.currentPlayers[widget.game.myId]?.name ??
                  "Bạn",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: "FzCoTrang",
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ),

          // "Chạm để bắt đầu"
          Align(
            alignment: const Alignment(0, 0.3),
            child:
                Text(
                      "Chạm để bắt đầu",
                      style: const TextStyle(
                        fontSize: 36,
                        fontFamily: "FzCoTrang",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(
                      begin: const Offset(0, 15),
                      end: Offset.zero,
                      duration: 1200.ms,
                    ),
          ),

          // Bàn tay tap
          Align(
            alignment: const Alignment(0, 0.7),
            child: SlideTransition(
              position: _handAnimation,
              child: Image.asset("assets/images/hand_tap.png", width: 100),
            ),
          ),
        ],
      ),
    );
  }
}
