// lib/features/theme/domain/usecases/save_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Creates or updates a custom theme. The Custom Theme Screen is
/// responsible for validating input (e.g. non-empty name) before
/// calling this — this use case does not re-validate.
///
/// Usage: `await saveCustomTheme(themeData)`.
class SaveCustomTheme {
  final ThemeRepository repository;

  const SaveCustomTheme(this.repository);

  Future<Either<Failure, void>> call(AppThemeData theme) {
    return repository.saveCustomTheme(theme);
  }
}