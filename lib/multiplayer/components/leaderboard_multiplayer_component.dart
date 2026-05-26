import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../services/flappy_multiplayer_service.dart';

class LeaderboardMultiplayerComponent extends PositionComponent with HasGameReference {
  final FlappyMultiplayerService service;
  final Map<String, Sprite> avatars;

  LeaderboardMultiplayerComponent({required this.service, required this.avatars});

  @override
  Future<void> onLoad() async {
    // Tính kích thước động
    _updateSizeAndPosition();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateSizeAndPosition();
  }

  void _updateSizeAndPosition() {
    final playerCount = service.currentPlayers.length;
    final visibleCount = playerCount.clamp(1, 5); // chỉ hiện tối đa 5 người

    // 🧮 Tính chiều cao động
    const basePadding = 20; // top + bottom
    const rowHeight = 32;

    final dynamicHeight = basePadding + visibleCount * rowHeight;

    size = Vector2(320, dynamicHeight.toDouble());

    // 🟢 Đặt vị trí bottom center
    final gameSize = game.size;
    position = Vector2((gameSize.x - size.x) / 2, gameSize.y - size.y - 10);
  }

  // Thay toàn bộ hàm render() bằng đoạn này:
@override
void render(Canvas canvas) {
  final rect = size.toRect();
  final rankColors = [
    const Color(0xFFFF6B6B), // 1 - đỏ
    const Color(0xFF87CEEB), // 2 - xanh nhạt
    const Color(0xFFFFD700), // 3 - vàng
    const Color(0xFF98FB98), // 4 - xanh lá nhạt
    const Color(0xFFDA70D6), // 5 - tím nhạt
  ];

  // 1. Background + Border (giữ nguyên)
  final bgPaint = Paint()..color = const Color(0xFF0D4D4D).withAlpha((0.9 * 255).toInt());
  final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(15));
  canvas.drawRRect(rrect, bgPaint);
  final borderPaint = Paint()
    ..color = const Color(0xFF0A3939)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawRRect(rrect, borderPaint);

  // SORT ỔN ĐỊNH: ĐIỂM CAO TRƯỚC + NẾU BẰNG NHAU → GIỮ THỨ TỰ PLAYERID (UNIQUE!)
  final sortedPlayers = service.currentPlayers.entries.toList()
    ..sort((a, b) {
      final scoreCompare = b.value.score.compareTo(a.value.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.key.compareTo(b.key); // ỔN ĐỊNH 100% – playerId là unique!
    });

  double yOffset = 10;
  int rank = 1;

  for (final entry in sortedPlayers.take(5)) {
    final playerId = entry.key;
    final player = entry.value;

    // LẤY ẢNH THEO PLAYERID → KHÔNG BAO GIỜ BỊ LỆCH!
    final avatarSprite = avatars[playerId];

    // Rank
    final rankPainter = TextPainter(
      text: TextSpan(
        text: '$rank',
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    rankPainter.layout();
    rankPainter.paint(canvas, Offset(25, yOffset + 5));

    // Avatar – DỰA VÀO PLAYERID → ỔN ĐỊNH 100%
    if (avatarSprite != null) {
      const avatarSize = 28.0;
      avatarSprite.renderRect(
        canvas,
        Rect.fromLTWH(50, yOffset, avatarSize, avatarSize),
      );
    }

    // Tên người chơi
    final namePainter = TextPainter(
      text: TextSpan(
        text: player.name.length > 12 ? '${player.name.substring(0, 12)}...' : player.name,
        style: TextStyle(
          color: rankColors[(rank - 1).clamp(0, rankColors.length - 1)],
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'FzCoTrang',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(90, yOffset + 7));

    // Điểm
    final scorePainter = TextPainter(
      text: TextSpan(
        text: '${player.score}',
        style: TextStyle(
          color: rankColors[(rank - 1).clamp(0, rankColors.length - 1)],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, Offset(size.x - 45, yOffset + 6));

    yOffset += 32;

    // Divider
    if (rank < sortedPlayers.length && rank < 5) {
      _drawDashedLine(
        canvas,
        Offset(20, yOffset - 4),
        Offset(size.x - 20, yOffset - 4),
        const Color(0xFF1A6666),
        dashWidth: 6,
        dashSpace: 3,
        strokeWidth: 1,
      );
    }

    rank++;
  }
}

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    double dashWidth = 5,
    double dashSpace = 3,
    double strokeWidth = 1,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / totalDistance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / totalDistance;

      final p1 = Offset.lerp(start, end, t1)!;
      final p2 = Offset.lerp(start, end, t2.clamp(0, 1))!;
      canvas.drawLine(p1, p2, paint);
    }
  }
}
