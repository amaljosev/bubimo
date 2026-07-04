// lib/core/db/tables/custom_themes_table.dart
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
  static const String columnHeaderImagePath = 'header_image_path';
  static const String columnCreatedAt = 'created_at';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnPrimaryColor TEXT NOT NULL,
      $columnBackgroundColor TEXT NOT NULL,
      $columnAccentColor TEXT NOT NULL,
      $columnHeaderImagePath TEXT,
      $columnCreatedAt TEXT NOT NULL
    );
  ''';
}