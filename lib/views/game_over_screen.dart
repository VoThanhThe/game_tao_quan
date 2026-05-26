import 'package:flutter/material.dart';

import '../multiplayer/services/flappy_multiplayer_service.dart';
import '../services/audio_service.dart';
import '../widgets/flappy_button.dart';
import 'home_screen.dart';
import 'start_game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final FlappyMultiplayerService? multiplayerService;
  const GameOverScreen({
    super.key,
    required this.score,
    this.multiplayerService,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  // Dữ liệu mẫu cho bảng xếp hạng
  final List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(
      rank: 1,
      name: "Nguyễn Văn A",
      score: 850,
      avatarColor: Colors.blue,
    ),
    LeaderboardEntry(
      rank: 2,
      name: "Trần Thị B",
      score: 720,
      avatarColor: Colors.purple,
    ),
    LeaderboardEntry(
      rank: 3,
      name: "Lê Văn C",
      score: 680,
      avatarColor: Colors.green,
    ),
    LeaderboardEntry(
      rank: 4,
      name: "Phạm Thị D",
      score: 590,
      avatarColor: Colors.orange,
    ),
    LeaderboardEntry(
      rank: 5,
      name: "Hoàng Văn E",
      score: 520,
      avatarColor: Colors.pink,
    ),
  ];

  @override
  void initState() {
    AudioService().playEffect(SoundType.win);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Kết Quả".toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        color: Colors.black.withAlpha((0.15 * 255).toInt()),
                      ),
                    ],
                    fontFamily: 'FzCoTrang',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.score} Điểm",
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        color: Colors.black.withAlpha((0.3 * 255).toInt()),
                      ),
                    ],
                    fontFamily: 'FzCoTrang',
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Image.asset(
                    "assets/images/ong_tao.png",
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 16),
                // Bảng xếp hạng
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF4A4),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          color: Colors.black.withAlpha((0.2 * 255).toInt()),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "BẢNG XẾP HẠNG",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FzCoTrang',
                          ),
                        ),
                        const SizedBox(height: 12),
          
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(
                                  "Hạng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: 'FzCoTrang',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Người chơi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: 'FzCoTrang',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  "Điểm",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: 'FzCoTrang',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
          
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final entry = leaderboard[index];
                              return _buildLeaderboardRow(entry);
                            },
                            itemCount: leaderboard.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FlappyButton(
                          onPressed: () {
                            AudioService().playButton();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StartGameScreen(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFFFF5722),
                          textColor: Colors.white,
                          borderColor: const Color(0xFFD84315),
                          text: "Chơi lại",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FlappyButton(
                          onPressed: () {
                            // Xử lý về trang chủ
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          backgroundColor: const Color(0xFF4CAF50),
                          textColor: Colors.white,
                          borderColor: const Color(0xFF388E3C),
                          text: "Về Trang Chủ",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: entry.rank <= 3 ? Colors.yellow[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: entry.rank <= 3 ? Colors.amber : Colors.grey[300]!,
          width: entry.rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Số thứ hạng
          SizedBox(width: 50, child: _buildRankBadge(entry.rank)),

          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: entry.avatarColor,
            child: Text(
              entry.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Tên
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: entry.rank <= 3
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87,
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),

          // Điểm
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  entry.score.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                    fontFamily: 'FzCoTrang',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.grey[400]!;
    }

    if (rank <= 3) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: badgeColor, size: 32),
          Positioned(
            top: 5,
            child: Text(
              rank.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          rank.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'FzCoTrang',
          ),
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final Color avatarColor;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarColor,
  });
}
