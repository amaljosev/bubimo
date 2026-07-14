// lib/features/diary_entry/presentation/widgets/overlay/overlay_layer.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/overlay_image.dart';
import '../../../domain/entities/sticker.dart';
import 'editable_overlay_image.dart';
import 'editable_sticker_overlay.dart';

/// Hosts every [OverlayImage] and [Sticker] for the diary form as
/// absolutely positioned, draggable/rotatable/resizable children
/// stacked on top of [child] (the Quill editor + its surrounding
/// scroll content).
///
/// Generalized to handle both item kinds in one layer (rather than a
/// separate StickerLayer) since they share identical transform
/// behavior and coordinate space — only the id namespace and selection
/// need to stay distinguishable, which is handled here via
/// [selectedImageId]/[selectedStickerId] being tracked independently
/// (an image and a sticker could theoretically share the same
/// generated id string, so they are never merged into one combined
/// "selected id" concept).
///
/// Tapping anywhere in the layer that isn't an image or sticker
/// deselects whichever one is currently selected.
///
/// This widget is meant to be nested *inside* the description area's
/// `SingleChildScrollView`, wrapping the Quill editor as its scrolling
/// sibling, so overlay items scroll together with the text as part of
/// the same `Scrollable` — rather than being pinned to the viewport.
/// Because of that, this layer's own coordinate space (used to clamp
/// drag positions in [TransformableItem]) can be *taller* than the
/// fixed-size viewport referenced by [boundsKey] for a long entry —
/// see the internal content-bounds key used for clamping vs [boundsKey]
/// used for "visible area" placement.
class OverlayLayer extends StatelessWidget {
  final Widget child;
  final List<OverlayImage> images;
  final List<Sticker> stickers;
  final String? selectedImageId;
  final String? selectedStickerId;

  final ValueChanged<String> onSelectImage;
  final ValueChanged<String> onSelectSticker;
  final VoidCallback onDeselect;

  final void Function({
    required String id,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) onImageTransform;
  final void Function({
    required String id,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) onStickerTransform;

  final ValueChanged<String> onRemoveImage;
  final ValueChanged<String> onRemoveSticker;

  /// Key of the *viewport* (the fixed-size box wrapping the
  /// description area's `SingleChildScrollView`) — used only to
  /// compute "the currently visible area" for placing newly added
  /// items via [findFreePosition]. Its size never changes as the user
  /// scrolls or types.
  final GlobalKey boundsKey;

  /// Key of this layer's own root `Stack` — its [RenderBox] is the
  /// *content's* coordinate space, which can be taller than the
  /// viewport once the entry has enough text to scroll. Drag/pinch
  /// clamping in [TransformableItem] uses this (via [getBounds]) so an
  /// item dragged near the bottom of a long entry isn't incorrectly
  /// snapped back up into the viewport's fixed height.
  final GlobalKey _contentBoundsKey = GlobalKey();

   OverlayLayer({
    super.key,
    required this.child,
    required this.images,
    this.stickers = const [],
    required this.selectedImageId,
    this.selectedStickerId,
    required this.onSelectImage,
    required this.onSelectSticker,
    required this.onDeselect,
    required this.onImageTransform,
    required this.onStickerTransform,
    required this.onRemoveImage,
    required this.onRemoveSticker,
    required this.boundsKey,
  });

  /// Bounds used for clamping an item's drag position — the layer's own
  /// content size (which grows with the document), not the fixed
  /// viewport. Passed as `getBounds` to each [EditableOverlayImage]/
  /// [EditableStickerOverlay] so `TransformableItem._clampToBounds`
  /// keeps items within the full scrollable content instead of
  /// snapping them back into the visible viewport height.
  Rect? _getContentBounds() {
    final box =
        _contentBoundsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return Rect.fromLTWH(0, 0, box.size.width, box.size.height);
  }

  /// Finds an unoccupied spot for a newly added overlay item, starting
  /// from the center of [bounds] and spiraling outward if the center is
  /// already occupied. Falls back to a fixed offset if [bounds] isn't
  /// available yet (e.g. not laid out on the very first frame).
  ///
  /// [bounds] is treated as an arbitrary window within the overlay
  /// layer's full content coordinate space — its `top`/`left` origin is
  /// respected rather than assumed to be `(0, 0)`. This is what lets a
  /// caller pass "the currently scrolled-into-view region" (top offset
  /// by the current scroll position) for a long entry, so a new sticker
  /// or overlay image lands where the user is actually looking rather
  /// than always at the top of the document.
  ///
  /// Considers both existing overlay images AND stickers as occupied
  /// space, so a newly added sticker won't stack directly on top of an
  /// existing image and vice versa.
  static Offset findFreePosition({
    required Rect? bounds,
    required List<OverlayImage> existingImages,
    List<Sticker> existingStickers = const [],
    required double width,
    required double height,
  }) {
    if (bounds == null) return const Offset(20, 20);

    final existing = <Rect>[
      for (final img in existingImages)
        Rect.fromLTWH(
          img.x,
          img.y,
          OverlayImage.baseWidth * img.scale,
          OverlayImage.baseHeight * img.scale,
        ),
      for (final sticker in existingStickers)
        Rect.fromLTWH(
          sticker.x,
          sticker.y,
          Sticker.baseWidth * sticker.scale,
          Sticker.baseHeight * sticker.scale,
        ),
    ];

    bool isValid(Rect rect) {
      if (rect.left < bounds.left ||
          rect.top < bounds.top ||
          rect.right > bounds.right ||
          rect.bottom > bounds.bottom) {
        return false;
      }
      return existing.every((r) => !rect.overlaps(r));
    }

    final startTL = Offset(
      (bounds.left + (bounds.width - width) / 2).clamp(
        bounds.left,
        math.max(bounds.left, bounds.right - width),
      ),
      (bounds.top + (bounds.height - height) / 2).clamp(
        bounds.top,
        math.max(bounds.top, bounds.bottom - height),
      ),
    );
    if (isValid(Rect.fromLTWH(startTL.dx, startTL.dy, width, height))) {
      return startTL;
    }

    final searchCenter = bounds.center;
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
    // Wrapping the whole Stack in a `KeyedSubtree` (rather than keying
    // the Stack widget directly) lets `_contentBoundsKey` resolve to
    // this subtree's own RenderBox — which, per the Stack's default
    // sizing rule (it matches its one non-positioned child's natural
    // size), reflects the content's full natural height. That's what
    // `_getContentBounds` needs for correct drag clamping once an entry
    // is long enough to scroll past the viewport.
    return KeyedSubtree(
      key: _contentBoundsKey,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base content (Quill editor etc). This is the Stack's only
          // non-positioned child, so per Stack's default sizing rules
          // the whole Stack sizes itself to match this child's natural
          // size — the overlay items below are all Positioned and
          // don't contribute to that sizing, so they float on top
          // without affecting (or collapsing) the editor's layout.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDeselect,
            child: child,
          ),
          for (final image in images)
            EditableOverlayImage(
              key: ValueKey('image_${image.id}'),
              image: image,
              isSelected: selectedImageId == image.id,
              getBounds: _getContentBounds,
              onSelect: () => onSelectImage(image.id),
              onUpdate: ({
                required id,
                required x,
                required y,
                required scale,
                required rotation,
              }) =>
                  onImageTransform(
                id: id,
                x: x,
                y: y,
                scale: scale,
                rotation: rotation,
              ),
              onRemove: () => onRemoveImage(image.id),
            ),
          for (final sticker in stickers)
            EditableStickerOverlay(
              key: ValueKey('sticker_${sticker.id}'),
              sticker: sticker,
              isSelected: selectedStickerId == sticker.id,
              getBounds: _getContentBounds,
              onSelect: () => onSelectSticker(sticker.id),
              onUpdate: ({
                required id,
                required x,
                required y,
                required scale,
                required rotation,
              }) =>
                  onStickerTransform(
                id: id,
                x: x,
                y: y,
                scale: scale,
                rotation: rotation,
              ),
              onRemove: () => onRemoveSticker(sticker.id),
            ),
        ],
      ),
    );
  }
}