// lib/features/theme/domain/usecases/save_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Creates or updates a custom theme.
///
/// Deliberately does NOT validate `theme.name` here — per the quality
/// requirement that custom theme inputs be validated before saving, that
/// check belongs in `CustomThemeFormBloc` (presentation layer), which has
/// the context to show a field-level validation error to the user. This
/// use case assumes it's only ever called with an already-validated
/// [AppThemeData], consistent with how `CreateDiaryEntry`/
/// `UpdateDiaryEntry` don't re-validate `title`/`content` either — the
/// validating layer and the persisting layer are kept separate.
class SaveCustomTheme {
  final ThemeRepository repository;

  const SaveCustomTheme(this.repository);

  Future<Either<Failure, AppThemeData>> call(AppThemeData theme) {
    return repository.saveCustomTheme(theme);
  }
}