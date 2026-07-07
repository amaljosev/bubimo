// lib/core/theme/background_image_theme_extension.dart

import 'package:flutter/material.dart';

/// A [ThemeExtension] carrying the active theme's optional header/
/// background image path.
///
/// `ThemeExtension` is the current, non-deprecated Flutter mechanism for
/// attaching custom theme data that flows through `Theme.of(context)`
/// alongside `ColorScheme` — any widget can read
/// `Theme.of(context).extension<BackgroundImageTheme>()` without needing
/// it threaded through as an explicit parameter. Used by Home's
/// `SliverAppBar` background.
///
/// [isAsset] distinguishes a bundled Flutter asset path (built-in
/// themes Ocean/Sunset — render with `Image.asset`) from a file path on
/// disk (custom themes with a picked+cropped header image — render
/// with `Image.file`).
class BackgroundImageTheme extends ThemeExtension<BackgroundImageTheme> {
  final String? imagePath;
  final bool isAsset;

  const BackgroundImageTheme({this.imagePath, this.isAsset = false});

  @override
  BackgroundImageTheme copyWith({String? imagePath, bool? isAsset}) {
    return BackgroundImageTheme(
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
    );
  }

  @override
  BackgroundImageTheme lerp(
    covariant ThemeExtension<BackgroundImageTheme>? other,
    double t,
  ) {
    if (other is! BackgroundImageTheme) return this;
    // Image paths aren't numeric/interpolatable — snap to the incoming
    // extension's value past the halfway point of the transition.
    return t < 0.5 ? this : other;
  }
}
