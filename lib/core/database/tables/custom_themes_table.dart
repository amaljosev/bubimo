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
/// Stores TWO independent color palettes per theme: [columnPrimaryColor]
/// / [columnSecondaryColor] / [columnSurfaceColor] / [columnBackgroundColor]
/// / [columnTextColor] hold the Light Mode palette, and the `*_dark`
/// -suffixed columns ([columnPrimaryColorDark] etc.) hold the Dark Mode
/// palette, so a single custom theme remembers its own colors for both
/// modes instead of one flat set that gets overwritten every time the
/// Dark Mode toggle is flipped on the Create/Edit Custom Theme screen.
/// [columnIsDark] records which mode is currently active/was last
/// edited. The `*_dark` columns are nullable — a theme that has never
/// been edited in Dark Mode simply has no dark palette yet, and the
/// form falls back to the Nightfall built-in's defaults for that case
/// (see `CustomThemeFormBloc._defaultPaletteFor`).
///
/// Pre-launch schema collapse: this table went through several
/// drop+recreate migrations during development as its column layout
/// evolved — see `AppDatabase`'s version-history note. None of that
/// migration SQL applies anymore now that the database is resetting to
/// version 1, so [dropTableSql] has been removed; [createTableSql]
/// below already reflects the final shape directly.
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

  // Dark Mode palette.
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
}