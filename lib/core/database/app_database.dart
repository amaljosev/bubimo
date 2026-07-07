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
  // Bumped 5 -> 6: rebuilds `custom_themes` for the new Theme feature.
  // Colors are now stored as full RGBA strings (`'r,g,b,o'`, see
  // RgbaColor.toStorageString()) instead of hex, and a new `type`
  // column distinguishes theme kinds. Existing custom theme rows use
  // the old hex-color schema, which isn't compatible with the new RGBA
  // format, so this migration drops and recreates the table (see
  // CustomThemesTable doc comment for the rationale).
  static const int _databaseVersion = 6;
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
