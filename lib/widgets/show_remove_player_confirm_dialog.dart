import 'package:flutter/material.dart';

import 'flappy_button.dart';

Future<bool> showRemovePlayerConfirmDialog(BuildContext context) {
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
              // Icon chim bay
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9800), width: 3),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  size: 35,
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
                  color: const Color(0xFF2B7A83),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'KÍCH NGƯỜI CHƠI?',
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
                child: const Text(
                  'Bạn có chắc muốn xóa người chơi này ra khỏi phòng không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2B7A83),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Nút Hủy
                  Expanded(
                    child: FlappyButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      backgroundColor: const Color(0xFFE0E0E0),
                      textColor: const Color(0xFF616161),
                      borderColor: const Color(0xFFBDBDBD),
                      text: 'HỦY',
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nút Đồng ý
                  Expanded(
                    child: FlappyButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      backgroundColor: const Color(0xFFFF5722),
                      textColor: Colors.white,
                      borderColor: const Color(0xFFD84315),
                      text: 'ĐỒNG Ý',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}
