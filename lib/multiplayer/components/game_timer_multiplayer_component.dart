// lib/components/game_timer_component.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GameTimerMultiplayerComponent extends PositionComponent
    with HasGameReference {
  final double totalTime;
  double remainingTime = 0;
  double elapsedTime = 0;
  bool isRunning = false;
  bool isCompleted = false;

  // 🔥 Thêm gameStartTime để đồng bộ
  int? gameStartTimestamp; // Timestamp từ Firebase

  late TextComponent _timeText;
  final double radius = 40;

  VoidCallback? onTimerEnd;

  GameTimerMultiplayerComponent({this.totalTime = 120.0})
    : super(size: Vector2(80, 80), anchor: Anchor.topCenter);

  @override
  Future<void> onLoad() async {
    anchor = Anchor.centerRight;
    position = Vector2(game.size.x - 16, 60);
    _timeText = TextComponent(
      text: _formatTime(totalTime),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'FzCoTrang',
          shadows: [
            Shadow(offset: Offset(2, 2), color: Colors.black54, blurRadius: 6),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_timeText);

    resetTimer();
  }

  // 🔥 Bắt đầu timer với timestamp từ Firebase
  void startTimerWithTimestamp(int timestamp) {
    gameStartTimestamp = timestamp;
    isRunning = true;
    isCompleted = false;

    // Tính elapsed time dựa trên thời gian thực
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = (now - timestamp) / 1000.0; // Convert to seconds
    elapsedTime = elapsed.clamp(0.0, totalTime);
    remainingTime = (totalTime - elapsedTime).clamp(0.0, totalTime);

    _updateText();
    debugPrint('⏱️ Timer started at: $timestamp, elapsed: ${elapsedTime}s');
  }

  void startTimer() {
    isRunning = true;
    isCompleted = false;
  }

  void pauseTimer() => isRunning = false;
  void resumeTimer() => isRunning = true;

  void resetTimer() {
    elapsedTime = 0;
    remainingTime = totalTime;
    isRunning = false;
    isCompleted = false;
    gameStartTimestamp = null;
    _updateText();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning || isCompleted) return;

    if (gameStartTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      elapsedTime = ((now - gameStartTimestamp!) / 1000.0).clamp(
        0.0,
        totalTime,
      );
      remainingTime = (totalTime - elapsedTime).clamp(0.0, totalTime);
    } else {
      elapsedTime += dt;
      remainingTime = (totalTime - elapsedTime).clamp(0.0, totalTime);
    }

    // KHI HẾT GIỜ → GỌI CALLBACK NGAY TẠI ĐÂY!
    if (elapsedTime >= totalTime && !isCompleted) {
      isCompleted = true;
      isRunning = false;
      remainingTime = 0;
      elapsedTime = totalTime;

      _updateText();

      // ← ĐÂY LÀ DÒNG QUAN TRỌNG NHẤT!
      onTimerEnd?.call(); // ← BẮT ĐƯỢC SỰ KIỆN HẾT GIỜ 100%!
      game.pauseEngine();
    } else {
      _updateText();
    }
  }

  void _updateText() {
    _timeText.text = _formatTime(remainingTime);
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // 🎨 Hàm tính màu mượt mà theo progress
  Color _getSmoothColor(double progress) {
    const colorStops = [
      (0.0, Color(0xFF00FF00)), // 0%: Xanh lá đậm
      (0.25, Color(0xFF7FFF00)), // 25%: Xanh vàng
      (0.5, Color(0xFFFFFF00)), // 50%: Vàng
      (0.65, Color(0xFFFFAA00)), // 65%: Cam nhạt
      (0.8, Color(0xFFFF6600)), // 80%: Cam đậm
      (1.0, Color(0xFFFF0000)), // 100%: Đỏ
    ];

    for (int i = 0; i < colorStops.length - 1; i++) {
      final (start, startColor) = colorStops[i];
      final (end, endColor) = colorStops[i + 1];

      if (progress >= start && progress <= end) {
        final t = (progress - start) / (end - start);
        return Color.lerp(startColor, endColor, t)!;
      }
    }

    return colorStops.last.$2;
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final progress = (elapsedTime / totalTime).clamp(0.0, 1.0);
    final sweepAngle = 2 * pi * progress;

    // 1. Nền đen mờ
    final bgPaint = Paint()
      ..color = Colors.black.withAlpha((0.7 * 255).toInt());
    canvas.drawCircle(center.toOffset(), radius, bgPaint);

    // 2. Viền trắng mờ
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha((0.4 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center.toOffset(), radius, borderPaint);

    // 3. Thanh progress vòng tròn
    if (progress > 0) {
      final baseColor = _getSmoothColor(progress);

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.sweep(
          center.toOffset(),
          [
            baseColor.withAlpha((1 * 255).toInt()),
            baseColor.withAlpha((0.8 * 255).toInt()),
            baseColor.withAlpha((0.5 * 255).toInt()),
          ],
          [0.0, 0.7, 1.0],
          TileMode.clamp,
          0,
          sweepAngle,
        );

      canvas.drawArc(
        Rect.fromCircle(center: center.toOffset(), radius: radius - 5),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // 4. Vòng tròn trong
    final innerPaint = Paint()
      ..color = Colors.black.withAlpha((0.75 * 255).toInt());
    canvas.drawCircle(center.toOffset(), radius - 16, innerPaint);

    // 5. Glow effect khi sắp hết giờ
    if (progress > 0.8) {
      final glowColor = _getSmoothColor(progress);
      final glowPaint = Paint()
        ..color = glowColor.withAlpha((0.4 * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center.toOffset(), radius - 5, glowPaint);
    }
  }
}
