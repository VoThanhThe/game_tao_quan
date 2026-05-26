import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GameTimerComponent extends PositionComponent with HasGameReference {
  final double totalTime;
  double remainingTime = 0;
  double elapsedTime = 0; // Thời gian đã trôi qua
  bool isRunning = false;
  bool isCompleted = false;

  final double barWidth = 200;
  final double barHeight = 20;

  GameTimerComponent({this.totalTime = 60.0, Vector2? position})
    : super(position: position ?? Vector2.zero(), size: Vector2(220, 40)) {
    resetTimer();
  }

  @override
  void onMount() {
    super.onMount();
    position = Vector2((game.size.x - size.x) / 2, 40);
  }

  void startTimer() {
    isRunning = true;
    elapsedTime = totalTime - remainingTime; // Giữ tiếp tục nếu đang giữa chừng
    isCompleted = false;
  }

  void pauseTimer() {
    isRunning = false;
  }

  void resumeTimer() {
    isRunning = true;
  }

  void resetTimer() {
    remainingTime = totalTime;
    elapsedTime = 0;
    isRunning = false;
    isCompleted = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isRunning && !isCompleted) {
      elapsedTime += dt;
      remainingTime = (totalTime - elapsedTime).clamp(0.0, totalTime);

      if (elapsedTime >= totalTime) {
        elapsedTime = totalTime;
        remainingTime = 0;
        isRunning = false;
        isCompleted = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background container
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(20),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withAlpha((0.4 * 255).toInt())
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // Progress bar background (màu xám ban đầu)
    final barX = (size.x - barWidth) / 2;
    final barY = 10.0;

    final barBgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      const Radius.circular(10),
    );

    final barBgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    canvas.drawRRect(barBgRect, barBgPaint);

    // Tính tiến độ: từ 0 → 1 (rỗng → đầy)
    final progress = (elapsedTime / totalTime).clamp(0.0, 1.0);
    final fillWidth = barWidth * progress;

    // Vẽ thanh tiến độ (nếu có)
    if (fillWidth > 0) {
      final barFillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, fillWidth, barHeight),
        const Radius.circular(10),
      );

      // Màu gradient theo tiến độ: xám → đỏ → cam → xanh dương
      Color startColor;
      Color endColor;

      if (progress < 0.25) {
        // 0% - 25%: đỏ (cảnh báo sớm)
        startColor = Colors.red;
        endColor = Colors.red.withAlpha((0.7 * 255).toInt());
      } else if (progress < 0.5) {
        // 25% - 50%: chuyển sang cam
        startColor = Colors.orange;
        endColor = Colors.orange.withAlpha((0.7 * 255).toInt());
      } else if (progress < 0.75) {
        // 50% - 75%: chuyển sang xanh lá
        startColor = Colors.lightGreen;
        endColor = Colors.lightGreen.withAlpha((0.7 * 255).toInt());
      } else {
        // 75% - 100%: xanh dương (hoàn thành)
        startColor = Colors.cyan;
        endColor = Colors.cyan.withAlpha((0.8 * 255).toInt());
      }

      final gradient = ui.Gradient.linear(
        Offset(barX, barY),
        Offset(barX + fillWidth, barY),
        [startColor, endColor],
      );

      final barFillPaint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill;

      canvas.drawRRect(barFillRect, barFillPaint);
    }

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha((0.4 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bgRect, borderPaint);
  }
}
