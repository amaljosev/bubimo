// lib/features/theme/domain/repositories/theme_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';

/// Abstract contract for theme persistence and retrieval.
/// Implemented in the data layer; domain and presentation only depend on
/// this.
abstract class ThemeRepository {
  /// Returns all themes available for selection: the bundled default
  /// themes plus any user-created custom themes from the `custom_themes`
  /// table, merged into one list.
  Future<Either<Failure, List<AppThemeData>>> getAllThemes();

  /// Returns the currently active theme — whichever `id` is stored as
  /// "selected" in `app_settings`, resolved back to its full
  /// [AppThemeData] (looking it up among defaults + custom themes). Falls
  /// back to the first default theme if no selection has ever been made,
  /// or if the previously-selected custom theme was since deleted.
  Future<Either<Failure, AppThemeData>> getSelectedTheme();

  /// Persists [id] as the selected theme in `app_settings`. Does not
  /// return the resolved [AppThemeData] — callers that need the full
  /// entity should follow up with [getSelectedTheme] or already have it
  /// on hand (e.g. from the list that was just tapped).
  Future<Either<Failure, Unit>> selectTheme(String id);

  /// Creates or updates a custom theme. If [theme.id] matches an existing
  /// custom theme, it's updated in place; otherwise a new row is
  /// inserted. Returns the saved [AppThemeData] (data layer may assign an
  /// id if one wasn't provided, mirroring [DiaryRepository.createEntry]'s
  /// pattern).
  Future<Either<Failure, AppThemeData>> saveCustomTheme(AppThemeData theme);

  /// Deletes the custom theme identified by [id]. Deleting the currently
  /// selected theme is expected to be handled by the caller (e.g.
  /// falling back to a default) — this method only removes the row.
  Future<Either<Failure, Unit>> deleteCustomTheme(String id);
}