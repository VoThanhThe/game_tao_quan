import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AvatarOval extends StatelessWidget {
  final String imageUrl;
  final double size;
  const AvatarOval({super.key, required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orangeAccent, width: 1),
        gradient: const LinearGradient(
          colors: [Color(0xFFFAD961), Color(0xFFF76B1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withAlpha((0.6 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,

          // 🌈 Hiệu ứng shimmer khi loading
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.grey.shade300),
          ),

          // ❌ Khi load lỗi (ảnh hỏng / mạng lỗi)
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.person,
              color: Colors.orangeAccent,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
