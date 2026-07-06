// lib/core/db/tables/user_profile_table.dart

/// Schema definition for the `user_profile` table.
///
/// This is a single-row ("singleton") table — there is only ever one user
/// profile in this app, keyed by a fixed id rather than a generated one.
///
/// v3 -> v4 added four optional personalization columns (see the combined
/// Profile & Analytics screen milestone): [columnDiaryName],
/// [columnAvatarPath], [columnHeaderImagePath]. [columnName] itself is
/// reused as the "username" field rather than adding a parallel column —
/// it was unused free text before this milestone.
class UserProfileTable {
  UserProfileTable._();

  static const String tableName = 'user_profile';

  /// Fixed row id — always use this value when reading/writing the
  /// single user profile row instead of generating a new id.
  static const String singletonId = 'singleton';

  static const String columnId = 'id';

  /// Doubles as the "username" shown on the Profile & Analytics screen.
  static const String columnName = 'name';
  static const String columnOnboardingCompleted = 'onboarding_completed';

  /// Optional custom name for the diary itself (e.g. "Amal's Journal"),
  /// shown in place of a generic "My Diary" label when set.
  static const String columnDiaryName = 'diary_name';

  /// Local filesystem path to the user's chosen profile photo. Null
  /// until the user picks one — the UI falls back to an initials/icon
  /// avatar in that case.
  static const String columnAvatarPath = 'avatar_path';

  /// Local filesystem path to the user's chosen profile header/cover
  /// image. Null until set — the UI falls back to a themed gradient.
  static const String columnHeaderImagePath = 'header_image_path';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT,
      $columnOnboardingCompleted INTEGER NOT NULL DEFAULT 0,
      $columnDiaryName TEXT,
      $columnAvatarPath TEXT,
      $columnHeaderImagePath TEXT
    );
  ''';

  /// Migration statements for existing installs (schema v3 -> v4): adds
  /// the three new nullable personalization columns. No DEFAULT needed
  /// since all three are nullable — existing rows simply get NULL.
  static const List<String> addProfilePersonalizationColumnsSql = [
    'ALTER TABLE $tableName ADD COLUMN $columnDiaryName TEXT;',
    'ALTER TABLE $tableName ADD COLUMN $columnAvatarPath TEXT;',
    'ALTER TABLE $tableName ADD COLUMN $columnHeaderImagePath TEXT;',
  ];
}