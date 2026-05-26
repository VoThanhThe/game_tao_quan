import 'package:flutter/material.dart';

import '../multiplayer/multiplayer_lobby_screen.dart';
import '../services/audio_service.dart';
import '../widgets/flappy_button.dart';
import 'leaderboard_screen.dart';
import 'start_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    AudioService().playMenu();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDD0303),
                  Color(0xFFFA812F),
                  Color(0xFFED3F27),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Image.asset(
              "assets/gifs/effect_tet_2.gif",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Image.asset(
              "assets/gifs/effect_end_game.gif",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Táo Quân\nVề Trời',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'FzCoTrang',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset("assets/images/ong_tao.png"),
                    ),
                    // slogan text
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FlappyButton(
                              onPressed: () {
                                AudioService().stopMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StartGameScreen(),
                                  ),
                                );
                              },
                              backgroundColor: const Color(0xFFFF5722),
                              textColor: Colors.white,
                              borderColor: const Color(0xFFD84315),
                              text: "🙋 Một người chơi",
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              AudioService().playButton();
                              AudioService().stopMenu();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaderboardScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 1),
                                    color: Colors.black.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.leaderboard,
                                size: 32,
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FlappyButton(
                        onPressed: () {
                          AudioService().stopMenu();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MultiplayerLobbyScreen(),
                            ),
                          );
                        },
                        backgroundColor: const Color(0xFF4CAF50),
                        textColor: Colors.white,
                        borderColor: const Color(0xFF388E3C),
                        text: "👨‍👩‍👧‍👦 Nhiều người chơi",
                        paddingHZ: 64,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 16,
                  child: Icon(Icons.settings, color: Colors.orange, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
