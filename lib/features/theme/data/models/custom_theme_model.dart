// lib/features/theme/data/models/custom_theme_model.dart

import '../../../../core/database/tables/custom_themes_table.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/entities/rgba_color.dart';
import '../../domain/entities/theme_palette.dart';
import '../../domain/entities/theme_type.dart';

/// Data-layer wrapper around [AppThemeData] for custom themes — maps
/// to/from a `custom_themes` table row.
///
/// [theme]'s flat color fields (`primaryColor`, `secondaryColor`, etc.)
/// always reflect whichever mode is CURRENTLY ACTIVE
/// ([AppThemeData.isDark]); [AppThemeData.lightPalette] /
/// [AppThemeData.darkPalette] carry the other mode's colors alongside,
/// each mapped to its own `*_dark`-suffixed column (see
/// `CustomThemesTable` doc comment for the version-9 schema change).
class CustomThemeModel {
  final AppThemeData theme;

  const CustomThemeModel(this.theme);

  /// Builds from a raw sqflite row.
  factory CustomThemeModel.fromMap(Map<String, Object?> map) {
    final isDark = (map[CustomThemesTable.columnIsDark] as int? ?? 0) == 1;

    final lightPalette = ThemePalette(
      primaryColor: RgbaColor.fromStorageString(
        map[CustomThemesTable.columnPrimaryColor] as String,
      ),
      secondaryColor: RgbaColor.fromStorageString(
        map[CustomThemesTable.columnSecondaryColor] as String,
      ),
      surfaceColor: RgbaColor.fromStorageString(
        map[CustomThemesTable.columnSurfaceColor] as String,
      ),
      backgroundColor: RgbaColor.fromStorageString(
        map[CustomThemesTable.columnBackgroundColor] as String,
      ),
      textColor: RgbaColor.fromStorageString(
        map[CustomThemesTable.columnTextColor] as String,
      ),
    );

    final darkPalette = _readOptionalPalette(
      map,
      primaryKey: CustomThemesTable.columnPrimaryColorDark,
      secondaryKey: CustomThemesTable.columnSecondaryColorDark,
      surfaceKey: CustomThemesTable.columnSurfaceColorDark,
      backgroundKey: CustomThemesTable.columnBackgroundColorDark,
      textKey: CustomThemesTable.columnTextColorDark,
    );

    final activePalette =
        isDark ? (darkPalette ?? lightPalette) : lightPalette;

    return CustomThemeModel(
      AppThemeData(
        id: map[CustomThemesTable.columnId] as String,
        name: map[CustomThemesTable.columnName] as String,
        type: ThemeType.fromStorageValue(
          map[CustomThemesTable.columnType] as String,
        ),
        primaryColor: activePalette.primaryColor,
        secondaryColor: activePalette.secondaryColor,
        surfaceColor: activePalette.surfaceColor,
        backgroundColor: activePalette.backgroundColor,
        textColor: activePalette.textColor,
        isDark: isDark,
        fontFamily: map[CustomThemesTable.columnFontFamily] as String,
        headerImagePath:
            map[CustomThemesTable.columnHeaderImagePath] as String?,
        isHeaderImageAsset: false,
        isBuiltIn: false,
        lightPalette: lightPalette,
        darkPalette: darkPalette,
      ),
    );
  }

  static ThemePalette? _readOptionalPalette(
    Map<String, Object?> map, {
    required String primaryKey,
    required String secondaryKey,
    required String surfaceKey,
    required String backgroundKey,
    required String textKey,
  }) {
    final primary = map[primaryKey] as String?;
    final secondary = map[secondaryKey] as String?;
    final surface = map[surfaceKey] as String?;
    final background = map[backgroundKey] as String?;
    final text = map[textKey] as String?;

    // A palette is only considered "saved" once every one of its 5
    // columns has a value — a partially-populated row shouldn't happen
    // in practice, but treating it as "no dark palette yet" rather
    // than crashing keeps this defensive.
    if (primary == null ||
        secondary == null ||
        surface == null ||
        background == null ||
        text == null) {
      return null;
    }

    return ThemePalette(
      primaryColor: RgbaColor.fromStorageString(primary),
      secondaryColor: RgbaColor.fromStorageString(secondary),
      surfaceColor: RgbaColor.fromStorageString(surface),
      backgroundColor: RgbaColor.fromStorageString(background),
      textColor: RgbaColor.fromStorageString(text),
    );
  }

  /// [createdAt] is supplied by the caller (the local data source),
  /// which is the layer that owns "now" for a given write — this model
  /// doesn't call `DateTime.now()` itself, since on an UPDATE (editing
  /// an existing custom theme) the data source may prefer to preserve
  /// the row's original creation timestamp rather than overwrite it.
  /// See `ThemeLocalDataSourceImpl.saveCustomTheme`.
  Map<String, Object?> toMap({required String createdAt}) {
    final light = theme.lightPalette ?? theme.activePalette;
    final dark = theme.darkPalette;

    return {
      CustomThemesTable.columnId: theme.id,
      CustomThemesTable.columnName: theme.name,
      CustomThemesTable.columnType: theme.type.name,
      CustomThemesTable.columnPrimaryColor:
          light.primaryColor.toStorageString(),
      CustomThemesTable.columnSecondaryColor:
          light.secondaryColor.toStorageString(),
      CustomThemesTable.columnSurfaceColor:
          light.surfaceColor.toStorageString(),
      CustomThemesTable.columnBackgroundColor:
          light.backgroundColor.toStorageString(),
      CustomThemesTable.columnTextColor: light.textColor.toStorageString(),
      CustomThemesTable.columnPrimaryColorDark:
          dark?.primaryColor.toStorageString(),
      CustomThemesTable.columnSecondaryColorDark:
          dark?.secondaryColor.toStorageString(),
      CustomThemesTable.columnSurfaceColorDark:
          dark?.surfaceColor.toStorageString(),
      CustomThemesTable.columnBackgroundColorDark:
          dark?.backgroundColor.toStorageString(),
      CustomThemesTable.columnTextColorDark: dark?.textColor.toStorageString(),
      CustomThemesTable.columnIsDark: theme.isDark ? 1 : 0,
      CustomThemesTable.columnFontFamily: theme.fontFamily,
      CustomThemesTable.columnHeaderImagePath: theme.headerImagePath,
      CustomThemesTable.columnCreatedAt: createdAt,
    };
  }
}