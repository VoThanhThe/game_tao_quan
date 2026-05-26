import 'package:flame/components.dart';

/// Component hiển thị điểm số bằng sprite images
class ScoreComponent extends PositionComponent {
  int _score = 0;
  final List<SpriteComponent> _digitSprites = [];
  final double digitWidth = 24; // Chiều rộng mỗi chữ số
  final double digitHeight = 36; // Chiều cao mỗi chữ số
  final double spacing = 4; // Khoảng cách giữa các chữ số

  int get score => _score;

  set score(int value) {
    if (_score != value) {
      _score = value;
      _updateDigits();
    }
  }

  ScoreComponent({required Vector2 position, super.anchor = Anchor.center})
    : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateDigits();
  }

  /// Cập nhật hiển thị các chữ số
  Future<void> _updateDigits() async {
    // Xóa các sprite cũ
    for (var sprite in _digitSprites) {
      sprite.removeFromParent();
    }
    _digitSprites.clear();

    // Chuyển điểm số thành chuỗi
    String scoreString = _score.toString();
    int numDigits = scoreString.length;

    // Tính tổng chiều rộng
    double totalWidth = numDigits * digitWidth + (numDigits - 1) * spacing;

    // Tạo sprite cho mỗi chữ số
    for (int i = 0; i < numDigits; i++) {
      String digit = scoreString[i];

      // Load sprite từ file (ví dụ: 0.png, 1.png, ...)
      final sprite = await Sprite.load('$digit.png');

      // Tính vị trí x cho chữ số này (căn giữa)
      double xOffset =
          (i * (digitWidth + spacing)) - (totalWidth / 2) + (digitWidth / 2);

      final digitSprite = SpriteComponent(
        sprite: sprite,
        size: Vector2(digitWidth, digitHeight),
        position: Vector2(xOffset, 0),
        anchor: Anchor.center,
      );

      add(digitSprite);
      _digitSprites.add(digitSprite);
    }
  }
}
