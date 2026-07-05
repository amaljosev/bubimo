// lib/features/diary_entry/presentation/widgets/editable_sticker_overlay.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/sticker.dart';
import 'transformable_item.dart';

/// Interactive, draggable/rotatable/resizable rendering of a single
/// [Sticker] inside the diary form's editor.
///
/// Mirrors [EditableOverlayImage] exactly, but resolves its image from
/// [Sticker.localPath] (the cached download) rather than a gallery file
/// path directly — falling back to a broken-image placeholder if the
/// cache file is missing (e.g. not downloaded yet, or lost between a
/// backup/restore). Recovery (re-downloading a missing local file) is
/// the form bloc's responsibility, not this widget's — this widget only
/// renders whatever [Sticker.localPath] currently is.
class EditableStickerOverlay extends StatelessWidget {
  final Sticker sticker;
  final bool isSelected;
  final ValueGetter<Rect?>? getBounds;
  final VoidCallback onSelect;
  final ItemTransformUpdate onUpdate;
  final VoidCallback onRemove;

  const EditableStickerOverlay({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
    this.getBounds,
  });

  @override
  Widget build(BuildContext context) {
    return TransformableItem(
      id: sticker.id,
      initialPosition: Offset(sticker.x, sticker.y),
      initialScale: sticker.scale,
      initialRotation: sticker.rotation,
      isSelected: isSelected,
      baseWidth: Sticker.baseWidth,
      baseHeight: Sticker.baseHeight,
      getBounds: getBounds,
      onSelect: onSelect,
      onUpdate: onUpdate,
      onRemove: onRemove,
      child: _buildImage(),
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
    // Local file missing or not yet downloaded — never hit the network
    // directly from this widget; downloading/recovery is the form
    // bloc's job (see DiaryFormBloc's sticker recovery logic).
    return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
  }
}