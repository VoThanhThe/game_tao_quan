import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../widgets/flappy_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Dữ liệu mẫu cho bảng xếp hạng
  final List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(
      rank: 1,
      name: "Nguyễn Văn A",
      score: 1250,
      avatarColor: const Color(0xFF6366F1),
    ),
    LeaderboardEntry(
      rank: 2,
      name: "Trần Thị B",
      score: 1180,
      avatarColor: const Color(0xFFEC4899),
    ),
    LeaderboardEntry(
      rank: 3,
      name: "Lê Văn C",
      score: 1050,
      avatarColor: const Color(0xFF10B981),
    ),
    LeaderboardEntry(
      rank: 4,
      name: "Phạm Thị D",
      score: 980,
      avatarColor: const Color(0xFFF59E0B),
    ),
    LeaderboardEntry(
      rank: 5,
      name: "Hoàng Văn E",
      score: 920,
      avatarColor: const Color(0xFF8B5CF6),
    ),
    LeaderboardEntry(
      rank: 6,
      name: "Vũ Thị F",
      score: 850,
      avatarColor: const Color(0xFFEF4444),
    ),
    LeaderboardEntry(
      rank: 7,
      name: "Đặng Văn G",
      score: 780,
      avatarColor: const Color(0xFF3B82F6),
    ),
    LeaderboardEntry(
      rank: 8,
      name: "Bùi Thị H",
      score: 720,
      avatarColor: const Color(0xFF06B6D4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // Top 3 Podium
                  _buildPodium(),

                  const SizedBox(height: 20),

                  // Leaderboard List
                  Expanded(child: _buildLeaderboardList()),

                  // Back Button
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withAlpha((0.4 * 255).toInt()),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.yellow[300], size: 28),
                const SizedBox(width: 10),
                const Text(
                  "BẢNG XẾP HẠNG",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
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

  Widget _buildPodium() {
    final top3 = leaderboard.take(3).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2 (Bạc)
          if (top3.length > 1) _buildPodiumItem(top3[1], 160),
          const SizedBox(width: 10),
          // Rank 1 (Vàng)
          if (top3.isNotEmpty) _buildPodiumItem(top3[0], 200),
          const SizedBox(width: 10),
          // Rank 3 (Đồng)
          if (top3.length > 2) _buildPodiumItem(top3[2], 140),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, double height) {
    Color medalColor;
    Color podiumColor;

    switch (entry.rank) {
      case 1:
        medalColor = const Color(0xFFFFD700);
        podiumColor = const Color(0xFFFFE55C);
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0);
        podiumColor = const Color(0xFFE5E7EB);
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32);
        podiumColor = const Color(0xFFFBBF77);
        break;
      default:
        medalColor = Colors.grey;
        podiumColor = Colors.grey[300]!;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (entry.rank * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Avatar + Medal
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.avatarColor,
                      border: Border.all(color: medalColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.4 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        entry.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          fontFamily: 'FzCoTrang',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: medalColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.4 * 255).toInt()),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          entry.rank.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'FzCoTrang',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Name
              SizedBox(
                width: 80,
                child: Text(
                  entry.name.split(' ').last,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'FzCoTrang',
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Score
              Text(
                entry.score.toString(),
                style: TextStyle(
                  color: Colors.yellow[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'FzCoTrang',
                ),
              ),

              const SizedBox(height: 8),

              // Podium
              Container(
                width: 80,
                height: height / 2 * value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      podiumColor,
                      podiumColor.withAlpha((0.7 * 255).toInt()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white.withAlpha((0.5 * 255).toInt()),
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardList() {
    final otherPlayers = leaderboard.skip(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "TOP ${leaderboard.length}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'FzCoTrang',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: otherPlayers.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: _buildLeaderboardRow(otherPlayers[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.rank.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'FzCoTrang',
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: entry.avatarColor,
            child: Text(
              entry.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'FzCoTrang',
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Top ${entry.rank}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'FzCoTrang',
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[600]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha((0.4 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  entry.score.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: FlappyButton(
              onPressed: () {
                Navigator.of(context).pop();
                AudioService().playMenu();
              },
              backgroundColor: const Color(0xFFFF5722),
              textColor: Colors.white,
              borderColor: const Color(0xFFD84315),
              text: "TRỞ LẠI",
            ),
          ),
        ],
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
