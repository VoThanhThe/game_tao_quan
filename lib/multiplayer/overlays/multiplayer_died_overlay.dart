import 'dart:ui';

import 'package:flutter/material.dart';

class MultiplayerDiedOverlayWidget extends StatelessWidget {
  const MultiplayerDiedOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bạn đã chết!",
                style: const TextStyle(
                  color: Color(0xFFFFCA00),
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Bạn sẽ quay trở lại trong 5 giây...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
