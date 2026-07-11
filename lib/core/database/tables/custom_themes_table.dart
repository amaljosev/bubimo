// lib/core/database/tables/custom_themes_table.dart

/// Schema definition for the `custom_themes` table.
///
/// Built-in/preset themes are NOT stored here — they're defined as
/// static data in `core/theme/built_in_themes.dart`. Only user-created
/// custom themes (max 3, enforced in the domain layer by
/// `SaveCustomTheme`) live in this table.
///
/// Color columns store the full `'r,g,b,o'` RGBA string produced by
/// `RgbaColor.toStorageString()` (see
/// `features/theme/domain/entities/rgba_color.dart`) rather than a hex
/// string, since the app's color picker is RGBO-based and this avoids a
/// lossy hex round-trip for the opacity channel.
///
/// Version 8 replaced the single `accent_color` column with 3 new
/// distinct role-based color columns ([columnSecondaryColor],
/// [columnSurfaceColor], [columnTextColor]) plus an explicit
/// [columnIsDark] flag — see `AppDatabase._onUpgrade` oldVersion < 8.
///
/// Version 9 adds a SECOND, independent set of 5 color columns
/// (`*_dark` suffix: [columnPrimaryColorDark] etc.) so a single custom
/// theme can remember its own Light Mode colors AND its own Dark Mode
/// colors at once, instead of overwriting one flat set every time the
/// Dark Mode toggle is flipped on the Create/Edit Custom Theme screen.
/// The original (non-suffixed) columns keep storing the LIGHT Mode
/// palette; the new `*_dark` columns store the DARK Mode palette.
/// [columnIsDark] continues to record which mode is currently active/
/// was last edited. The `*_dark` columns are nullable — a theme that
/// has never been edited in Dark Mode simply has no dark palette yet,
/// and the form falls back to the Nightfall built-in's defaults for
/// that case (see `CustomThemeFormBloc._defaultPaletteFor`).
class CustomThemesTable {
  CustomThemesTable._();

  static const String tableName = 'custom_themes';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnType = 'type';

  // Light Mode palette (also the legacy/original columns).
  static const String columnPrimaryColor = 'primary_color';
  static const String columnSecondaryColor = 'secondary_color';
  static const String columnSurfaceColor = 'surface_color';
  static const String columnBackgroundColor = 'background_color';
  static const String columnTextColor = 'text_color';

  // Dark Mode palette — added in version 9.
  static const String columnPrimaryColorDark = 'primary_color_dark';
  static const String columnSecondaryColorDark = 'secondary_color_dark';
  static const String columnSurfaceColorDark = 'surface_color_dark';
  static const String columnBackgroundColorDark = 'background_color_dark';
  static const String columnTextColorDark = 'text_color_dark';

  static const String columnIsDark = 'is_dark';
  static const String columnFontFamily = 'font_family';
  static const String columnHeaderImagePath = 'header_image_path';
  static const String columnCreatedAt = 'created_at';

  static const String defaultFontFamily = 'Poppins';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnType TEXT NOT NULL DEFAULT 'custom',
      $columnPrimaryColor TEXT NOT NULL,
      $columnSecondaryColor TEXT NOT NULL,
      $columnSurfaceColor TEXT NOT NULL,
      $columnBackgroundColor TEXT NOT NULL,
      $columnTextColor TEXT NOT NULL,
      $columnPrimaryColorDark TEXT,
      $columnSecondaryColorDark TEXT,
      $columnSurfaceColorDark TEXT,
      $columnBackgroundColorDark TEXT,
      $columnTextColorDark TEXT,
      $columnIsDark INTEGER NOT NULL DEFAULT 0,
      $columnFontFamily TEXT NOT NULL DEFAULT '$defaultFontFamily',
      $columnHeaderImagePath TEXT,
      $columnCreatedAt TEXT NOT NULL
    );
  ''';

  /// Migration for installs already on a previous `custom_themes`
  /// schema: drop and recreate, following the same precedent as the
  /// v2->v3, v5->v6, and v7->v8 migrations on this same table. Custom
  /// themes are user-created convenience data, not irreplaceable diary
  /// content, so a clean recreate is an acceptable trade-off versus
  /// writing a column-by-column data migration for a layout that's
  /// changing anyway. Existing custom themes will need to be recreated
  /// by the user after this upgrade.
  static const String dropTableSql = 'DROP TABLE IF EXISTS $tableName;';
}