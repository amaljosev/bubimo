// lib/features/diary_entry/presentation/widgets/overlay_layer.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/overlay_image.dart';
import 'editable_overlay_image.dart';

/// Hosts every [OverlayImage] for the diary form as absolutely
/// positioned, draggable/rotatable/resizable children stacked on top
/// of [child] (the Quill editor + its surrounding scroll content).
///
/// This is the layer that makes overlay photos feel like stickers on a
/// story — they float above the text and are transformed independently
/// of it. Tapping anywhere in the layer that isn't an image deselects
/// the currently selected one.
class OverlayLayer extends StatelessWidget {
  final Widget child;
  final List<OverlayImage> images;
  final String? selectedImageId;
  final ValueChanged<String> onSelect;
  final VoidCallback onDeselect;
  final void Function({
    required String id,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) onTransform;
  final ValueChanged<String> onRemove;

  /// Key of the widget whose [RenderBox] defines the coordinate space
  /// and bounds overlay images are clamped/placed within — typically
  /// the container wrapping the Quill editor.
  final GlobalKey boundsKey;

  const OverlayLayer({
    super.key,
    required this.child,
    required this.images,
    required this.selectedImageId,
    required this.onSelect,
    required this.onDeselect,
    required this.onTransform,
    required this.onRemove,
    required this.boundsKey,
  });

  Rect? _getBounds() {
    final box = boundsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return Rect.fromLTWH(0, 0, box.size.width, box.size.height);
  }

  /// Finds an unoccupied spot for a newly added overlay image, starting
  /// from the center of the bounds and spiraling outward if the center
  /// is already occupied. Falls back to a fixed offset if the bounds
  /// aren't laid out yet.
  ///
  /// Ported from the old project's `_findFreePositionForNewItem`.
  static Offset findFreePosition({
    required Rect? bounds,
    required List<OverlayImage> existingImages,
    required double width,
    required double height,
  }) {
    if (bounds == null) return const Offset(20, 20);

    final size = bounds.size;
    final existing = <Rect>[
      for (final img in existingImages)
        Rect.fromLTWH(
          img.x,
          img.y,
          OverlayImage.baseWidth * img.scale,
          OverlayImage.baseHeight * img.scale,
        ),
    ];

    bool isValid(Rect rect) {
      if (rect.left < 0 ||
          rect.top < 0 ||
          rect.right > size.width ||
          rect.bottom > size.height) {
        return false;
      }
      return existing.every((r) => !rect.overlaps(r));
    }

    final startTL = Offset(
      ((size.width - width) / 2).clamp(0.0, math.max(0.0, size.width - width)),
      ((size.height - height) / 2)
          .clamp(0.0, math.max(0.0, size.height - height)),
    );
    if (isValid(Rect.fromLTWH(startTL.dx, startTL.dy, width, height))) {
      return startTL;
    }

    final searchCenter = Offset(size.width / 2, size.height / 2);
    for (double r = 20.0; r <= 500.0; r += 20.0) {
      for (int d = 0; d < 8; d++) {
        final angle = d * math.pi / 4;
        final candidateCenter =
            searchCenter + Offset(r * math.cos(angle), r * math.sin(angle));
        final tl = Offset(
          candidateCenter.dx - width / 2,
          candidateCenter.dy - height / 2,
        );
        if (isValid(Rect.fromLTWH(tl.dx, tl.dy, width, height))) {
          return tl;
        }
      }
    }
    return startTL;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base content (Quill editor etc). This is the Stack's only
        // non-positioned child, so per Stack's default sizing rules the
        // whole Stack sizes itself to match this child's natural size —
        // the overlay images below are all Positioned and don't
        // contribute to that sizing, so they float on top without
        // affecting (or collapsing) the editor's layout.
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onDeselect,
          child: child,
        ),
        for (final image in images)
          EditableOverlayImage(
            key: ValueKey(image.id),
            image: image,
            isSelected: selectedImageId == image.id,
            getBounds: _getBounds,
            onSelect: () => onSelect(image.id),
            onUpdate: ({
              required id,
              required x,
              required y,
              required scale,
              required rotation,
            }) =>
                onTransform(
              id: id,
              x: x,
              y: y,
              scale: scale,
              rotation: rotation,
            ),
            onRemove: () => onRemove(image.id),
          ),
      ],
    );
  }
}