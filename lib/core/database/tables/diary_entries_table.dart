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

  /// Opacity (0.0–1.0) of the tint applied over the background image so
  /// text/embeds stay legible. Per-entry since different photos need
  /// different amounts of dimming/lightening. Defaults to 0.85 to match
  /// the fixed value every entry used before this column existed.
  static const String columnBgOverlayOpacity = 'bg_overlay_opacity';

  /// Which tint color is blended over the background image: `'white'`
  /// (lightens a busy/dark photo) or `'black'` (darkens a bright one).
  /// `NULL` means "Auto" — the tint automatically follows the app's
  /// active theme (dark theme → black tint so white entry text stays
  /// legible; light theme → white tint so dark entry text stays
  /// legible) until the user explicitly overrides it for that entry.
  /// See `OverlayTintUtils`. Auto is the default for every new entry —
  /// this column has no `NOT NULL`/default constraint (a prior schema
  /// version incorrectly forced `NOT NULL DEFAULT 'white'`; see
  /// [migrateOverlayColorToNullableSql] for the fix-up on existing DBs).
  static const String columnBgOverlayColor = 'bg_overlay_color';
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
      $columnBgOverlayOpacity REAL NOT NULL DEFAULT 0.85,
      $columnBgOverlayColor TEXT,
      $columnWordCount INTEGER NOT NULL DEFAULT 0,
      $columnFontFamily TEXT,
      $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
      $columnIsDeleted INTEGER NOT NULL DEFAULT 0,
      $columnDeletedAt TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    );
  ''';

  /// Migration SQL for existing databases created before
  /// [columnBgOverlayOpacity]/[columnBgOverlayColor] existed (schema
  /// version 1). SQLite's `ALTER TABLE ... ADD COLUMN` requires a
  /// constant default, so these match the CREATE TABLE defaults above —
  /// existing rows get the same fixed values every entry used to render
  /// with, so this migration doesn't change how any existing entry
  /// looks.
  static const List<String> addOverlayOpacityColumnsSql = [
    'ALTER TABLE $tableName '
        'ADD COLUMN $columnBgOverlayOpacity REAL NOT NULL DEFAULT 0.85;',
    'ALTER TABLE $tableName '
        "ADD COLUMN $columnBgOverlayColor TEXT NOT NULL DEFAULT 'white';",
  ];

  /// Fixes up the mistake in [addOverlayOpacityColumnsSql]: that
  /// migration declared [columnBgOverlayColor] `NOT NULL DEFAULT
  /// 'white'`, so every entry ever saved has an explicit `'white'`
  /// rather than the "Auto" (`NULL`, tint follows app theme) that's now
  /// the intended default — see `OverlayTintUtils`.
  ///
  /// SQLite has no `ALTER TABLE ... ALTER COLUMN`, so relaxing `NOT
  /// NULL` requires the standard rebuild pattern: create a new table
  /// with the corrected schema, copy every row across (translating
  /// `'white'` to `NULL` in the same statement, since a pre-existing
  /// `'white'` was never a deliberate per-entry choice — the picker UI
  /// that lets a user choose Light/Dark/Auto didn't exist until this
  /// column existed), drop the old table, rename the new one into place.
  ///
  /// Deliberately does NOT touch `'black'` rows — those are equally
  /// impossible to have been a real choice under the old code, but
  /// leaving them as an explicit `'black'` is harmless (an explicit
  /// `'black'` and an Auto-resolved-to-black render identically in
  /// dark-on-light contexts, and differs from Auto only once a user
  /// later switches app theme — at which point re-checking is a
  /// one-tap fix via the settings sheet's now-explicit Auto/Light/Dark
  /// chips, whereas silently reinterpreting `'black'` as anything could
  /// mask a deliberate choice already made under this same migration
  /// path for another row).
  static const List<String> migrateOverlayColorToNullableSql = [
    '''
    CREATE TABLE ${tableName}_new (
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
      $columnBgOverlayOpacity REAL NOT NULL DEFAULT 0.85,
      $columnBgOverlayColor TEXT,
      $columnWordCount INTEGER NOT NULL DEFAULT 0,
      $columnFontFamily TEXT,
      $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
      $columnIsDeleted INTEGER NOT NULL DEFAULT 0,
      $columnDeletedAt TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    );
    ''',
    '''
    INSERT INTO ${tableName}_new
    SELECT
      $columnId, $columnTitle, $columnDate, $columnContent, $columnPreview,
      $columnMood, $columnImagePath, $columnBgColor, $columnBgImagePath,
      $columnBgGalleryImagePath, $columnBgLocalPath, $columnStickers,
      $columnImages, $columnTags, $columnOverlayImages,
      $columnBgOverlayOpacity,
      CASE WHEN $columnBgOverlayColor = 'white' THEN NULL
           ELSE $columnBgOverlayColor END,
      $columnWordCount, $columnFontFamily, $columnIsFavorite,
      $columnIsDeleted, $columnDeletedAt, $columnCreatedAt, $columnUpdatedAt
    FROM $tableName;
    ''',
    'DROP TABLE $tableName;',
    'ALTER TABLE ${tableName}_new RENAME TO $tableName;',
  ];
}