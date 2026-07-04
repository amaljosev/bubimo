// lib/features/theme/domain/usecases/delete_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

/// Deletes a custom theme by id. If the deleted theme was the currently
/// selected one, the repository implementation falls back the selection
/// to the first default preset.
///
/// Usage: `await deleteCustomTheme(themeId)`.
class DeleteCustomTheme {
  final ThemeRepository repository;

  const DeleteCustomTheme(this.repository);

  Future<Either<Failure, void>> call(String themeId) {
    return repository.deleteCustomTheme(themeId);
  }
}