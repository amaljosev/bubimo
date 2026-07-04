// lib/core/db/tables/app_settings_table.dart

/// Schema definition for the `app_settings` table.
///
/// Like `user_profile`, this is a single-row ("singleton") table holding
/// all app-wide settings: reminders, theme selection, lock configuration.
class AppSettingsTable {
  AppSettingsTable._();

  static const String tableName = 'app_settings';

  /// Fixed row id — always use this value when reading/writing the
  /// single app settings row instead of generating a new id.
  static const String singletonId = 'singleton';

  static const String columnId = 'id';
  static const String columnReminderTime = 'reminder_time';
  static const String columnReminderEnabled = 'reminder_enabled';
  static const String columnThemeId = 'theme_id';
  static const String columnFontPreference = 'font_preference';

  /// Stored as one of: 'none', 'biometric', 'pin'.
  static const String columnLockType = 'lock_type';
  static const String columnLockPinHash = 'lock_pin_hash';
  static const String columnLockSecurityQuestion = 'lock_security_question';
  static const String columnLockSecurityAnswerHash =
      'lock_security_answer_hash';
  static const String columnBiometricEnabled = 'biometric_enabled';
  static const String columnLockTimeoutMinutes = 'lock_timeout_minutes';

  static const String defaultLockType = 'none';
  static const int defaultLockTimeoutMinutes = 1;

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnReminderTime TEXT,
      $columnReminderEnabled INTEGER NOT NULL DEFAULT 0,
      $columnThemeId TEXT,
      $columnFontPreference TEXT,
      $columnLockType TEXT NOT NULL DEFAULT '$defaultLockType',
      $columnLockPinHash TEXT,
      $columnLockSecurityQuestion TEXT,
      $columnLockSecurityAnswerHash TEXT,
      $columnBiometricEnabled INTEGER NOT NULL DEFAULT 0,
      $columnLockTimeoutMinutes INTEGER DEFAULT $defaultLockTimeoutMinutes
    );
  ''';
}