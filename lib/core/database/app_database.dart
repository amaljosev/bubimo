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
  // RESET TO 1 — pre-launch schema collapse.
  //
  // Versions 2 through 9 existed only during development (emulator
  // testing, no real installs to preserve), each incrementally patching
  // the schema as features were built — extra overlay columns, 3
  // separate `custom_themes` rebuilds, profile personalization columns,
  // a nullable-column fix-up, etc. None of that migration history has
  // any install to apply to, so it's collapsed here: [_onCreate] now
  // builds the FINAL schema directly (already reflected in each
  // table's `createTableSql` — see DiaryEntriesTable,
  // CustomThemesTable, UserProfileTable, AppSettingsTable), and this is
  // version 1 again.
  //
  // From this point forward, version 1 is the real, shipped baseline.
  // The NEXT schema change after publishing should bump this to 2 and
  // add a real, deliberate migration step in [_onUpgrade] — do not
  // repeat the drop+recreate pattern once real user data exists,
  // since that discards diary entries/themes/profile data instead of
  // preserving them.
  static const int _databaseVersion = 1;
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

  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No-op: version 1 is the current baseline, nothing precedes it.
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}