import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../services/audio_service.dart';
import 'player_component.dart';

class ItemComponent extends PositionComponent with CollisionCallbacks {
  Vector2 mSize;
  ItemComponent({required this.mSize}) : super(size: mSize) {
    debugMode = false;
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Khi player đi qua vùng item, tăng điểm 1 lần duy nhất
    if (other is PlayerComponent) {
      AudioService().playPoint();
      other.score++;

      // Xoá component này sau khi tính điểm để tránh cộng thêm lần nữa
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
