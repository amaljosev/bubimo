// lib/core/utils/overlay_tint_utils.dart

import 'package:flutter/material.dart';

/// Resolves the tint color + blend mode to apply over a background
/// image, from the entry's stored `bgOverlayColor` name (`'white'` or
/// `'black'`). Falls back to white for any unrecognized value rather
/// than throwing, since this is purely a display concern.
///
/// Previously duplicated identically in:
///   - `DiaryFormPage._resolveOverlayTintColor` (+ inline `BlendMode`
///     selection in its `build` method)
///   - `DiaryEntryViewPage._resolveOverlayTintColor` (+ its own inline
///     `BlendMode` selection)
abstract final class OverlayTintUtils {
  static Color resolveColor(String bgOverlayColor) {
    return bgOverlayColor == 'black' ? Colors.black : Colors.white;
  }

  /// 'lighten' is a no-op for a black tint (it can only brighten, never
  /// darken), so a black tint needs 'darken' to actually dim the image;
  /// a white tint uses 'lighten' for the reverse reason.
  static BlendMode resolveBlendMode(String bgOverlayColor) {
    return bgOverlayColor == 'black' ? BlendMode.darken : BlendMode.lighten;
  }

  /// Convenience: the ready-to-use [ColorFilter] for a
  /// `DecorationImage.colorFilter`, given the stored color name and
  /// opacity value.
  static ColorFilter resolveColorFilter({
    required String bgOverlayColor,
    required double opacity,
  }) {
    return ColorFilter.mode(
      resolveColor(bgOverlayColor).withValues(alpha: opacity),
      resolveBlendMode(bgOverlayColor),
    );
  }
}