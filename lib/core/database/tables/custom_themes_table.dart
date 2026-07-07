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
class CustomThemesTable {
  CustomThemesTable._();

  static const String tableName = 'custom_themes';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnType = 'type';
  static const String columnPrimaryColor = 'primary_color';
  static const String columnBackgroundColor = 'background_color';
  static const String columnAccentColor = 'accent_color';
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
      $columnBackgroundColor TEXT NOT NULL,
      $columnAccentColor TEXT NOT NULL,
      $columnFontFamily TEXT NOT NULL DEFAULT '$defaultFontFamily',
      $columnHeaderImagePath TEXT,
      $columnCreatedAt TEXT NOT NULL
    );
  ''';

  /// Migration for installs already on the previous `custom_themes`
  /// schema (hex-color columns, no `type` column): drop and recreate.
  /// Custom themes are user-created convenience data, not
  /// irreplaceable diary content, so a clean recreate on this
  /// particular upgrade path is an acceptable trade-off versus writing
  /// a hex->RGBA data migration for a column layout that's changing
  /// anyway.
  static const String dropTableSql = 'DROP TABLE IF EXISTS $tableName;';
}
