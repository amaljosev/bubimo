// lib/features/theme/data/models/custom_theme_model.dart

import '../../../../core/database/tables/custom_themes_table.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/entities/rgba_color.dart';
import '../../domain/entities/theme_type.dart';

/// Data-layer mapper between [AppThemeData] and a `custom_themes` SQLite
/// row (`Map<String, Object?>`).
///
/// Kept separate from [AppThemeData] itself (rather than putting
/// `toMap`/`fromMap` on the entity) so the domain entity stays free of
/// any persistence-format knowledge — a `CustomThemeModel` is purely a
/// data-layer concern, following the same pattern as the project's other
/// features (e.g. diary_entry's local data source models).
class CustomThemeModel {
  final AppThemeData theme;

  const CustomThemeModel(this.theme);

  factory CustomThemeModel.fromMap(Map<String, Object?> map) {
    return CustomThemeModel(
      AppThemeData(
        id: map[CustomThemesTable.columnId] as String,
        name: map[CustomThemesTable.columnName] as String,
        type: ThemeType.fromStorageValue(
          map[CustomThemesTable.columnType] as String? ?? 'custom',
        ),
        primaryColor: RgbaColor.fromStorageString(
          map[CustomThemesTable.columnPrimaryColor] as String,
        ),
        backgroundColor: RgbaColor.fromStorageString(
          map[CustomThemesTable.columnBackgroundColor] as String,
        ),
        accentColor: RgbaColor.fromStorageString(
          map[CustomThemesTable.columnAccentColor] as String,
        ),
        fontFamily: map[CustomThemesTable.columnFontFamily] as String,
        headerImagePath:
            map[CustomThemesTable.columnHeaderImagePath] as String?,
        isHeaderImageAsset: false,
        isBuiltIn: false,
      ),
    );
  }

  Map<String, Object?> toMap({required String createdAt}) {
    return {
      CustomThemesTable.columnId: theme.id,
      CustomThemesTable.columnName: theme.name,
      CustomThemesTable.columnType: theme.type.name,
      CustomThemesTable.columnPrimaryColor:
          theme.primaryColor.toStorageString(),
      CustomThemesTable.columnBackgroundColor:
          theme.backgroundColor.toStorageString(),
      CustomThemesTable.columnAccentColor:
          theme.accentColor.toStorageString(),
      CustomThemesTable.columnFontFamily: theme.fontFamily,
      CustomThemesTable.columnHeaderImagePath: theme.headerImagePath,
      CustomThemesTable.columnCreatedAt: createdAt,
    };
  }
}
