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
/// [AppThemeData] stores colors as hex strings (e.g. `'#6750A4'`) so the
/// domain layer stays free of Flutter's `Color` type — [_colorFromHex]
/// parses them here, at the boundary where they're actually needed as
/// `Color` values.
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
ThemeData buildThemeData(AppThemeData theme) {
  final primaryColor = _colorFromHex(theme.primaryColor);
  final accentColor = _colorFromHex(theme.accentColor);
  final backgroundColor = _colorFromHex(theme.backgroundColor);

  final brightness = _brightnessFor(backgroundColor);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    secondary: accentColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
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

/// Parses a `'#RRGGBB'` (or `'RRGGBB'`) hex string into a [Color].
/// Falls back to opaque black if the string is malformed, rather than
/// throwing — a corrupt/unexpected stored color shouldn't crash theme
/// loading for the whole app.
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final parsed = int.tryParse('FF$cleaned', radix: 16);
  return Color(parsed ?? 0xFF000000);
}

/// A background is treated as "dark" when its relative luminance falls
/// below the standard midpoint threshold — the same threshold Flutter's
/// own `ThemeData.estimateBrightnessForColor` uses internally.
Brightness _brightnessFor(Color background) {
  return background.computeLuminance() < 0.5
      ? Brightness.dark
      : Brightness.light;
}