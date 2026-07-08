// lib/core/theme/theme_tokens.dart

/// Shared design tokens: corner radii, spacing, and animation durations
/// used across the Theme feature (and safe to reuse app-wide).
///
/// Extracted so that visually-related values (e.g. "a tile card" vs "a
/// bottom sheet") stay consistent by construction instead of by
/// convention — previously the same conceptual radius was hand-typed as
/// 14, 16, 18, or 20 in different widgets with no shared source.
class ThemeRadii {
  ThemeRadii._();

  /// Small controls: chips, input fields, small buttons.
  static const double sm = 12.0;

  /// Standard tappable rows/tiles (e.g. [ColorFieldTile]).
  static const double md = 14.0;

  /// Cards and list tiles (e.g. theme tiles, current-theme header).
  static const double lg = 16.0;

  /// Prominent containers (tab bar pill, theme tile cards).
  static const double xl = 18.0;

  /// Large surfaces (bottom sheet tops, current-theme header).
  static const double xxl = 20.0;

  /// Modal bottom sheet top corners.
  static const double sheet = 28.0;
}

class ThemeSpacing {
  ThemeSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class ThemeDurations {
  ThemeDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration scroll = Duration(milliseconds: 300);
}
