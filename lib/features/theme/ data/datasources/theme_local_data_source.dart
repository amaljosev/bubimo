// lib/features/theme/data/datasources/theme_local_data_source.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../../../core/database/tables/custom_themes_table.dart';
import '../../../../core/utils/date_utils.dart';
import '../models/app_theme_model.dart';

/// Raw sqflite access for custom themes (`custom_themes` table) and the
/// currently selected theme (`theme_id` column on the singleton
/// `app_settings` row). No error-wrapping here — exceptions propagate up
/// to [ThemeRepositoryImpl].
abstract class ThemeLocalDataSource {
  Future<List<AppThemeModel>> getCustomThemes();
  Future<void> saveCustomTheme(AppThemeModel theme);
  Future<void> deleteCustomTheme(String id);
  Future<String?> getSelectedThemeId();
  Future<void> setSelectedThemeId(String themeId);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final AppDatabase appDatabase;

  const ThemeLocalDataSourceImpl(this.appDatabase);

  @override
  Future<List<AppThemeModel>> getCustomThemes() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      CustomThemesTable.tableName,
      orderBy: '${CustomThemesTable.columnCreatedAt} DESC',
    );
    return rows.map(AppThemeModel.fromMap).toList();
  }

  @override
  Future<void> saveCustomTheme(AppThemeModel theme) async {
    final db = await appDatabase.database;

    // Preserve the original createdAt on update; use "now" only when
    // this is a brand new custom theme.
    final existingRows = await db.query(
      CustomThemesTable.tableName,
      columns: [CustomThemesTable.columnCreatedAt],
      where: '${CustomThemesTable.columnId} = ?',
      whereArgs: [theme.id],
      limit: 1,
    );

    final createdAt = existingRows.isNotEmpty
        ? existingRows.first[CustomThemesTable.columnCreatedAt] as String
        : AppDateUtils.toStorageString(DateTime.now());

    await db.insert(
      CustomThemesTable.tableName,
      theme.toMap(createdAt: createdAt),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCustomTheme(String id) async {
    final db = await appDatabase.database;
    await db.delete(
      CustomThemesTable.tableName,
      where: '${CustomThemesTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<String?> getSelectedThemeId() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      AppSettingsTable.tableName,
      columns: [AppSettingsTable.columnThemeId],
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[AppSettingsTable.columnThemeId] as String?;
  }

  @override
  Future<void> setSelectedThemeId(String themeId) async {
    final db = await appDatabase.database;

    final rowsAffected = await db.update(
      AppSettingsTable.tableName,
      {AppSettingsTable.columnThemeId: themeId},
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
    );

    // The singleton settings row doesn't exist yet (fresh install) —
    // create it now with the theme selection set.
    if (rowsAffected == 0) {
      await db.insert(
        AppSettingsTable.tableName,
        {
          AppSettingsTable.columnId: AppSettingsTable.singletonId,
          AppSettingsTable.columnThemeId: themeId,
          AppSettingsTable.columnLockType: AppSettingsTable.defaultLockType,
          AppSettingsTable.columnLockTimeoutMinutes:
              AppSettingsTable.defaultLockTimeoutMinutes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}