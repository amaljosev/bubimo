// lib/core/database/tables/custom_themes_table.dart

/// Schema definition for the `custom_themes` table.
///
/// Default/preset themes are NOT stored here — they're defined as static
/// data in the theme feature. Only user-created custom themes live in
/// this table.
class CustomThemesTable {
  CustomThemesTable._();

  static const String tableName = 'custom_themes';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnPrimaryColor = 'primary_color';
  static const String columnBackgroundColor = 'background_color';
  static const String columnAccentColor = 'accent_color';
  static const String columnFontFamily = 'font_family';
  static const String columnHeaderImagePath = 'header_image_path';
  static const String columnCreatedAt = 'created_at';

  /// Fallback font family backfilled onto any custom themes that were
  /// created before this column existed. Matches the fallback used in
  /// [AppDatabase]'s v2→v3 migration — keep these two in sync.
  static const String defaultFontFamily = 'Poppins';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnPrimaryColor TEXT NOT NULL,
      $columnBackgroundColor TEXT NOT NULL,
      $columnAccentColor TEXT NOT NULL,
      $columnFontFamily TEXT NOT NULL DEFAULT '$defaultFontFamily',
      $columnHeaderImagePath TEXT,
      $columnCreatedAt TEXT NOT NULL
    );
  ''';

  /// Migration statement for existing installs (schema v2 → v3): adds
  /// [columnFontFamily] to the already-created table. SQLite requires a
  /// `DEFAULT` on a `NOT NULL` column added via `ALTER TABLE` so existing
  /// rows get a valid value immediately.
  static const String addFontFamilyColumnSql = '''
    ALTER TABLE $tableName
    ADD COLUMN $columnFontFamily TEXT NOT NULL DEFAULT '$defaultFontFamily';
  ''';
}