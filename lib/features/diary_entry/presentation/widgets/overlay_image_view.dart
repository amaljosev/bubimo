// lib/features/diary_entry/presentation/widgets/overlay_image_view.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/overlay_image.dart';
import 'full_screen_image_viewer.dart';

/// Read-only, positioned rendering of a single [OverlayImage] for the
/// diary entry view (detail) page.
///
/// Not draggable — the view page only ever displays the transform data
/// that was saved from the form page. Tapping opens the full-screen
/// viewer via a Hero transition.
class OverlayImageView extends StatelessWidget {
  final OverlayImage image;

  const OverlayImageView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'overlay_image_${image.id}';
    final size = OverlayImage.baseWidth * image.scale;
    final height = OverlayImage.baseHeight * image.scale;

    return Positioned(
      left: image.x,
      top: image.y,
      child: Transform.rotate(
        angle: image.rotation,
        child: GestureDetector(
          onTap: () => FullScreenImageViewer.show(
            context,
            imagePath: image.path,
            heroTag: heroTag,
          ),
          child: SizedBox(
            width: size,
            height: height,
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}