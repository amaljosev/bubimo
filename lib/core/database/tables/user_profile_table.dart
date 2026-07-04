// lib/core/db/tables/user_profile_table.dart

/// Schema definition for the `user_profile` table.
///
/// This is a single-row ("singleton") table — there is only ever one user
/// profile in this app, keyed by a fixed id rather than a generated one.
class UserProfileTable {
  UserProfileTable._();

  static const String tableName = 'user_profile';

  /// Fixed row id — always use this value when reading/writing the
  /// single user profile row instead of generating a new id.
  static const String singletonId = 'singleton';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnOnboardingCompleted = 'onboarding_completed';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT,
      $columnOnboardingCompleted INTEGER NOT NULL DEFAULT 0
    );
  ''';
}