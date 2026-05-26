import 'package:flutter/material.dart';

import '../services/audio_service.dart';

class FlappyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String text;
  final double? textSize;
  final double? paddingHZ;
  final double? paddingVT;
  final IconData? iconLeft;

  const FlappyButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.text,
    this.textSize,
    this.paddingHZ,
    this.paddingVT,
    this.iconLeft,
  });

  @override
  State<FlappyButton> createState() => FlappyButtonState();
}

class FlappyButtonState extends State<FlappyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // BẬT hiệu ứng ngay lập tức
        setState(() => _isPressed = true);

        // TỰ ĐỘNG TẮT sau 120ms → tap nhanh vẫn thấy đẹp
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            setState(() => _isPressed = false);
          }
        });
      },
      onTapUp: (_) {
        AudioService().playButton();
        widget.onPressed();
        // Không cần tắt ở đây nữa, đã tự tắt bằng Future
      },
      onTapCancel: () {
        // Vẫn tắt nếu người dùng kéo tay ra ngoài
        if (mounted) setState(() => _isPressed = false);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: widget.paddingVT ?? 14,
            horizontal: widget.paddingHZ ?? 0,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.borderColor, width: 3),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.borderColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconLeft != null)
                Icon(widget.iconLeft, color: widget.textColor, size: 28),
              if (widget.iconLeft != null) const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.textSize ?? 20,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
