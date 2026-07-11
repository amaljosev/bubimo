// lib/core/database/app_database.dart

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'tables/app_settings_table.dart';
import 'tables/custom_themes_table.dart';
import 'tables/diary_entries_table.dart';
import 'tables/user_profile_table.dart';

/// Central access point for the app's single SQLite database.
///
/// Registered as a lazy singleton in GetIt. Call `await AppDatabase().database`
/// once during app startup (before runApp) so the DB is ready before any
/// feature tries to use it.
///
/// Note: `package:path` is a transitive dependency of `sqflite` and is safe
/// to import directly, but add it explicitly to pubspec.yaml if you want to
/// pin its version.
class AppDatabase {
  // Bumped 6 -> 7: fixes `bg_overlay_color` to be nullable. It was
  // originally added as `NOT NULL DEFAULT 'white'` (version 2), but
  // NULL is now a meaningful value ("Auto" — tint follows the app
  // theme; see OverlayTintUtils/DiaryEntriesTable). SQLite can't
  // ALTER COLUMN to relax NOT NULL, so this rebuilds the table (see
  // DiaryEntriesTable.migrateOverlayColorToNullableSql), translating
  // existing 'white' rows to NULL since that value was never a real
  // per-entry choice under the old code.
  static const int _databaseVersion = 7;
  static const String _databaseName = 'diary_app.db';

  Database? _database;

  /// Returns the open database, opening it on first access.
  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final opened = await _openDatabase();
    _database = opened;
    return opened;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DiaryEntriesTable.createTableSql);
    await db.execute(UserProfileTable.createTableSql);
    await db.execute(AppSettingsTable.createTableSql);
    await db.execute(CustomThemesTable.createTableSql);
  }

  /// Migration hook for future schema versions. Since the current schema
  /// is designed to cover every planned field upfront (see project
  /// blueprint), this should rarely need real migration logic — but the
  /// hook is here so version bumps don't require restructuring later.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    for (final sql in DiaryEntriesTable.addOverlayOpacityColumnsSql) {
      await db.execute(sql);
    }
  }

  if (oldVersion < 3) {
    await db.execute(CustomThemesTable.dropTableSql);
    await db.execute(CustomThemesTable.createTableSql);
  }

  if (oldVersion < 4) {
    for (final sql in UserProfileTable.addProfilePersonalizationColumnsSql) {
      await db.execute(sql);
    }
  }

  if (oldVersion < 5) {
    await db.execute(AppSettingsTable.createTableSql);
  }

  if (oldVersion < 6) {
    await db.execute(CustomThemesTable.dropTableSql);
    await db.execute(CustomThemesTable.createTableSql);
  }

  if (oldVersion < 7) {
    for (final sql in DiaryEntriesTable.migrateOverlayColorToNullableSql) {
      await db.execute(sql);
    }
  }
}

  /// Closes the database. Rarely needed in app code (GetIt keeps this
  /// alive for the app's lifetime), but useful for tests/debug tooling.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}