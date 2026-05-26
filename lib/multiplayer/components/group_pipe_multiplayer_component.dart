import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';

import '../../utils/config.dart';
import 'item_multiplayer_component.dart';
import 'pipe_multiplayer_component.dart';

class GroupPipeMultiplayerComponent extends PositionComponent
    with HasGameReference {
  final double? topHeight;
  final double? gapY;

  GroupPipeMultiplayerComponent({this.topHeight, this.gapY});

  @override
  FutureOr<void> onLoad() async {
    position.x = game.size.x;

    final random = Random();
    final space = Config.spaceCenterPipe;

    // Nếu có topHeight và gapY từ Firebase, sử dụng chúng
    // Nếu không, tạo random như cũ
    double centerY;
    double height;
    double heightDevice = game.size.y;

    if (topHeight != null && gapY != null) {
      // Đồng bộ từ Firebase
      height = topHeight!;
      centerY = gapY!;
    } else {
      // Tạo mới (cho host)
      centerY =
          random.nextDouble() * (game.size.y - Config.groundHeight - space) +
          space * 0.5;
      if (centerY <
          (heightDevice < Config.iphoneSE
              ? 0
              : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
              ? 210
              : heightDevice > Config.ipadPro
              ? 210
              : 110)) {
        centerY = (heightDevice < Config.iphoneSE
            ? 0
            : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
            ? 210
            : heightDevice > Config.ipadPro
            ? 210
            : 110);
      }
      final minHeight =
          (heightDevice < Config.iphoneSE
              ? 0
              : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
              ? 250
              : heightDevice > Config.ipadPro
              ? 250
              : 50) +
          space * 0.5;
      height = max(centerY - space * 0.5, minHeight);
    }

    // Pipe phía trên
    PipeMultiplayerComponent topPipe = PipeMultiplayerComponent(
      isTop: true,
      height: height,
    );

    // Pipe phía dưới (sửa lại công thức giống code cũ)
    PipeMultiplayerComponent bottomPipe = PipeMultiplayerComponent(
      isTop: false,
      height: game.size.y - Config.groundHeight - height - space * 0.5,
    );

    // Item để tính điểm
    ItemMultiplayerComponent itemComponent = ItemMultiplayerComponent(
      mSize: Vector2(
        heightDevice < Config.iphoneSE
            ? 50
            : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
            ? 70
            : heightDevice > Config.ipadPro
            ? 90
            : 60,
        Config.itemPointHeight,
      ),
    )..position.y = height;

    addAll([topPipe, bottomPipe, itemComponent]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.x -= Config.baseSpeed * dt;
    double heightDevice = game.size.y;
    // Tự xóa khi ra khỏi màn hình
    if (position.x <
        (heightDevice < Config.iphoneSE
            ? -50
            : heightDevice > Config.miniIpad && heightDevice < Config.ipadPro
            ? -70
            : heightDevice > Config.ipadPro
            ? -90
            : -60)) {
      removeFromParent();
    }

    super.update(dt);
  }
}
