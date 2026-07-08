// lib/core/theme/theme_data_builder.dart

import 'package:flutter/material.dart';

import 'theme_tokens.dart';

/// Builds the common `ThemeData` skeleton — `cardTheme`,
/// `appBarTheme`, `inputDecorationTheme`, `floatingActionButtonTheme` —
/// shared by both [AppTheme] (the app's fallback/default theme, built
/// straight from a seed color) and `buildThemeData` in `theme_mapper.dart`
/// (built from a user's [AppThemeData]).
///
/// Both call sites previously duplicated this shape with only the
/// `ColorScheme`/`TextTheme` differing. Centralizing it here means a
/// future shape/radius change only happens in one place, and the two
/// theme-construction paths can never silently drift apart.
class ThemeDataBuilder {
  ThemeDataBuilder._();

  static ThemeData build({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    TextTheme? textTheme,
    bool transparentAppBar = false,
    List<ThemeExtension<dynamic>> extensions = const [],
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            transparentAppBar ? Colors.transparent : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme?.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeRadii.lg),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeRadii.sm),
          borderSide: BorderSide.none,
        ),
      ),
      extensions: extensions,
    );
  }
}
