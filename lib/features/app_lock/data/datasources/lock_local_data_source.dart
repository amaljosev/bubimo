// lib/features/app_lock/data/datasources/lock_local_data_source.dart

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../domain/entities/lock_type.dart';
import '../models/lock_settings_model.dart';

/// Reads/writes this feature's columns on the single `app_settings`
/// row via the app's existing AppDatabase — the same sqflite instance
/// and the same singleton row every other feature (reminders, theme,
/// font) already shares. No new table, no migration needed: every
/// lock_* / biometric_enabled column already exists in
/// AppSettingsTable.createTableSql and app_database.dart's _onCreate
/// already seeds the row.
abstract class LockLocalDataSource {
  Future<LockSettingsModel> getSettings();

  /// Updates ONLY the app-lock columns on the existing singleton row.
  /// Never inserts a new row and never touches reminder/theme/font
  /// columns on that row.
  Future<void> updateSettings(LockSettingsModel model);
}

class LockLocalDataSourceImpl implements LockLocalDataSource {
  const LockLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<LockSettingsModel> getSettings() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      AppSettingsTable.tableName,
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
      limit: 1,
    );

    // The singleton row is seeded by app_database.dart's _onCreate, so
    // this should always find exactly one row. Falling back to an
    // all-defaults model rather than throwing keeps this datasource
    // resilient if that invariant is ever violated (e.g. a future
    // migration bug), instead of crashing the whole lock-config load.
    if (rows.isEmpty) {
      return const LockSettingsModel(lockType: LockType.none);
    }
    return LockSettingsModel.fromMap(rows.first);
  }

  @override
  Future<void> updateSettings(LockSettingsModel model) async {
    final db = await _appDatabase.database;
    await db.update(
      AppSettingsTable.tableName,
      model.toColumnMap(),
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
    );
  }
}