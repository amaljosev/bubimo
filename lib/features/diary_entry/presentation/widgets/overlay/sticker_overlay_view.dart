// lib/features/diary_entry/presentation/widgets/overlay/sticker_overlay_view.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/entities/sticker.dart';

/// Read-only, positioned rendering of a single [Sticker] for the diary
/// entry view (detail) page.
///
/// Mirrors [OverlayImageView] — not draggable, just renders the saved
/// transform data as-is. No tap-to-fullscreen behavior (unlike
/// [OverlayImageView]) since a sticker isn't a photo the user would want
/// to inspect full-screen.
class StickerOverlayView extends StatelessWidget {
  final Sticker sticker;

  const StickerOverlayView({super.key, required this.sticker});

  @override
  Widget build(BuildContext context) {
    final size = Sticker.baseWidth * sticker.scale;
    final height = Sticker.baseHeight * sticker.scale;

    return Positioned(
      left: sticker.x,
      top: sticker.y,
      child: Transform.rotate(
        angle: sticker.rotation,
        child: SizedBox(
          width: size,
          height: height,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final localPath = sticker.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      }
    }
    return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
  }
}