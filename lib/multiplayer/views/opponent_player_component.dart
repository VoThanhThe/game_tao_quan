import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 🐦 Component cho opponent (người chơi khác)
/// Hiển thị nhỏ hơn, bên cạnh player chính
class OpponentPlayerComponent extends PositionComponent with HasGameReference {
  final String playerId;
  final String playerName;
  final Color playerColor;
  
  double birdY = 0; // Vị trí Y từ Firebase (-1 đến 1)
  bool isAlive = true;
  int score = 0;
  int opponentIndex = 0; // Vị trí X offset

  late TextComponent nameText;

  OpponentPlayerComponent({
    required this.playerId,
    required this.playerName,
    required this.playerColor,
    super.position,
  }) : super(
          size: Vector2(35, 35), // Nhỏ hơn player chính (50x50)
        );

  @override
  Future<void> onLoad() async {
    // 🎨 Vẽ bird đơn giản bằng circles
    
    // Body - circle chính
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()
        ..color = playerColor
        ..style = PaintingStyle.fill,
      position: size / 2,
      anchor: Anchor.center,
    ));

    // Viền trắng
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      position: size / 2,
      anchor: Anchor.center,
    ));

    // Mắt trắng
    add(CircleComponent(
      radius: 5,
      paint: Paint()..color = Colors.white,
      position: Vector2(size.x / 2 + 5, size.y / 2 - 3),
      anchor: Anchor.center,
    ));
    
    // Đồng tử
    add(CircleComponent(
      radius: 2.5,
      paint: Paint()..color = Colors.black,
      position: Vector2(size.x / 2 + 5, size.y / 2 - 3),
      anchor: Anchor.center,
    ));

    // Mỏ (tam giác nhỏ)
    final beakPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final beak = PolygonComponent(
      [
        Vector2(size.x * 0.7, size.y * 0.5),
        Vector2(size.x * 0.9, size.y * 0.45),
        Vector2(size.x * 0.9, size.y * 0.55),
      ],
      paint: beakPaint,
    );
    add(beak);

    // Tên player
    nameText = TextComponent(
      text: playerName,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, -12),
    );
    add(nameText);

    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Cập nhật vị trí dựa trên birdY từ Firebase
    if (game.size.y > 0) {
      double xPosition;
      
      // 🎯 Xếp opponents theo hàng ngang
      switch (opponentIndex) {
        case 0: // Opponent đầu tiên - bên phải
          xPosition = game.size.x * 0.65;
          break;
        case 1: // Opponent thứ 2 - xa hơn bên phải
          xPosition = game.size.x * 0.80;
          break;
        case 2: // Opponent thứ 3 - bên trái
          xPosition = game.size.x * 0.50;
          break;
        default:
          xPosition = game.size.x * 0.70;
      }

      // Vị trí Y dựa trên birdY từ Firebase
      position = Vector2(
        xPosition,
        game.size.y * 0.5 + (birdY * game.size.y * 0.35),
      );
    }

    // Làm mờ nếu chết
    // opacity = isAlive ? 1.0 : 0.3;
    
    super.update(dt);
  }

  /// 📥 Cập nhật dữ liệu từ Firebase
  void updateFromFirebase(double newBirdY, int newScore, bool newIsAlive) {
    birdY = newBirdY;
    score = newScore;
    isAlive = newIsAlive;
  }
}

// 📝 LƯU Ý:
// - Component này TỰ ĐỘNG cập nhật vị trí dựa trên dữ liệu từ Firebase
// - Không cần xử lý collision vì chỉ hiển thị
// - Nếu muốn dùng sprite thật, thay các CircleComponent bằng SpriteComponent