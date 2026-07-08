// lib/core/theme/theme_mapper.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/theme/domain/entities/app_theme_data.dart';
import 'background_image_theme_extension.dart';
import 'theme_data_builder.dart';

/// Converts a domain [AppThemeData] into a Flutter [ThemeData].
///
/// Kept as a standalone pure function (not a method on [AppThemeData]
/// itself, and not inlined into `AppThemeCubit`) so the domain layer
/// stays free of `ThemeData`/`Color` concerns and this conversion logic
/// is independently readable/testable.
///
/// Colors come from [AppThemeData]'s [RgbaColor] value objects via
/// `.toColor()` — the domain layer never imports `dart:ui`/`material`
/// directly (see `rgba_color.dart`).
///
/// Uses `ColorScheme.fromSeed` — the current Material 3 recommended way
/// to generate a full, accessible tonal palette from one or two source
/// colors, rather than hand-specifying every color role. `primaryColor`
/// seeds the scheme; `accentColor` is passed as `secondary` so it
/// influences the generated secondary/tertiary tones rather than being
/// ignored.
///
/// `backgroundColor`'s relative luminance determines [Brightness] —
/// derived rather than stored as a separate flag, so a theme's declared
/// background color and its light/dark classification can never
/// disagree.
///
/// [AppThemeData.fontFamily] is a Google Fonts family name applied
/// across the entire generated `TextTheme` via `GoogleFonts.getTextTheme`
/// — every text style (headings through body) uses the theme's font.
/// `GoogleFonts.getTextTheme` also fetches/caches the font at runtime,
/// so no font asset bundling or pubspec registration is needed per font.
///
/// The rest of the `ThemeData` shape (card/appBar/input decoration
/// shapes) is shared with `AppTheme` via [ThemeDataBuilder] so the two
/// theme-construction paths can't drift apart.
ThemeData buildThemeData(AppThemeData theme) {
  final primaryColor = theme.primaryColor.toColor();
  final accentColor = theme.accentColor.toColor();
  final backgroundColor = theme.backgroundColor.toColor();

  final brightness = _brightnessFor(backgroundColor);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    secondary: accentColor,
    brightness: brightness,
  );

  // Base text theme (correct on-surface colors for light/dark) first,
  // then swap in the theme's font family across all styles.
  final baseTextTheme = brightness == Brightness.dark
      ? ThemeData(brightness: Brightness.dark).textTheme
      : ThemeData(brightness: Brightness.light).textTheme;
  final themedTextTheme = GoogleFonts.getTextTheme(
    theme.fontFamily,
    baseTextTheme,
  );

  return ThemeDataBuilder.build(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: themedTextTheme,
    transparentAppBar: true,
    extensions: [
      BackgroundImageTheme(
        imagePath: theme.headerImagePath,
        isAsset: theme.isHeaderImageAsset,
      ),
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
