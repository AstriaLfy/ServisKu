import 'dart:io';
import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';

class ServicePhoto extends StatelessWidget {
  final String? imageUrl;
  final String? filePath;
  final double size;

  const ServicePhoto({
    super.key,
    this.imageUrl,
    this.filePath,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      color: const Color(0xFFEFF6FF),
      child: Icon(
        Icons.handyman_outlined,
        color: AppColors.primary,
        size: size * 0.5,
      ),
    );

    final Widget image;
    final localPath = filePath;
    final url = imageUrl;

    if (localPath != null && localPath.isNotEmpty) {
      image = Image.file(File(localPath), width: size, height: size, fit: BoxFit.cover);
    } else if (url != null && url.isNotEmpty) {
      image = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) => progress == null ? child : fallback,
      );
    } else {
      image = fallback;
    }

    return ClipOval(child: SizedBox(width: size, height: size, child: image));
  }
}

class ServicePhotoPicker extends StatelessWidget {
  final String? imageUrl;
  final String? filePath;
  final VoidCallback? onTap;

  const ServicePhotoPicker({
    super.key,
    this.imageUrl,
    this.filePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ServicePhoto(imageUrl: imageUrl, filePath: filePath, size: 96),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (filePath ?? imageUrl) == null ? 'Tambah foto layanan' : 'Ganti foto layanan',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
