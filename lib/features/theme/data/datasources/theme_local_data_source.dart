// lib/features/theme/data/datasources/theme_local_data_source.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../../../core/database/tables/custom_themes_table.dart';
import '../../../../core/error/exceptions.dart';
import '../models/custom_theme_model.dart';

/// Local SQLite access for the Theme feature: CRUD on the `custom_themes`
/// table, plus reading/writing the active theme id in the singleton
/// `app_settings` row.
///
/// Built-in themes never touch this data source — they're static data
/// merged in by `ThemeRepositoryImpl`.
abstract class ThemeLocalDataSource {
  Future<List<CustomThemeModel>> getCustomThemes();
  Future<void> saveCustomTheme(CustomThemeModel model);
  Future<void> deleteCustomTheme(String themeId);

  /// Returns the persisted active theme id, or `null` if none has been
  /// set yet (fresh install).
  Future<String?> getActiveThemeId();
  Future<void> setActiveThemeId(String themeId);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final AppDatabase _appDatabase;

  ThemeLocalDataSourceImpl(this._appDatabase);

  @override
  Future<List<CustomThemeModel>> getCustomThemes() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        CustomThemesTable.tableName,
        orderBy: '${CustomThemesTable.columnCreatedAt} ASC',
      );
      return rows.map(CustomThemeModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException(
        message: 'Failed to load custom themes: $e',
      );
    }
  }

  @override
  Future<void> saveCustomTheme(CustomThemeModel model) async {
    try {
      final db = await _appDatabase.database;
      await db.insert(
        CustomThemesTable.tableName,
        model.toMap(createdAt: DateTime.now().toIso8601String()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to save custom theme: $e');
    }
  }

  @override
  Future<void> deleteCustomTheme(String themeId) async {
    try {
      final db = await _appDatabase.database;
      await db.delete(
        CustomThemesTable.tableName,
        where: '${CustomThemesTable.columnId} = ?',
        whereArgs: [themeId],
      );
    } catch (e) {
      throw AppDatabaseException(
        message: 'Failed to delete custom theme: $e',
      );
    }
  }

  @override
  Future<String?> getActiveThemeId() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        AppSettingsTable.tableName,
        columns: [AppSettingsTable.columnThemeId],
        where: '${AppSettingsTable.columnId} = ?',
        whereArgs: [AppSettingsTable.singletonId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first[AppSettingsTable.columnThemeId] as String?;
    } catch (e) {
      throw AppDatabaseException(
        message: 'Failed to read active theme id: $e',
      );
    }
  }

  @override
  Future<void> setActiveThemeId(String themeId) async {
    try {
      final db = await _appDatabase.database;
      await db.insert(
        AppSettingsTable.tableName,
        {
          AppSettingsTable.columnId: AppSettingsTable.singletonId,
          AppSettingsTable.columnThemeId: themeId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      // The singleton row may already exist (created by another
      // feature, e.g. reminders) — `insert` with `ignore` above is a
      // no-op in that case, so explicitly update the theme_id column
      // too.
      await db.update(
        AppSettingsTable.tableName,
        {AppSettingsTable.columnThemeId: themeId},
        where: '${AppSettingsTable.columnId} = ?',
        whereArgs: [AppSettingsTable.singletonId],
      );
    } catch (e) {
      throw AppDatabaseException(
        message: 'Failed to persist active theme id: $e',
      );
    }
  }
}
