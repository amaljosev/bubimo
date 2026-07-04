// lib/core/db/tables/diary_entries_table.dart
/// Schema definition for the `diary_entries` table.
///
/// This is the FINAL schema covering every field the app will ever need,
/// including fields not yet used by any milestone (e.g. stickers, images,
/// tags, is_deleted). This avoids future ALTER TABLE migrations for every
/// new feature milestone.
class DiaryEntriesTable {
  DiaryEntriesTable._();

  static const String tableName = 'diary_entries';

  // Column names — use these constants everywhere instead of raw strings
  // to avoid typos causing silent query failures.
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDate = 'date';
  static const String columnContent = 'content';
  static const String columnPreview = 'preview';
  static const String columnMood = 'mood';
  static const String columnImagePath = 'image_path';
  static const String columnBgColor = 'bg_color';
  static const String columnBgImagePath = 'bg_image_path';
  static const String columnBgGalleryImagePath = 'bg_gallery_image_path';
  static const String columnBgLocalPath = 'bg_local_path';
  static const String columnStickers = 'stickers';
  static const String columnImages = 'images';
  static const String columnTags = 'tags';

  /// JSON-encoded list of overlay image transform records (id, path, x,
  /// y, scale, rotation) — free-floating photos layered on top of the
  /// Quill editor. Kept separate from [columnImages], which tracks
  /// inline Quill embed paths only.
  static const String columnOverlayImages = 'overlay_images';
  static const String columnWordCount = 'word_count';
  static const String columnFontFamily = 'font_family';
  static const String columnIsFavorite = 'is_favorite';
  static const String columnIsDeleted = 'is_deleted';
  static const String columnDeletedAt = 'deleted_at';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT,
      $columnDate TEXT NOT NULL,
      $columnContent TEXT,
      $columnPreview TEXT,
      $columnMood TEXT,
      $columnImagePath TEXT,
      $columnBgColor TEXT,
      $columnBgImagePath TEXT,
      $columnBgGalleryImagePath TEXT,
      $columnBgLocalPath TEXT,
      $columnStickers TEXT,
      $columnImages TEXT,
      $columnTags TEXT,
      $columnOverlayImages TEXT,
      $columnWordCount INTEGER NOT NULL DEFAULT 0,
      $columnFontFamily TEXT,
      $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
      $columnIsDeleted INTEGER NOT NULL DEFAULT 0,
      $columnDeletedAt TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    );
  ''';
}