// lib/core/theme/background_image_theme_extension.dart

import 'package:flutter/material.dart';

/// A [ThemeExtension] carrying the active theme's optional header/
/// background image path.
///
/// `ThemeExtension` is the current, non-deprecated Flutter mechanism for
/// attaching custom theme data that flows through `Theme.of(context)`
/// alongside `ColorScheme` — any widget can read
/// `Theme.of(context).extension<BackgroundImageTheme>()?.imagePath`
/// without needing it threaded through as an explicit parameter. Used
/// today by Home's `SliverAppBar` background.
class BackgroundImageTheme extends ThemeExtension<BackgroundImageTheme> {
  final String? imagePath;

  const BackgroundImageTheme({this.imagePath});

  @override
  BackgroundImageTheme copyWith({String? imagePath}) {
    return BackgroundImageTheme(imagePath: imagePath ?? this.imagePath);
  }

  @override
  BackgroundImageTheme lerp(
    covariant ThemeExtension<BackgroundImageTheme>? other,
    double t,
  ) {
    if (other is! BackgroundImageTheme) return this;
    // Image paths aren't numeric/interpolatable — snap to the incoming
    // extension's value past the halfway point of the transition, same
    // behavior as the reference file this pattern was adapted from.
    return t < 0.5 ? this : other;
  }
}