// lib/overlays/game_over_overlay.dart

import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../widgets/flappy_button.dart';
import '../flappy_game_multiplayer.dart';
import '../services/flappy_multiplayer_service.dart';

class GameOverOverlay extends StatelessWidget {
  final MultiplayerFlappyGame game;
  final int myScore;
  final FlappyMultiplayerService? multiplayerService;

  GameOverOverlay({super.key, required this.game, this.multiplayerService})
    : myScore = game.birds[game.myId]?.score.toInt() ?? 0;

  // Dữ liệu bảng xếp hạng từ game (real-time)
  List<LeaderboardEntry> get leaderboard {
    final entries = <String, LeaderboardEntry>{};

    // Lấy điểm từ tất cả chim
    for (final bird in game.birds.values) {
      final playerId = bird.playerId;
      final player = game.service.currentPlayers[playerId];
      final name = player?.name ?? "Unknown";
      final score = bird.score.toInt();

      entries[playerId] = LeaderboardEntry(
        playerId: playerId,
        name: name,
        score: score,
        isMe: playerId == game.myId,
      );
    }

    // Sắp xếp theo điểm giảm dần
    final sorted = entries.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Gán rank
    for (int i = 0; i < sorted.length; i++) {
      sorted[i] = sorted[i].copyWith(rank: i + 1);
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Nội dung chính
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
                  // Tiêu đề
                  Text(
                    "KẾT QUẢ".toUpperCase(),
                    style: const TextStyle(
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
                    'assets/images/${_getMyAvatar()}',
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
                            color: Colors.black.withAlpha((0.3 * 255).toInt()),
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
                          _buildLeaderboardHeader(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: leaderboard.length,
                              itemBuilder: (context, index) {
                                return _buildLeaderboardRow(leaderboard[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nút điều khiển
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: FlappyButton(
                            onPressed: () {
                              AudioService().playButton();
                              // Chơi lại → tạo game mới
                              // Navigator.of(context).pushNamedAndRemoveUntil(
                              //   '/waiting_room',
                              //   (route) => false,
                              //   arguments: multiplayerService,
                              // );
                              Navigator.of(context);
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
                              AudioService().playButton();
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
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

          // GIF nền (2 lớp như cũ)
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

  Widget _buildLeaderboardHeader() {
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

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: entry.isMe ? Colors.yellow[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: entry.isMe
              ? Colors.amber
              : entry.rank <= 3
              ? Colors.amber
              : Colors.grey[400]!,
          width: entry.isMe || entry.rank <= 3 ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 50, child: _buildRankBadge(entry.rank)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(
              'assets/images/${_getAvatarForPlayer(entry.playerId)}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontWeight: entry.isMe ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
                color: entry.isMe ? Colors.deepOrange : Colors.black87,
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
                  entry.score.toString(),
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

  String _getMyAvatar() {
    return game.playerIdToAvatar[game.myId] ?? 'ong_tao.png';
  }

  String _getAvatarForPlayer(String playerId) {
    return game.playerIdToAvatar[playerId] ?? 'ong_tao.png';
  }
}

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

  LeaderboardEntry copyWith({int? rank}) {
    return LeaderboardEntry(
      playerId: playerId,
      name: name,
      score: score,
      isMe: isMe,
      rank: rank ?? this.rank,
    );
  }
}
