// lib/features/theme/domain/repositories/theme_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';

/// Contract for reading/writing themes. Implemented by
/// `ThemeRepositoryImpl`, backed by `ThemeLocalDataSource`.
///
/// Built-in themes are static in-memory data (see `built_in_themes.dart`)
/// merged with the persisted custom themes from SQLite — callers of
/// this repository don't need to know which storage a given theme came
/// from.
abstract class ThemeRepository {
  /// All themes available to the user: the 4 built-ins followed by any
  /// saved custom themes (0-3).
  Future<Either<Failure, List<AppThemeData>>> getAllThemes();

  /// The currently active/applied theme. Falls back to the default
  /// built-in theme if no selection has been persisted yet.
  Future<Either<Failure, AppThemeData>> getSelectedTheme();

  /// Persists [themeId] as the active theme.
  Future<Either<Failure, void>> selectTheme(String themeId);

  /// Persists the default built-in theme as the active theme.
  Future<Either<Failure, void>> resetToDefaultTheme();

  /// Creates a new custom theme. Fails with [ValidationFailure] if the
  /// user already has 3 custom themes, or updates the existing row when
  /// [theme.id] matches an existing custom theme (edit path).
  Future<Either<Failure, void>> saveCustomTheme(AppThemeData theme);

  /// Deletes a custom theme by id. If it was the active theme, callers
  /// should follow up with [resetToDefaultTheme].
  Future<Either<Failure, void>> deleteCustomTheme(String themeId);
}
