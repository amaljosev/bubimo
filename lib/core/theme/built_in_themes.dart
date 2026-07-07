// lib/core/theme/built_in_themes.dart

import '../../../features/theme/domain/entities/app_theme_data.dart';
import '../../../features/theme/domain/entities/rgba_color.dart';
import '../../../features/theme/domain/entities/theme_type.dart';

/// The 5 built-in themes, defined as static in-memory data — these are
/// never read from or written to the database. `ThemeRepositoryImpl`
/// prepends this list ahead of the persisted custom themes whenever
/// `getAllThemes()` is called.
///
/// Built-in theme ids are stable string constants (not generated via
/// [IdGenerator]) since they're referenced permanently — e.g. as the
/// `theme_id` value persisted in `app_settings`, and as
/// [defaultBuiltInThemeId] for "Reset to Default".
class BuiltInThemes {
  BuiltInThemes._();

  static const String duskId = 'builtin_dusk';
  static const String meadowId = 'builtin_meadow';
  static const String oceanId = 'builtin_ocean';
  static const String sunsetId = 'builtin_sunset';
  static const String bloomId = 'builtin_bloom';

  /// The theme "Reset to Default" applies, and the one used on very
  /// first launch before any selection has been persisted.
  static const String defaultBuiltInThemeId = duskId;

  /// Bundled asset paths for the built-in themes that ship a header
  /// image. Register these under `flutter: assets:` in pubspec.yaml.
  /// Placeholder files — swap in real artwork at these paths.
  static const String oceanHeaderAsset = 'assets/theme/theme_1.jpg';
  static const String sunsetHeaderAsset = 'assets/theme/theme_2.jpg';
  static const String bloomHeaderAsset = 'assets/theme/theme_3.jpg';

  /// Dusk — the default theme. Violet/lilac palette, no header image
  /// (Type 1: Colors + Font). Primary/accent pulled from a twilight
  /// wildflower-field reference (deep violet-blue + soft lilac).
  /// Background stays light for text-contrast safety, since the
  /// reference art itself is a genuinely dark night palette.
  static final AppThemeData dusk = AppThemeData(
    id: duskId,
    name: 'Dusk',
    type: ThemeType.colorsAndFont,
    primaryColor: const RgbaColor(red: 88, green: 86, blue: 168),
    backgroundColor: const RgbaColor(red: 253, green: 252, blue: 255),
    accentColor: const RgbaColor(red: 168, green: 138, blue: 214),
    fontFamily: 'Poppins',
    isBuiltIn: true,
    isDefault: true,
  );

  /// Meadow — fresh green palette, no header image (Type 1).
  static final AppThemeData meadow = AppThemeData(
    id: meadowId,
    name: 'Meadow',
    type: ThemeType.colorsAndFont,
    primaryColor: const RgbaColor(red: 58, green: 106, blue: 62),
    backgroundColor: const RgbaColor(red: 247, green: 253, blue: 242),
    accentColor: const RgbaColor(red: 121, green: 134, blue: 41),
    fontFamily: 'Nunito',
    isBuiltIn: true,
  );

  /// Ocean — teal/blue palette with a bundled header image (Type 2).
  /// Primary/accent updated to the vivid sky-blue and deep azure of a
  /// clear-sky-over-city reference image.
  static final AppThemeData ocean = AppThemeData(
    id: oceanId,
    name: 'Ocean',
    type: ThemeType.colorsAndFontWithHeaderImage,
    primaryColor: const RgbaColor(red: 0, green: 122, blue: 204),
    backgroundColor: const RgbaColor(red: 240, green: 249, blue: 255),
    accentColor: const RgbaColor(red: 20, green: 70, blue: 150),
    fontFamily: 'Quicksand',
    headerImagePath: oceanHeaderAsset,
    isHeaderImageAsset: true,
    isBuiltIn: true,
  );

  /// Sunset — warm amber/rose palette with a bundled header image
  /// (Type 2).
  static final AppThemeData sunset = AppThemeData(
    id: sunsetId,
    name: 'Sunset',
    type: ThemeType.colorsAndFontWithHeaderImage,
    primaryColor: const RgbaColor(red: 199, green: 120, blue: 0),
    backgroundColor: const RgbaColor(red: 255, green: 248, blue: 246),
    accentColor: const RgbaColor(red: 180, green: 67, blue: 108),
    fontFamily: 'Merriweather',
    headerImagePath: sunsetHeaderAsset,
    isHeaderImageAsset: true,
    isBuiltIn: true,
  );

  /// Bloom — soft rose/lavender palette with a bundled header image
  /// (Type 2). New theme, sourced from a pastel pink-and-violet
  /// cloudscape reference image.
  static final AppThemeData bloom = AppThemeData(
    id: bloomId,
    name: 'Bloom',
    type: ThemeType.colorsAndFontWithHeaderImage,
    primaryColor: const RgbaColor(red: 219, green: 112, blue: 147),
    backgroundColor: const RgbaColor(red: 255, green: 250, blue: 250),
    accentColor: const RgbaColor(red: 147, green: 112, blue: 178),
    fontFamily: 'Quicksand',
    headerImagePath: bloomHeaderAsset,
    isHeaderImageAsset: true,
    isBuiltIn: true,
  );

  static final List<AppThemeData> all = [dusk, meadow, ocean, sunset, bloom];

  static AppThemeData get defaultTheme => dusk;
}