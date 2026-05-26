import 'package:flutter/material.dart';
import '../../views/home_screen.dart';
import '../../widgets/flappy_button.dart';
import '../flappy_game_multiplayer.dart';
import '../services/flappy_multiplayer_service.dart';

class GameOverMultiplayerScreen extends StatelessWidget {
  final int myScore;
  final FlappyMultiplayerService multiplayerService;
  final MultiplayerFlappyGame game; // Nhận luôn game để lấy dữ liệu real-time

  const GameOverMultiplayerScreen({
    super.key,
    required this.myScore,
    required this.multiplayerService,
    required this.game,
  });

  // Lấy bảng xếp hạng real-time giống hệt overlay
  List<LeaderboardEntry> get leaderboard {
    final entries = <LeaderboardEntry>[];

    // ✅ Lấy toàn bộ người chơi từ Firebase
    for (final entry in multiplayerService.currentPlayers.entries) {
      final playerId = entry.key;
      final player = entry.value;

      final name = player.name;
      final score = player.score.toInt();

      entries.add(
        LeaderboardEntry(
          playerId: playerId,
          name: name,
          score: score,
          isMe: playerId == game.myId,
        ),
      );
    }

    // ✅ Sắp xếp giảm dần theo điểm
    entries.sort((a, b) => b.score.compareTo(a.score));

    // ✅ Gán hạng
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }

    return entries;
  }

  String _getAvatar(String playerId) {
    return game.playerIdToAvatar[playerId] ?? 'ong_tao.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient + GIF
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
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "KẾT QUẢ",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FzCoTrang',
                      shadows: [
                        Shadow(
                          offset: Offset(0, 3),
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$myScore ĐIỂM",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FzCoTrang',
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          color: Colors.black87,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avatar của bạn
                  Image.asset(
                    'assets/images/${_getAvatar(game.myId)}',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),

                  // Bảng xếp hạng
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4A4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 6),
                            color: Colors.black.withAlpha((0.4 * 255).toInt()),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "BẢNG XẾP HẠNG",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FzCoTrang',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHeader(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: leaderboard.length,
                              itemBuilder: (context, i) =>
                                  _buildRow(leaderboard[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nút chơi lại + về home
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: FlappyButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            backgroundColor: const Color(0xFFFF5722),
                            textColor: Colors.white,
                            borderColor: const Color(0xFFD84315),
                            text: "Chơi Lại",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FlappyButton(
                            onPressed: () {
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
                            text: "Trang Chủ",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 2 lớp GIF nền
          IgnorePointer(
            child: Image.asset(
              "assets/gifs/effect_tet_2.gif",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          IgnorePointer(
            child: Image.asset(
              "assets/gifs/effect_end_game.gif",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "Hạng",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Người chơi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              "Điểm",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(LeaderboardEntry e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: e.isMe ? Colors.yellow[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: e.isMe || e.rank <= 3 ? Colors.amber : Colors.grey[400]!,
          width: e.isMe || e.rank <= 3 ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 50, child: _buildRankBadge(e.rank)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(
              'assets/images/${_getAvatar(e.playerId)}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e.name,
              style: TextStyle(
                fontWeight: e.isMe ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
                color: e.isMe ? Colors.deepOrange : Colors.black87,
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  e.score.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
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
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    if (rank <= 3) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.emoji_events, color: colors[rank - 1], size: 36),
          Positioned(
            top: 6,
            child: Text(
              rank.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Class hỗ trợ
class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String name;
  final int score;
  final bool isMe;

  LeaderboardEntry({
    required this.playerId,
    required this.name,
    required this.score,
    this.isMe = false,
    this.rank = 0,
  });

  LeaderboardEntry copyWith({int? rank}) => LeaderboardEntry(
    playerId: playerId,
    name: name,
    score: score,
    isMe: isMe,
    rank: rank ?? this.rank,
  );
}
