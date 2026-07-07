// lib/features/theme/domain/entities/theme_type.dart

/// The three theme kinds described in the product spec.
///
/// [colorsAndFont] and [colorsAndFontWithHeaderImage] are both used by
/// built-in themes (some built-ins ship a header image, some don't).
/// [custom] is exclusively for user-created themes stored in the
/// `custom_themes` table — it's tracked as its own type (rather than
/// inferring "custom" purely from `isBuiltIn == false`) so the
/// distinction is explicit wherever [ThemeType] is pattern-matched,
/// e.g. deciding whether the Theme Switcher's edit/delete affordances
/// should show for a given theme.
enum ThemeType {
  colorsAndFont,
  colorsAndFontWithHeaderImage,
  custom;

  bool get supportsHeaderImage => this != ThemeType.colorsAndFont;

  static ThemeType fromStorageValue(String value) {
    return ThemeType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ThemeType.custom,
    );
  }
}
