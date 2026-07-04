// lib/features/theme/domain/repositories/theme_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';

/// Contract for all theme data access, implemented by
/// `ThemeRepositoryImpl` in the data layer.
///
/// [getAllThemes] merges the static default presets with any
/// user-created custom themes from the `custom_themes` table — callers
/// never need to know which source a theme came from.
abstract class ThemeRepository {
  /// Returns every available theme: built-in defaults plus custom ones.
  Future<Either<Failure, List<AppThemeData>>> getAllThemes();

  /// Returns the currently selected theme (from `app_settings.theme_id`),
  /// falling back to the first default preset if none has been selected
  /// yet.
  Future<Either<Failure, AppThemeData>> getSelectedTheme();

  /// Persists [themeId] as the selected theme in `app_settings`.
  Future<Either<Failure, void>> selectTheme(String themeId);

  /// Creates or updates a custom theme.
  Future<Either<Failure, void>> saveCustomTheme(AppThemeData theme);

  /// Deletes a custom theme by id. Deleting the currently selected theme
  /// should fall back the selection to the first default preset — the
  /// repository implementation is responsible for that fallback.
  Future<Either<Failure, void>> deleteCustomTheme(String themeId);
}