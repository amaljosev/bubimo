// lib/core/theme/theme_mapper.dart

import 'package:flutter/material.dart';

import '../../features/theme/domain/entities/app_theme_data.dart';
import 'background_image_theme_extension.dart';

/// Converts a domain [AppThemeData] into a Flutter [ThemeData].
///
/// Kept as a standalone pure function (not a method on [AppThemeData]
/// itself, and not inlined into `AppThemeCubit`) so the domain layer
/// stays free of `ThemeData` concerns and this conversion logic is
/// independently readable/testable.
///
/// Uses `ColorScheme.fromSeed` — the current Material 3 recommended way
/// to generate a full, accessible tonal palette from one or two source
/// colors, rather than hand-specifying every color role. `primaryColor`
/// seeds the scheme; `accentColor` is passed as `secondarySeedColor` so
/// it influences the generated secondary/tertiary tones rather than
/// being ignored.
///
/// `backgroundColor`'s relative luminance determines [Brightness] —
/// derived rather than stored as a separate flag, so a theme's declared
/// background color and its light/dark classification can never
/// disagree.
ThemeData buildThemeData(AppThemeData theme) {
  final brightness = _brightnessFor(theme.backgroundColor);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: theme.primaryColor,
    secondary: theme.accentColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: theme.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    extensions: [
      BackgroundImageTheme(imagePath: theme.headerImagePath),
    ],
  );
}

/// A background is treated as "dark" when its relative luminance falls
/// below the standard midpoint threshold — the same threshold Flutter's
/// own `ThemeData.estimateBrightnessForColor` uses internally.
Brightness _brightnessFor(Color background) {
  return background.computeLuminance() < 0.5
      ? Brightness.dark
      : Brightness.light;
}