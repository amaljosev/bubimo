// lib/features/diary_entry/presentation/widgets/editable_overlay_image.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/overlay_image.dart';
import 'transformable_item.dart';

/// Interactive, draggable/rotatable/resizable rendering of a single
/// [OverlayImage] inside the diary form's editor.
///
/// This is intentionally separate from any inline Quill image embed —
/// it floats above the whole editor at an absolute position and never
/// participates in the document's text flow.
class EditableOverlayImage extends StatelessWidget {
  final OverlayImage image;
  final bool isSelected;
  final ValueGetter<Rect?>? getBounds;
  final VoidCallback onSelect;
  final ItemTransformUpdate onUpdate;
  final VoidCallback onRemove;

  const EditableOverlayImage({
    super.key,
    required this.image,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
    this.getBounds,
  });

  @override
  Widget build(BuildContext context) {
    return TransformableItem(
      id: image.id,
      initialPosition: Offset(image.x, image.y),
      initialScale: image.scale,
      initialRotation: image.rotation,
      isSelected: isSelected,
      baseWidth: OverlayImage.baseWidth,
      baseHeight: OverlayImage.baseHeight,
      getBounds: getBounds,
      onSelect: onSelect,
      onUpdate: onUpdate,
      onRemove: onRemove,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(image.path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}