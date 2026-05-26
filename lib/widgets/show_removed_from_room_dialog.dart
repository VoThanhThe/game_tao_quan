import 'package:flutter/material.dart';

import 'flappy_button.dart';

Future<bool> showRemovedFromRoomDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4EC0CA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2B7A83), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.4 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon buồn
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD84315), width: 3),
                ),
                child: const Icon(
                  Icons.sentiment_dissatisfied,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BẠN ĐÃ BỊ KÍCH!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2B7A83), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Chủ phòng đã xóa bạn khỏi phòng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFF5722),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn có thể tham gia phòng khác hoặc tạo phòng mới.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2B7A83),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button
              FlappyButton(
                onPressed: () => Navigator.of(context).pop(true),
                backgroundColor: const Color(0xFF4CAF50),
                textColor: Colors.white,
                borderColor: const Color(0xFF388E3C),
                text: 'ĐỒNG Ý',
                paddingHZ: 32,
              ),
            ],
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}
