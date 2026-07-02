// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Base light theme for the app.
///
/// Deliberately minimal for now — full theming (typography scale, custom
/// component themes, dark mode) is planned for a later milestone. This
/// establishes the Material 3 color scheme and wires it into a `ThemeData`
/// using current (non-deprecated) APIs.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}