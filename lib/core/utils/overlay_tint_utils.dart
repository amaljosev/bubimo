// lib/core/utils/overlay_tint_utils.dart

import 'package:flutter/material.dart';

/// Resolves the tint color + blend mode to apply over a background
/// image, from the entry's stored `bgOverlayColor` name (`'white'` or
/// `'black'`).
///
/// `bgOverlayColor` is nullable: `null` ("Auto") means the user hasn't
/// explicitly chosen a tint for this entry, so the tint is derived from
/// the app's currently active theme via [themeBrightness] — a light
/// app theme gets a dark tint, a dark app theme gets a light tint,
/// mirroring the same light/dark-adaptive treatment already applied to
/// entry text color. An explicit `'white'`/`'black'` value always wins
/// over the theme, since it reflects a deliberate per-entry choice made
/// in the overlay settings sheet.
///
/// Previously duplicated identically in:
///   - `DiaryFormPage._resolveOverlayTintColor` (+ inline `BlendMode`
///     selection in its `build` method)
///   - `DiaryEntryViewPage._resolveOverlayTintColor` (+ its own inline
///     `BlendMode` selection)
abstract final class OverlayTintUtils {
  static Color resolveColor(
    String? bgOverlayColor,
    Brightness themeBrightness,
  ) {
    final effective = bgOverlayColor ?? _autoColorName(themeBrightness);
    return effective == 'black' ? Colors.black : Colors.white;
  }

  /// 'lighten' is a no-op for a black tint (it can only brighten, never
  /// darken), so a black tint needs 'darken' to actually dim the image;
  /// a white tint uses 'lighten' for the reverse reason.
  static BlendMode resolveBlendMode(
    String? bgOverlayColor,
    Brightness themeBrightness,
  ) {
    final effective = bgOverlayColor ?? _autoColorName(themeBrightness);
    return effective == 'black' ? BlendMode.darken : BlendMode.lighten;
  }

  /// Convenience: the ready-to-use [ColorFilter] for a
  /// `DecorationImage.colorFilter`, given the stored color name (or
  /// `null` for "Auto"), the current app theme's brightness, and the
  /// entry's opacity value.
  static ColorFilter resolveColorFilter({
    required String? bgOverlayColor,
    required Brightness themeBrightness,
    required double opacity,
  }) {
    return ColorFilter.mode(
      resolveColor(bgOverlayColor, themeBrightness).withValues(alpha: opacity),
      resolveBlendMode(bgOverlayColor, themeBrightness),
    );
  }

  /// Light app theme → dark tint (keeps text readable against what's
  /// presumed to be a lighter overall palette); dark app theme → light
  /// tint. Mirrors the same rule already applied to entry text color
  /// when the user selects a dark app theme.
  static String _autoColorName(Brightness themeBrightness) {
    return themeBrightness == Brightness.dark ? 'white' : 'black';
  }
}