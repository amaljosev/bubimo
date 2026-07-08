// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

import 'theme_data_builder.dart';

/// Builds the app's base/default ThemeData.
///
/// This is the fallback theme used before AppThemeCubit (theme feature)
/// loads the user's selected theme, and the template default preset
/// themes are derived from. Uses current Material 3 conventions
/// (ColorScheme.fromSeed) rather than deprecated primarySwatch/accentColor
/// fields.
///
/// The actual `ThemeData` shape (card/appBar/input decoration shapes)
/// is shared with `theme_mapper.dart` via [ThemeDataBuilder] so the two
/// theme-construction paths can't drift apart.
class AppTheme {
  AppTheme._();

  static ThemeData light({Color seedColor = const Color(0xFF6750A4)}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeDataBuilder.build(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static ThemeData dark({Color seedColor = const Color(0xFF6750A4)}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeDataBuilder.build(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}
