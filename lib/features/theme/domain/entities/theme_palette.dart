// lib/features/theme/domain/entities/theme_palette.dart

import 'package:equatable/equatable.dart';

import 'rgba_color.dart';

/// A complete set of the 5 user-editable colors for ONE mode (Light or
/// Dark) of a custom theme.
///
/// Introduced so a single custom theme can remember two independent
/// palettes — one for Light Mode, one for Dark Mode — rather than a
/// single flat set of 5 colors plus an [AppThemeData.isDark] flag that
/// gets overwritten every time the mode is toggled. See
/// `AppThemeData.lightPalette` / `AppThemeData.darkPalette`.
///
/// Built-in themes don't use this — each built-in theme is only ever
/// one mode, so its 5 colors live directly on [AppThemeData] as before.
class ThemePalette extends Equatable {
  final RgbaColor primaryColor;
  final RgbaColor secondaryColor;
  final RgbaColor surfaceColor;
  final RgbaColor backgroundColor;
  final RgbaColor textColor;

  const ThemePalette({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textColor,
  });

  ThemePalette copyWith({
    RgbaColor? primaryColor,
    RgbaColor? secondaryColor,
    RgbaColor? surfaceColor,
    RgbaColor? backgroundColor,
    RgbaColor? textColor,
  }) {
    return ThemePalette(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  List<Object?> get props => [
        primaryColor,
        secondaryColor,
        surfaceColor,
        backgroundColor,
        textColor,
      ];
}